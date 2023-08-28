# MLED - Multi-sectoral Latent Electricity Demand assessment platform
# v0.2 (LEAP_RE)
# 23/01/2023

####
# system parameters

setwd("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled") # path of the cloned M-LED GitHub repository

db_folder = 'F:/Il mio Drive/MLED_database' # path to (or where to download) the M-LED database

email<- "giacomo.falchetta@gmail.com" # NB: need to have previously enabled it to use Google Earth Engine via https://signup.earthengine.google.com

download_data <- F # flag: download the M-LED database? Type "F" if you already have done so previously.

allowparallel=T # allows paralellised processing. considerably shortens run time but requires computer with large CPU cores # (e.g. >=8 cores) and RAM (e.g. >=16 GB)

######################
# country and year

countrystudy <- "zambia" # country to run M-LED on

exclude_countries <- paste("rwanda", "nigeria", "zimbabwe", "kenya", sep="|") # countries in the database files to exclude from the current run

exclude_countries2 <- paste("RWA", "NGA", "ZWE", "KEN", sep="|") # countries in the database files to exclude from the current run


planning_year = seq(2020, 2060, 10) # time steps and horizon year to make projections

######################
# options and constriants 

latent_d_tot <- T # estimate evolution of demand given current (and projected) electricity access rates (if FALSE) OR total LATENT DEMAND (DEMAND If EVERYBODY HAD SUDDEN ACCESS TO ELECTRICITY, if TRUE)

output_hourly_resolution <- F  # produce hourly load curves for each month. if false, produce just monthly and yearly totals. ############ NB: bug-fixing in progress, please leave to F

no_productive_demand_in_small_clusters <- F # remove any type of productive use of energy in clusters below the "pop_threshold_productive_loads" parameter value

buffers_cropland_distance <- T # do not include agricultural loads from cropland distant more than n km (customisable in scenario file) from cluster centroid 

field_size_contraint <- T # consider only small farmland patches (smallholder farming)

process_already_irrigated_crops <- T # crop processing: include energy demand to process yield in already irrigated land

calculate_yg_potential <- T # also estimate yield growth potential thanks to input of irrigation

groundwater_sustainability_contraint <- F # impose limit on groundwater pumping based on monthly recharge

water_tank_storage <- T # water storage is possible

###



repo_folder <- home_repo_folder <- getwd()

#

input_folder = paste0(db_folder , '/input_folder/')
dir.create(file.path(input_folder), showWarnings = FALSE)
processed_folder = paste0(input_folder , '/processed_folder/')
dir.create(file.path(processed_folder), showWarnings = FALSE)
input_country_specific <- paste0(input_folder, "/country_studies/", countrystudy, "/mled_inputs/")
dir.create(file.path(input_country_specific), showWarnings = FALSE)

all_input_files <- list.files(path=input_folder, recursive = T, full.names = T)

all_input_files <- all_input_files[grep(exclude_countries, all_input_files,ignore.case=TRUE, invert = TRUE)]

all_input_files <- all_input_files[grep(exclude_countries2, all_input_files,ignore.case=TRUE, invert = TRUE)]

all_input_files <- all_input_files[grep("\\.ini$|\\.docx$|\\.png$|\\.r$|\\.mat$|r_tmp_|\\.pyc$|\\.pdf$|\\.rds$|\\.rdata$|\\.xml$", all_input_files,ignore.case=TRUE, invert = TRUE)] 

all_input_files <- gsub("//", "/", all_input_files)

all_input_files <- all_input_files[!grepl("PVOUT|groundwater_distance_|slope_|miroc5_landuse|pv_cost|_A.tif|_H.tif|_L.tif", all_input_files)]

all_input_files_sizes <- data.frame(all_input_files)
all_input_files_sizes$size <- file.size(all_input_files_sizes$all_input_files)/1e6

sum(all_input_files_sizes$size)/1e3

all_input_files_basename <- basename(all_input_files)

all_input_files_stub <- gsub("F:/Il mio Drive/MLED_database/", "", all_input_files)
all_input_files_stub <- gsub("//", "/", all_input_files_stub)

#

setwd("F:/Il mio Drive/MLED_database")

sapply(file.path("F:/Il mio Drive/MLED_database_dwnld", dirname(all_input_files_stub)),
       dir.create, recursive = TRUE, showWarnings = FALSE)

#

for (i in 1:length(all_input_files)){
  print(i)
  file.copy(all_input_files[i], gsub("MLED_database", "MLED_database_dwnld", all_input_files[i]))
}

####

