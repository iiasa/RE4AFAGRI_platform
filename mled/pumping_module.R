# Script to estimate, given monthly irrigation needs:
#1) Power of pump (W) given flow of pump (m3/s), or flow of pump given a fixed power of pump
#2) KWh/month required

#############

# Groundwater and surface water pumping module

img_01 <- raster(find_it("slope_africa.tif"))
img_02 <- raster(find_it("surfwater_distance_africa.tif"))

img_01 <- crop(img_01, extent(clusters_voronoi))
img_02 <- crop(img_02, extent(clusters_voronoi))

# # Calculate the mean distance from each cluster to the nearest source of surface water
clusters$surfw_dist <-  exact_extract(img_02, clusters, fun="mean")
clusters$slope <-  exact_extract(img_01, clusters, fun="mean")

# Groundwater depth
# Reclassify to numeric
DepthToGroundwater$depthwater = ifelse(DepthToGroundwater$DTWAFRICA_ == 'VS', 3.5, ifelse(DepthToGroundwater$DTWAFRICA_ == "S", 16, ifelse(DepthToGroundwater$DTWAFRICA_ == "SM", 37.5, ifelse(DepthToGroundwater$DTWAFRICA_ == "M", 75, ifelse(DepthToGroundwater$DTWAFRICA_ == "D", 175, ifelse(DepthToGroundwater$DTWAFRICA_ == "D", 250, 0))))))

DepthToGroundwater$depthwater <- as.numeric(DepthToGroundwater$depthwater)

groundwater_depth <- rasterFromXYZ(DepthToGroundwater[c("X", "Y", "depthwater")], crs = 4326)

# Extract mean value within each cluster
clusters$gr_wat_depth <- exact_extract(groundwater_depth, clusters, fun="mean")

# Groundwater storage
GroundwaterStorage$storagewater = ifelse(GroundwaterStorage$GWSTOR_V2 == 'VL', 0, ifelse(GroundwaterStorage$GWSTOR_V2 == "L", 500, ifelse(GroundwaterStorage$GWSTOR_V2 == "LM", 5500, ifelse(GroundwaterStorage$GWSTOR_V2 == "M", 17500, ifelse(GroundwaterStorage$GWSTOR_V2 == "H", 37500, 50000)))))

GroundwaterStorage$storagewater <- as.numeric(GroundwaterStorage$storagewater)

groundwater_storage <- rasterFromXYZ(GroundwaterStorage[c("X", "Y", "storagewater")], crs = 4326)

# Extract mean value within each cluster
clusters$gr_wat_storage <- exact_extract(groundwater_storage, clusters, fun="mean")


# Groundwate productivity
GroundwaterProductivity$Productivitywater = ifelse(GroundwaterProductivity$GWPROD_V2 == 'VH', 25, ifelse(GroundwaterProductivity$GWPROD_V2 == "H", 12.5, ifelse(GroundwaterProductivity$GWPROD_V2 == "M", 3, ifelse(GroundwaterProductivity$GWPROD_V2 == "LM", 0.75, ifelse(GroundwaterProductivity$GWPROD_V2 == "L", 0.3, 0.05)))))

GroundwaterProductivity$Productivitywater <- as.numeric(GroundwaterProductivity$Productivitywater)

groundwater_Productivity <- rasterFromXYZ(GroundwaterProductivity[c("X", "Y", "Productivitywater")], crs = 4326)

