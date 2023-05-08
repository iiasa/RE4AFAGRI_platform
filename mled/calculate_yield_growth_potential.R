# Extract yield 
# Import all Yield (kg/ha) cropland layers (Default datasets used: MapSPAM)
# NB: when using MapSPAM use harvested area, which accounts for multiple growing seasons per year)

crops_v <- c("barl", "cass", "coco", "cott", "grou", "maiz", "pmil", "smil", "oilp", "pota", "rape", "rice", "sorg", "soyb", "sugb", "sugc", "sunf", "whea", "yams")

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
clusters[a] <- outs2[[X]]

aa <- clusters
aa$geom=NULL
aa$geometry=NULL

clusters[a] <- ifelse(is.na( pull(aa[a])), mean(aa[a], na.rm=T),  pull(aa[a]))

}

#####

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
  clusters[a] <- outs2[[X]] 
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL
  
  clusters[a] <- ifelse(is.na( pull(aa[a])), 0,  pull(aa[a]))
  
}

########################################################################################

if(rownames(scenarios)[scenario]=="baseline"){
  
  yg_potential <- yg_potential[grepl("scen1", basename(yg_potential)) & grepl("2050", basename(yg_potential))]
  yield <- yield[grepl("scen1", basename(yield)) & grepl("2050", basename(yield))]
  
} else if(rownames(scenarios)[scenario]=="improved_access") {
  
  yg_potential <- yg_potential[grepl("scen2", basename(yg_potential)) & grepl("2050", basename(yg_potential))]
  yield <- yield[grepl("scen2", basename(yield)) & grepl("2050", basename(yield))]
  
} else{
  
  yg_potential <- yg_potential[grepl("scen3", basename(yg_potential)) & grepl("2050", basename(yg_potential))]
  yield <- yield[grepl("scen3", basename(yield)) & grepl("2050", basename(yield))]
  
}


yg_potential <- mixedsort(yg_potential)
yg_potential <- lapply(yg_potential, raster)
yg_potential <- stack(yg_potential)
crs(yg_potential) <- as.character(CRS("+init=epsg:4236"))
yg_potential <- mask_raster_to_polygon(yg_potential, st_as_sfc(st_bbox(clusters_voronoi)))

yield <- mixedsort(yield)
yield <- lapply(yield, raster)
yield <- stack(yield)
crs(yield) <- as.character(CRS("+init=epsg:4236"))
yield <- mask_raster_to_polygon(yield, st_as_sfc(st_bbox(clusters_voronoi)))

##############

outs <- lapply(1:nlayers(yg_potential), function(X){  exact_extract(yg_potential[[X]], clusters_voronoi, fun="mean") })
outs2 <- lapply(1:nlayers(yield), function(X){  exact_extract(yield[[X]], clusters_voronoi, fun="mean") })

outs <- Map("/",outs,outs2)

###############################

for (X in 1:length(crops_v)){

  a = paste0("yg_potential_" , crops_v[X])
  clusters[a] <- ifelse(outs[[X]]<1, 1, outs[[X]]) 
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL
  
  clusters[a] <- ifelse(is.na( pull(aa[a])), mean(pull(aa[a]), na.rm=T),  pull(aa[a]))
}

####

crops_v <- intersect(crops_v, energy_crops[,1])

for (timestep in planning_year){
  
  for (crop in crops_v){
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
  
  clusters[paste0("yg_potential_" , crop, "_", timestep)] = pull((aa[paste0("Y_" ,  crop, "_r")] * aa[paste0("A_" ,  crop, "_r")]) * (aa[paste0("yg_potential_" ,  crop)] * scenarios$irrigated_cropland_share_target[scenario] * demand_growth_weights[match(timestep, planning_year)]))
  
  
  }}

