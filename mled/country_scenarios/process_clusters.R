rm(list=ls())
gc()

# Task 12.2 - Integration of Modelling Infrastructure -> data_repository

library(raster)
library(sf)
library(rgis)
library(tidyverse)
library(stars)
library(exactextractr)

#####################

setwd("F:/Il mio Drive/MLED_database/input_folder/country_studies")

rasterOptions(tmpdir = "L:/Falchetta")
write("TMP = 'L:/Falchetta", file=file.path(Sys.getenv('R_USER'), '.Renviron'))

template <- read_sf("F:/Il mio Drive/MLED_database/input_folder/country_studies/zambia/mled_inputs/Zambia_clusters/clusters_Zambia_GRID3_above5population.gpkg")
# 
# template <- template[c(1:10),]
# gc()
# 
# colnames(template)

# > colnames(template)
# [1] "adm1_name"              "adm2_name"              "country"                "population"             "type_1"                
# [6] "nightlight"             "elecpop"                "id"                     "area"                   "elecperc"              
# [11] "isurban"                "pop_start_un"           "elecpop_start_un"       "pop_start_worldpop"     "elecpop_start_worldpop"
# [16] "geom"                  


###########
# rwanda

clusters <- read_sf("rwanda/GRID3_Rwanda_Settlements.geojson")

clusters <- dplyr::select(clusters, colnames(clusters)[colnames(clusters) %in% colnames(template)])

#"type_1"   ??

# pop_start_un

un_pop <- 13600000  

clusters$pop_start_un <- clusters$population * (un_pop / sum(clusters$population, na.rm=T))

pop <- raster("rwanda/rwa_ppp_2020_UNadj_constrained.tif")
clusters$pop_start_worldpop <- exact_extract(pop, clusters, "sum", max_cells_in_memory= 1e9 )


clusters$id <- 1:nrow(clusters)

clusters <- st_transform(clusters, 3395)
clusters <- st_make_valid(clusters)
clusters$area <- as.numeric(st_area(clusters)) / 1e6
clusters <- st_transform(clusters, 4326)


# # remove clusters with less than 5 pop
# 
clusters <- filter(clusters, pop_start_un>5)

# 
# # v2.1 filtered colorado school of mines night lights up to 2020 -> median
# 
ntl <- list.files(path="H:/ECIP/Falchetta", pattern="VNL", full.names = T)

# mean to see if elec_status >0
ntl_s <- raster(ntl[[1]])

ntl_s <- mask_raster_to_polygon(ntl_s, clusters)

clusters$nightlight <- exact_extract(ntl_s, clusters, "mean", max_cells_in_memory= 1e9 )
clusters$nightlight <- ifelse(is.na(clusters$nightlight ), 0, clusters$nightlight )

pop <- raster::aggregate(pop, fact=5, fun="sum")
pop <- projectRaster(pop, ntl_s)
raster::values(ntl_s) <- ifelse(is.na(raster::values(ntl_s)), 0, raster::values(ntl_s))
raster::values(pop) <- ifelse(is.na(raster::values(pop)), 0, raster::values(pop))

clusters$elecperc <- clusters$elrate <- exact_extract(ntl_s>0, clusters, "weighted_mean", weights=pop, max_cells_in_memory= 1e9 )

clusters$elec_pop <- exact_extract(ntl_s, clusters, "sum", max_cells_in_memory= 1e9 )
clusters$elecpop_start_un <- clusters$elecperc * clusters$pop_start_un
clusters$elecpop_start_worldpop <- clusters$elecperc * clusters$pop_start_worldpop

# isurban

clusters = dplyr::arrange(clusters, -population)

urb_rate =   0.176

i = 1

clusters$isurban = 0

repeat{
  
  clusters[i,"isurban"] = 1
  
  urb_rate_est = sum( clusters$population[clusters$isurban==1], na.rm=T) / sum(clusters$population, na.rm=T)
  
  i = i + 1
  
  if (urb_rate_est >= urb_rate) break
}

clusters = dplyr::arrange(clusters, id)

# split big big clusters in very dense areas using administrative units

write_sf(clusters, "rwanda/clusters_Rwanda_GRID3_above5population.gpkg")


###########
# zimbabwe

rm(list=ls())
template <- read_sf("F:/Il mio Drive/MLED_database/input_folder/country_studies/zambia/mled_inputs/Zambia_clusters/clusters_Zambia_GRID3_above5population.gpkg")

clusters <- read_sf("zimbabwe/GRID3_Zimbabwe_Settlement_Extents%2C_Version_01.01..geojson")
clusters <- dplyr::select(clusters, colnames(clusters)[colnames(clusters) %in% colnames(template)])