# Extract mean value within each cluster
clusters$gr_wat_productivity <- exact_extract(groundwater_Productivity, clusters, fun="mean")

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
      
      clusters[paste0("q" , as.character(i))] = pull((aa[paste0('monthly_IRREQ' , "_" , as.character(i), "_", timestep)] / (30/irrigation_frequency_days))/nhours_irr)
    
    else{
      
      clusters[paste0("q" , as.character(i))] = pull(((aa[paste0('monthly_IRREQ' , "_" , as.character(i), "_", timestep)]     * (1- aa[paste0('monthly_unmet_IRRIG_share' , "_" , as.character(i), "_", timestep)])
      )/ (30/irrigation_frequency_days))/nhours_irr)
      
    }
    
  }
  
  
  # npumps required
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  clusters$maxq <- NULL
  clusters$maxq <- as.vector(matrixStats::rowMaxs(as.matrix(aa[grepl("^q", colnames(aa))]), na.rm = T))
  
  clusters$npumps <- ceiling(clusters$maxq / clusters$maxflow)
  
  clusters$npumps <- ifelse((is.infinite(clusters$gr_wat_depth) & is.infinite(clusters$surfw_dist)), 0, clusters$npumps)
  
  # ground water pumping
  
  for (i in 1:12){
    print(i)
    aa <- clusters
    aa$geometry=NULL
    aa$geom=NULL
    
    # RGH to estimate power for pump (in kW), missing the head losses
    clusters[paste0('powerforpump', as.character(i))] = ifelse(clusters$npumps>0, ((rho* g * clusters$gr_wat_depth* pull(aa[paste0("q", as.character(i))])/ clusters$npumps)/(3.6*10^6))/eta_pump/eta_motor, 0)
    
    aa <- clusters
    aa$geometry=NULL
    aa$geom=NULL
    
    clusters$powerforpump <- NULL
    clusters$powerforpump <- as.vector(matrixStats::rowMaxs(as.matrix(aa[grepl("^powerforpump", colnames(aa))]), na.rm = TRUE))
    
    aa <- clusters
    aa$geometry=NULL
    aa$geom=NULL
    
    #Calculate monthly electric requirement
    clusters[paste0('wh_monthly', as.character(i))] = pull(aa[paste0('powerforpump')])*nhours_irr*(30/irrigation_frequency_days)
    
    aa <- clusters
    aa$geometry=NULL
    aa$geom=NULL
    
    clusters[paste0('er_kwh' , as.character(i), "_", timestep)] = aa[paste0('wh_monthly', as.character(i))]
    
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
    
    v = (pull(aa[paste0("q", as.character(i))]) / aa$npumps) / (3600 * pi * (pipe_diameter/2)^2)
    
    delta_p_psi <- ((0.1 * v^2 * pull(aa["surfw_dist"]) * 1000 * 1) / (2 * pipe_diameter)) 
    
    clusters[paste0("surfw_w", as.character(i))] = ifelse((clusters$npumps>0 & is.finite(clusters$surfw_dist)), ((delta_p_psi * (pull(aa[paste0("q", as.character(i))]) / aa$npumps)) / eta_pump/eta_motor) /100, 0)
    
    aa <- clusters
    aa$geometry=NULL
    aa$geom=NULL
    
    clusters$surfw_w <- NULL
    clusters$surfw_w <- as.vector(matrixStats::rowMaxs(as.matrix(aa[grepl("^surfw_w", colnames(aa))]), na.rm = TRUE))
    
    aa <- clusters
    aa$geometry=NULL
    aa$geom=NULL
    
    clusters[paste0('surface_er_kwh', as.character(i), "_", timestep)] = aa[paste0('surfw_w', as.character(i))]*nhours_irr*(30/irrigation_frequency_days)
    
  }
  
  ######################
  # select less energy intensive option between surface and groundwater pumping
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  clusters[paste0('er_kwh_tt', "_", timestep)] <- as.numeric(rowSums(aa[,grepl("^er_kwh", colnames(aa)) & grepl(timestep, colnames(aa)) & !grepl("surface", colnames(aa))], na.rm = T))
  clusters[paste0('surface_er_kwh_tt', "_", timestep)] <- as.numeric(rowSums(aa[,grepl("^surface_er_kwh", colnames(aa)) & grepl(timestep, colnames(aa))], na.rm = T))
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  
  filter_a <- (pull(aa[paste0('er_kwh_tt', "_", timestep)]) < pull(aa[paste0('surface_er_kwh_tt', "_", timestep)]))
  filter_a <- ifelse(is.na(filter_a), FALSE, filter_a)
  
  filter_b <- (pull(aa[paste0('surface_er_kwh_tt', "_", timestep)]) < pull(aa[paste0('er_kwh_tt', "_", timestep)]))
  filter_b <- ifelse(is.na(filter_b), FALSE, filter_b)
  
  aa[paste0('which_pumping', "_", timestep)] <- "Neither possible"
  aa[paste0('which_pumping', "_", timestep)][filter_a,] <- "Ground water pumping"
  aa[paste0('which_pumping', "_", timestep)][filter_b,] <- "Surface water pumping"
  
  clusters[paste0('which_pumping', "_", timestep)] <- aa[paste0('which_pumping', "_", timestep)] 
  
  for (i in 1:12){
    
    aa <- clusters
    aa$geometry=NULL
    aa$geom=NULL
    
    clusters[paste0("er_kwh", as.character(i), "_", timestep)] = ifelse(aa[paste0('which_pumping', "_", timestep)]=="Ground water pumping", pull(aa[paste0("er_kwh", as.character(i), "_", timestep)]), ifelse(aa[paste0('which_pumping', "_", timestep)]=="Surface water pumping", pull(aa[paste0("surface_er_kwh", as.character(i), "_", timestep)]), NA)) * clusters$npumps
    
  }
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  clusters[paste0('powerforpump', "_", timestep)] <- ifelse(pull(aa[paste0('which_pumping', "_", timestep)])=="Ground water pumping", clusters$powerforpump, ifelse(pull(aa[paste0('which_pumping', "_", timestep)])=="Surface water pumping", clusters$surfw_w, NA))
  
  clusters[paste0('er_kwh_tt', "_", timestep)] <- as.numeric(rowSums(aa[,grepl("^er_kwh", colnames(aa)) & grepl(timestep, colnames(aa)) & !grepl("surface", colnames(aa)) & !grepl("tt", colnames(aa))], na.rm = T)) * clusters$npumps
  
  # # simulate daily profile
  
  # if (output_hourly_resolution==T){
  # 
  # for (k in 1:12){
  # 
  #   print(k)
  # 
  #   for (i in 1:24){
  # 
  #     aa <- clusters
  #     aa$geometry=NULL
  # 
  #     clusters[paste0('er_kwh_' , as.character(k) , "_" , as.character(i), "_", timestep)] <- (aa[paste0('er_kwh', as.character(k), "_", timestep)]/30)*load_curve_irr[i]
  #   }}
  # 
  # }
  
}

#save.image(paste0(processed_folder, "clusters_pumping_module.Rdata"))
