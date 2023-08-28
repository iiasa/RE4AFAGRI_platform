# MLED - Multi-sectoral Latent Electricity Demand assessment platform
# uploader

####
# system parameters

setwd("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled") # path of the cloned M-LED GitHub repository

db_folder = 'F:/Il mio Drive/MLED_database' # path to (or where to download) the M-LED database

email<- "giacomo.falchetta@gmail.com" # NB: need to have previously enabled it to use Google Earth Engine via https://signup.earthengine.google.com

######################
# country and year

ctrs <- c("zambia", "kenya", "rwanda", "zimbabwe", "nigeria", "all") # country(ies) to run M-LED on 

for (ctr in ctrs){
  
  print(ctr)

countrystudy <- ctr # country to run M-LED on

if (ctr!="all"){

exclude_countries <- paste0(setdiff(ctrs, ctr), collapse="|") # countries in the database files to exclude from the current run

exclude_countries2 <- paste0(countrycode::countrycode(setdiff(ctrs, ctr), 'country.name', 'iso3c'), collapse="|") # countries in the database files to exclude from the current run

}

repo_folder <- home_repo_folder <- getwd()

#

input_folder = paste0(db_folder , '/input_folder/')
dir.create(file.path(input_folder), showWarnings = FALSE)
processed_folder = paste0(input_folder , '/processed_folder/')
dir.create(file.path(processed_folder), showWarnings = FALSE)
input_country_specific <- paste0(input_folder, "/country_studies/", countrystudy, "/mled_inputs/")
dir.create(file.path(input_country_specific), showWarnings = FALSE)

all_input_files <- list.files(path=input_folder, recursive = T, full.names = T)

if (ctr!="all"){

all_input_files <- all_input_files[grep(exclude_countries, all_input_files,ignore.case=TRUE, invert = TRUE)]
all_input_files <- all_input_files[grep(exclude_countries2, all_input_files,ignore.case=TRUE, invert = TRUE)]
}

all_input_files <- all_input_files[grep("\\.ini$|\\.docx$|\\.png$|\\.r$|\\.mat$|r_tmp_|\\.pyc$|\\.pdf$|\\.rds$|\\.rdata$|\\.xml$|\\~\\$", all_input_files,ignore.case=TRUE, invert = TRUE)] 

all_input_files <- gsub("//", "/", all_input_files)

all_input_files <- all_input_files[!grepl("PVOUT|pv_cost|_A.tif|_H.tif|_L.tif", all_input_files)]

all_input_files_sizes <- data.frame(all_input_files)
all_input_files_sizes$size <- file.size(all_input_files_sizes$all_input_files)/1e6

sum(all_input_files_sizes$size)/1e3

all_input_files_basename <- basename(all_input_files)

all_input_files_stub <- gsub("F:/Il mio Drive/MLED_database/", "", all_input_files)
all_input_files_stub <- gsub("//", "/", all_input_files_stub)

#

setwd("F:/Il mio Drive/MLED_database")

sapply(file.path(paste0("F:/Il mio Drive/MLED_database_dwnld/", ctr), dirname(all_input_files_stub)),
       dir.create, recursive = TRUE, showWarnings = FALSE)

#

for (i in 1:length(all_input_files)){
  print(i/length(all_input_files))
  file.copy(all_input_files[i], gsub("MLED_database", paste0("MLED_database_dwnld/", ctr), all_input_files[i]))
}}

####

