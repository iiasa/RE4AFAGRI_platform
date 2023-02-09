
crops <- c("barl", "cass", "coco", "cott", "grou", "maiz", "pmil", "smil", "oilp", "pota", "rape", "rice", "sorg", "soyb", "sugb", "sugc", "sunf", "whea", "yams")

yg_potential <- mixedsort(yg_potential)
yg_potential <- lapply(yg_potential, raster)
yg_potential <- stack(yg_potential)
crs(yg_potential) <- as.character(CRS("+init=epsg:4236"))
yg_potential <- mask_raster_to_polygon(yg_potential, st_as_sfc(st_bbox(clusters_voronoi)))

##############

clusters_voronoi <- read_sf(paste0(input_country_specific, "clusters_voronoi.gpkg"))

outs <- lapply(1:nlayers(yg_potential), function(X){  exact_extract(yg_potential[[X]], clusters_voronoi, fun="mean") })

for (X in 1:nlayers(yg_potential)){

  a = paste0("yg_potential_" , crops[X])
  clusters[a] <- outs[[X]]
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL
  
  clusters[a] <- ifelse(is.na( pull(aa[a])), mean(pull(aa[a]), na.rm=T),  pull(aa[a]))
}

####

crops <- intersect(crops, energy_crops[,1])

for (timestep in planning_year){
  
  for (crop in crops){
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
  
  clusters[paste0("yg_potential_" , crop, "_", timestep)] = pull((aa[paste0("Y_" ,  crop, "_r")] * aa[paste0("A_" ,  crop, "_r")]) * (1 + (aa[paste0("yg_potential_" ,  crop)]/100 * scenarios$irrigated_cropland_share_target[scenario] * demand_growth_weights[match(timestep, planning_year)])))
  
  
  }}

clusters <- dplyr::select(clusters, -paste0("yg_potential_" , crops))

save.image(paste0(processed_folder, "last_module_checkpoint.Rdata"))
