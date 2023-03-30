
## This R-script:
##      1) calculates irrigation water needs at each cluster given the constaints imposed in the main M-LED file (e.g. smallholder farming only, or maximum distance to cluster threshold)
##      2) calculates environmental flow constraints at each cluster to avoid aquifer groundwater unsustainable extraction

clusters_buffers_cropland_distance <- fasterize(clusters_buffers_cropland_distance, field_size)

rainfed2 <- str_replace(rainfed, str_extract(rainfed, "[^_]+(?=\\.tif$)"), as.character(match(str_extract(rainfed, "[^_]+(?=\\.tif$)"), month.name)))
rainfed2 <- mixedsort(rainfed2)
rainfed2 <- str_replace(rainfed2, paste0(str_extract(rainfed2, "[^_]+(?=\\.tif$)"), ".tif"), paste0(month.name[as.numeric(str_extract(rainfed2, "[^_]+(?=\\.tif$)"))], ".tif"))

rainfed2 <- future_lapply(rainfed2, raster, future.seed=TRUE)

rainfed2 <- stack(rainfed2)
rainfed2 <-  mask_raster_to_polygon(rainfed2, st_as_sfc(st_bbox(clusters_voronoi)))

crs(rainfed2) <- as.character(CRS("+init=epsg:4236"))
rainfed2 <- as.list(rainfed2)

field_size_proc <-  mask_raster_to_polygon(field_size, st_as_sfc(st_bbox(clusters_voronoi)))

if(field_size_contraint==T){field_size_proc <- projectRaster(field_size_proc, mask_raster_to_polygon(rainfed2[[1]], st_as_sfc(st_bbox(clusters_voronoi))), method = "bilinear") ; m <- field_size_proc; m[m > 29] <- NA; field_size_proc <- mask(field_size_proc, m); rainfed2 <- future_lapply(rainfed2, function(X){return(mask_raster_to_polygon(X, st_as_sfc(st_bbox(clusters_voronoi))))}, future.seed=TRUE); for (i in 1:length(rainfed2)){crs(rainfed2[[i]]) <- crs(field_size_proc)}; field_size_proc <- projectRaster(field_size_proc,rainfed2[[1]]); rainfed2 <- future_lapply(rainfed2, function(X){mask(X, field_size_proc)}, future.seed=TRUE)}

if(buffers_cropland_distance==T){clusters_buffers_cropland_distance <- projectRaster(clusters_buffers_cropland_distance,rainfed2[[1]], method = "ngb"); rainfed2 <- future_lapply(rainfed2, function(X){mask(X, clusters_buffers_cropland_distance)}, future.seed=TRUE)}

rainfed2 <- split(rainfed2,  tolower(unlist(qdapRegex::ex_between(rainfed, "watercrop/", "/20"))))

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

if (watercrop_unit =="mm"){
rainfed <- future_lapply(1:nlayers(files), function(X) {stack(rainfed[[X]] * (files[[X]] / crops_efficiency_irr$eta_irr[X]) * 10)}, future.seed=TRUE)
} else{ 
  rainfed <- future_lapply(1:nlayers(files), function(X) {stack(rainfed[[X]] / crops_efficiency_irr$eta_irr[X])}, future.seed=TRUE)
}

# sum by month and year

rainfed_sum <- list()

for (timestep in planning_year[-length(planning_year)]){
for (m in 1:12){
  
  rainfed_sum[[as.character(timestep)]][[m]] <- do.call("sum", c(future_lapply(1:nlayers(files), function(X){rainfed[[X]][[((match(timestep, planning_year) - 1) * 12) + m]]}, future.seed=TRUE), na.rm = TRUE))
  
}}

rainfed_sum[[5]] <- rainfed_sum[[4]]; names(rainfed_sum)[5] <- as.character(as.numeric(names(rainfed_sum)[4])+ 10) #add 2060

rainfed <- rainfed_sum

####
# do the same for already irrigated cropland

irrigated2 <- str_replace(irrigated, str_extract(irrigated, "[^_]+(?=\\.tif$)"), as.character(match(str_extract(irrigated, "[^_]+(?=\\.tif$)"), month.name)))
irrigated2 <- mixedsort(irrigated2)
irrigated2 <- str_replace(irrigated2, paste0(str_extract(irrigated2, "[^_]+(?=\\.tif$)"), ".tif"), paste0(month.name[as.numeric(str_extract(irrigated2, "[^_]+(?=\\.tif$)"))], ".tif"))

irrigated2 <- future_lapply(irrigated2, raster, future.seed=TRUE)

irrigated2 <- stack(irrigated2)

irrigated2 <-  mask_raster_to_polygon(irrigated2, st_as_sfc(st_bbox(clusters_voronoi)))

crs(irrigated2) <- as.character(CRS("+init=epsg:4236"))
irrigated2 <- as.list(irrigated2)

field_size_proc <-  mask_raster_to_polygon(field_size, st_as_sfc(st_bbox(clusters_voronoi)))

