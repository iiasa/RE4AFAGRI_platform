# Script to estimate, given monthly irrigation needs:
#1) Power of pump (W) given flow of pump (m3/s), or flow of pump given a fixed power of pump
#2) KWh/month required

#############

# Groundwater and surface water pumping module

# Use Google Earth Engine to extract the distance to the nearest source of surface water

if (length(grep(paste0("slope_", countrystudy, ".tif"), all_input_files_basename))>0){
  
  img_01 <- raster(paste0(input_folder, "slope_", countrystudy, ".tif"))
  
} else{
  
  geom <- ee$Geometry$Rectangle(c(as.vector(extent(clusters))[1], as.vector(extent(clusters))[3], as.vector(extent(clusters))[2], as.vector(extent(clusters))[4]))
  
  srtm = ee$Image('USGS/SRTMGL1_003');
  slope = ee$Terrain$slope(srtm);
  
  img_01 <- ee_as_raster(
    image = slope,
    via = "drive",
    region = geom,
    scale = 500,
    dsn= paste0(input_folder, "slope_", countrystudy, ".tif")
  )}

if (length(grep(paste0("groundwater_distance_", countrystudy, ".tif"), all_input_files_basename))>0){
  
  img_02 <- raster(paste0(input_folder, "groundwater_distance_", countrystudy, ".tif"))
  
} else{
  
  
  i = ee$FeatureCollection("WWF/HydroSHEDS/v1/FreeFlowingRivers") #$filter(ee$Filter$lte('RIV_ORD', 7))
  i = i$map(function(f) {
    f$buffer(20, 10);
  });
  
  distance = i$distance(searchRadius = 50000, maxError = 25)$clip(geom)
  
  img_02 <- ee_as_raster(
    image = distance,
    via = "drive",
    region = geom,
    scale = 500,
    dsn= paste0(input_folder, "groundwater_distance_", countrystudy, ".tif")
  )}


#
# # Calculate the mean distance from each cluster to the nearest source of surface water
clusters$surfw_dist <-  exact_extract(img_02, clusters_voronoi, fun="mean")
clusters$slope <-  exact_extract(img_01, clusters_voronoi, fun="mean")

# Extract mean value within each cluster
clusters$gr_wat_depth <- exact_extract(groundwater_depth, clusters_voronoi, fun="mean")


# Extract mean value within each cluster
clusters$gr_wat_storage <- exact_extract(groundwater_storage, clusters_voronoi, fun="mean")


# Extract mean value within each cluster
clusters$gr_wat_productivity <- exact_extract(groundwater_Productivity, clusters_voronoi, fun="mean")

##########

# To fix potential bugs in the data, delete negative values
clusters <- clusters %>% mutate(gr_wat_depth=ifelse(is.na(gr_wat_depth), mean(gr_wat_depth, na.rm=T), gr_wat_depth)) %>% ungroup()

clusters <- clusters %>% mutate(surfw_dist=ifelse(is.nan(surfw_dist), mean(surfw_dist, na.rm=T), surfw_dist)) %>% ungroup()

#clusters$surfw_dist <- ifelse(clusters$slope > slope_limit, Inf, clusters$surfw_dist) # an excessive slope renders groundwater pumping not feasible

clusters$surfw_dist = ifelse(clusters$surfw_dist>threshold_surfacewater_distance, Inf, clusters$surfw_dist)

clusters$gr_wat_depth = ifelse(clusters$gr_wat_depth>threshold_groundwater_pumping, Inf, clusters$gr_wat_depth)

######################

