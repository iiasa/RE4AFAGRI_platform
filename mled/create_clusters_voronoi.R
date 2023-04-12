
## This R-script:
##      1) generates voronoi polygons for attaching agricultural land (and the related energy demand) to each population cluster

if (length(grep(paste0("clusters_voronoi_", countrystudy, ".gpkg"), all_input_files_basename))>0){
  
  clusters_voronoi <- read_sf(find_it(paste0("clusters_voronoi_", countrystudy, ".gpkg")))
  st_crs(clusters_voronoi) <- 4326
  clusters_voronoi <- dplyr::select(clusters_voronoi, geom)
  clusters_voronoi <- st_intersection(clusters_voronoi, gadm0)
  
  if (nrow(clusters_voronoi)==nrow(clusters)) {
    
    clusters_voronoi$id <- clusters$id
    
  } else{
    
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
    
    clusters_voronoi$id <- clusters$id
    
    clusters_voronoi <- st_intersection(clusters_voronoi, gadm0)
    
    st_crs(clusters_voronoi) <- 4326
    
    write_sf(clusters_voronoi %>% dplyr::select(id), paste0(input_country_specific, paste0("clusters_voronoi_", countrystudy, ".gpkg")))
    
  }
  
}  else {

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

clusters_voronoi$id <- clusters$id

clusters_voronoi <- st_intersection(clusters_voronoi, gadm0)

st_crs(clusters_voronoi) <- 4326

write_sf(clusters_voronoi %>% dplyr::select(id), paste0(input_country_specific, paste0("clusters_voronoi_", countrystudy, ".gpkg")))

}
