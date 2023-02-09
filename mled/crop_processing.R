
## This R-script:
##      1) calculate monthly yield at each cluster for each crop
##      2) estimates machinery (#, power) requirements at each crop-processing eligible cluster to carry out crop processing and cold storage at each time step and consistently with the share of crop yield to be processed specified in the main M-LED file. N.B. processing machinery considered are listed and can be customised in the "" file.
##      3) calculates crop-specific and total electricity demand for crop processing at each time step

# Extract yield 
# Import all Yield (kg/ha) cropland layers (Default datasets used: MapSPAM)
# NB: when using MapSPAM use harvested area, which accounts for multiple growing seasons per year)
files <- list.files(path=paste0(input_folder, "spam_folder/spam2017v2r1_ssa_yield.geotiff"), pattern="R.tif", full.names=T)
files <- files[grepl(paste(energy_crops[,1], collapse="|") , files, ignore.case =T)]

files2 = list.files(path = paste0(input_folder, "spam_folder/spam2017v2r1_ssa_harv_area.geotiff") , pattern = 'R.tif', full.names = T)
files2 <- files2[grepl(paste(energy_crops[,1], collapse="|") , files2, ignore.case =T)]

## implement these constraints

files <- stack(lapply(files, function(X)(raster(X))))
names(files) <- tolower(unlist(qdapRegex::ex_between(names(files), "SSA_Y_", "_R")))

files2 <- stack(lapply(files2, function(X)(raster(X))))
names(files2) <- tolower(unlist(qdapRegex::ex_between(names(files2), "SSA_H_", "_R")))

for (i in 1:nlayers(files)){
  crs(files[[i]]) <- as.character(CRS("+init=epsg:4236"))
}

for (i in 1:nlayers(files2)){
  crs(files2[[i]]) <- as.character(CRS("+init=epsg:4236"))
}

files <- mask_raster_to_polygon(files, st_as_sfc(st_bbox(clusters_voronoi)))
files2 <- mask_raster_to_polygon(files2, st_as_sfc(st_bbox(clusters_voronoi)))


# field_size <- raster(find_it("field_size_10_40_cropland.img"))
# field_size <- mask_raster_to_polygon(field_size, st_as_sfc(st_bbox(clusters)))
# crs(field_size) <- as.character(CRS("+init=epsg:4236"))
# 
# if(field_size_contraint==T){field_size <- projectRaster(field_size, mask_raster_to_polygon(files[[1]], st_as_sfc(st_bbox(clusters_voronoi))), method = "bilinear") ; m <- field_size; m[m > 29] <- NA; field_size <- mask(field_size, m); for (i in 1:nlayers(files)){crs(files[[i]]) <- crs(field_size)}; field_size <- projectRaster(field_size,files[[1]]); files <- mask(files, field_size)}
# 
# field_size <- raster(find_it("field_size_10_40_cropland.img"))
# field_size <- mask_raster_to_polygon(field_size, st_as_sfc(st_bbox(clusters)))
# crs(field_size) <- as.character(CRS("+init=epsg:4236"))
# 
# if(field_size_contraint==T){field_size <- projectRaster(field_size, mask_raster_to_polygon(files2[[1]], st_as_sfc(st_bbox(clusters_voronoi))), method = "bilinear") ; m <- field_size; m[m > 29] <- NA; field_size <- mask(field_size, m); for (i in 1:nlayers(files2)){crs(files2[[i]]) <- crs(field_size)}; field_size <- projectRaster(field_size,files2[[1]]); files2 <- mask(files2, field_size)}

####

outs <- future_lapply(1:nlayers(files2), function(X){  exact_extract(files2[[X]], clusters_voronoi, fun="sum")}, future.seed = TRUE )

outs2 <- future_lapply(1:nlayers(files), function(X){  exact_extract(files[[X]], clusters_voronoi, fun="mean")}, future.seed = TRUE )