for (timestep in planning_year){

# Calculate average water pumps flow rate required in m3/h in each month
for (i in c(1:12)){
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  if(groundwater_sustainability_contraint==F)
    
    clusters[paste0("q" , as.character(i), "_offgrid")] = pull((aa[paste0('monthly_IRREQ' , "_" , as.character(i), "_", timestep, "_offgrid")] / (30/irrigation_frequency_days))/nhours_irr)
  
  else{
    
    clusters[paste0("q" , as.character(i), "_offgrid")] = pull(((aa[paste0('monthly_IRREQ' , "_" , as.character(i), "_", timestep, "_offgrid")]     * (1- aa[paste0('monthly_unmet_IRRIG_share' , "_" , as.character(i), "_", timestep, "_offgrid")])
    )/ (30/irrigation_frequency_days))/nhours_irr)
    
  }
  
}


# npumps required
aa <- clusters
aa$geometry=NULL
aa$geom=NULL

aa <- dplyr::select(aa, contains("offgrid"))

clusters$maxq <- NULL
clusters$maxq <- as.vector(matrixStats::rowMaxs(as.matrix(aa[grepl("^q", colnames(aa))]), na.rm = T))

clusters$npumps_offgrid <- ceiling(clusters$maxq / clusters$maxflow)

clusters$npumps_offgrid <- ifelse((is.infinite(clusters$gr_wat_depth) & is.infinite(clusters$surfw_dist)), 0, clusters$npumps_offgrid)

# ground water pumping

for (i in 1:12){
  print(i)
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  # RGH to estimate power for pump (in kW), missing the head losses
  clusters[paste0('powerforpump', as.character(i), "_offgrid")] = ifelse(clusters$npumps_offgrid>0, ((rho* g * clusters$gr_wat_depth* pull(aa[paste0("q", as.character(i), "_offgrid")])/ clusters$npumps_offgrid)/(3.6*10^6))/eta_pump/eta_motor, 0)
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  aa <- dplyr::select(aa, contains("offgrid"))
  
  clusters$powerforpump <- NULL
  clusters$powerforpump <- as.vector(matrixStats::rowMaxs(as.matrix(aa[grepl("^powerforpump", colnames(aa))]), na.rm = TRUE))
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  #Calculate monthly electric requirement
  clusters[paste0('wh_monthly', as.character(i), "_offgrid")] = pull(aa[paste0('powerforpump')])*nhours_irr*(30/irrigation_frequency_days)
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  clusters[paste0('er_kwh' , as.character(i), "_", timestep, "_offgrid")] = aa[paste0('wh_monthly', as.character(i), "_offgrid")]
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
}

# surface water pumping

for (i in 1:12){
  print(i)
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  v = (pull(aa[paste0("q", as.character(i), "_offgrid")]) / aa$npumps_offgrid) / (3600 * pi * (pipe_diameter/2)^2)
  
  delta_p_psi <- ((0.1 * v^2 * pull(aa["surfw_dist"]) * 1000 * 1) / (2 * pipe_diameter)) 
  
  clusters[paste0("surfw_w", as.character(i), "_offgrid")] = ifelse((clusters$npumps_offgrid>0 & is.finite(clusters$surfw_dist)), ((delta_p_psi * (pull(aa[paste0("q", as.character(i), "_offgrid")]) / aa$npumps_offgrid)) / eta_pump/eta_motor) /100, 0)
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  aa <- dplyr::select(aa, contains("offgrid"))
  
  clusters$surfw_w <- NULL
  clusters$surfw_w <- as.vector(matrixStats::rowMaxs(as.matrix(aa[grepl("^surfw_w", colnames(aa))]), na.rm = TRUE))
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  clusters[paste0('surface_er_kwh', as.character(i), "_", timestep, "_offgrid")] = aa[paste0('surfw_w', as.character(i), "_offgrid")]*nhours_irr*(30/irrigation_frequency_days)
  
}

######################
# select less energy intensive option between surface and groundwater pumping

aa <- clusters
aa$geometry=NULL
aa$geom=NULL

aa <- dplyr::select(aa, contains("offgrid"))

clusters[paste0('er_kwh_tt', "_", timestep, "_offgrid")] <- as.numeric(rowSums(aa[,grepl("^er_kwh", colnames(aa)) & grepl(timestep, colnames(aa)) & !grepl("surface", colnames(aa))], na.rm = T))
clusters[paste0('surface_er_kwh_tt', "_", timestep, "_offgrid")] <- as.numeric(rowSums(aa[,grepl("^surface_er_kwh", colnames(aa)) & grepl(timestep, colnames(aa))], na.rm = T))

aa <- clusters
aa$geometry=NULL
aa$geom=NULL

aa <- dplyr::select(aa, contains("offgrid"))

filter_a <- (pull(aa[paste0('er_kwh_tt', "_", timestep, "_offgrid")]) < pull(aa[paste0('surface_er_kwh_tt', "_", timestep, "_offgrid")]))
filter_a <- ifelse(is.na(filter_a), FALSE, filter_a)

filter_b <- (pull(aa[paste0('surface_er_kwh_tt', "_", timestep, "_offgrid")]) < pull(aa[paste0('er_kwh_tt', "_", timestep, "_offgrid")]))
filter_b <- ifelse(is.na(filter_b), FALSE, filter_b)

aa[paste0('which_pumping', "_", timestep, "_offgrid")] <- "Neither possible"
aa[paste0('which_pumping', "_", timestep, "_offgrid")][filter_a,] <- "Ground water pumping"
aa[paste0('which_pumping', "_", timestep, "_offgrid")][filter_b,] <- "Surface water pumping"

clusters[paste0('which_pumping', "_", timestep, "_offgrid")] <- aa[paste0('which_pumping', "_", timestep, "_offgrid")] 

for (i in 1:12){
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  aa <- dplyr::select(aa, contains("offgrid"))
  
  clusters[paste0("er_kwh", as.character(i), "_", timestep, "_offgrid")] = ifelse(aa[paste0('which_pumping', "_", timestep, "_offgrid")]=="Ground water pumping", pull(aa[paste0("er_kwh", as.character(i), "_", timestep, "_offgrid")]), ifelse(aa[paste0('which_pumping', "_", timestep, "_offgrid")]=="Surface water pumping", pull(aa[paste0("surface_er_kwh", as.character(i), "_", timestep, "_offgrid")]), NA)) * clusters$npumps_offgrid
  
}

aa <- clusters
aa$geometry=NULL
aa$geom=NULL

aa <- dplyr::select(aa, contains("offgrid"))

clusters[paste0('powerforpump', "_", timestep, "_offgrid")] <- ifelse(pull(aa[paste0('which_pumping', "_", timestep, "_offgrid")])=="Ground water pumping", clusters$powerforpump, ifelse(pull(aa[paste0('which_pumping', "_", timestep, "_offgrid")])=="Surface water pumping", clusters$surfw_w, NA))

clusters[paste0('er_kwh_tt', "_", timestep, "_offgrid")] <- as.numeric(rowSums(aa[,grepl("^er_kwh", colnames(aa)) & grepl(timestep, colnames(aa)) & !grepl("surface", colnames(aa)) & !grepl("tt", colnames(aa))], na.rm = T)) * clusters$npumps_offgrid

# # simulate daily profile

# if (output_hourly_resolution==T){
#   
#   for (k in 1:12){
#     
#     print(k)
#     
#     for (i in 1:24){
#       
#       aa <- clusters
#       aa$geometry=NULL
#       
#       clusters[paste0('er_kwh_' , as.character(k) , "_" , as.character(i), "_", timestep, "_offgrid")] <- (aa[paste0('er_kwh', as.character(k), "_", timestep, "_offgrid")]/30)*load_curve_irr[i]
#     }}
#   
# }

}

#save.image(paste0(processed_folder, "clusters_pumping_module_offgrid.Rdata"))