#"type_1"   ??

# pop_start_un

un_pop <- 16320537  

clusters$pop_start_un <- clusters$population * (un_pop / sum(clusters$population, na.rm=T))

pop <- raster("zimbabwe/zwe_ppp_2020_UNadj_constrained.tif")
clusters$pop_start_worldpop <- exact_extract(pop, clusters, "sum", max_cells_in_memory= 1e9 )


clusters$id <- 1:nrow(clusters)

clusters <- st_transform(clusters, 3395)
clusters <- st_make_valid(clusters)
clusters$area <- as.numeric(st_area(clusters)) / 1e6
clusters <- st_transform(clusters, 4326)


# # remove clusters with less than 5 pop
# 
clusters <- filter(clusters, pop_start_un>5)

# 
# # v2.1 filtered colorado school of mines night lights up to 2020 -> median
# 
ntl <- list.files(path="H:/ECIP/Falchetta", pattern="VNL", full.names = T)

# mean to see if elec_status >0
ntl_s <- raster(ntl[[1]])

ntl_s <- mask_raster_to_polygon(ntl_s, clusters)

clusters$nightlight <- exact_extract(ntl_s, clusters, "mean", max_cells_in_memory= 1e9 )
clusters$nightlight <- ifelse(is.na(clusters$nightlight ), 0, clusters$nightlight )

pop <- raster::aggregate(pop, fact=5, fun="sum")
pop <- projectRaster(pop, ntl_s)
raster::values(ntl_s) <- ifelse(is.na(raster::values(ntl_s)), 0, raster::values(ntl_s))
raster::values(pop) <- ifelse(is.na(raster::values(pop)), 0, raster::values(pop))

clusters$elecperc <- clusters$elrate <- exact_extract(ntl_s>0, clusters, "weighted_mean", weights=pop, max_cells_in_memory= 1e9 )

clusters$elec_pop <- exact_extract(ntl_s, clusters, "sum", max_cells_in_memory= 1e9 )
clusters$elecpop_start_un <- clusters$elecperc * clusters$pop_start_un
clusters$elecpop_start_worldpop <- clusters$elecperc * clusters$pop_start_worldpop

# isurban

clusters = dplyr::arrange(clusters, -population)

urb_rate =   0.32

i = 1

clusters$isurban = 0

repeat{
  
  clusters[i,"isurban"] = 1
  
  urb_rate_est = sum( clusters$population[clusters$isurban==1], na.rm=T) / sum(clusters$population, na.rm=T)
  
  i = i + 1
  
  if (urb_rate_est >= urb_rate) break
}

clusters = dplyr::arrange(clusters, id)

# split big big clusters in very dense areas using administrative units

write_sf(clusters, "zimbabwe/clusters_Zimbabwe_GRID3_above5population.gpkg")



###########
# nigeria

rm(list=ls())
template <- read_sf("F:/Il mio Drive/MLED_database/input_folder/country_studies/zambia/mled_inputs/Zambia_clusters/clusters_Zambia_GRID3_above5population.gpkg")

clusters <- read_sf("nigeria/GRID3_Nigeria_Settlement_Extents_Version_01.02..shp")
clusters <- dplyr::select(clusters, colnames(clusters)[colnames(clusters) %in% colnames(template)])

#"type_1"   ??

# pop_start_un

un_pop <- 218541212  

clusters$pop_start_un <- clusters$population * (un_pop / sum(clusters$population, na.rm=T))

pop <- raster("nigeria/NGA_population_v2_0_gridded_WorldPop_GRID3.tif")
clusters$pop_start_worldpop <- exact_extract(pop, clusters, "sum", max_cells_in_memory= 1e9 )


clusters$id <- 1:nrow(clusters)

clusters <- st_transform(clusters, 3395)
clusters <- st_make_valid(clusters)
clusters$area <- as.numeric(st_area(clusters)) / 1e6
clusters <- st_transform(clusters, 4326)


# # remove clusters with less than 5 pop
# 
clusters <- filter(clusters, pop_start_un>5)

# 
# # v2.1 filtered colorado school of mines night lights up to 2020 -> median
# 
ntl <- list.files(path="H:/ECIP/Falchetta", pattern="VNL", full.names = T)

# mean to see if elec_status >0
ntl_s <- raster(ntl[[1]])

ntl_s <- mask_raster_to_polygon(ntl_s, clusters)

clusters$nightlight <- exact_extract(ntl_s, clusters, "mean", max_cells_in_memory= 1e9 )
clusters$nightlight <- ifelse(is.na(clusters$nightlight ), 0, clusters$nightlight )

