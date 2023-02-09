
## This R-script:
##      1) estimates electricity access in each cluster in the spirit of Falchetta et al. (2019) Scientific Data's paper, using built-up area and nighttime lights
##      2) downscales national electricity consumption statistics to each cluster using the dissever methodology (see Roudier et al. 2017 Computers and Electronics in Agriculture paper)


geom <- ee$Geometry$Rectangle(c(as.vector(extent(gadm0))[1], as.vector(extent(gadm0))[3], as.vector(extent(gadm0))[2], as.vector(extent(gadm0))[4]))

GHSSMOD2015 = ee$Image("JRC/GHSL/P2016/BUILT_LDSMT_GLOBE_V1")$select('built')

GHSSMOD2015 = GHSSMOD2015$gte(3)

nl19 =  ee$Image("users/giacomofalchetta/ntl_payne_2021")$subtract(0.125)
nl19 = nl19$where(nl19$lt(0.25), ee$Image(0))

GHSSMOD2015_lit <- GHSSMOD2015$mask(nl19$gt(0))

if (paste0("builtup_", countryiso3, ".tif") %in% all_input_files_basename){
  
  GHSSMOD2015 <- raster(find_it(paste0("builtup_", countryiso3, ".tif")))
  
} else {
  
  GHSSMOD2015 <- ee_as_raster(
    image = GHSSMOD2015,
    via = "drive",
    region = geom,
    scale = 500,
    dsn = paste0(processed_folder, "builtup_", countryiso3, ".tif")
  )
  
}


if (paste0("builtup_lit_", countryiso3, ".tif") %in% all_input_files_basename){
  
  GHSSMOD2015_lit <- raster(find_it(paste0("builtup_lit_", countryiso3, ".tif")))
  
} else {
  
  
  GHSSMOD2015_lit <- ee_as_raster(
    image = GHSSMOD2015_lit,
    via = "drive",
    region = geom,
    scale = 500,
    dsn = paste0(processed_folder, "builtup_lit_", countryiso3, ".tif")
  )
  
}

clusters$elrate <-  exact_extract(GHSSMOD2015_lit, clusters, fun="sum") / exact_extract(GHSSMOD2015, clusters, fun="sum")
clusters$elrate <- ifelse(is.na(clusters$elrate), 0, clusters$elrate)

######

# Spread current (residential) consumption

