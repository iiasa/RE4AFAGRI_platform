
## This R-script:
##      1) generates voronoi polygons for attaching agricultural land (and the related energy demand) to each population cluster

if (length(grep("clusters_voronoi.gpkg", all_input_files_basename))>0){
  
  clusters_voronoi <- read_sf(find_it("clusters_voronoi.gpkg"))
  st_crs(clusters_voronoi) <- 4326
  clusters_voronoi <- dplyr::select(clusters_voronoi, geom)
  clusters_voronoi <- st_intersection(clusters_voronoi, gadm0)
} 

if (nrow(clusters_voronoi)==nrow(clusters)) {
  
  clusters_voronoi <- clusters_voronoi
  
} else {

clusters_centroids <- st_centroid(clusters)
p <- clusters_centroids

st_voronoi_point <- function(points){
  ## points must be POINT geometry
  if(!all(st_geometry_type(points) == "POINT")){
    stop("Input not  POINT geometries")
  }
  g = st_combine(st_geometry(points)) # make multipoint
  v = st_voronoi(g)
  v = st_collection_extract(v)
  return(v[unlist(st_intersects(p, v))])
}

clusters_voronoi = st_voronoi_point(p)
clusters_voronoi = st_set_geometry(p, clusters_voronoi)
clusters_voronoi <- st_intersection(clusters_voronoi, gadm0)
st_crs(clusters_voronoi) <- 4326

write_sf(clusters_voronoi, paste0(input_country_specific, "clusters_voronoi.gpkg"))

}
