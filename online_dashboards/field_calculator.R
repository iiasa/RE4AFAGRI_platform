library(tidyverse)
library(sf)

# 1) irrigation needs (total and crop specific)

template_names = colnames(read_sf(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", ctr[1], "_gadm2_with_mled_loads_ALL_SCENARIOS.geojson")))


setwd("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/online_dashboards/") # path of the cloned M-LED GitHub repository

#setwd("D:/OneDrive - IIASA/RE4AFAGRI_platform/online_platform") # path of the cloned M-LED GitHub repository

crops_list <- read.csv("supporting_files/crops_list.csv", header = F)
sectors_list <- read.csv("supporting_files/sectors_list.csv", header = F)

months <- c("Yearly", 1:12)
rcps <- c("rcp26", "rcp60")
ssps <- c("ssp2")
year <- seq(2020, 2060, 10)
crop <- as.character(crops_list$V1)
crop[1] <- "barl"
og_of <- c("ongrid", "offgrid")
scen <- c("baseline", "improved_access", "ambitious_development")

l <- expand.grid(months, rcps, ssps, year, og_of, scen, stringsAsFactors = F)

l <- dplyr::filter(l, (Var3=="ssp2" & Var2=="rcp26" & Var6=="baseline") | (Var3=="ssp2" & Var2=="rcp60" & Var6!="baseline"))

out <- paste0('ELSEIF
[Month]=="', l$Var1,
'" \nAND
[Proximity]=="', l$Var5,
'" \nAND
[Year]=="', l$Var4,
'"AND
[Scenario]=="', l$Var6, ifelse(l$Var1!="Yearly", paste0('"
THEN',
'\n[monthly_IRREQ_', l$Var1, '_', l$Var4, '_', ifelse(l$Var5=="ongrid", "", "offgrid_"), l$Var6, '] / 1000000 \n'), 
paste0('"
THEN',
'\n[yearly_IRREQ_', l$Var4, '_', ifelse(l$Var5=="ongrid", "", "offgrid_"), l$Var6, '] / 1000000 \n') ))

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/irrigation_M.txt")

# 2) area

crop <- list.files(path=paste0("F:/Il mio Drive/MLED_database/input_folder/spam_folder/spam2017v2r1_ssa_yield.geotiff"), pattern="R.tif", full.names=T)
crop <- tolower(unlist(qdapRegex::ex_between(crop, "SSA_Y_", "_R")))

write.csv(crop, "C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/online_dashboards/supporting_files/crops.csv", row.names = F)

irr_tech <- c("r", "i")

l <- expand.grid(crop, irr_tech, stringsAsFactors = F)

