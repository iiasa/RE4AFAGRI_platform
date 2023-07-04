library(sf)
library(tidyverse)
library(googledrive)

googledrive::drive_auth("giacomo.falchetta@unive.it")

#
f <- list.files(path="C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results", pattern="gadm2_with", full.names = T, recursive = T)
f <- f[grepl("gpkg", f)]
f_all <- f[!grepl("ALL_SCENARIOS", f)]

##########################################

for (ctr in ctrs){

f <- f_all[grepl(ctr, f_all)]
  
f_out <- lapply(f, read_sf)

for (i in 1:length(f_out)){
  
  stri0 <- qdapRegex::ex_between(f[i], "loads_", "_tot_lat_d")[[1]]
  # stri1 <- qdapRegex::ex_between(f[i], "ssp", "_")[[1]]
  # stri2 <- qdapRegex::ex_between(f[i], "rcp", "_")[[1]]
  # stri3 <- ifelse(i==1, "_s1", ifelse(i==2, "_s2", "_s3"))

  names(f_out[[i]])[15:(length(names(f_out[[i]]))-1)] <- paste0(names(f_out[[i]])[15:(length(names(f_out[[i]]))-1)], "_", stri0)
  
}

#

for (i in c(2:length(f_out))){
  
  f_out[[i]] <- dplyr::select(f_out[[i]], 15:(length(names(f_out[[i]]))))
  
  st_geometry(f_out[[i]]) <- NULL
  
}

f_out[[1]] <- st_as_sf(f_out[[1]])
f_out_b <- bind_cols(f_out)
sf <- st_as_sf(f_out_b)

#

file.remove(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS_nourls.geojson"))

write_sf(sf, paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS_nourls.geojson"))


#

f_mled <- list.files(path="C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results", pattern="onsset_clusters_with_mled", full.names = T, recursive = T)
f_mled <- f_mled[grepl("gpkg", f_mled)]
f_mled <- f_mled[!grepl("ALL_SCENARIOS", f_mled)]
f_mled <- f_all[grepl(ctr, f_mled)]

f_out_mled <- lapply(f_mled, read_sf)

for (i in 1:length(f_out_mled)){
  
  stri0 <- qdapRegex::ex_between(f_mled[i], "loads_", "_tot_lat_d")[[1]]
  # stri1 <- qdapRegex::ex_between(f_mled[i], "ssp", "_")[[1]]
  # stri2 <- qdapRegex::ex_between(f_mled[i], "rcp", "_")[[1]]
  # stri3 <- ifelse(i==1, "_s1", ifelse(i==2, "_s2", "_s3"))
  
  names(f_out_mled[[i]])[15:(length(names(f_out_mled[[i]]))-1)] <- paste0(names(f_out_mled[[i]])[15:(length(names(f_out_mled[[i]]))-1)], "_", stri0)
  
}

#

for (i in c(2:length(f_out_mled))){
  
  f_out_mled[[i]] <- dplyr::select(f_out_mled[[i]], 15:(length(names(f_out_mled[[i]]))))
  
  st_geometry(f_out_mled[[i]]) <- NULL
  
}

f_out_mled <- bind_cols(f_out_mled)
f_out_mled <- st_as_sf(f_out_mled)

#f_out_mled <- st_join(f_out_mled, sf %>% dplyr::select(NAME_2), st_intersects)

sf_split <- split(f_out_mled, f_out_mled$NAME_2)

up <- vector()

for (i in 1:length(sf_split)){
  
  file.remove(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", gsub("'|/", "-", sf_split[[i]][1,]$NAME_2) , "_clusters_RE4AFAGRI.geojson"))
  
  write_sf(sf_split[[i]][1,], paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", gsub("'|/", "-", sf_split[[i]][1,]$NAME_2) , "_clusters_RE4AFAGRI.geojson"))
  
  ups <- drive_upload(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", gsub("'|/", "-", sf_split[[i]][1,]$NAME_2), "_clusters_RE4AFAGRI.geojson"), path = as_id("1KgQOdJWW79_Dx1fW8k8sC-6Qta1raVDC")) %>% drive_share_anyone()
  
  up[i] <- ups$drive_resource[[1]]$webContentLink 
  
}

#

sf$link <- c(up, up[which(duplicated(sf$NAME_2))]) 

sf <- st_as_sf(sf)

file.remove(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS.geojson"))

write_sf(sf, paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS.geojson"))

}