for (X in 1:nlayers(files)){
  a = paste0("A_" , names(files)[X], "_r")
  clusters[a] <- outs[[X]]
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL
  
  clusters[a] <- ifelse(is.na( pull(aa[a])), 0,  pull(aa[a]))
  
  a = paste0("Y_" ,  names(files)[X], "_r")
  clusters[a] <- outs2[[X]]
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL
  
  clusters[a] <- ifelse(is.na( pull(aa[a])), mean(aa[a], na.rm=T),  pull(aa[a]))
  
  for (timestep in planning_year){
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
    clusters <- clusters %>%  mutate(!!paste0("yield_",  names(files)[X], "_r_cp_", timestep) := (!!as.name(a)) * pull(!!aa[paste0("A_",  names(files)[X], "_r")]) * scenarios$crop_processed_share_target[scenario] * demand_growth_weights[match(timestep, planning_year)])
    
  }}

################
# Same but for already irrigated cropland

if (process_already_irrigated_crops==T){
  
  files <- list.files(path=paste0(input_folder, "spam_folder/spam2017v2r1_ssa_yield.geotiff"), pattern="I.tif", full.names=T)
  files <- files[grepl(paste(energy_crops[,1], collapse="|") , files, ignore.case =T)]
  
  files2 = list.files(path = paste0(input_folder, "spam_folder/spam2017v2r1_ssa_harv_area.geotiff") , pattern = 'I.tif', full.names = T)
  files2 <- files2[grepl(paste(energy_crops[,1], collapse="|") , files2, ignore.case =T)]
  
  ## implement these constraints
  
  files <- stack(lapply(files, function(X)(raster(X))))
  names(files) <- tolower(unlist(qdapRegex::ex_between(names(files), "SSA_Y_", "_I")))
  
  files2 <- stack(lapply(files2, function(X)(raster(X))))
  names(files2) <- tolower(unlist(qdapRegex::ex_between(names(files2), "SSA_H_", "_I")))
  
  for (i in 1:nlayers(files)){
    crs(files[[i]]) <- as.character(CRS("+init=epsg:4236"))
  }
  
  for (i in 1:nlayers(files2)){
    crs(files2[[i]]) <- as.character(CRS("+init=epsg:4236"))
  }
  
  files <- mask_raster_to_polygon(files, st_as_sfc(st_bbox(clusters_voronoi)))
  files2 <- mask_raster_to_polygon(files2, st_as_sfc(st_bbox(clusters_voronoi)))
  
  
  field_size <- raster(find_it("field_size_10_40_cropland.img"))
  field_size <- mask_raster_to_polygon(field_size, st_as_sfc(st_bbox(clusters)))
  crs(field_size) <- as.character(CRS("+init=epsg:4236"))
  
  if(field_size_contraint==T){field_size <- projectRaster(field_size, mask_raster_to_polygon(files[[1]], st_as_sfc(st_bbox(clusters_voronoi))), method = "bilinear") ; m <- field_size; m[m > 29] <- NA; field_size <- mask(field_size, m); for (i in 1:nlayers(files)){crs(files[[i]]) <- crs(field_size)}; field_size <- projectRaster(field_size,files[[1]]); files <- mask(files, field_size)}
  
  field_size <- raster(find_it("field_size_10_40_cropland.img"))
  field_size <- mask_raster_to_polygon(field_size, st_as_sfc(st_bbox(clusters)))
  crs(field_size) <- as.character(CRS("+init=epsg:4236"))
  
  if(field_size_contraint==T){field_size <- projectRaster(field_size, mask_raster_to_polygon(files2[[1]], st_as_sfc(st_bbox(clusters_voronoi))), method = "bilinear") ; m <- field_size; m[m > 29] <- NA; field_size <- mask(field_size, m); for (i in 1:nlayers(files2)){crs(files2[[i]]) <- crs(field_size)}; field_size <- projectRaster(field_size,files2[[1]]); files2 <- mask(files2, field_size)}
  
  outs <- future_lapply(1:nlayers(files2), function(X){  exact_extract(files2[[X]], clusters_voronoi, fun="sum") }, future.seed = TRUE)
  
  outs2 <- future_lapply(1:nlayers(files), function(X){  exact_extract(files[[X]], clusters_voronoi, fun="mean") }, future.seed = TRUE)
  
  for (X in 1:nlayers(files)){
    
    a = paste0("A_" , names(files)[X], "_i")
    clusters[a] <- outs[[X]] 
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
    clusters[a] <- ifelse(is.na( pull(aa[a])), 0,  pull(aa[a]))
    
    a = paste0("Y_" ,  names(files)[X], "_i")
    clusters[a] <- outs2[[X]] 
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
    clusters[a] <- ifelse(is.na( pull(aa[a])), 0,  pull(aa[a]))
    
    
    for (timestep in planning_year){
      
      aa <- clusters
      aa$geom=NULL
      aa$geometry=NULL
      
      clusters <- clusters %>%  mutate(!!paste0("yield_",  names(files)[X], "_i_cp_", timestep) := (!!as.name(a)) * pull(!!aa[paste0("A_",  names(files)[X], "_i")]) * scenarios$crop_processed_share_target[scenario] * demand_growth_weights[match(timestep, planning_year)])
      
      
    }}}