if(field_size_contraint==T){field_size_proc <- projectRaster(field_size_proc, mask_raster_to_polygon(irrigated2[[1]], st_as_sfc(st_bbox(clusters_voronoi))), method = "bilinear") ; m <- field_size_proc; m[m > 29] <- NA; field_size_proc <- mask(field_size_proc, m); irrigated2 <- future_lapply(irrigated2, function(X){return(mask_raster_to_polygon(X, st_as_sfc(st_bbox(clusters_voronoi))))}, future.seed=TRUE); for (i in 1:length(irrigated2)){crs(irrigated2[[i]]) <- crs(field_size_proc)}; field_size_proc <- projectRaster(field_size_proc,irrigated2[[1]]); irrigated2 <- future_lapply(irrigated2, function(X){mask(X, field_size_proc)}, future.seed=TRUE)}

if(buffers_cropland_distance==T){clusters_buffers_cropland_distance <- projectRaster(clusters_buffers_cropland_distance,irrigated2[[1]], method = "ngb"); irrigated2 <- future_lapply(irrigated2, function(X){mask(X, clusters_buffers_cropland_distance)}, future.seed=TRUE)}

irrigated2 <- split(irrigated2,  tolower(unlist(qdapRegex::ex_between(irrigated, "watercrop/", "/20"))))

irrigated <- lapply(irrigated2, stack)

names(irrigated) <- c("barl", "cass", "coco", "cott", "grou", "maiz", "pmil", "smil", "oilp", "pota", "rape", "rice", "sorg", "soyb", "sugb", "sugc", "sunf", "whea", "yams")

#

clusters_voronoi$area <- as.numeric(st_area(clusters_voronoi)) * 0.0001 # in hectares

# extract total bluewater demand in each cluster

files = list.files(path = paste0(input_folder, "spam_folder/spam2017v2r1_ssa_harv_area.geotiff") , pattern = 'I.tif', full.names = T)
nomi <- tolower(unlist(qdapRegex::ex_between(files, "SSA_H_", "_I.tif")))
files <- future_lapply(files, raster, future.seed=TRUE)
files <- stack(files)
names(files) <- nomi
files <- raster::subset(files, names(irrigated))

# convert crop water need to actualy water need by applying irrigation efficiency factors specific to each crop

crops_efficiency_irr <- crops[crops$crop %in% names(files),]
crops_efficiency_irr <- crops_efficiency_irr[order(crops_efficiency_irr$crop),]

gc()

# mm to m3 -> 1 mm supplies 0.001 m3 per m^2 of soil

files <- mask_raster_to_polygon(files, st_as_sfc(st_bbox(clusters_voronoi)))
files <- stack(files)

if (watercrop_unit =="mm"){
  irrigated <- future_lapply(1:nlayers(files), function(X) {stack(irrigated[[X]] * (files[[X]] / crops_efficiency_irr$eta_irr[X]) * 10)}, future.seed=TRUE)
} else{ 
  irrigated <- future_lapply(1:nlayers(files), function(X) {stack(irrigated[[X]] / crops_efficiency_irr$eta_irr[X])}, future.seed=TRUE)
}

# sum by month and year

irrigated_sum <- list()

for (timestep in planning_year[-length(planning_year)]){
  for (m in 1:12){
    
    irrigated_sum[[as.character(timestep)]][[m]] <- do.call("sum", c(future_lapply(1:nlayers(files), function(X){irrigated[[X]][[((match(timestep, planning_year) - 1) * 12) + m]]}, future.seed=TRUE), na.rm = TRUE))
    
  }}

irrigated_sum[[5]] <- irrigated_sum[[4]]; names(irrigated_sum)[5] <- as.character(as.numeric(names(irrigated_sum)[4])+ 10) #add 2060

irrigated <- irrigated_sum


#########

for (timestep in planning_year){

  outs <- future_lapply(1:12, function(i){  exact_extract(rainfed[[match(timestep, planning_year)]][[i]], clusters_voronoi, "sum")}, future.seed = TRUE)
  
  outs2 <- future_lapply(1:12, function(i){  exact_extract(irrigated[[match(timestep, planning_year)]][[i]], clusters_voronoi, "sum")}, future.seed = TRUE)

  for (i in 1:12){
  
  clusters_voronoi[paste0('monthly_IRREQ' , "_" , as.character(i), "_", timestep)] <- outs[[i]] + outs2[[i]]
  
}
  
# Apply sustainability constraint for groundwater depletion
  
  index_qr <- ifelse(timestep==2020, 169, 169 + (timestep-2020-1)*12)
  
  qr_fut <- qr_baseline[[index_qr:(index_qr+11)]] # for speed, consider only the latest year
  qr_fut <- qr_fut * 60*60*24*30  #convert to mm per month
  
  
  outs <- future_lapply(1:12, function(i){exact_extract(qr_fut[[i]], clusters_voronoi, "mean") * clusters_voronoi$area * 10}, future.seed = TRUE)
  
  for (i in 1:12){
    
    clusters_voronoi[paste0('monthly_GQ' , "_" , as.character(i), "_", timestep)] <- outs[[i]]
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

clusters_voronoi_data <- clusters_voronoi
clusters_voronoi_data$geom <- NULL
clusters_voronoi_data <- dplyr::select(clusters_voronoi_data, id, starts_with("monthly"), starts_with("yearly"), area, maxflow)
clusters_voronoi_data <- dplyr::rename(clusters_voronoi_data, area_voronoi_ha = area)

clusters <- merge(clusters, clusters_voronoi_data, by="id")
        
