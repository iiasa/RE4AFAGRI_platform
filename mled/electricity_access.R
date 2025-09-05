
## This R-script:
##      1) estimates electricity access in each cluster in the spirit of Falchetta et al. (2019) Scientific Data's paper, using built-up area and nighttime lights
##      2) downscales national electricity consumption statistics to each cluster using the dissever methodology (see Roudier et al. 2017 Computers and Electronics in Agriculture paper)

GHSSMOD2015 <- rast(find_it("builtup_africa.tif"))
GHSSMOD2015_lit <- rast(find_it("builtup_lit_africa.tif"))
  
GHSSMOD2015 <- crop(GHSSMOD2015, extent(clusters %>% st_transform(crs(GHSSMOD2015))))
GHSSMOD2015_lit <- crop(GHSSMOD2015_lit, extent(clusters %>% st_transform(crs(GHSSMOD2015_lit))))

######

# Spread current (residential) consumption

if (paste0("ely_cons_1_km_", countrystudy, ".tif") %in% all_input_files_basename){
  
  res_rf <- rast(find_it(paste0("ely_cons_1_km_", countrystudy, ".tif")))
  
  clusters$current_consumption_kWh <- exact_extract(res_rf, clusters, "sum")
  clusters$current_consumption_kWh <- ifelse(is.na(clusters$current_consumption_kWh ), 0, clusters$current_consumption_kWh)
  
  # readjust
  adj <- sum(clusters$current_consumption_kWh, na.rm=T) / residential_final_demand_tot
  clusters$current_consumption_kWh <- clusters$current_consumption_kWh / adj
  
} else {
  
  
  total <- residential_final_demand_tot
  weights <- rep(1/6, 6)
  
  pop <- rast(find_it("GHS_POP_E2015_GLOBE_R2019A_4326_30ss_V1_0.tif"))
  pop <- crop(pop, extent(gadm0))
  pop <- mask_raster_to_polygon(pop, gadm0)
  terra::values(pop) <- ifelse(is.na(terra::values(pop)), 0, terra::values(pop))
  
  listone <- read.csv(find_it(paste0(countryiso3, "_relative_wealth_index.csv")))
  listone$iso3c <- listone$.id
  listone$.id = NULL
  data <- st_as_sf(as.data.frame(listone), coords=c("longitude", "latitude"), crs=4326) %>% st_transform(3395) %>% st_buffer(2400) %>% st_transform(4326)
  rwi <- rasterize(data, pop, field = data$rwi, fun = max, na.rm = TRUE) # or mean
  rwi <- mask_raster_to_polygon(rwi, gadm0)
  rwi <- rwi + abs(min(terra::values(rwi), na.rm=T))
  
  el_access <- GHSSMOD2015_lit
  el_access <- projectRaster(el_access, pop)
  el_access <- crop(el_access, extent(gadm0))
  terra::values(el_access) <- ifelse(is.na(terra::values(el_access)), 0, 1)
  el_access <- mask_raster_to_polygon(el_access, gadm0)
  el_access <- projectRaster(el_access, pop, method="near")
  
  image1 <- rast(find_it('travel.tif'))
  image1 <- crop(image1, extent(gadm0))
  image1 <- mask_raster_to_polygon(image1, gadm0)
  tt <-projectRaster(image1, pop, method="near")
  tt <- -tt 
  tt <- tt - min(terra::values(tt), na.rm=T)
  
  prio <- read.csv(find_it("PRIO-GRID Static Variables - 2021-05-24.csv"))
  prio <- st_as_sf(prio, coords = c("xcoord", "ycoord"), crs=4326)
  prio2 <- read.csv(find_it("PRIO-GRID Yearly Variables for 2014-2014 - 2021-05-24.csv"))
  prio2 <- filter(prio2, year==2014)
  prio <- bind_cols(prio, prio2)
  
  prio <- prio %>% dplyr::select(diamprim_s, diamsec_s, goldvein_s, gem_s, petroleum_s)
  prio <- prio %>% mutate(resources = as.numeric(rowSums(prio[,c(1:5),drop=TRUE], na.rm=T)))
  
  # resources (PRIO)
  prio <- filter(prio, resources>0)
  prio <- st_transform(prio, 3395) %>% st_buffer(1000) %>% st_transform(4326)
  
  resources <- terra::rasterize(prio, pop, field="resources", fun="first")
  resources <- resources>0
  resources <- mask_raster_to_polygon(resources, gadm0)
  
  # resources (PRIO)
  
  if(!is.na(unique(values(resources)))){
  
  resources <- terra::distance(projectRaster(resources, crs="+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs")) 
  resources <- projectRaster(resources, crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs 
")
  resources <- mask_raster_to_polygon(resources/1000, gadm0)
  resources <- -resources 
  resources <- resources - min(terra::values(resources), na.rm=T) } else{
    
    values(resources) <- 1
    
    resources <- projectRaster(resources, crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs 
")
    resources <- mask_raster_to_polygon(resources/1000, gadm0)
    
  }
  
  #
  
  cdds <- rast(find_it("gldas_0p25_deg_cdd_base_T_24C_1970_2018_ann.nc4"))
  
  cdds_l <- list()
  
  for (i in 1:nlyr(cdds)){
    
    cdds_l[[i]] <- crop(cdds[[i]], extent(gadm0))
    
  }
  
  cdds <- rast(cdds_l)
  cdds <- calc(cdds, fun=sum, na.rm=T)
  
  cdds <-projectRaster(cdds, pop, method="near")
  
  ##############
  
  covs_1 <- aggregate(pop, fact=200, "sum")
  
  covs_2 <- aggregate(rwi, fact=200, "mean") # try max
  
  covs_2 <- covs_2 + abs(min(terra::values(covs_2), na.rm=T)) + 0.01
  
  covs_3 <- aggregate(el_access, fact=200, "sum")
  
  covs_4 <- aggregate(resources, fact=200, "sum")
  
  covs_5 <- aggregate(tt, fact=200, "mean")
  
  covs_6 <- aggregate(cdds, fact=200, "mean")
  
  
  ###
  
  fine <- pop
  terra::values(fine) <- ifelse(terra::values(fine) == 0, NA, terra::values(fine) )
  fine2 <- rwi
  fine3 <- el_access
  terra::values(fine3) <- ifelse(terra::values(fine3) == 0, NA, terra::values(fine3) )
  resources <- projectRaster(resources, pop)
  
  fine <- rast(fine, fine2, fine3,resources, tt, cdds)
  
  covs <- rast(covs_1, covs_2, covs_3, covs_4, covs_5, covs_6)
  
  ##
  
  begin_disserve <- function(total, covs, weights){
    
    sum_weights <- sum(weights)
    
    covs <- covs / unlist(lapply(as.list(covs), function(X){sum(terra::values(X), na.rm=T)}))
    
    cov_weights <- covs * (weights/sum_weights)
    
    datasum<- rastApply(cov_weights, indices = nlyr(cov_weights), fun = sum)
    
    return(datasum * total)
    
  }
  
  output <- begin_disserve(total, covs, weights)
  
  min_iter <- 2 # Minimum number of iterations
  max_iter <- 5 # Maximum number of iterations
  p_train <- 0.25 # Subsampling of the initial data
  
  # res_rf <- dissever(
  #   coarse = output, # rast of fine resolution covariates
  #   fine = fine, # coarse resolution rast
  #   method = "rf", # regression method used for disseveration
  #   p = p_train, # proportion of pixels sampled for training regression model
  #   min_iter = min_iter, # minimum iterations
  #   max_iter = max_iter # maximum iterations
  # )
  
  res_gam <- dissever(
    coarse = output, # rast of fine resolution covariates
    fine = fine, # coarse resolution rast
    method = "gamSpline", # regression method used for disseveration
    p = p_train, # proportion of pixels sampled for training regression model
    min_iter = min_iter, # minimum iterations
    max_iter = max_iter # maximum iterations
  )
  
  res_lm <- dissever(
    coarse = output, # rast of fine resolution covariates
    fine = fine, # coarse resolution rast
    method = "lm", # regression method used for disseveration
    p = p_train, # proportion of pixels sampled for training regression model
    min_iter = min_iter, # minimum iterations
    max_iter = max_iter # maximum iterations
  )
  
  # plot(caret::varImp(res_rf$fit))
  # 
  # par(mfrow = c(2, 2))
  # plot(res_rf, type = 'map', main = "Random Forest")
  # plot(res_gam, type = 'map', main = "GAM")
  # plot(res_lm, type = 'map', main = "Linear Model")
  # dev.off()
  # 
  # par(mfrow = c(2, 2))
  # plot(res_rf, type = 'perf', main = "Random Forest")
  # plot(res_gam, type = 'perf', main = "GAM")
  # plot(res_lm, type = 'perf', main = "Linear Model")
  # dev.off()
  
  preds <- extractPrediction(list(res_gam$fit, res_lm$fit))
  # plotObsVsPred(preds)
  # dev.off()
  
  perf <- preds %>%
    group_by(model, dataType) %>%
    summarise(
      rsq = cor(obs, pred)^2,
      rmse = sqrt(mean((pred - obs)^2))
    )
  
  # We can weight results with Rsquared
  w <- perf$rsq / sum(perf$rsq)
  
  # Make rast of weighted predictions and compute sum
  l_maps <- list(res_gam$map, res_lm$map)
  
  ens <- lapply(1:2, function(x) l_maps[[x]] * w[x]) %>%
    rast %>%
    sum
  
  
  res_rf_w <- ens/sum(terra::values(ens), na.rm=T)
  
  res_rf <- res_rf_w * total
  
  writeRaster(res_rf, paste0(processed_folder, "ely_cons_1_km_", countrystudy, ".tif"), overwrite=T)
  
  ####
  
  clusters$current_consumption_kWh <- exact_extract(res_rf, clusters, "sum")
  clusters$current_consumption_kWh <- ifelse(is.na(clusters$current_consumption_kWh ), 0, clusters$current_consumption_kWh)
  
  # readjust
  adj <- sum(clusters$current_consumption_kWh, na.rm=T) / residential_final_demand_tot
  clusters$current_consumption_kWh <- clusters$current_consumption_kWh / adj
  
}


if(isTRUE(latent_d_tot)){  clusters$elrate <- 1 }
