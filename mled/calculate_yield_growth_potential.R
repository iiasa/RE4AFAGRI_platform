# Extract yield 
# Import all Yield (kg/ha) cropland layers (Default datasets used: MapSPAM)
# NB: when using MapSPAM use harvested area, which accounts for multiple growing seasons per year)

crops_v <- c("barl", "cass", "coco", "cott", "grou", "maiz", "pmil", "smil", "oilp", "pota", "rape", "rice", "sorg", "soyb", "sugb", "sugc", "sunf", "whea", "yams")

files <- list.files(path=paste0(input_folder, "spam_folder/spam2017v2r1_ssa_yield.geotiff"), pattern="R.tif", full.names=T)
#files <- files[grepl(paste(energy_crops[,1], collapse="|") , files, ignore.case =T)]

files2 = list.files(path = paste0(input_folder, "spam_folder/spam2017v2r1_ssa_harv_area.geotiff") , pattern = 'R.tif', full.names = T)
#files2 <- files2[grepl(paste(energy_crops[,1], collapse="|") , files2, ignore.case =T)]

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

###########

outs <- future_lapply(1:nlayers(files2), function(X){  exact_extract(files2[[X]], clusters_voronoi, fun="sum")})

outs2 <- future_lapply(1:nlayers(files), function(X){  exact_extract(files[[X]], clusters_voronoi, fun="mean")})

for (X in 1:nlayers(files)){
  
  a = paste0("A_" , names(files)[X], "_r")
  clusters[a] <- outs[[X]]
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL
  
  clusters[a] <- ifelse(is.na( pull(aa[a])), 0,  pull(aa[a]))
  
  a = paste0("Y_" ,  names(files)[X], "_r")
  clusters[a] <- outs2[[X]] / 1000
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL
  
  clusters[a] <- ifelse(is.na( pull(aa[a])), mean(aa[a], na.rm=T),  pull(aa[a]))
  
}

#####

files <- list.files(path=paste0(input_folder, "spam_folder/spam2017v2r1_ssa_yield.geotiff"), pattern="I.tif", full.names=T)
#files <- files[grepl(paste(energy_crops[,1], collapse="|") , files, ignore.case =T)]

files2 = list.files(path = paste0(input_folder, "spam_folder/spam2017v2r1_ssa_harv_area.geotiff") , pattern = 'I.tif', full.names = T)
#files2 <- files2[grepl(paste(energy_crops[,1], collapse="|") , files2, ignore.case =T)]

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

outs <- future_lapply(1:nlayers(files2), function(X){  exact_extract(files2[[X]], clusters_voronoi, fun="sum")})

outs2 <- future_lapply(1:nlayers(files), function(X){  exact_extract(files[[X]], clusters_voronoi, fun="mean")})


for (X in 1:nlayers(files)){
  
  a = paste0("A_" , names(files)[X], "_i")
  clusters[a] <- outs[[X]] 
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL
  
  clusters[a] <- ifelse(is.na( pull(aa[a])), 0,  pull(aa[a]))
  
  a = paste0("Y_" ,  names(files)[X], "_i")
  clusters[a] <- outs2[[X]] / 1000
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL
  
}

########################################################################################

for (timestep in planning_year[-length(planning_year)]){
  
  if(rownames(scenarios)[scenario]=="baseline"){
    
    yg_potential_s <- yield[grepl("scen1", basename(yg_potential)) & grepl(timestep, basename(yg_potential))]
    yield_s <- yield[grepl("scen1", basename(yield)) & grepl(timestep, basename(yield))]
    
  } else if(rownames(scenarios)[scenario]=="improved_access") {
    
    yg_potential_s <- yg_potential[grepl("scen2", basename(yg_potential)) & grepl(timestep, basename(yg_potential))]
    yield_s <- yield[grepl("scen2", basename(yield)) & grepl(timestep, basename(yield))]
    
  } else{
    
    yg_potential_s <- yg_potential[grepl("scen3", basename(yg_potential)) & grepl(timestep, basename(yg_potential))]
    yield_s <- yield[grepl("scen3", basename(yield)) & grepl(timestep, basename(yield))]
    
  }
  
  ####
  
  yg_potential_s <- mixedsort(yg_potential_s)
  yg_potential_s <- lapply(yg_potential_s, raster)
  yg_potential_s <- stack(yg_potential_s)
  crs(yg_potential_s) <- as.character(CRS("+init=epsg:4236"))
  yg_potential_s <- mask_raster_to_polygon(yg_potential_s, st_as_sfc(st_bbox(clusters_voronoi)))
  
  yield_s <- mixedsort(yield_s)
  yield_s <- lapply(yield_s, raster)
  yield_s <- stack(yield_s)
  crs(yield_s) <- as.character(CRS("+init=epsg:4236"))
  yield_s <- mask_raster_to_polygon(yield_s, st_as_sfc(st_bbox(clusters_voronoi)))
  
  ##############
  
  outs <- lapply(1:nlayers(yg_potential_s), function(X){  exact_extract(yg_potential_s[[X]], clusters_voronoi, fun="mean") })
  #outs2 <- lapply(1:nlayers(yield_s), function(X){  exact_extract(yield_s[[X]], clusters_voronoi, fun="mean") })
  
  ###############################
  
  for (X in 1:length(crops_v)){
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
    a = paste0("yg_potential_" , crops_v[X], "_", timestep)
    
    if(rownames(scenarios)[scenario]!="baseline"){
    
    clusters[a] <- outs[[X]] 
    
    } else{
      
      b = paste0("Y_" , crops_v[X], "_r")
      
      clusters[a] <- pull(aa[b]) * 1000
  
    }
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
    clusters[a] <- ifelse(is.na( pull(aa[a])), mean(pull(aa[a]), na.rm=T),  pull(aa[a]))
    
  }}
