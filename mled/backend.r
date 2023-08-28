
## This R-script:
##      1) automatically installs and/or loads the required package dependenices for running M-LED
##      2) if required in the main M-LED script, it downloads the entire M-LED database
##      3) it creates an index of all files in the M-LED database and a wrapper function to load them

if (!require("pacman")) install.packages("pacman"); library(pacman)

if (!require("Rcpp")) install.packages("Rcpp", repos="https://rcppcore.github.io/drat"); library(Rcpp)

pacman::p_load(sf, raster, exactextractr, dplyr, readxl, cowplot, ggplot2, scales, tidyr, tidyverse, rgeos, gdalUtils, chron, nngeo, strex, data.table, gdata, FactoMineR, factoextra, maps  , mapdata, maptools, grid, randomForestSRC, countrycode, remotes, stars, gdistance, rgl, rasterVis, qlcMatrix, stars, tvm, gtools, wbstats, stars, patchwork, ggrepel, terra, pbapply, googledrive, nnet, caret, randomForest, beepr, ncdf4, s2, zip, sfsmisc, dissever, gam, lsa, doBy, geojsonio, matrixStats, purrr, future.apply, parallel, doParallel, qdapRegex, geodata, lwgeom)

if (allowparallel==T){

cl <- parallel::makeCluster((floor(detectCores() * 0.25)))
#cl <- parallel::makeCluster(4)
plan(cluster, workers=cl)

future_lapply <- purrr::partial(future.apply::future_lapply, future.seed = TRUE)


} else {
  
  future_lapply <- lapply 
  
}

# exact_extract <- purrr::partial(exactextractr::exact_extract, x=crop(x, extent(y)), max_cells_in_memory = 1e9 )

exact_extract <- purrr::partial(exactextractr::exact_extract, max_cells_in_memory = 1e9 )

tmpDir(create=TRUE)

if (!require("rgis")) remotes::install_github("JGCRI/rgis"); library(rgis)
if (!require("fasterize")) remotes::install_github("ecohealthalliance/fasterize"); library(fasterize)
if (!require("gdalUtils")) remotes::install_github("gearslaboratory/gdalUtils"); library(gdalUtils)

mask_raster_to_polygon <- function (raster_object, polygon) 
{
  if (class(polygon)[[1]] != "sf") 
    polygon <- st_as_sf(polygon)
  r_crs <- st_crs(projection(raster_object))
  polys <- polygon %>% st_transform(crs = r_crs)
  n_lcs <- crop(raster_object, polys) %>% mask(polys)
  return(n_lcs)
}

sf::sf_use_s2(F)

options(future.globals.maxSize= 891289600)

fast_mask <- function(ras = NULL, mask = NULL, inverse = FALSE, updatevalue = NA) {
  
  stopifnot(inherits(ras, "Raster"))
  
  stopifnot(inherits(mask, "Raster") | inherits(mask, "sf"))
  
  stopifnot(raster::compareCRS(ras, mask))
  
  
  ## If mask is a polygon sf, pre-process:
  
  if (inherits(mask, "sf")) {
    
    stopifnot(unique(as.character(sf::st_geometry_type(mask))) %in% c("POLYGON", "MULTIPOLYGON"))
    
    # First, crop sf to raster extent
    sf.crop <- suppressWarnings(sf::st_crop(mask,
                                            y = c(
                                              xmin = raster::xmin(ras),
                                              ymin = raster::ymin(ras),
                                              xmax = raster::xmax(ras),
                                              ymax = raster::ymax(ras)
                                            )))
    sf.crop <- sf::st_cast(sf.crop)
    
    # Now rasterize sf
    mask <- fasterize::fasterize(sf.crop, raster = ras)
    
  }
  
  
  
  if (isTRUE(inverse)) {
    
    ras.masked <- raster::overlay(ras, mask,
                                  fun = function(x, y)
                                  {ifelse(!is.na(y), updatevalue, x)})
    
  } else {
    
    ras.masked <- raster::overlay(ras, mask,
                                  fun = function(x, y)
                                  {ifelse(is.na(y), updatevalue, x)})
    
  }
  
  ras.masked
  
}

ifelse(!dir.exists(file.path(getwd(), "/results")), dir.create(file.path(getwd(), "/results")), FALSE)
ifelse(!dir.exists(file.path(paste0(getwd(), "/results/"), countrystudy)), dir.create(file.path(paste0(getwd(), "/results/"), countrystudy)), FALSE)

###########

repo_folder <- home_repo_folder <- getwd()

if (download_data==T){
  
  write(paste0(timestamp(), "downloading M-LED database"), "log.txt", append=T)
  
  wd_bk <- getwd()
  
  setwd(db_folder)
  
  d <- download.file("https://zenodo.org/record/7908475/files/mled_replication.zip", destfile = "mled_replication.zip")
  unzip("mled_replication.zip")
  file.remove("mled_replication.zip")
  
  db_folder <- paste0(db_folder, "/MLED_database_dwnld/")
  
  setwd(wd_bk)
  
}


#

input_folder = paste0(db_folder , '/input_folder/')
dir.create(file.path(input_folder), showWarnings = FALSE)
processed_folder = paste0(input_folder , '/processed_folder/')
dir.create(file.path(processed_folder), showWarnings = FALSE)
output_figures_folder = paste0(repo_folder , '/output_figures/')
dir.create(file.path(output_figures_folder), showWarnings = FALSE)
input_country_specific <- paste0(input_folder, "/country_studies/", countrystudy, "/mled_inputs/")
dir.create(file.path(input_country_specific), showWarnings = FALSE)

all_input_files <- list.files(path=input_folder, recursive = T, full.names = T)

all_input_files <- all_input_files[grep(exclude_countries, all_input_files,ignore.case=TRUE, invert = TRUE)]

all_input_files <- all_input_files[grep("\\.ini$|\\.docx$|\\.png$|\\.r$|\\.mat$|r_tmp_|\\.pyc$|\\.pdf$|\\.rds$|\\.rdata$|\\.xml$|\\~\\$", all_input_files,ignore.case=TRUE, invert = TRUE)] 

all_input_files <- gsub("//", "/", all_input_files)

all_input_files_basename <- basename(all_input_files)

user.input <- function(prompt) {
    x= readline(prompt)
    return(x)
  }


find_it <- function(X){
  
    out_file <- all_input_files[str_detect(all_input_files_basename, paste0('\\b', X, '\\b'))]
  
  if(length(out_file)>1){
    
    beep()
    print(out_file)
    pick_one <- user.input("Which one: ")
    return(out_file[as.numeric(pick_one)])
    
    } 
  
  if(length(out_file)==0){
    
    beep()
    stop("Cannot find file")

  } else {
  
  return(out_file)

}}
