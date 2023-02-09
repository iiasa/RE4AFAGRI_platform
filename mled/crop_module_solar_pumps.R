
## This R-script:
##      1) calculates irrigation water needs at each cluster given the constaints imposed in the main M-LED file (e.g. smallholder farming only, or maximum distance to cluster threshold)
##      2) calculates environmental flow constraints at each cluster to avoid aquifer groundwater unsustainable extraction

rainfed <- list.files(paste0(input_folder, "watercrop"), full.names = T, pattern = "closure", recursive=T)

field_size <- raster(find_it("field_size_10_40_cropland.img"))
field_size <- mask_raster_to_polygon(field_size, st_as_sfc(st_bbox(clusters)))
gc()

clusters_voronoi <- read_sf(paste0(input_country_specific, "clusters_voronoi.gpkg"))

####

rainfed2 <- mixedsort(rainfed)
rainfed2 <- future_lapply(rainfed2, raster, future.seed=TRUE)
rainfed2 <- stack(rainfed2)
crs(rainfed2) <- as.character(CRS("+init=epsg:4236"))
rainfed2 <- mask_raster_to_polygon(rainfed2, st_as_sfc(st_bbox(clusters_voronoi)))
rainfed2 <- as.list(rainfed2)

field_size <-  mask_raster_to_polygon(field_size, st_as_sfc(st_bbox(clusters_voronoi)))

if(field_size_contraint==T){field_size <- projectRaster(field_size, mask_raster_to_polygon(rainfed2[[1]], st_as_sfc(st_bbox(clusters_voronoi))), method = "bilinear") ; m <- field_size; m[m > 29] <- NA; field_size <- mask(field_size, m); rainfed2 <- future_lapply(rainfed2, function(X){return(mask_raster_to_polygon(X, st_as_sfc(st_bbox(clusters_voronoi))))}, future.seed=TRUE); for (i in 1:length(rainfed2)){crs(rainfed2[[i]]) <- crs(field_size)}; field_size <- projectRaster(field_size,rainfed2[[1]]); rainfed2 <- future_lapply(rainfed2, function(X){mask(X, field_size)}, future.seed=TRUE)}

rainfed2 <- split(rainfed2,  tolower(unlist(qdapRegex::ex_between(rainfed, "watercrop/", "/cl"))))

rainfed <- lapply(rainfed2, stack)

names(rainfed) <- c("barl", "cass", "coco", "cott", "grou", "maiz", "pmil", "smil", "oilp", "pota", "rape", "rice", "sorg", "soyb", "sugb", "sugc", "sunf", "whea", "yams")

#

clusters_voronoi$area <- as.numeric(st_area(clusters_voronoi)) * 0.0001 # in hectares

# extract total bluewater demand in each cluster

files = list.files(path = paste0(input_folder, "spam_folder/spam2017v2r1_ssa_harv_area.geotiff") , pattern = 'R.tif', full.names = T)
nomi <- tolower(unlist(qdapRegex::ex_between(files, "SSA_H_", "_R.tif")))
files <- future_lapply(files, raster, future.seed=TRUE)
files <- stack(files)
names(files) <- nomi
files <- raster::subset(files, names(rainfed))

# convert crop water need to actualy water need by applying irrigation efficiency factors specific to each crop

crops_efficiency_irr <- crops[crops$crop %in% names(files),]
crops_efficiency_irr <- crops_efficiency_irr[order(crops_efficiency_irr$crop),]

gc()

# mm to m3 -> 1 mm supplies 0.001 m3 per m^2 of soil

files <- mask_raster_to_polygon(files, st_as_sfc(st_bbox(clusters_voronoi)))
files <- stack(files)

rainfed <- future_lapply(1:nlayers(files), function(X) {stack(rainfed[[X]] * (files[[X]] / crops_efficiency_irr$eta_irr[X]) * 10)}, future.seed=TRUE)

# sum by month

rainfed_sum <- rainfed

for (m in 1:12){
  
  rainfed_sum[[m]] <- do.call("sum", c(future_lapply(1:nlayers(files), function(X){rainfed[[X]][[m]]}, future.seed=TRUE), na.rm = TRUE))
  
}

rainfed_sum <- stack(rainfed_sum)
rainfed <- rainfed_sum

#save.image(paste0(processed_folder, "clusters_crop_module_offgrid.Rdata"))

#########

