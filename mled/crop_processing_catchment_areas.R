
## This R-script:
##      1) if the relative constraint is activated in the main M-LED script, it generates catchment areas within a given travel time (specified in the scenario file) around each city to constrain crop processing to those clusters which are sufficiently close to markets (i.e. cities)
##      2) it generates a new variable identifying crop processing eligible clusters

pop <- population_baseline # gridded population raster of reference

all_facilities <- cities
all_facilities$id <- 1:nrow(all_facilities)

# Prepare the friction layer

function_sens <- function(x){
  a <-(1/mean(x))
  ifelse(a<0, 0, a)
}

#friction <- aggregate(friction, fact=10, fun=function_sens, na.rm=TRUE)## to reduce resolution of orignal friction layer and hasten the process (to the cost of accuracy, of course)

#friction <- raster::aggregate(friction, fact=10, fun=mean)

Tr <- transition(friction, function_sens, 8) # RAM intensive, can be very slow for large areas

saveRDS(Tr, "T_sens.rds")

T.GC <- geoCorrection(Tr)

saveRDS(T.GC, "T.GC_sens.rds")

T.filename <- 'T.rds'

T.GC.filename <- 'T.GC.rds'

#############

if (length(grep(paste0(processed_folder, "clusters_traveltime_processing_", countryiso3, "_", as.character(minutes_cluster),".gpkg"), all_input_files_basename))>0){
  
  clusters_traveltime_processing <- read_sf(find_it(paste0(processed_folder, "clusters_traveltime_processing_", countryiso3, "_", as.character(minutes_cluster),".gpkg")))

} else {


# create catchment areas

functpop <-future_lapply(1:nrow(all_facilities),function(i){
  id_exp = all_facilities[i, ]$id
  xy.matrix <-st_coordinates(all_facilities[i, ])
  servedpop <- accCost(T.GC, xy.matrix)
  servedpop[servedpop>minutes_cluster] <- NA
  servedpop <- trim(servedpop)
  servedpop <- stars::st_as_stars(servedpop)
  servedpop <- st_as_sf(servedpop)
  p = servedpop %>% summarise()
  p = st_sf(p)
  p$id = id_exp
  p
})


for(i in 1:length(functpop)){
  functpop[[i]] <- st_cast(functpop[[i]], "MULTIPOLYGON")
}

clusters_traveltime_processing <-sf::st_as_sf(bind_rows(functpop))

write_sf(clusters_traveltime_processing, paste0(processed_folder, "clusters_traveltime_processing_", countryiso3, "_", as.character(minutes_cluster),".gpkg"))

}

clusters_traveltime_processing <- fasterize(clusters_traveltime_processing, friction, "id")

clusters$suitable_for_local_processing <- exact_extract(clusters_traveltime_processing, clusters, "sum")

clusters$suitable_for_local_processing <- ifelse(clusters$suitable_for_local_processing > 0 & !is.na(clusters$suitable_for_local_processing), 1, 0)

save.image(paste0(processed_folder, "clusters_crop_processing_ca.Rdata"))
