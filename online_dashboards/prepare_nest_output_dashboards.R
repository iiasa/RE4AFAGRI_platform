# prepare NEST output for dashboards

library(tidyverse)
library(sf)
library(countrycode)
library(googledrive)

googledrive::drive_auth(email="giacomo.falchetta@unive.it")

setwd("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform") # path of the cloned M-LED GitHub repository

for (ctr in "zambia"){
  
#############

nest_r1 <- read.csv(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/online_dashboards/NEST outputs/MESSAGEix_", countrycode(ctr, 'country.name', 'iso2c'), "_MLED_baseline_nexus_full_leap-re.csv"))

nest_r2 <- read.csv(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/online_dashboards/NEST outputs/MESSAGEix_", countrycode(ctr, 'country.name', 'iso2c'), "_MLED_improved_nexus_full_leap-re.csv"))

nest_r3 <- read.csv(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/online_dashboards/NEST outputs/MESSAGEix_", countrycode(ctr, 'country.name', 'iso2c'), "_MLED_ambitious_nexus_full_leap-re.csv"))

nest_r <- bind_rows(nest_r1, nest_r2, nest_r3)

###########

sf <- read_sf(paste0("F:/Il mio Drive/MLED_database/input_folder/country_studies/", ctr, "/mled_inputs/", str_to_title(ctr), "_NEST_delineation/", "/", str_to_title(ctr), "_NEST_delineation.shp"))
 
nest_r$scenario <- ifelse(nest_r$scenario=="MLED_improved_nexus_full", "improved_access", ifelse(nest_r$scenario=="MLED_baseline_nexus_full", "baseline", "ambitious_development"))

nest_r$subannual <- ifelse(nest_r$subannual=="year", "Yearly", nest_r$subannual)

sf$region_m <- paste0("B", sf$BCU)
nest_r$region_m <- sub("\\|.*", "", nest_r$region)

################

nest_r_1 <- filter(nest_r, variable=="Capacity Additions|Infrastructure|Water")
nest_r_1 <- group_by(nest_r_1, region_m, variable, year, scenario, subannual) %>% dplyr::summarise(value=sum(value, na.rm=T))
nest_r_1 $variable = "water_infra_volume_km3_yr"
nest_r_1$value <- nest_r_1$value*1000
nest_r_1 <- nest_r_1 %>% ungroup() %>% tidyr::complete(variable, scenario, subannual, year, region_m)
nest_r_1 <- nest_r_1 %>% dplyr::group_by(variable, scenario, subannual, year) %>% dplyr::mutate(value=ifelse(is.na(value), sum(na.omit(value))/length(unique(sf$region_m)), value))
nest_r_1 <- pivot_wider(nest_r_1, names_from = c("variable", "scenario", "subannual", "year"), names_sep = "_",
                        values_from = value)

nest_r_2 <- filter(nest_r, variable=="Investment|Infrastructure|Water")
nest_r_2 <- group_by(nest_r_2, region_m, variable, year, scenario, subannual) %>% dplyr::summarise(value=sum(value, na.rm=T))
nest_r_2 $variable = "water_infr_invest_bn"
nest_r_2$value <- nest_r_2$value*1000
nest_r_2 <- nest_r_2 %>% ungroup() %>% tidyr::complete(variable, scenario, subannual, year, region_m)
nest_r_2 <- nest_r_2 %>% dplyr::group_by(variable, scenario, subannual, year) %>% dplyr::mutate(value=ifelse(is.na(value), sum(na.omit(value))/length(unique(sf$region_m)), value))
nest_r_2 <- pivot_wider(nest_r_2, names_from = c("variable", "scenario", "subannual", "year"), names_sep = "_",
                        values_from = value)

nest_r_5 <- filter(nest_r, variable=="Price|Drinking Water")
nest_r_5 <- group_by(nest_r_5, region_m, variable, year, scenario, subannual) %>% dplyr::summarise(value=mean(value, na.rm=T))
nest_r_5 $variable = "drinking_water_price_usd_m3"
nest_r_5 <- nest_r_5 %>% ungroup() %>% tidyr::complete(variable, scenario, subannual, year)
nest_r_5 <- pivot_wider(nest_r_5, names_from = c("variable", "scenario", "subannual", "year"), names_sep = "_",
                        values_from = value)

nest_r_6 <- filter(nest_r, grepl("Water Withdrawal",  variable))
nest_r_6$variable <- gsub("\\|", "_", nest_r_6$variable)
nest_r_6 <- group_by(nest_r_6, region_m, variable, year, scenario, subannual) %>% dplyr::summarise(value=sum(value, na.rm=T))
nest_r_6$variable = paste0(ifelse(gsub("Water Withdrawal", "", nest_r_6$variable)=="", "total", gsub("Water Withdrawal_", "", nest_r_6$variable)), "_km3_yr")
nest_r_6$variable <- gsub(" ", "_", nest_r_6$variable)
nest_r_6 <- dplyr::filter(nest_r_6, variable %in% paste0(c("total", "Energy_techs_&_Irrigation", "Industrial_Water_Unconnected", "Irrigation", "Municipal_Water", "Electricity_Hydro"), "_", "km3_yr"))
nest_r_6$variable = paste0("water_withdrawal_", nest_r_6$variable)
nest_r_6 <- nest_r_6 %>% ungroup() %>% tidyr::complete(variable, scenario, subannual, year, region_m)
nest_r_6 <- nest_r_6 %>% dplyr::group_by(variable, scenario, subannual, year) %>% dplyr::mutate(value=ifelse(is.na(value), sum(na.omit(value))/length(unique(sf$region_m)), value))

nest_r_6 <- nest_r_6 %>% dplyr::group_by(region_m, scenario, subannual, year) %>% dplyr::mutate(value=ifelse(grepl("total", variable), sum(value[!grepl("total", variable)], na.rm=T), value))


nest_r_6 <- pivot_wider(nest_r_6, names_from = c("variable", "scenario", "subannual", "year"), names_sep = "_",
                        values_from = value)

nest_r_7 <- filter(nest_r, grepl("Water Extraction",  variable))
nest_r_7$variable <- gsub("\\|", "_", nest_r_7$variable)
nest_r_7 <- group_by(nest_r_7, region_m, variable, year, scenario, subannual) %>% dplyr::summarise(value=sum(value, na.rm=T))
nest_r_7$variable = paste0(ifelse(gsub("Water Extraction", "", nest_r_7$variable)=="", "total", gsub("Water Extraction_", "", nest_r_7$variable)), "_km3_yr")
nest_r_7$variable <- gsub(" ", "_", nest_r_7$variable)
nest_r_7$variable = paste0("water_extraction_", nest_r_7$variable)
nest_r_7 <- nest_r_7 %>% ungroup() %>% tidyr::complete(variable, scenario, subannual, year, region_m)
nest_r_7 <- nest_r_7 %>% dplyr::group_by(variable, scenario, subannual, year) %>% dplyr::mutate(value=ifelse(is.na(value), sum(na.omit(value))/length(unique(sf$region_m)), value))

nest_r_7 <- nest_r_7 %>% dplyr::group_by(region_m, scenario, subannual, year) %>% dplyr::mutate(value=ifelse(grepl("total", variable), sum(value[!grepl("total", variable)], na.rm=T), value))

nest_r_7 <- pivot_wider(nest_r_7, names_from = c("variable", "scenario", "subannual", "year"), names_sep = "_",
                        values_from = value)

################

nest_r_m <- Reduce(function(dtf1, dtf2) merge(dtf1, dtf2, by = "region_m"), list(nest_r_1, nest_r_2, nest_r_3, nest_r_4, nest_r_5, nest_r_6, nest_r_7))

sf::sf_use_s2(F)

sf_z <- sf %>% summarise()
sf_z$region_m <- ctr

sf <- bind_rows(sf, sf_z)

nest_r_m <- merge(nest_r_m, sf, "region_m")

nest_r_m[is.na(nest_r_m)] <- as.numeric(0)

nest_r_m <- st_as_sf(nest_r_m)

########

file.remove(paste0("mled/results/", ctr, "/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS_NEST_added.geojson"))
write_sf(nest_r_m, paste0("mled/results/", ctr, "/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS_NEST_added.geojson"))

ups <- drive_upload(paste0("mled/results/", ctr, "/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS_NEST_added.geojson"), path = as_id("1KgQOdJWW79_Dx1fW8k8sC-6Qta1raVDC")) %>% drive_share_anyone()

#######
#######

nest_r1 <- read.csv(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/online_dashboards/NEST outputs/MESSAGEix_", countrycode(ctr, 'country.name', 'iso2c'), "_MLED_baseline_nexus_full_leap-re.csv"))

nest_r2 <- read.csv(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/online_dashboards/NEST outputs/MESSAGEix_", countrycode(ctr, 'country.name', 'iso2c'), "_MLED_improved_nexus_full_leap-re.csv"))

nest_r3 <- read.csv(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/online_dashboards/NEST outputs/MESSAGEix_", countrycode(ctr, 'country.name', 'iso2c'), "_MLED_ambitious_nexus_full_leap-re.csv"))

nest_r <- bind_rows(nest_r1, nest_r2, nest_r3)

###########

sf <- read_sf(paste0("F:/Il mio Drive/MLED_database/input_folder/country_studies/", ctr, "/mled_inputs/", str_to_title(ctr), "_NEST_delineation/", "/", str_to_title(ctr), "_NEST_delineation.shp"))

nest_r$scenario <- ifelse(nest_r$scenario=="MLED_improved_nexus_full", "improved_access", ifelse(nest_r$scenario=="MLED_baseline_nexus_full", "baseline", "ambitious_development"))

nest_r$subannual <- ifelse(nest_r$subannual=="year", "Yearly", nest_r$subannual)

sf$region_m <- paste0("B", sf$BCU)
nest_r$region_m <- sub("\\|.*", "", nest_r$region)

#############################
#############################
#############################

nest_r_3 <- filter(nest_r, grepl("Investment\\|Energy Supply\\|Electricity",  variable))
nest_r_3 <- group_by(nest_r_3, variable, year, scenario, subannual) %>% dplyr::summarise(value=sum(value, na.rm=T))
nest_r_3$variable = paste0(ifelse(gsub("Investment\\|Energy Supply\\|Electricity\\|", "", nest_r_3$variable)=="Investment|Energy Supply|Electricity", "total", gsub("Investment\\|Energy Supply\\|Electricity\\|", "", nest_r_3$variable)))
nest_r_3 <- filter(nest_r_3, variable!="total")
nest_r_3$value <- nest_r_3$value*1000
nest_r_3 <- nest_r_3 %>% ungroup() %>% tidyr::complete(variable, scenario, subannual, year)
nest_r_3 <- nest_r_3 %>% dplyr::group_by(variable, scenario, subannual, year) %>% dplyr::mutate(value=ifelse(is.na(value),0, value))

write.csv(nest_r_3, paste0("mled/results/", ctr, "/", ctr, "_ely_invest.csv"))

nest_r_4 <- filter(nest_r, grepl("Secondary Energy\\|Electricity",  variable))
nest_r_4 <- group_by(nest_r_4, variable, year, scenario) %>% dplyr::summarise(value=sum(value, na.rm=T))
nest_r_4$variable = paste0(ifelse(gsub("Secondary Energy\\|Electricity\\|", "", nest_r_4$variable)=="Secondary Energy|Electricity", "total", gsub("Secondary Energy\\|Electricity\\|", "", nest_r_4$variable)))
nest_r_4 <- filter(nest_r_4, variable!="total")
nest_r_4$value <- nest_r_4$value * 277.77777777778 #convert to twh
nest_r_4 <- nest_r_4 %>% ungroup() %>% tidyr::complete(variable, scenario, year)
nest_r_4 <- nest_r_4 %>% dplyr::group_by(variable, scenario, year) %>% dplyr::mutate(value=ifelse(is.na(value),0, value))

write.csv(nest_r_4, paste0("mled/results/", ctr, "/", ctr, "_ely_supply.csv"))

}

  