########################

# Multiply yearly yield of each crop by unit processing energy requirement to estimate yearly demand in each cluster as the sum of each crop processing energy demand

rm(geom_bk)

gc()

for (timestep in planning_year){
  
  
  for (X in as.vector(energy_crops[,1])){
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
    clusters[paste0("kwh_" , X , "_cp_", timestep)] = pull(aa[paste0("yield_", X, "_r_cp_", timestep)]) * energy_crops$kw_kg._h[as.vector(energy_crops[,1]) == X] 
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
    clusters[paste0("kwh_" , X , "_cp_", timestep)] = ifelse(clusters$suitable_for_local_processing==1, pull(aa[paste0("kwh_" , X , "_cp_", timestep)]), 0)
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
    if (process_already_irrigated_crops==T){
      
      clusters[paste0("kwh_" , X , "_cp_", timestep)] = pull(aa[paste0("kwh_" , X , "_cp_", timestep)]) + pull(aa[paste0("yield_", X, "_i_cp_", timestep)]) * energy_crops$kw_kg._h[as.vector(energy_crops[,1]) == X]
      
      aa <- clusters
      aa$geom=NULL
      aa$geometry=NULL
      
      clusters[paste0("kwh_" , X , "_cp_", timestep)] = ifelse(clusters$suitable_for_local_processing==1, pull(aa[paste0("kwh_" , X , "_cp_", timestep)]), 0)
     

    }
    
    gc()
    
  }
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL
  
  clusters[paste0("kwh_cp_tt_", timestep)] <- as.vector(aa %>%  dplyr::select(starts_with('kwh') & contains(as.character(timestep))) %>% rowSums(na.rm = T) %>% as.numeric())
  
}

# processing to take place in post-harvesting months: for each crop 1) take harvesting date 2) take plantation months. for those months between 1 and 2 equally allocate crop processing

gc()

crops <- crops[complete.cases(crops), ]
crops <-  crops[crops$crop %in% as.vector(energy_crops[,1]), ]

for (timestep in planning_year){
  
  for (i in 1:nrow(crops)){
    for (m in 1:12){
      daily=data.frame("daily" = c(1:729))
      daily$date = seq(as.Date("2019-01-01"), length.out = 729, by = "days")
      daily$month = lubridate::month(daily$date)
      daily$day = lubridate::day(daily$date)
      
      pm1= as.Date(paste0(crops[i, 'pm_1'], "2019"), format= "%d%m%Y")
      pm2= as.Date(paste0(crops[i, 'pm_2'], "2019"), format= "%d%m%Y")
      
      a =  filter(daily, date>= pm1 + as.numeric(crops[i, 'nd_1']) + as.numeric(crops[i, 'nd_2']) + as.numeric(crops[i, 'nd_3']) + as.numeric(crops[i, 'nd_4']))
      a =  filter(a, date < as.Date("2020-03-15", format="%Y-%m-%d"))
      a =  filter(a, lubridate::month(month) == m)
      a = unique(a$month)
      
      aa <- clusters
      aa$geom=NULL
      aa$geometry=NULL
      
      clusters[paste0("kwh_cp" , as.character(crops$crop[i]) , "_" , as.character(m), "_", timestep)] = pull(aa[paste0("kwh_" , as.character(crops$crop[i]) , "_cp", "_", timestep)]) / ifelse(length(a)==0, 0, a)
      
      aa <- clusters
      aa$geom=NULL
      aa$geometry=NULL
      
      clusters[paste0("kwh_cp" , as.character(crops$crop[i]) , "_" , as.character(m), "_", timestep)]  = ifelse(is.infinite(pull(aa[paste0("kwh_cp" , as.character(crops$crop[i]) , "_" , as.character(m), "_", timestep)])), 0, pull(aa[paste0("kwh_cp" , as.character(crops$crop[i]) , "_" , as.character(m), "_", timestep)]))
      
    }}
  
  # sum all crops by months
  for (z in 1:12){
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
    
    aa <- aa %>% dplyr::select(starts_with('kwh_cp') & contains(as.character(timestep))) %>% dplyr::select(ends_with(paste0('_' , as.character(z), "_", timestep))) %>% mutate(a=rowSums(., na.rm = T))
    
    clusters = clusters %>% mutate(!!as.name(paste0('crop_processing_tt_monthly', "_" , as.character(z), "_", timestep)) := as.vector(aa$a))
    
  }
  
  gc()
  
  }