for (timestep in planning_year){
  
  markup <- stack(find_it(paste0("markup_", ifelse(scenarios$ssp[scenario]=="ssp2", 245, 585), ".nc")))[[ifelse(timestep==2020, 1, ifelse(timestep==2030, 10, ifelse(timestep==2040, 20, 20)))]]
  
  clusters_voronoi$markup <- exact_extract(brick(markup), clusters_voronoi, "median")
  clusters_voronoi$markup <- ifelse(clusters_voronoi$markup>1, 1, clusters_voronoi$markup)
  clusters_voronoi$markup <- ifelse(is.na(clusters_voronoi$markup), mean(clusters_voronoi$markup, na.rm=T), clusters_voronoi$markup)
  
  
  outs <- future_lapply(1:12, function(i){ exact_extract(rainfed[[i]], clusters_voronoi, "sum") * (1 + clusters_voronoi$markup) * scenarios$irrigated_cropland_share_target[scenario] * demand_growth_weights[match(timestep, planning_year)] }, future.seed = TRUE)
  
  for (i in 1:12){
    
    clusters_voronoi[paste0('monthly_IRREQ' , "_" , as.character(i), "_", timestep)] <- outs[[i]]
    
  }
  
  # Apply sustainability constraint for groundwater depletion
  
  index_qr <- ifelse(timestep==2020, 169, 169 + (timestep-2020-1)*12)
  
  qr_fut <- qr_baseline[[index_qr:(index_qr+11)]] # for speed, consider only the latest year
  qr_fut <- qr_fut * 60*60*24*30  #convert to mm per month
  
  outs <- future_lapply(1:12, function(i){ exact_extract(qr_fut[[i]], clusters_voronoi, "mean") * clusters_voronoi$area * 10 }, future.seed = TRUE)
  
  for (i in 1:12){
    
    clusters_voronoi[paste0('monthly_GQ' , "_" , as.character(i), "_", timestep)] <-  outs[[i]]
  }
  
  ###
  
  if(groundwater_sustainability_contraint==T){
    
    for (i in 1:12){
      
      aa <- clusters_voronoi
      aa$geom=NULL
      aa$geometry=NULL
      
      clusters_voronoi[paste0('monthly_unmet_IRRIG_share' , "_" , as.character(i), "_", timestep)] <- as.numeric(ifelse((unlist(aa[paste0('monthly_GQ' , "_" , as.character(i), "_", timestep)]) < unlist(aa[paste0('monthly_IRREQ' , "_" , as.character(i), "_", timestep)]))==TRUE, (unlist(aa[paste0('monthly_IRREQ' , "_" , as.character(i), "_", timestep)]) - unlist(aa[paste0('monthly_GQ' , "_" , as.character(i), "_", timestep)]))/ unlist(aa[paste0('monthly_IRREQ' , "_" , as.character(i), "_", timestep)]), 0))
      
    }}
  
  aa <- clusters_voronoi
  aa$geometry=NULL
  aa$geom=NULL
  
  clusters_voronoi[paste0('yearly_IRREQ' , "_", timestep)] <- rowSums(dplyr::select(aa, starts_with("monthly_IRREQ") & contains(as.character(timestep))))
  
}

#

clusters_voronoi$maxflow <- exact_extract(maxflow, clusters_voronoi, "mean")

##############################
# difference with on-grid demand

int <- intersect(colnames(clusters), colnames(clusters_voronoi))
int <- int[grep("IRREQ", int)]

aa <- clusters
aa$geometry=NULL
aa$geom=NULL

geom_bk <- clusters_voronoi$geom   
clusters_voronoi$geom <- NULL 

diff <- as.data.frame(clusters_voronoi[int]) -  as.data.frame(aa[int])
diff <- diff %>% mutate_if(is.numeric, ~ifelse(.<0, 0, .))

colnames(diff) <- paste0(colnames(diff), "_offgrid") 

clusters_voronoi[int] <- diff
colnames(clusters_voronoi)[as.numeric(na.omit(match(int, colnames(clusters_voronoi))))] <- colnames(diff) 
  
clusters_voronoi$geom <- geom_bk 
clusters_voronoi <- st_as_sf(clusters_voronoi)

############################

clusters$maxflow <- NULL
clusters$area_voronoi_ha <- NULL

clusters_voronoi_data <- clusters_voronoi
clusters_voronoi_data$geom <- NULL
clusters_voronoi_data <- dplyr::select(clusters_voronoi_data, starts_with("monthly") &  !contains("GQ"), starts_with("yearly") &  !contains("GQ"), area, maxflow)
clusters_voronoi_data <- dplyr::rename(clusters_voronoi_data, area_voronoi_ha = area)
clusters_voronoi_data$id <- clusters_voronoi$id

################

clusters <- merge(clusters, clusters_voronoi_data, by="id")
