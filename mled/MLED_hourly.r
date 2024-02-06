# MLED - Multi-sectoral Latent Electricity Demand assessment platform
# v0.2 (LEAP_RE)
# 24/08/2023

####
# system parameters

setwd("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled") # path of the cloned M-LED GitHub repository

db_folder = 'F:/Il mio Drive/MLED_database' # path to (or where to download) the M-LED database [must be an existing path]

email<- "giacomo.falchetta@gmail.com"

download_data <- F # flag: download the M-LED database? Type "F" if you already have done so previously.

allowparallel=T # allows paralellised processing. considerably shortens run time but requires computer with large CPU cores # (e.g. >=8 cores) and RAM (e.g. >=16 GB)

######################
# country and year

countrystudy <- c("zambia") # country(ies) to run M-LED on 

for (countrystudy in countrystudy){

exclude_countries <- paste(gsub("\\.r", "",gsub("scenario_", "", basename(list.files(pattern="scenario_", recursive = T))), ignore.case = T)[! gsub("\\.r", "",gsub("scenario_", "", basename(list.files(pattern="scenario_", recursive = T))), ignore.case = T) %in% c(countrystudy)], collapse ="|") # countries in the database files to exclude from the current run 

planning_year = seq(2020, 2060, 10) # time steps and horizon year to make projections

######################
# options and constriants 

latent_d_tot <- T # estimate evolution of demand given current (and projected) electricity access rates (if FALSE) OR total LATENT DEMAND (DEMAND If EVERYBODY HAD SUDDEN ACCESS TO ELECTRICITY, if TRUE)

watercrop_unit  <- "m3" # unit of water demand for irrigation, from Watercrop

no_productive_demand_in_small_clusters <- F # remove any type of productive use of energy in clusters below the "pop_threshold_productive_loads" parameter value

buffers_cropland_distance <- T # do not include agricultural loads from cropland distant more than n km (customisable in scenario file) from cluster centroid 

field_size_contraint <- T # consider only small farmland patches (smallholder farming)

process_already_irrigated_crops <- T # crop processing: include energy demand to process yield in already irrigated land

groundwater_sustainability_contraint <- F # impose limit on groundwater pumping based on monthly recharge

water_tank_storage <- T # water storage is possible

######################
# load modules and database

timestamp()
source("backend.R")

######################
# scenarios

ssp <- c("ssp2", "ssp2", "ssp2") # list SSP scenarios (socio-economic development) to run
rcp <- c("rcp60", "rcp60", "rcp26") # list RCP scenarios (climate change) to run

r <- readLines(paste0("country_scenarios/scenario_", countrystudy, ".R"))[17]; source(textConnection(r))
r2 <- readLines(paste0("country_scenarios/scenario_", countrystudy, ".R"))[30]; source(textConnection(r2))

el_access_share_target <- c(national_official_elrate, 1, 1) # target share of population with electricity in the last planning year
irrigated_cropland_share_target <- c(cropland_equipped_irrigation, .5, .75)  # target share of rainfed cropland irrigation water demand met in the last planning year
crop_processed_share_target <-  c(0.1, .5, .75)  #target share of crop yield locally processed in the last planning year

# calibrate baseline targets
write(paste0(timestamp(), "starting calibration module n2"), "log.txt", append=T)
source("calculate_rates_for_baseline.R", local=F)

scenarios <- data.frame(ssp = ssp, rcp = rcp, el_access_share_target=el_access_share_target, irrigated_cropland_share_target=irrigated_cropland_share_target, crop_processed_share_target=crop_processed_share_target, stringsAsFactors = F)

scenarios[,3:4] <- round(scenarios[,3:4], 3)

rownames(scenarios) <- c("baseline", "improved_access", "ambitious_development") # name the scenarios

############
# run the analysis

lapply(1:nrow(scenarios), function(scenario){
  
  file.edit("log.txt")
  
  scenario <- scenario
  
  print(paste("Running ", rownames(scenarios)[scenario]))
  
  # Load the country and scenario-specific data
  write(paste0(timestamp(), "starting scenario module"), "log.txt")
  source(paste0("country_scenarios/scenario_", countrystudy, ".R"), local=TRUE)
  
  # Determines how demand grows across time steps. Calibrated with GDP per capita growth rates
  write(paste0(timestamp(), "starting calibration module"), "log.txt", append=T)
  source("demand_growth_weights.R", local=TRUE)
  
  # Estimate electricity access levels and downscale current consumption level at each cluster
  write(paste0(timestamp(), "starting electricity access module"), "log.txt", append=T)
  source("electricity_access.R", local=TRUE)
  
  # Create catchment areas to link agricultural land to population clusters
  write(paste0(timestamp(), "starting clusters voronoi"), "log.txt", append=T)
  source("create_clusters_voronoi.R", local=TRUE)
  
  # Irrigation demand
  write(paste0(timestamp(), "starting crop module"), "log.txt", append=T)
  source("crop_module.R", local=TRUE)
  
  # Water pumping to energy
  write(paste0(timestamp(), "starting pumping module"), "log.txt", append=T)
  source("pumping_module.R", local=TRUE)
  
  # Irrigation demand for remote cropland (off-grid pumps)
  write(paste0(timestamp(), "starting offgrid crop module"), "log.txt", append=T)
  source("crop_module_solar_pumps.R", local=TRUE)
  
  # Water pumping to energy for remote cropland (off-grid pumps)
  write(paste0(timestamp(), "starting offgrid offgrid pumping module"), "log.txt", append=T)
  source("pumping_module_solar_pump.R", local=TRUE)
  
  # Mining
  write(paste0(timestamp(), "starting mining module"), "log.txt", append=T)
  source("mining_module.R", local=TRUE)
  
  # Residential energy demand
  write(paste0(timestamp(), "starting residential module"), "log.txt", append=T)
  source("residential.R", local=TRUE)
  
  # Health and education demand 
  write(paste0(timestamp(), "starting health&edu module"), "log.txt", append=T)
  source("health_education_module.R", local=TRUE)
  
  # Crop processing and storage
  write(paste0(timestamp(), "starting crop processing CA module"), "log.txt", append=T)
  source("crop_processing_catchment_areas.R", local=TRUE)
  
  # YG potential
  write(paste0(timestamp(), "starting yield growth module"), "log.txt", append=T)
  source("calculate_yield_growth_potential.R", local=TRUE)
  
  write(paste0(timestamp(), "starting crop processing module"), "log.txt", append=T)
  source("crop_processing.R", local=TRUE)
  
  # Other productive: SMEs
  write(paste0(timestamp(), "starting other productive module"), "log.txt", append=T)
  source("other_productive.R", local=TRUE)
  
  # Clean output
  write(paste0(timestamp(), "starting cleaner module"), "log.txt", append=T)
  source("cleaner.R", local=TRUE)
  

  ####
  
  # Write output for soft-linking into OnSSET and NEST and for online visualisation
  
  write(paste0(timestamp(), "starting writing outputs"), "log.txt", append=T)
  gc()
  
  demand_fields <- c("residential_tt", "residential_tt_monthly", "nonfarm_smes_tt", "nonfarm_smes_tt_monthly", "healthcare_tt", "healthcare_tt_monthly", "education_tt", "education_tt_monthly", "water_pumping", "crop_processing_tt", "mining_kwh_tt", "other_tt")
  
  clusters_onsset <- dplyr::select(clusters, id, starts_with("pop"), contains("isurban"), starts_with("gdp"), starts_with("yield_"), starts_with("A"), contains(demand_fields) & !contains("surface"))
  
  clusters_onsset[is.na(clusters_onsset)] <- 0
  
  for(timestep in planning_year){
    
    aa <- clusters_onsset
    aa$geometry <- NULL
    aa$geom <- NULL
    
    clusters_onsset[paste0("tot_dem_", timestep)] <- aa[paste0("residential_tt_", timestep)] + aa[paste0("nonfarm_smes_tt_", timestep)] + aa[paste0("healthcare_tt_", timestep)] + aa[paste0("education_tt_", timestep)] + aa[paste0("water_pumping_tt_", timestep)] + aa[paste0("crop_processing_tt_", timestep)] + aa[paste0("mining_kwh_tt_", timestep)] + aa[paste0("other_tt_", timestep)]
  }
  
  clusters_nest_BCU <- fasterize(st_cast(clusters_nest, "MULTIPOLYGON"), disaggregate(rainfed[[1]][[1]], fact=100), "BCU")
  
  clusters_onsset$BCU <- exact_extract(clusters_nest_BCU, clusters_onsset, "majority")
  
  indexes <- st_nearest_feature(clusters_onsset[is.na(clusters_onsset$BCU),], clusters_onsset[!is.na(clusters_onsset$BCU),])
  
  clusters_onsset$BCU[is.na(clusters_onsset$BCU)] <-  clusters_onsset$BCU[!is.na(clusters_onsset$BCU)][indexes]
  
  write_sf(clusters_onsset, paste0("results/", countrystudy, "_onsset_clusters_with_mled_loads_", rownames(scenarios)[scenario], ifelse(isTRUE(latent_d_tot), "_tot_lat_d", "_dem"), ".gpkg"), overwrite=T, layer_options = "SPATIAL_INDEX=NO")
  
  #write_sf(clusters_voronoi %>% dplyr::select(id), paste0("results/", countrystudy, "_onsset_clusters_voronoi.gpkg"))
  
  ############
  
  clusters_nest_output <- st_cast(clusters_nest, "MULTIPOLYGON")
  clusters_nest_output$id <- 1:nrow(st_cast(clusters_nest, "MULTIPOLYGON"))
  id <- fasterize(clusters_nest_output,  disaggregate(rainfed[[1]][[1]], fact=100), "id")
  
  clusters_onsset$id <- exact_extract(id, clusters_onsset, "majority")
  clusters_onsset$geom <- NULL
  clusters_onsset$geometry <- NULL
  clusters_onsset <- filter(clusters_onsset, !is.na(id))
  clusters_onsset <- dplyr::select(clusters_onsset, id, contains("isurban"), (contains(demand_fields) & !contains("surface")))
  
  clusters_onsset_2020 <- group_by(clusters_onsset, id, isurban) %>% summarize_at(vars(contains("2020")), sum, na.rm=T) %>% dplyr::select(-contains("isurban_future"))
  clusters_onsset_2030 <- group_by(clusters_onsset, id, isurban_future_2030) %>% summarize_at(vars(contains("2030")), sum, na.rm=T) %>% rename(isurban = isurban_future_2030) %>% dplyr::select(-contains("isurban_future"))
  clusters_onsset_2040 <- group_by(clusters_onsset, id, isurban_future_2040) %>% summarize_at(vars(contains("2040")), sum, na.rm=T) %>% rename(isurban = isurban_future_2040) %>% dplyr::select(-contains("isurban_future"))
  clusters_onsset_2050 <- group_by(clusters_onsset, id, isurban_future_2050) %>% summarize_at(vars(contains("2050")), sum, na.rm=T) %>% rename(isurban = isurban_future_2050) %>% dplyr::select(-contains("isurban_future"))
  clusters_onsset_2060 <- group_by(clusters_onsset, id, isurban_future_2060) %>% summarize_at(vars(contains("2060")), sum, na.rm=T) %>% rename(isurban = isurban_future_2060) %>% dplyr::select(-contains("isurban_future"))
  
  clusters_onsset_t <- bind_rows(clusters_onsset_2020, clusters_onsset_2030, clusters_onsset_2040, clusters_onsset_2050, clusters_onsset_2060)
  
  clusters_onsset_t <- group_by(clusters_onsset_t, id, isurban) %>% summarise_all(., sum, na.rm=T)
  
  clusters_onsset <- group_by(clusters_onsset, id) %>% summarise_all(., sum, na.rm=T)
  
  clusters_nest_output_1 <- merge(clusters_nest_output, clusters_onsset, "id")
  clusters_nest_output_1$id <- NULL
  
  clusters_nest_output_1 <- dplyr::select(clusters_nest_output_1, -contains("isurban"))
  
  st_crs(clusters_nest_output_1) <- 4326
  
  write_sf(clusters_nest_output_1, paste0("results/", countrystudy, "_nest_clusters_with_mled_loads_", rownames(scenarios)[scenario], ifelse(isTRUE(latent_d_tot), "_tot_lat_d", "_dem"), ".gpkg"), layer_options = "SPATIAL_INDEX=NO", overwrite=T)
  
  clusters_nest_output_2 <- merge(clusters_nest_output, clusters_onsset_t, "id")
  clusters_nest_output_2$id <- NULL
  
  clusters_nest_output_2 <- complete(clusters_nest_output_2, nesting(BCU), isurban)
  
  clusters_nest_output_2 <- group_by(clusters_nest_output_2, BCU) %>% mutate(geometry = ifelse(st_is_empty(geometry), geometry[!st_is_empty(geometry)], geometry)) %>% st_as_sf()
  
  clusters_nest_output_2[is.na(clusters_nest_output_2) & is.numeric(clusters_nest_output_2)] <- 0 
  
  clusters_nest_output_2 <- dplyr::select(clusters_nest_output_2, -contains("isurban_"))
  
  clusters_nest_output_2 <- st_as_sf(clusters_nest_output_2)
  
  st_crs(clusters_nest_output_2) <- 4326
  
  write_sf(clusters_nest_output_2, paste0("results/", countrystudy, "_nest_clusters_with_mled_loads_UR_", rownames(scenarios)[scenario], ifelse(isTRUE(latent_d_tot), "_tot_lat_d", "_dem"), ".gpkg"), layer_options = "SPATIAL_INDEX=NO", overwrite=T)
  
  
  #
  
  demand_fields <- c("residential_tt", "residential_tt_monthly", "nonfarm_smes_tt", "nonfarm_smes_tt_monthly", "healthcare_tt", "healthcare_tt_monthly", "education_tt", "education_tt_monthly", "water_pumping", "crop_processing_tt", "mining_kwh_tt", "other_tt")
  
  gadm2_output <- gadm2
  
  gadm2_output$id <- 1:nrow(gadm2_output)
  id <- fasterize(st_collection_extract(gadm2_output, "POLYGON"), disaggregate(rainfed[[1]][[1]], fact=100), "id")
  
  clusters_onsset <- dplyr::select(clusters, contains(demand_fields) & !contains("surface"), contains("IRREQ"), starts_with("Y_"), contains("machines"), contains("yg_potential_"), starts_with("A_"), starts_with("yield_"))
  clusters_onsset$id <- exact_extract(id, clusters_onsset, "majority")
  
  if(length(unique( clusters_onsset$id))<nrow(gadm2)){
    
    gadm2_output <- gadm1
    
    gadm2_output$id <- 1:nrow(gadm2_output)
    id <- fasterize(st_collection_extract(gadm2_output, "POLYGON"), disaggregate(rainfed[[1]][[1]], fact=100), "id")
    
    clusters_onsset <- dplyr::select(clusters, contains(demand_fields) & !contains("surface"), contains("IRREQ"), starts_with("Y_"), contains("machines"), contains("yg_potential_"), starts_with("A_"), starts_with("yield_"))
    clusters_onsset$id <- exact_extract(id, clusters_onsset, "majority")
    
  }
  
  clusters_onsset$geom <- NULL
  clusters_onsset$geometry <- NULL
  
  clusters_onsset_t1 <- group_by(clusters_onsset, id) %>%  summarize_at(vars(!starts_with("Y_")), sum, na.rm=T)
  
  clusters_onsset_t2 <- group_by(clusters_onsset, id) %>% summarize_at(vars(starts_with("Y_")), mean, na.rm=T)
  
  clusters_onsset <- reduce(list(clusters_onsset_t1, clusters_onsset_t2), 
                            left_join, by = "id")
  
  gadm2_output <- merge(gadm2_output, clusters_onsset, "id")
  
  write_sf(gadm2_output, paste0("results/", countrystudy, "_gadm2_with_mled_loads_", rownames(scenarios)[scenario], ifelse(isTRUE(latent_d_tot), "_tot_lat_d", "_dem"), ".gpkg"), layer_options = "SPATIAL_INDEX=NO", overwrite=T)
  
  gc()
  
  write(paste0(timestamp(), "scenario run completed"), "log.txt", append=T)
  return(print("Scenario run completed"))
  
})

if(allowparallel==T){stopCluster(cl)}
gc()

}