out <- paste0('ELSEIF
[Crop]=="', l$Var1,
              '" \nAND
[Irrigation type]=="', l$Var2,'"
THEN',
              '\n[A_',l$Var1, '_', l$Var2, "_baseline", ']  / 1000 \n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/cropland_A.txt")

#########################

# 2) yield growth potential (total and crop specific)

year <- seq(2020, 2060, 10)
rcps <- c("rcp26", "rcp60")
ssps <- c("ssp2")
crop <- as.character(crops_list$V1)
crop[1] <- "barl"

l <- expand.grid(rcps, ssps, crop, year, scen, stringsAsFactors = F)

l <- dplyr::filter(l, (Var2=="ssp2" & Var1=="rcp26" & Var5=="baseline") | (Var2=="ssp2" & Var1=="rcp60" & Var5!="baseline"))

out <- paste0('ELSEIF
[Crop]=="', l$Var3,
'" \nAND
[Scenario]=="', l$Var5,'"
 \nAND
[Year]=="', l$Var4,'"
THEN',
              '\n[yg_potential_',l$Var3, '_', l$Var4, '_', l$Var5, '] \n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/yield_growth_potential.txt")

# 4) current yield

energy_crops <- read.csv(paste0("F:/Il Mio Drive/MLED_database/input_folder/country_studies/", ctr[1], "/mled_inputs/crop_processing.csv"))

crop <- list.files(path=paste0("F:/Il mio Drive/MLED_database/input_folder/spam_folder/spam2017v2r1_ssa_yield.geotiff"), pattern="R.tif", full.names=T)
crop <- tolower(unlist(qdapRegex::ex_between(crop, "SSA_Y_", "_R")))

rcps <- c("rcp26", "rcp60")
ssps <- c("ssp2")
curr_fut <- c("ssp2")
irr_tech <- c("r", "i")

l <- expand.grid(crop, rcps, ssps, irr_tech, scen, stringsAsFactors = F)
l <- dplyr::filter(l, (Var3=="ssp2" & Var2=="rcp26" & Var5=="baseline") | (Var3=="ssp2" & Var2=="rcp60" & Var5!="baseline"))

out <- paste0('ELSEIF
[Crop]=="', l$Var1,'"
\nAND
[Scenario]=="', l$Var5,'"
\nAND
[Irrigation type]=="', l$Var4,'"
THEN',
              '\n[Y_',l$Var1, '_', l$Var4, "_", l$Var5, '] \n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/yield_current.txt")

# 3) ely demand (sector, month, year, ssp, rcp)

months <- c("Yearly", 1:12)
rcps <- c("rcp26", "rcp60")
ssps <- c("ssp2")
year <- seq(2020, 2060, 10)
sector <- as.character(sectors_list$V1)
sector[1] <- "residential"

l <- expand.grid(year, months, sector, rcps, ssps, scen, stringsAsFactors = F)

l <- dplyr::filter(l, (Var5=="ssp2" & Var4=="rcp26" & Var6=="baseline") | (Var5=="ssp2" & Var4=="rcp60" & Var6!="baseline"))

out <- paste0('ELSEIF
[Year]=="', l$Var1,
              '" \nAND
[Month]=="', l$Var2,'"
\nAND
[Sector]=="', l$Var3,'"
\nAND
[Scenario]=="', l$Var6,'"
THEN',
              '\n[', ifelse(l$Var3=="water_pumping_offgrid", "water_pumping", l$Var3), ifelse(l$Var2=="Yearly", '_tt', ifelse(l$Var3!="water_pumping" & l$Var3!="water_pumping_offgrid", paste0('_tt_monthly_', l$Var2), paste0('_monthly_', l$Var2))), '_', l$Var1, '_', ifelse(l$Var3=="water_pumping_offgrid", "offgrid_", ""), l$Var6, '] / 1000000 \n')


out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/ely_demand.txt")

#########

# CP throughput

months <- c("Yearly", 1:12)
rcps <- c("rcp26", "rcp60")
ssps <- c("ssp2")
year <- seq(2020, 2060, 10)
sector <- as.character(sectors_list$V1)
sector[1] <- "residential"

l <- expand.grid(year, months, sector, rcps, ssps, scen, stringsAsFactors = F)

l <- dplyr::filter(l, (Var5=="ssp2" & Var4=="rcp26" & Var6=="baseline") | (Var5=="ssp2" & Var4=="rcp60" & Var6!="baseline"))

out <- paste0('ELSEIF
[Year]=="', l$Var1,
              '" \nAND
[Month]=="', l$Var2,'"
\nAND
[Scenario]=="', l$Var6,'"
THEN',
              '\n[', "crop_processing", ifelse(l$Var2=="Yearly", '_tt', paste0('_tt_monthly_', l$Var2)), '_', l$Var1, '_', l$Var6, '] / 1000000 \n')


out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/ely_demand_cp.txt")

###

year <- seq(2020, 2060, 10)
rcps <- c("rcp26", "rcp60")
ssps <- c("ssp2")
crop <- as.character(crops_list$V1)[-c(1,3,4,9,10,13,15,19)]
#crop[1] <- "barl"
irr_tech <- c("r", "i")

l <- expand.grid(rcps, ssps, crop, year, scen, irr_tech, stringsAsFactors = F)

l <- dplyr::filter(l, (Var2=="ssp2" & Var1=="rcp26" & Var5=="baseline") | (Var2=="ssp2" & Var1=="rcp60" & Var5!="baseline"))

out <- paste0('ELSEIF
[Crop]=="', l$Var3,
              '" \nAND
[Scenario]=="', l$Var5,'"
 \nAND
[Year]=="', l$Var4,'"
THEN',
              '\n[yield_',l$Var3, '_', l$Var6, "_cp_", l$Var4, '_', l$Var5, '] / 1000000 \n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/cp_throughput.txt")

###############################
###############################
###############################
###############################
###############################
###############################


# 4) crop processing - machineries requirements and power needs (crop, rcp)

rcps <- c("rcp26", "rcp60")
ssps <- c("ssp2")
crop <- as.character(crops_list$V1)
crop[1] <- "barl"
year <- seq(2020, 2060, 10)

l <- expand.grid(rcps, ssps, crop, year, scen, stringsAsFactors = F)

l <- dplyr::filter(l, (Var2=="ssp2" & Var1=="rcp26" & Var5=="baseline") | (Var2=="ssp2" & Var1=="rcp60" & Var5!="baseline"))

out <- paste0('ELSEIF
[Year]=="', l$Var4,
              '" \nAND
[Crop]=="', l$Var3,
              '" \nAND
[Scenario]=="', l$Var5,'"
THEN',
              '\n[machinery_', l$Var3, '_', l$Var4, '_', l$Var1, '_', l$Var2, '_', l$Var5, ']\n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/machinery.txt")


# 5) solar pumps -> 

rcps <- c("rcp26", "rcp60")
ssps <- c("ssp2")
year <- seq(2020, 2060, 10)

l <- expand.grid(rcps, ssps,year, scen, stringsAsFactors = F)
l <- dplyr::filter(l, (Var2=="ssp2" & Var1=="rcp26" & Var4=="baseline") | (Var2=="ssp2" & Var1=="rcp60" & Var4!="baseline"))

out <- paste0('ELSEIF
[Year]=="', l$Var3,
              '" \nAND
[Scenario]=="', l$Var4,'"
THEN',
              '\n[solar_pumps_', l$Var3, '_', l$Var1, '_', l$Var2, '_', l$Var4, ']\n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/solar_pumps.txt")

################################################################
###############################################################

# 6) onsset -> technology; investment requirement; capacity; LCOE (year, ssp, rcp, other parameter)

other_par_list <- read.csv("supporting_files/onsset_pars.csv", header = T)

rcps <- c("rcp26", "rcp60")
ssps <- c("ssp2")
year <- c(2030, 2060)
other_par <- c(other_par_list$pars[1])
scen <- c("baseline", "improved_access", "ambitious_development")

l <- expand.grid(rcps, ssps, year, other_par, scen, stringsAsFactors = F)
l <- dplyr::filter(l, (Var2=="ssp2" & Var1=="rcp26" & Var5=="baseline") | (Var2=="ssp2" & Var1=="rcp60" & Var5!="baseline"))

out <- paste0('ELSEIF
[Period]=="', l$Var3,
              '" \nAND
[Scenario]=="', l$Var5,'"
THEN',
              '\n[', other_par, '_', l$Var3, '_', l$Var5, '] /1000 \n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/onsset_capacity.txt")

##

other_par_list <- read.csv("supporting_files/onsset_pars.csv", header = T)

rcps <- c("rcp26", "rcp60")
ssps <- c("ssp2")
year <- c(2030, 2060)
other_par <- c(other_par_list$pars[2])

l <- expand.grid(rcps, ssps, year, other_par, scen, stringsAsFactors = F)
l <- dplyr::filter(l, (Var2=="ssp2" & Var1=="rcp26" & Var5=="baseline") | (Var2=="ssp2" & Var1=="rcp60" & Var5!="baseline"))

out <- paste0('ELSEIF
[Period]=="', l$Var3,
              '" \nAND
[Scenario]=="', l$Var5,'"
THEN',
              '\n[', other_par, '_', l$Var3, '_', l$Var5, '] / 1000000 \n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/onsset_investment.txt")

##

other_par_list <- read.csv("supporting_files/onsset_pars.csv", header = T)

rcps <- c("rcp26", "rcp60")
ssps <- c("ssp2")
year <- c(2030, 2060)
other_par <- c(other_par_list$techs)

l <- expand.grid(rcps, ssps, year, other_par, scen, stringsAsFactors = F)
l <- dplyr::filter(l, (Var2=="ssp2" & Var1=="rcp26" & Var5=="baseline") | (Var2=="ssp2" & Var1=="rcp60" & Var5!="baseline"))

out <- paste0('ELSEIF
[Period]=="', l$Var3,
              '" \nAND
[Scenario]=="', l$Var5,'"
 \nAND
[ONSSET_TECH]=="', l$Var4,'"
THEN',
              '\n[', l$Var4, '_', l$Var3, '_', l$Var5, '] *100 \n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/onsset_split.txt")

##

other_par_list <- read.csv("supporting_files/onsset_pars.csv", header = T)

rcps <- c("rcp26", "rcp60")
ssps <- c("ssp2")
year <- c(2030, 2060)
other_par <- "min_lcoe"

l <- expand.grid(rcps, ssps, year, other_par, scen, stringsAsFactors = F)
l <- dplyr::filter(l, (Var2=="ssp2" & Var1=="rcp26" & Var5=="baseline") | (Var2=="ssp2" & Var1=="rcp60" & Var5!="baseline"))

out <- paste0('ELSEIF
[Period]=="', l$Var3,
              '" \nAND
[Scenario]=="', l$Var5,'"
THEN',
              '\n[', other_par, '_', l$Var3, '_', l$Var5, ']\n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/onsset_lcoe.txt")


########

# 7) nest -> (year, ssp, rcp, other parameter)

r <- read_sf(paste0("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/mled/results/", ctr[1], "/", ctr[1], "_gadm2_with_mled_loads_ALL_SCENARIOS_NEST_added.geojson"))

months <- c("Yearly")
scen <- c("baseline", "improved_access", "ambitious_development")
year <- seq(2020, 2060, 10)

l <- expand.grid(scen, year, months, stringsAsFactors = F)

out <- paste0('ELSEIF
[Year]=="', l$Var2,
              '" \nAND
[Scenario]=="', l$Var1,
              '"
THEN',
              '\n[', 'water_infra_volume_km3_yr_', l$Var1, '_', "Yearly", '_', l$Var2, ']\n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/nest_water_infra_volume_km3_yr.txt")

####

months <- c("Yearly")
scen <- c("baseline", "improved_access", "ambitious_development")
year <- seq(2020, 2060, 10)

l <- expand.grid(scen, year, months, stringsAsFactors = F)

out <- paste0('ELSEIF
[Year]=="', l$Var2,
              '" \nAND
[Scenario]=="', l$Var1,
              '"
THEN',
              '\n[', 'water_infr_invest_bn_', l$Var1, '_', "Yearly", '_', l$Var2, ']\n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/nest_water_infr_invest_bn.txt")

####

months <- c("Yearly")
scen <- c("baseline", "improved_access", "ambitious_development")
year <- seq(2020, 2060, 10)
techs <- c("total", "Off-Grid", "Biomass", "Coal", "Gas", "Geothermal", "Hydro", "Nuclear", "Oil", "Solar", "Transmission and Distribution", "Wind")

l <- expand.grid(scen, year, months, techs, stringsAsFactors = F)

out <- paste0('ELSEIF
[Year]=="', l$Var2,
              '" \nAND
[tech_electricity_investment]=="', l$Var4,
              '" \nAND              
[Scenario]=="', l$Var1,
              '"
THEN',
              '\n[', 'electricity_investment_', l$Var4, "_bn_usd_yr", "_", l$Var1, '_', "Yearly", '_', l$Var2, ']\n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/electricity_investment_bn_usd_yr.txt")

####

months <- c("Yearly", 1:12)
scen <- c("baseline", "improved_access", "ambitious_development")
year <- seq(2020, 2060, 10)
techs <- c("total", "Energy_techs_&_Irrigation", "Industrial_Water_Unconnected", "Irrigation", "Municipal_Water", "Electricity_Hydro")

l <- expand.grid(scen, year, months, techs, stringsAsFactors = F)
l <- filter(l, !(Var4=="Electricity_Hydro" & Var3 %in% as.character(1:12)))
l <- filter(l, !(Var3 == "Yearly" & !(Var4 %in% c("Electricity_Hydro", "total"))))

out <- paste0('ELSEIF
[Year]=="', l$Var2,
              '" \nAND
[tech_water_withdrawal]=="', l$Var4,
              '" \nAND              
[Scenario]=="', l$Var1,
              '" \nAND
[Month]=="', l$Var3,'"
THEN',
              '\n[', 'water_withdrawal_', l$Var4, "_km3_yr", "_", l$Var1, '_', l$Var3, '_', l$Var2, ']\n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/water_withdrawal_km3_yr.txt")


####

months <- c("Yearly", 1:12)
scen <- c("baseline", "improved_access", "ambitious_development")
year <- seq(2020, 2060, 10)
techs <- c("total", "Final_Energy_Commercial_Water_Surface_Water_Extraction", "Brackish_Water", "Groundwater", "Seawater", "Seawater_Desalination", "Surface_Water", "Seawater_Cooling")

l <- expand.grid(scen, year, months, techs, stringsAsFactors = F)

out <- paste0('ELSEIF
[Year]=="', l$Var2,
              '" \nAND
[tech_water_extraction]=="', l$Var4,
              '" \nAND              
[Scenario]=="', l$Var1,
              '" \nAND
[Month]=="', l$Var3,'"
THEN',
              '\n[', 'water_extraction_', l$Var4, "_km3_yr", "_", l$Var1, '_', l$Var3, '_', l$Var2, ']\n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/water_extraction_km3_yr.txt")

####

months <- c("Yearly", 1:12)
scen <- c("baseline", "improved_access", "ambitious_development")
year <- seq(2020, 2060, 10)
techs <- c("total", "Off-Grid", "Biomass", "Coal", "Gas", "Geothermal", "Hydro", "Nuclear", "Oil", "Solar", "Wind")

l <- expand.grid(scen, year, months, techs, stringsAsFactors = F)

out <- paste0('ELSEIF
[Year]=="', l$Var2,
              '" \nAND
[tech_electricity_supply]=="', l$Var4,
              '" \nAND              
[Scenario]=="', l$Var1,
              '" \nAND
[Month]=="', l$Var3,'"
THEN',
              '\n[', 'electricity_supply_', l$Var4, "_twh_yr", "_", l$Var1, '_', l$Var3, '_', l$Var2, ']\n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/electricity_supply_twh_yr.txt")

####

months <- c(1:12)
scen <- c("baseline")
year <- seq(2020, 2060, 10)

l <- expand.grid(scen, year, months, stringsAsFactors = F)

out <- paste0('ELSEIF
[Year]=="', l$Var2,
              '" \nAND
[Scenario]=="', l$Var1,
              '" \nAND
[Month]=="', l$Var3,'"
THEN',
              '\n[', 'drinking_water_price_usd_m3_', l$Var1, '_', l$Var3, '_', l$Var2, ']\n')

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/drinking_water_price_usd_m3.txt")