pop <- raster::aggregate(pop, fact=5, fun="sum")
pop <- projectRaster(pop, ntl_s)
raster::values(ntl_s) <- ifelse(is.na(raster::values(ntl_s)), 0, raster::values(ntl_s))
raster::values(pop) <- ifelse(is.na(raster::values(pop)), 0, raster::values(pop))

clusters$elecperc <- clusters$elrate <- exact_extract(ntl_s>0, clusters, "weighted_mean", weights=pop, max_cells_in_memory= 1e9 )

clusters$elec_pop <- exact_extract(ntl_s, clusters, "sum", max_cells_in_memory= 1e9 )
clusters$elecpop_start_un <- clusters$elecperc * clusters$pop_start_un
clusters$elecpop_start_worldpop <- clusters$elecperc * clusters$pop_start_worldpop

# isurban

clusters = dplyr::arrange(clusters, -population)

urb_rate =   0.53

i = 1

clusters$isurban = 0

repeat{
  
  clusters[i,"isurban"] = 1
  
  urb_rate_est = sum( clusters$population[clusters$isurban==1], na.rm=T) / sum(clusters$population, na.rm=T)
  
  i = i + 1
  
  if (urb_rate_est >= urb_rate) break
}

clusters = dplyr::arrange(clusters, id)

# split big big clusters in very dense areas using administrative units

write_sf(clusters, "nigeria/clusters_Nigeria_GRID3_above5population.gpkg")

###########
# kenya

rm(list=ls())
template <- read_sf("F:/Il mio Drive/MLED_database/input_folder/country_studies/zambia/mled_inputs/Zambia_clusters/clusters_Zambia_GRID3_above5population.gpkg")

clusters <- read_sf("kenya/GRID3_Kenya_Settlement_Extents_2C_Version_01.01.geojson")
clusters <- dplyr::select(clusters, colnames(clusters)[colnames(clusters) %in% colnames(template)])

#"type_1"   ??

# pop_start_un

un_pop <- 54027487  

clusters$pop_start_un <- clusters$population * (un_pop / sum(clusters$population, na.rm=T))

pop <- raster("kenya/KEN_population_v1_0_gridded.tif")
clusters$pop_start_worldpop <- exact_extract(pop, clusters, "sum", max_cells_in_memory= 1e9 )


clusters$id <- 1:nrow(clusters)

clusters <- st_transform(clusters, 3395)
clusters <- st_make_valid(clusters)
clusters$area <- as.numeric(st_area(clusters)) / 1e6
clusters <- st_transform(clusters, 4326)


# # remove clusters with less than 5 pop
# 
clusters <- filter(clusters, pop_start_un>5)

# 
# # v2.1 filtered colorado school of mines night lights up to 2020 -> median
# 
ntl <- list.files(path="H:/ECIP/Falchetta", pattern="VNL", full.names = T)

# mean to see if elec_status >0
ntl_s <- raster(ntl[[1]])

ntl_s <- mask_raster_to_polygon(ntl_s, clusters)

clusters$nightlight <- exact_extract(ntl_s, clusters, "mean", max_cells_in_memory= 1e9 )
clusters$nightlight <- ifelse(is.na(clusters$nightlight ), 0, clusters$nightlight )

pop <- raster::aggregate(pop, fact=5, fun="sum")
pop <- projectRaster(pop, ntl_s)
raster::values(ntl_s) <- ifelse(is.na(raster::values(ntl_s)), 0, raster::values(ntl_s))
raster::values(pop) <- ifelse(is.na(raster::values(pop)), 0, raster::values(pop))

clusters$elecperc <- clusters$elrate <- exact_extract(ntl_s>0, clusters, "weighted_mean", weights=pop, max_cells_in_memory= 1e9 )

clusters$elec_pop <- exact_extract(ntl_s, clusters, "sum", max_cells_in_memory= 1e9 )
clusters$elecpop_start_un <- clusters$elecperc * clusters$pop_start_un
clusters$elecpop_start_worldpop <- clusters$elecperc * clusters$pop_start_worldpop

# isurban

clusters = dplyr::arrange(clusters, -population)

urb_rate =   0.28

i = 1

clusters$isurban = 0

repeat{
  
  clusters[i,"isurban"] = 1
  
  urb_rate_est = sum( clusters$population[clusters$isurban==1], na.rm=T) / sum(clusters$population, na.rm=T)
  
  i = i + 1
  
  if (urb_rate_est >= urb_rate) break
}

clusters = dplyr::arrange(clusters, id)

# split big big clusters in very dense areas using administrative units

write_sf(clusters, "kenya/clusters_Kenya_GRID3_above5population.gpkg")

