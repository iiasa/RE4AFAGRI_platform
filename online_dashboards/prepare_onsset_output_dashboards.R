# prepare OnSSET output for dashboards

library(tidyverse)
library(sf)
library(countrycode)

setwd("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform") # path of the cloned M-LED GitHub repository

for (ctr in ctrs){

#############

onsset_r <- read.csv(paste0("onsset/results/onsset_full_results/baseline_", tolower(countrycode(ctr, 'country.name', 'iso2c')), "-2-0_0_0_0_0_0.csv"))
#onsset_r[onsset_r==99] <- NA

onsset_r <- st_as_sf(onsset_r, coords=c("X_deg", "Y_deg"), crs=4326)

sf <- read_sf(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS.geojson")) %>% dplyr::select(NAME_2)

onsset_r <- st_join(onsset_r, sf)

###

colnames(onsset_r)

onsset_r$geometry <- NULL

library(spatstat)

onsset_r$Grid2030_share <- onsset_r$Grid2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r$SA_PV2030_share <- onsset_r$SA_PV2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r$MG_Hydro2030_share <- onsset_r$MG_Hydro2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r$MG_PV_Hybrid2030_share <- onsset_r$MG_PV_Hybrid2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r$MG_Wind_Hybrid2030_share <- onsset_r$MG_Wind_Hybrid2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r_s_baseline_2030 <- onsset_r %>% dplyr::group_by(NAME_2) %>% 
  dplyr::summarise(new_capacity_2030_baseline=sum(NewCapacity2030, na.rm=T), tot_inv_2030_baseline = sum(InvestmentCost2030, na.rm=T), inv_cap_2030_baseline = weighted.mean(InvestmentCapita2030, NewConnections2030, na.rm=T), min_cost_tech_2030_baseline=weighted.median(MinimumOverallCode2030, NewConnections2030, na.rm=T), min_lcoe_2030_baseline=weighted.mean(MinimumOverallLCOE2030, NewConnections2030, na.rm=T), sh_grid_2030_baseline = weighted.mean(Grid2030_share, NewConnections2030, na.rm=T), sh_SA_PV_2030_baseline = weighted.mean(SA_PV2030_share, NewConnections2030, na.rm=T), sh_MG_Hydro_2030_baseline = weighted.mean(MG_Hydro2030_share, NewConnections2030, na.rm=T), sh_MG_PV_2030_baseline = weighted.mean(MG_PV_Hybrid2030_share, NewConnections2030, na.rm=T), sh_MG_Wind_2030_baseline = weighted.mean(MG_Wind_Hybrid2030_share, NewConnections2030, na.rm=T), ElecStatusIn2030_baseline = weighted.mean(ElecStatusIn2030, Pop2030, na.rm=T))

onsset_r$Grid2060_share <- onsset_r$Grid2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r$SA_PV2060_share <- onsset_r$SA_PV2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r$MG_Hydro2060_share <- onsset_r$MG_Hydro2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r$MG_PV_Hybrid2060_share <- onsset_r$MG_PV_Hybrid2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r$MG_Wind_Hybrid2060_share <- onsset_r$MG_Wind_Hybrid2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r_s_baseline_2060 <- onsset_r %>% dplyr::group_by(NAME_2) %>% 
  dplyr::summarise(new_capacity_2060_baseline=sum(NewCapacity2060, na.rm=T), tot_inv_2060_baseline = sum(InvestmentCost2060, na.rm=T), inv_cap_2060_baseline = weighted.mean(InvestmentCapita2060, NewConnections2060, na.rm=T), min_cost_tech_2060_baseline=weighted.median(MinimumOverallCode2060, NewConnections2060, na.rm=T), min_lcoe_2060_baseline=weighted.mean(MinimumOverallLCOE2060, NewConnections2060, na.rm=T), sh_grid_2060_baseline = weighted.mean(Grid2060_share, NewConnections2060, na.rm=T), sh_SA_PV_2060_baseline = weighted.mean(SA_PV2060_share, NewConnections2060, na.rm=T), sh_MG_Hydro_2060_baseline = weighted.mean(MG_Hydro2060_share, NewConnections2060, na.rm=T), sh_MG_PV_2060_baseline = weighted.mean(MG_PV_Hybrid2060_share, NewConnections2060, na.rm=T), sh_MG_Wind_2060_baseline = weighted.mean(MG_Wind_Hybrid2060_share, NewConnections2060, na.rm=T), ElecStatusIn2060_baseline = weighted.mean(ElecStatusIn2060, Pop2060, na.rm=T))

##############
##############

onsset_r <- read.csv(paste0("onsset/results/onsset_full_results/improved_access_", tolower(countrycode(ctr, 'country.name', 'iso2c')), "-2-0_0_0_0_0_0.csv"))
onsset_r[onsset_r==99] <- NA

onsset_r <- st_as_sf(onsset_r, coords=c("X_deg", "Y_deg"), crs=4326)

sf <- read_sf(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS.geojson")) %>% dplyr::select(NAME_2)

onsset_r <- st_join(onsset_r, sf)

###

colnames(onsset_r)

onsset_r$geometry <- NULL

library(spatstat)

onsset_r$Grid2030_share <- onsset_r$Grid2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r$SA_PV2030_share <- onsset_r$SA_PV2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r$MG_Hydro2030_share <- onsset_r$MG_Hydro2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r$MG_PV_Hybrid2030_share <- onsset_r$MG_PV_Hybrid2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r$MG_Wind_Hybrid2030_share <- onsset_r$MG_Wind_Hybrid2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r_s_improved_access_2030 <- onsset_r %>% dplyr::group_by(NAME_2) %>% 
  dplyr::summarise(new_capacity_2030_improved_access=sum(NewCapacity2030, na.rm=T), tot_inv_2030_improved_access = sum(InvestmentCost2030, na.rm=T), inv_cap_2030_improved_access = weighted.mean(InvestmentCapita2030, NewConnections2030, na.rm=T), min_cost_tech_2030_improved_access=weighted.median(MinimumOverallCode2030, NewConnections2030, na.rm=T), min_lcoe_2030_improved_access=weighted.mean(MinimumOverallLCOE2030, NewConnections2030, na.rm=T), sh_grid_2030_improved_access = weighted.mean(Grid2030_share, NewConnections2030, na.rm=T), sh_SA_PV_2030_improved_access = weighted.mean(SA_PV2030_share, NewConnections2030, na.rm=T), sh_MG_Hydro_2030_improved_access = weighted.mean(MG_Hydro2030_share, NewConnections2030, na.rm=T), sh_MG_PV_2030_improved_access = weighted.mean(MG_PV_Hybrid2030_share, NewConnections2030, na.rm=T), sh_MG_Wind_2030_improved_access = weighted.mean(MG_Wind_Hybrid2030_share, NewConnections2030, na.rm=T), ElecStatusIn2030_improved_access = weighted.mean(ElecStatusIn2030, Pop2030, na.rm=T))

onsset_r$Grid2060_share <- onsset_r$Grid2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r$SA_PV2060_share <- onsset_r$SA_PV2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r$MG_Hydro2060_share <- onsset_r$MG_Hydro2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r$MG_PV_Hybrid2060_share <- onsset_r$MG_PV_Hybrid2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r$MG_Wind_Hybrid2060_share <- onsset_r$MG_Wind_Hybrid2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r_s_improved_access_2060 <- onsset_r %>% dplyr::group_by(NAME_2) %>% 
  dplyr::summarise(new_capacity_2060_improved_access=sum(NewCapacity2060, na.rm=T), tot_inv_2060_improved_access = sum(InvestmentCost2060, na.rm=T), inv_cap_2060_improved_access = weighted.mean(InvestmentCapita2060, NewConnections2060, na.rm=T), min_cost_tech_2060_improved_access=weighted.median(MinimumOverallCode2060, NewConnections2060, na.rm=T), min_lcoe_2060_improved_access=weighted.mean(MinimumOverallLCOE2060, NewConnections2060, na.rm=T), sh_grid_2060_improved_access = weighted.mean(Grid2060_share, NewConnections2060, na.rm=T), sh_SA_PV_2060_improved_access = weighted.mean(SA_PV2060_share, NewConnections2060, na.rm=T), sh_MG_Hydro_2060_improved_access = weighted.mean(MG_Hydro2060_share, NewConnections2060, na.rm=T), sh_MG_PV_2060_improved_access = weighted.mean(MG_PV_Hybrid2060_share, NewConnections2060, na.rm=T), sh_MG_Wind_2060_improved_access = weighted.mean(MG_Wind_Hybrid2060_share, NewConnections2060, na.rm=T), ElecStatusIn2060_improved_access = weighted.mean(ElecStatusIn2060, Pop2060, na.rm=T))

##############
##############

onsset_r <- read.csv(paste0("onsset/results/onsset_full_results/ambitious_development_", tolower(countrycode(ctr, 'country.name', 'iso2c')), "-2-0_0_0_0_0_0.csv"))

onsset_r[onsset_r==99] <- NA

onsset_r <- st_as_sf(onsset_r, coords=c("X_deg", "Y_deg"), crs=4326)

sf <- read_sf(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS.geojson")) %>% dplyr::select(NAME_2)

onsset_r <- st_join(onsset_r, sf)

###

colnames(onsset_r)

onsset_r$geometry <- NULL

library(spatstat)

onsset_r$Grid2030_share <- onsset_r$Grid2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r$SA_PV2030_share <- onsset_r$SA_PV2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r$MG_Hydro2030_share <- onsset_r$MG_Hydro2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r$MG_PV_Hybrid2030_share <- onsset_r$MG_PV_Hybrid2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r$MG_Wind_Hybrid2030_share <- onsset_r$MG_Wind_Hybrid2030 / (onsset_r$SA_PV2030 + onsset_r$Grid2030 + onsset_r$MG_Hydro2030 + onsset_r$MG_PV_Hybrid2030 + onsset_r$MG_Wind_Hybrid2030)

onsset_r_s_ambitious_development_2030 <- onsset_r %>% dplyr::group_by(NAME_2) %>% 
  dplyr::summarise(new_capacity_2030_ambitious_development=sum(NewCapacity2030, na.rm=T), tot_inv_2030_ambitious_development = sum(InvestmentCost2030, na.rm=T), inv_cap_2030_ambitious_development = weighted.mean(InvestmentCapita2030, NewConnections2030, na.rm=T), min_cost_tech_2030_ambitious_development=weighted.median(MinimumOverallCode2030, NewConnections2030, na.rm=T), min_lcoe_2030_ambitious_development=weighted.mean(MinimumOverallLCOE2030, NewConnections2030, na.rm=T), sh_grid_2030_ambitious_development = weighted.mean(Grid2030_share, NewConnections2030, na.rm=T), sh_SA_PV_2030_ambitious_development = weighted.mean(SA_PV2030_share, NewConnections2030, na.rm=T), sh_MG_Hydro_2030_ambitious_development = weighted.mean(MG_Hydro2030_share, NewConnections2030, na.rm=T), sh_MG_PV_2030_ambitious_development = weighted.mean(MG_PV_Hybrid2030_share, NewConnections2030, na.rm=T), sh_MG_Wind_2030_ambitious_development = weighted.mean(MG_Wind_Hybrid2030_share, NewConnections2030, na.rm=T), ElecStatusIn2030_ambitious_development = weighted.mean(ElecStatusIn2030, Pop2030, na.rm=T))

onsset_r$Grid2060_share <- onsset_r$Grid2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r$SA_PV2060_share <- onsset_r$SA_PV2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r$MG_Hydro2060_share <- onsset_r$MG_Hydro2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r$MG_PV_Hybrid2060_share <- onsset_r$MG_PV_Hybrid2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r$MG_Wind_Hybrid2060_share <- onsset_r$MG_Wind_Hybrid2060 / (onsset_r$SA_PV2060 + onsset_r$Grid2060 + onsset_r$MG_Hydro2060 + onsset_r$MG_PV_Hybrid2060 + onsset_r$MG_Wind_Hybrid2060)

onsset_r_s_ambitious_development_2060 <- onsset_r %>% dplyr::group_by(NAME_2) %>% 
  dplyr::summarise(new_capacity_2060_ambitious_development=sum(NewCapacity2060, na.rm=T), tot_inv_2060_ambitious_development = sum(InvestmentCost2060, na.rm=T), inv_cap_2060_ambitious_development = weighted.mean(InvestmentCapita2060, NewConnections2060, na.rm=T), min_cost_tech_2060_ambitious_development=weighted.median(MinimumOverallCode2060, NewConnections2060, na.rm=T), min_lcoe_2060_ambitious_development=weighted.mean(MinimumOverallLCOE2060, NewConnections2060, na.rm=T), sh_grid_2060_ambitious_development = weighted.mean(Grid2060_share, NewConnections2060, na.rm=T), sh_SA_PV_2060_ambitious_development = weighted.mean(SA_PV2060_share, NewConnections2060, na.rm=T), sh_MG_Hydro_2060_ambitious_development = weighted.mean(MG_Hydro2060_share, NewConnections2060, na.rm=T), sh_MG_PV_2060_ambitious_development = weighted.mean(MG_PV_Hybrid2060_share, NewConnections2060, na.rm=T), sh_MG_Wind_2060_ambitious_development = weighted.mean(MG_Wind_Hybrid2060_share, NewConnections2060, na.rm=T), ElecStatusIn2060_ambitious_development = weighted.mean(ElecStatusIn2060, Pop2060, na.rm=T))


################

onsset_r_s_2030 <- bind_cols(onsset_r_s_baseline_2030, onsset_r_s_improved_access_2030 %>% dplyr::select(-NAME_2), onsset_r_s_ambitious_development_2030 %>% dplyr::select(-NAME_2))

onsset_r_s_2060 <- bind_cols(onsset_r_s_baseline_2060, onsset_r_s_improved_access_2060 %>% dplyr::select(-NAME_2), onsset_r_s_ambitious_development_2060 %>% dplyr::select(-NAME_2))

sf <- read_sf(paste0("mled/results/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS.geojson"))

sf <- merge(sf, onsset_r_s_2030, "NAME_2")
sf <- merge(sf, onsset_r_s_2060, "NAME_2")

######## multiply demand by elrates

onsset_r <- read.csv(paste0("onsset/results/onsset_full_results/ambitious_development_", tolower(countrycode(ctr, 'country.name', 'iso2c')), "-2-0_0_0_0_0_0.csv"))

onsset_r <- st_as_sf(onsset_r, coords=c("X_deg", "Y_deg"), crs=4326)

sff <- read_sf(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS.geojson")) %>% dplyr::select(NAME_2)

onsset_r <- st_join(onsset_r, sff)

onsset_r$geometry <- NULL

onsset_r_s_2020 <- onsset_r %>% dplyr::group_by(NAME_2) %>% 
  dplyr::summarise(ElecStart = weighted.mean(ElecStart, PopStartYear, na.rm=T))

sf <- merge(sf, onsset_r_s_2020, "NAME_2")
sf <- st_as_sf(sf, sf$geometry)

###

sf <- sf  %>%  mutate_at(vars((contains('2020')) & contains(colnames(sf)[c(15:599, 1432:2016, 2849:3433)])) , funs(.*ElecStart))

sf <- sf  %>%  mutate_at(vars((contains('2030') | contains('2040')) & contains('baseline') & contains(colnames(sf)[1432:2016])) , funs(.*ElecStatusIn2030_baseline))

sf <- sf  %>%  mutate_at(vars((contains('2050') | contains('2060')) & contains('baseline') & contains(colnames(sf)[1432:2016])) , funs(.*ElecStatusIn2060_baseline))

sf <- sf  %>%  mutate_at(vars((contains('2030') | contains('2040') | contains('2050')) & contains('improved_access') & contains(colnames(sf)[2849:3433])) , funs(.*ElecStatusIn2030_improved_access))

sf <- sf  %>%  mutate_at(vars((contains('2050') | contains('2060')) & contains('improved_access') & contains(colnames(sf)[2849:3433])) , funs(.*ElecStatusIn2060_improved_access))

sf <- sf  %>%  mutate_at(vars((contains('2030') | contains('2040') | contains('2050')) & contains('ambitious_development') & contains(colnames(sf)[15:599])) , funs(.*ElecStatusIn2030_ambitious_development))

sf <- sf  %>%  mutate_at(vars((contains('2050') | contains('2060')) & contains('ambitious_development') & contains(colnames(sf)[15:599])) , funs(.*ElecStatusIn2060_ambitious_development))

########

file.remove(paste0("mled/results/", ctr, "/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS_OnSSET_added.geojson"))
write_sf(sf, paste0("mled/results/", ctr, "/", ctr, "_gadm2_with_mled_loads_ALL_SCENARIOS_OnSSET_added.geojson"))

}