########

# for (timestep in planning_year){
#
#   print(timestep)
#
#   # crop_processing_tt_monthly nel mese m / (potenza della macchina: assunta / numero di ore operazionali) = numero di macchine necessarie
#
#   for (X in as.vector(energy_crops[,1])){
#     for (m in 1:12){
#
#       aa <- clusters
#       aa$geom=NULL
#       aa$geometry=NULL
#
#       clusters[paste0("n_machines_" , X , "_" , as.character(m), "_", timestep)] <- pull(ceiling(aa[paste0("kwh_cp" , X , "_" , as.character(m), "_", timestep)] / ((energy_crops$kg_per_hour_kwmin[as.vector(energy_crops[,1]) == X]) * (sum(load_curve_cp>0)))))
#
#       aa <- clusters
#       aa$geom=NULL
#       aa$geometry=NULL
#
#       clusters[paste0("kw_tot_machines_" , X , "_" , as.character(m), "_", timestep)] <- pull(aa[paste0("n_machines_" , X , "_" , as.character(m),  "_",timestep)]) * energy_crops$kw_min[as.vector(energy_crops[,1]) == X]
#
#       aa <- clusters
#       aa$geom=NULL
#       aa$geometry=NULL
#
#       clusters[paste0("n_machines_" , X , "_" , as.character(m), "_", timestep)] <- ifelse(clusters$suitable_for_local_processing==1, pull(aa[paste0("n_machines_" , X , "_" , as.character(m), "_", timestep)]), 0)
#
#       aa <- clusters
#       aa$geom=NULL
#       aa$geometry=NULL
#
#       clusters[paste0("kw_tot_machines" , X , "_" , as.character(m), "_", timestep)] <- ifelse(clusters$suitable_for_local_processing==1, pull(aa[paste0("kw_tot_machines_" , X , "_" , as.character(m), "_", timestep)]), 0)
#
#       gc()
#
#     }
#
#     aa <- clusters
#     aa$geom=NULL
#     aa$geometry=NULL
#
#     clusters[paste0("n_machines_" , X,  "_",timestep)] <- as.vector(as.matrix(aa %>%  dplyr::select(starts_with(paste0("n_machines_" , X)) & contains(as.character(timestep)))) %>% matrixStats::rowMaxs(., na.rm = TRUE) %>% as.numeric())
#
#     aa <- clusters
#     aa$geom=NULL
#     aa$geometry=NULL
#
#     clusters[paste0("kw_tot_machines_" , X, "_", timestep)] <- as.vector(as.matrix(aa %>%  dplyr::select(starts_with(paste0("kw_tot_machines_" , X)) & contains(as.character(timestep)))) %>% matrixStats::rowMaxs(., na.rm = TRUE) %>% as.numeric())
#
#   }}
# 
# ###
# 
# if (output_hourly_resolution==T){
#   
#   # simulate daily profile
#   
#   for (k in 1:12){
#     
#     aa <- clusters
#     aa$geom=NULL
#     aa$geometry=NULL
#     
#     
#     clusters[paste0('kwh_cropproc_tt_', as.character(k))] = pull(aa[paste0('crop_processing_tt_monthly' , "_" , as.character(k))])/30
#     
#   }
#   
#   for (k in 1:12){
#     for (i in 1:24){
#       
#       aa <- clusters
#       aa$geom=NULL
#       aa$geometry=NULL
#       
#       
#       clusters[paste0('kwh_cropproc' , as.character(k) , "_" ,  as.character(i))] = pull(aa[paste0('kwh_cropproc_tt_' , as.character(k))])*load_curve_cp[i]
#       
#     }}
#   
# }

#save.image(paste0(processed_folder, "clusters_crop_processing.Rdata"))
