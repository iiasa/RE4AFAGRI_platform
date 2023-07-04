library(sf)
library(gtools)
library(raster)
library(sf)
library(tidyverse)
library(exactextractr)
library(future)
library(future.apply)
plan(multisession, workers = 20) ## Run in parallel on local computer

setwd("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform") # path of the cloned M-LED GitHub repository

clusters <- read_sf("online_dashboards/supporting_files/gadm_410-level_2.gpkg")

###

input_folder <- "F:/Il mio Drive/MLED_database/input_folder/"

watercrop_unit <- "m3"

for (scenario in c("baseline", "improved_access", "ambitious_development")){
  
  print(scenario)

rainfed <- list.files(paste0(input_folder, "watercrop"), full.names = T, pattern = "watergap", recursive=T) %>% .[grepl(ifelse(scenario=="baseline", "scen1", ifelse(scenario=="improved_access", "scen2", "scen3")), .)]

irrigated <- list.files(paste0(input_folder, "watercrop"), full.names = T, pattern = "waterwith", recursive=T) %>% .[grepl(ifelse(scenario=="baseline", "scen1", ifelse(scenario=="improved_access", "scen2", "scen3")), .)]

yield <- list.files(paste0(input_folder, "watercrop"), full.names = T, pattern = "yield_avg_ton", recursive=T) %>% .[grepl(ifelse(scenario=="baseline", "scen1", ifelse(scenario=="improved_access", "scen2", "scen3")), .)]

yg_potential <- list.files(paste0(input_folder, "watercrop"), full.names = T, pattern = "yield_avg_closure", recursive=T) %>% .[grepl(ifelse(scenario=="baseline", "scen1", ifelse(scenario=="improved_access", "scen2", "scen3")), .)]

####

rainfed2 <- str_replace(rainfed, str_extract(rainfed, "[^_]+(?=\\.tif$)"), as.character(match(str_extract(rainfed, "[^_]+(?=\\.tif$)"), month.name)))
rainfed2 <- mixedsort(rainfed2)
rainfed2 <- str_replace(rainfed2, paste0(str_extract(rainfed2, "[^_]+(?=\\.tif$)"), ".tif"), paste0(month.name[as.numeric(str_extract(rainfed2, "[^_]+(?=\\.tif$)"))], ".tif"))

rainfed2 <- lapply(rainfed2, raster)
rainfed2 <- stack(rainfed2)
crs(rainfed2) <- as.character(CRS("+init=epsg:4236"))
rainfed2 <- as.list(rainfed2)

####

rainfed2 <- split(rainfed2,  tolower(unlist(qdapRegex::ex_between(rainfed, "watercrop/", "/20"))))
rainfed <- lapply(rainfed2, stack)

names(rainfed) <- c("barl", "cass", "coco", "cott", "grou", "maiz", "pmil", "smil", "oilp", "pota", "rape", "rice", "sorg", "soyb", "sugb", "sugc", "sunf", "whea", "yams")

# extract total bluewater demand in each cluster

files = list.files(path = paste0(input_folder, "spam_folder/spam2017v2r1_ssa_harv_area.geotiff") , pattern = 'R.tif', full.names = T)
nomi <- tolower(unlist(qdapRegex::ex_between(files, "SSA_H_", "_R.tif")))
files <- lapply(files, raster)
files <- stack(files)
names(files) <- nomi
files <- raster::subset(files, names(rainfed))

# convert crop water need to actualy water need by applying irrigation efficiency factors specific to each crop

crops = readxl::read_xlsx('F:/Il mio Drive/MLED_database/input_folder/country_studies/zambia/mled_inputs/crops_cfs_ndays_months_ZMB.xlsx')

crops_efficiency_irr <- crops[crops$crop %in% names(files),]
crops_efficiency_irr <- crops_efficiency_irr[order(crops_efficiency_irr$crop),]

gc()

# mm to m3 -> 1 mm supplies 0.001 m3 per m^2 of soil

files <- stack(files)

if (watercrop_unit =="mm"){
  rainfed <- future_lapply(1:nlayers(files), FUN=function(X) {stack(rainfed[[X]] * (files[[X]] / crops_efficiency_irr$eta_irr[X]) * 10)}, future.seed = TRUE)
} else{ 
  rainfed <- future_lapply(1:nlayers(files), FUN=function(X) {stack(rainfed[[X]] / crops_efficiency_irr$eta_irr[X])}, future.seed = TRUE)
}

# sum by month and year

planning_year <- seq(2020, 2050, 10)

rainfed_sum <- list()

for (timestep in planning_year){
  for (m in 1:12){
    
    rainfed_sum[[as.character(timestep)]][[m]] <- do.call("sum", c(lapply(1:nlayers(files), function(X){rainfed[[X]][[((match(timestep, planning_year) - 1) * 12) + m]]}), na.rm = TRUE))
    
  }}

####

irrigated2 <- str_replace(irrigated, str_extract(irrigated, "[^_]+(?=\\.tif$)"), as.character(match(str_extract(irrigated, "[^_]+(?=\\.tif$)"), month.name)))
irrigated2 <- mixedsort(irrigated2)
irrigated2 <- str_replace(irrigated2, paste0(str_extract(irrigated2, "[^_]+(?=\\.tif$)"), ".tif"), paste0(month.name[as.numeric(str_extract(irrigated2, "[^_]+(?=\\.tif$)"))], ".tif"))

irrigated2 <- lapply(irrigated2, raster)

irrigated2 <- stack(irrigated2)

crs(irrigated2) <- as.character(CRS("+init=epsg:4236"))
irrigated2 <- as.list(irrigated2)

irrigated2 <- split(irrigated2,  tolower(unlist(qdapRegex::ex_between(irrigated, "watercrop/", "/20"))))
irrigated <- lapply(irrigated2, stack)

names(irrigated) <- c("barl", "cass", "coco", "cott", "grou", "maiz", "pmil", "smil", "oilp", "pota", "rape", "rice", "sorg", "soyb", "sugb", "sugc", "sunf", "whea", "yams")

# extract total bluewater demand in each cluster

files = list.files(path = paste0(input_folder, "spam_folder/spam2017v2r1_ssa_harv_area.geotiff") , pattern = 'I.tif', full.names = T)
nomi <- tolower(unlist(qdapRegex::ex_between(files, "SSA_H_", "_I.tif")))
files <- lapply(files, raster)
files <- stack(files)
names(files) <- nomi
files <- raster::subset(files, names(irrigated))

# convert crop water need to actualy water need by applying irrigation efficiency factors specific to each crop

crops_efficiency_irr <- crops[crops$crop %in% names(files),]
crops_efficiency_irr <- crops_efficiency_irr[order(crops_efficiency_irr$crop),]

gc()

# mm to m3 -> 1 mm supplies 0.001 m3 per m^2 of soil

files <- stack(files)

if (watercrop_unit =="mm"){
  irrigated <- future_lapply(1:nlayers(files), FUN=function(X) {stack(irrigated[[X]] * (files[[X]] / crops_efficiency_irr$eta_irr[X]) * 10)}, future.seed = TRUE)
} else{ 
  irrigated <- future_lapply(1:nlayers(files), FUN=function(X) {stack(irrigated[[X]] / crops_efficiency_irr$eta_irr[X])}, future.seed = TRUE)
}

# sum by month and year

irrigated_sum <- list()

for (timestep in planning_year){
  for (m in 1:12){
    
    irrigated_sum[[as.character(timestep)]][[m]] <- do.call("sum", c(lapply(1:nlayers(files), function(X){irrigated[[X]][[((match(timestep, planning_year) - 1) * 12) + m]]}), na.rm = TRUE))
    
  }
  
  outs <- lapply(1:12, function(i){  exact_extract(rainfed_sum[[match(timestep, planning_year)]][[i]], clusters, "sum")})
  
  outs2 <- lapply(1:12, function(i){  exact_extract(irrigated_sum[[match(timestep, planning_year)]][[i]], clusters, "sum")})
  
  for (i in 1:12){
    
    clusters[paste0('IRREQ_irrigated_total' , "_" , as.character(i), "_", timestep, "_", scenario)] <- outs2[[i]]
    
    clusters[paste0('IRREQ_rainfed_total' , "_" , as.character(i), "_", timestep, "_", scenario)] <- outs[[i]]
    
    
  }
  
  aa <- clusters
  aa$geometry=NULL
  aa$x=NULL
  aa$geom=NULL
  
  clusters[paste0('IRREQ_irrigated' , "_total_Yearly_",  timestep, "_", scenario)] <- rowSums(dplyr::select(aa, starts_with("IRREQ_irrigated_total") & contains(as.character(timestep))& contains(as.character(scenario))))
  
  clusters[paste0('IRREQ_rainfed' , "_total_Yearly_",  timestep, "_", scenario)] <- rowSums(dplyr::select(aa, starts_with("IRREQ_rainfed_total") & contains(as.character(timestep)) & contains(as.character(scenario))))
  
}
  
  ##########################
  ##########################
  ##########################
  
    outs <- exact_extract(stack(rainfed), clusters, "sum")
  
    n <- expand.grid(c("barl", "cass", "coco", "cott", "grou", "maiz", "pmil", "smil", "oilp", "pota", "rape", "rice", "sorg", "soyb", "sugb", "sugc", "sunf", "whea", "yams"), 1:12, planning_year)
    
    n <- arrange(n, Var1, Var3, Var2)
  
    colnames(outs) <- paste0('IRREQ_rainfed' , "_", n$Var1, "_", n$Var2, "_", n$Var3, "_", scenario)
    
    outs2 <- exact_extract(stack(irrigated), clusters, "sum")
  
    colnames(outs2) <- paste0('IRREQ_irrigated' , "_", n$Var1, "_", n$Var2, "_", n$Var3, "_", scenario)
    
    ##########################
    
clusters <- bind_cols(outs, outs2)
  
}

#############

file.remove("watercrop/watercrop_results_for_africawide_dashboard.geojson")
write_sf(clusters, "watercrop/watercrop_results_for_africawide_dashboard.geojson")

