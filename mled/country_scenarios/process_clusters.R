rm(list=ls())
gc()

# Task 12.2 - Integration of Modelling Infrastructure -> data_repository

library(raster)
library(sf)
library(devtools)
devtools::install_github('jgcri/rgis')
library(rgis)
library(tidyverse)
library(stars)
library(exactextractr)

#####################

path = "F:/Il mio Drive/MLED_database/"

setwd(path)

setwd("input_folder/country_studies")

###

template <- read_sf("zambia/mled_inputs/Zambia_clusters/clusters_Zambia_GRID3_above5population.gpkg")

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
# ethopia

clusters <- read_sf("ethiopia/Ethiopia_Settlement_Extents_Version_01.01.geojson")

clusters <- dplyr::select(clusters, colnames(clusters)[colnames(clusters) %in% colnames(template)])

#"type_1"   ??

# pop_start_un

un_pop <- 120000000  
ele_rate =  0.23 
urb_rate =   0.176

clusters$pop_start_un <- clusters$population * (un_pop / sum(clusters$population, na.rm=T))

pop <- raster("ethiopia/eth_ppp_2020_constrained.tif")
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
ntl <- list.files(pattern="VNL", full.names = T, recursive = T)

# mean to see if elec_status >0
ntl_s <- raster(ntl[[1]])

ntl_s <- crop(ntl_s, extent(clusters))

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

#####

# calibrate electrification rate
electrification_rate_modelled <- sum(clusters$elecpop_start_un, na.rm=T) / sum(clusters$pop_start_un, na.rm=T)
electrification_rate_adjustment_factor = ele_rate / electrification_rate_modelled
clusters$elecpop_start_un = clusters$elecpop_start_un * electrification_rate_adjustment_factor

electrification_rate_modelled <- sum(clusters$elecpop_start_worldpop, na.rm=T) / sum(clusters$pop_start_worldpop, na.rm=T)
electrification_rate_adjustment_factor = ele_rate / electrification_rate_modelled
clusters$elecpop_start_worldpop = clusters$elecpop_start_worldpop * electrification_rate_adjustment_factor

electrification_rate_modelled <- sum(clusters$elec_pop, na.rm=T) / sum(clusters$population, na.rm=T)
electrification_rate_adjustment_factor = ele_rate / electrification_rate_modelled
clusters$elec_pop = clusters$elec_pop * electrification_rate_adjustment_factor


# isurban 

clusters = dplyr::arrange(clusters, -population)

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

write_sf(clusters, "ethiopia/clusters_Ethiopia_GRID3_above5population.gpkg")