if (paste0("ely_cons_1_km_", countrystudy, ".tif") %in% all_input_files_basename){
  
  res_rf <- raster(find_it(paste0("ely_cons_1_km_", countrystudy, ".tif")))
  
  clusters$current_consumption_kWh <- exact_extract(res_rf, clusters, "sum")
  clusters$current_consumption_kWh <- ifelse(is.na(clusters$current_consumption_kWh ), 0, clusters$current_consumption_kWh)
  
  # readjust
  adj <- sum(clusters$current_consumption_kWh, na.rm=T) / residential_final_demand_tot
  clusters$current_consumption_kWh <- clusters$current_consumption_kWh / adj
  
} else {
  
  
  total <- residential_final_demand_tot
  weights <- rep(1/6, 6)
  
  pop <- raster(find_it("GHS_POP_E2015_GLOBE_R2019A_4326_30ss_V1_0.tif"))
  pop <- crop(pop, extent(gadm0))
  pop <- mask_raster_to_polygon(pop, gadm0)
  raster::values(pop) <- ifelse(is.na(raster::values(pop)), 0, raster::values(pop))
  
  listone <- read.csv(find_it(paste0(countryiso3, "_relative_wealth_index.csv")))
  listone$iso3c <- listone$.id
  listone$.id = NULL
  data <- st_as_sf(as.data.frame(listone), coords=c("longitude", "latitude"), crs=4326) %>% st_transform(3395) %>% st_buffer(2400) %>% st_transform(4326)
  rwi <- rasterize(data, pop, field = data$rwi, fun = max, na.rm = TRUE) # or mean
  rwi <- mask_raster_to_polygon(rwi, gadm0)
  rwi <- rwi + abs(min(raster::values(rwi), na.rm=T))
  
  el_access <- GHSSMOD2015_lit
  el_access <- crop(el_access, extent(gadm0))
  raster::values(el_access) <- ifelse(is.na(raster::values(el_access)), 0, 1)
  el_access <- mask_raster_to_polygon(el_access, gadm0)
  el_access <- projectRaster(el_access, pop, method="ngb")
  
  image1 <- raster(find_it('travel.tif'))
  image1 <- crop(image1, extent(gadm0))
  image1 <- mask_raster_to_polygon(image1, gadm0)
  tt <-projectRaster(image1, pop, method="ngb")
  tt <- -tt 
  tt <- tt - min(raster::values(tt), na.rm=T)
  
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
  
  resources <- fasterize::fasterize(prio, pop, field="resources", fun="first")
  resources <- resources>0
  resources <- mask_raster_to_polygon(resources, gadm0)
  
  # resources (PRIO)
  resources <- raster::distance(projectRaster(resources, crs="+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"))
  resources <- projectRaster(resources, crs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs 
")
  resources <- mask_raster_to_polygon(resources/1000, gadm0)
  resources <- -resources 
  resources <- resources - min(raster::values(resources), na.rm=T)
  
  #
  
  cdds <- stack(find_it("gldas_0p25_deg_cdd_base_T_24C_1970_2018_ann.nc4"))
  
  cdds_l <- list()
  
  for (i in 1:nlayers(cdds)){
    
    cdds_l[[i]] <- crop(cdds[[i]], extent(gadm0))
    
  }
  
  cdds <- stack(cdds_l)
  cdds <- calc(cdds, fun=sum, na.rm=T)
  
  cdds <-projectRaster(cdds, pop, method="ngb")
  
  ##############
  
  covs_1 <- aggregate(pop, fact=200, "sum")
  
  covs_2 <- aggregate(rwi, fact=200, "mean") # try max
  
  covs_2 <- covs_2 + abs(min(raster::values(covs_2), na.rm=T)) + 0.01
  
  covs_3 <- aggregate(el_access, fact=200, "sum")
  
  covs_4 <- aggregate(resources, fact=200, "sum")
  
  covs_5 <- aggregate(tt, fact=200, "mean")
  
  covs_6 <- aggregate(cdds, fact=200, "mean")
  
  
  ###
  
  fine <- pop
  raster::values(fine) <- ifelse(raster::values(fine) == 0, NA, raster::values(fine) )
  fine2 <- rwi
  fine3 <- el_access
  raster::values(fine3) <- ifelse(raster::values(fine3) == 0, NA, raster::values(fine3) )
  resources <- projectRaster(resources, pop)
  
  fine <- stack(fine, fine2, fine3,resources, tt, cdds)
  
  covs <- stack(covs_1, covs_2, covs_3, covs_4, covs_5, covs_6)
  
  ##
  
  begin_disserve <- function(total, covs, weights){
    
    sum_weights <- sum(weights)
    
    covs <- covs / unlist(lapply(as.list(covs), function(X){sum(raster::values(X), na.rm=T)}))
    
    cov_weights <- covs * (weights/sum_weights)
    
    datasum<- stackApply(cov_weights, indices = nlayers(cov_weights), fun = sum)
    
    return(datasum * total)
    
  }
  
  output <- begin_disserve(total, covs, weights)
  
  min_iter <- 2 # Minimum number of iterations
  max_iter <- 5 # Maximum number of iterations
  p_train <- 0.25 # Subsampling of the initial data
  
  res_rf <- dissever(
    coarse = output, # stack of fine resolution covariates
    fine = fine, # coarse resolution raster
    method = "rf", # regression method used for disseveration
    p = p_train, # proportion of pixels sampled for training regression model
    min_iter = min_iter, # minimum iterations
    max_iter = max_iter # maximum iterations
  )
  
  res_gam <- dissever(
    coarse = output, # stack of fine resolution covariates
    fine = fine, # coarse resolution raster
    method = "gamSpline", # regression method used for disseveration
    p = p_train, # proportion of pixels sampled for training regression model
    min_iter = min_iter, # minimum iterations
    max_iter = max_iter # maximum iterations
  )
  
  res_lm <- dissever(
    coarse = output, # stack of fine resolution covariates
    fine = fine, # coarse resolution raster
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
  
  preds <- extractPrediction(list(res_rf$fit, res_gam$fit, res_lm$fit))
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
  
  # Make stack of weighted predictions and compute sum
  l_maps <- list(res_gam$map, res_lm$map, res_rf$map)
  
  ens <- lapply(1:3, function(x) l_maps[[x]] * w[x]) %>%
    stack %>%
    sum
  
  
  res_rf_w <- ens/sum(raster::values(ens), na.rm=T)
  
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


