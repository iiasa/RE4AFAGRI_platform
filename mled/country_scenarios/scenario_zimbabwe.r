
## This R-script:
##      1) defines country-specific and global M-LED parameters for the run
##      2) imports and processes all input data, including the cluster (geographical unit of reference at which M-LED is run)
##      3) projects future population, GDP, per-capita GDP, and urbanisation in each cluster
##      4) saves an environment file "scenario_%countryname%.Rdata" which can be used to run the analysis


#####################
# Parameters
#####################

# Country parameters
countryname = 'Zimbabwe' 
countryiso3 = 'ZWE' # ISO3
national_official_population = 14860000 # number of people
national_official_elrate = 0.528 # national residential electricity access rate
national_official_population_without_access = national_official_population- (national_official_population*national_official_elrate) # headcount of people without access
ppp_gdp_capita <- 2444.5
gini <- 50.3

electr_final_demand_tot <- 7.4 * 10e9  #https://www.iea.org/countries/zimbabwe

industry_final_demand_tot <- 3.158 * 10e9

residential_final_demand_tot <- 2.4172 * 10e9

other_final_demand_tot <- electr_final_demand_tot - industry_final_demand_tot - residential_final_demand_tot

cropland_equipped_irrigation = 0.25 #https://tableau.apps.fao.org/#/views/ReviewDashboard-v1/country_dashboard

urban_hh_size <- 3.8
rural_hh_size <- 4.3

# Planning horizon parameters
today = 2022
planning_horizon = last(planning_year) - today
discount_rate = 0.2 

# if cluster population is smaller than parameter value, then do not allow for productive demand
pop_threshold_productive_loads <- 50

# Maximum distance of cropland to include load in community load (radius buffer in meters from cluster centroid)
m_radius_buffer_cropland_distance <- 1000

#Threshold parameters
threshold_surfacewater_distance = 5000 # (m): distance threshold which discriminates if groundwater pumping is necessary or a surface pump is enough # REF:
threshold_groundwater_pumping = 75 # (m): maximum depth at which the model allows for water pumping: beyond it, no chance to install the pump # REF:

# boundaries for the flow of irrigation pumps, in m3/s
maxflow_boundaries <- c(1, 25) #i.e. 1-25 m3/h

# Energy efficiency improvement factors for appliances (% per year)
eff_impr_rur1= 0.05 / planning_horizon
eff_impr_rur2= 0.075 / planning_horizon
eff_impr_rur3= 0.1 / planning_horizon
eff_impr_rur4= 0.125 / planning_horizon
eff_impr_rur5= 0.15 / planning_horizon

eff_impr_urb1= 0.05 / planning_horizon
eff_impr_urb2= 0.075 / planning_horizon
eff_impr_urb3= 0.1 / planning_horizon
eff_impr_urb4= 0.125 / planning_horizon
eff_impr_urb5= 0.15 / planning_horizon

eff_impr_crop_proc <- 0.25 / planning_horizon

eff_impr_irrig <- 0.25 / planning_horizon

# efficiency of the water pump
eta_pump = 0.75
eta_motor = 0.75 

# lifetime of the pump
lifetimepump = 20

# water storage tank range 
range_tank <- c(1000, 20000) #liters

# water storage tank cost
tank_usd_lit <- 0.075

# Groundwater pump technical parameters
rho = 1000 # density of water (1000 kg / m3)
g = 9.81 # gravitational constant (m / s2)
c = 3.6 * (10^6) # differential pressure, (Pa)

# Surface water parameters
water_speed = 2 #m/s, https://www.engineeringtoolbox.com/flow-velocity-water-pipes-d_385.html
water_viscosity = 0.00089 #https://www.engineersedge.com/physics/water__density_viscosity_specific_weight_13146.htm
pipe_diameter = 0.8 # m

slope_limit <- 8 # %, for surface pumping

# Transportation costs
fuel_consumption = 15 # (l/h) # REF: OnSSET
fuel_cost = 1 # (USD/l) # baseline, then adapted based on distance to city
truck_bearing_t = 15 # (tons) # REF: https://en.wikipedia.org/wiki/Dump_truck

# Healthcare and education facilities assumptions
beds_tier2 <- 45
beds_tier3 <- 150
beds_tier4 <- 450

pupils_per_school <- 500

threshold_community_elec <- 0.75

#

minutes_cluster <- 180 # minutes of travel time around each settlement to create crop processing clusters


#####################
# Assumed load curves
#####################

# monthly redistribution of demand for sectors modeled yearly (mining and "other")
share_demand_by_month_other_sectors <- rep(1/12, 12)

# crop processing
load_curve_cp = c(0, 0, 0, 0, 0, 0, 0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0.0833, 0, 0, 0, 0, 0, 0)

# irrigation
load_curve_irrig = load_curve_irr = c(0, 0, 0, 0, 0, 0.166, 0.166, 0.166, 0.166, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.166, 0.166)

range_smes_markup <- c(0.6, 0.3)

#number of hours of pumping, 3 during the morning and 3 during the evening
nhours_irr = sum(load_curve_irrig!=0)
irrigation_frequency_days <- 2

# import load curve of productive activities
load_curve_prod_act <- read.csv(find_it('productive profile.csv'))

# Appliances cost, household (check ./ramp/ramp/RAMP_households/Appliances cost.xlsx for inputs)
rur1_app_cost=154
rur2_app_cost=171
rur3_app_cost=278
rur4_app_cost=958
rur5_app_cost=1905

urb1_app_cost=113
urb2_app_cost=307
urb3_app_cost=902
urb4_app_cost=1464
urb5_app_cost=2994

# Appliances cost, schools (check ./ramp/ramp/RAMP_social/Appliances_schools.xlsx for inputs)
sch_1_app_cost = 60
sch_2_app_cost = 360
sch_3_app_cost = 1590
sch_4_app_cost = 2550
sch_5_app_cost = 3220

# Appliances cost, healtchare  (check ./ramp/ramp/RAMP_social/Appliances_healthcare.xlsx for inputs)
hc_1_app_cost = 110
hc_2_app_cost = 4710
hc_3_app_cost = 95060
hc_4_app_cost = 305660
hc_5_app_cost = 611450

# PV parameters

battery_buffer <- 0.2
battery_efficiency <- 0.85
depth_discharge <- 0.8
usdperkwhbattery <- 500

calories_yearly_need <- 2000 * 365
proteinsg_yearly_need <- 50 * 365
fatsg_yearly_need <- 60 * 365

#####################
# Input data
#####################

#####################
# Irrigation needs (source: soft-link from WaterCROP)
#####################

rainfed <- list.files(paste0(input_folder, "watercrop"), full.names = T, pattern = "watergap", recursive=T)
irrigated <- list.files(paste0(input_folder, "watercrop"), full.names = T, pattern = "waterwith", recursive=T)

yield <- list.files(paste0(input_folder, "watercrop"), full.names = T, pattern = "yield_avg_ton", recursive=T)
yg_potential <- list.files(paste0(input_folder, "watercrop"), full.names = T, pattern = "yield_avg_closure", recursive=T)

#####################
# Country-specific data
#####################

# Country and provinces shapefiles
gadm0 = st_as_sf(geodata::gadm(country=countryiso3, level=0, path=getwd()))
gadm1 = st_as_sf(geodata::gadm(country=countryiso3, level=1, path=getwd()))
gadm2 = st_as_sf(geodata::gadm(country=countryiso3, level=2, path=getwd()))

# Define extent of country analysed
ext = extent(gadm0)

#

clusters <- read_sf(find_it("clusters_Zimbabwe_GRID3_above5population.gpkg"), crs=4326) #%>% sample_n(1000)
clusters <- filter(clusters, pop_start_worldpop>10)

clusters_centroids <- st_centroid(clusters)
clusters_buffers_cropland_distance <- st_transform(clusters_centroids, 3395) %>% st_buffer(m_radius_buffer_cropland_distance) %>% st_transform(4326)

#clusters$elrate <- clusters$elecpop_start_worldpop/clusters$pop_start_worldpop

clusters_nest <- gadm2 %>% mutate(BCU=1:nrow(gadm2)) #read_sf(find_it("Zimbabwe_NEST_delineation.shp"))

#####################
# Current gridded data
#####################

# gridded population (current)
population_baseline <- raster(find_it("zwe_ppp_2020_UNadj_constrained.tif"))

# gridded gdp_baseline (current)
gdp_baseline <- stack(find_it(paste0("gdp_", scenarios$ssp[scenario], "soc_10km_2010-2100.nc")))[[2]]
gdp_baseline <- mask_raster_to_polygon(gdp_baseline, gadm0)

# groundwater recharge (baseline)
qr_baseline <- stack(find_it(paste0("lpjml_gfdl-esm2m_ewembi_", scenarios$rcp[scenario], "_", scenarios$rcp[scenario], "soc_co2_qr_global_monthly_2006_2099.nc4")))

# wealth / GDP per capita

wealth_baseline <- all_input_files[grep(paste0(countryiso3, "_relative_wealth"), all_input_files)]
wealth_baseline <- read.csv(wealth_baseline)
wealth_baseline$iso3c <- countryiso3

write(paste0(timestamp(), "starting RWI to GDP capita"), "log.txt", append=T)
source("rwi_to_gdp_capita.R", local = T)

wealth_baseline <- st_as_sf(as.data.frame(wealth_baseline), coords=c("longitude", "latitude"), crs=4326)

# lv_grid_density <- raster(find_it("targets.tif"))
# lv_grid_density <- mask_raster_to_polygon(lv_grid_density, st_as_sfc(st_bbox(clusters)))
# lv_grid_density <- terra::aggregate(lv_grid_density, fun=sum, fact=20)
# writeRaster(lv_grid_density, file=find_it("targets_10km.tif"), overwrite=T)
lv_grid_density <- raster(find_it("targets_10km.tif"))
crs(lv_grid_density) <- crs(population)
lv_grid_density <- lv_grid_density>=1

#

calories <- read.csv(find_it("calories.csv"), stringsAsFactors = F)
crop_parser <- read.csv(find_it("4-Methodology-Crops-of-SPAM-2005-2015-02-26.csv"), stringsAsFactors = F)
prices <- read.csv(find_it("FAOSTAT_data_8-11-2021.csv"))
parser <- read.csv(find_it("parser.csv"))
food_insecurity <- read.csv(find_it("caloric_gap.csv"))

#####################
# Future gridded data and project data
#####################

write(paste0(timestamp(), "starting SSP project"), "log.txt", append=T)
source("projector.R", local = T)

# urbanisation
write(paste0(timestamp(), "Calibrating urban rates"), "log.txt", append=T)
urbproj = readxl::read_xlsx(find_it("urbproj_all.xlsx"), sheet = "data")
source("calib_urbs.R", local = T)

#####################
# residential appliances ownership and usage (representative monthly consumption)#####################

for (i in 1:12){
  assign(paste0('rur1' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_households/Rural/Outputs/Tier-1/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000) * (1-eff_impr_rur1*planning_horizon))) 
  
  assign(paste0('rur2' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_households/Rural/Outputs/Tier-2/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000) * (1-eff_impr_rur2*planning_horizon))) 
  
  assign(paste0('rur3' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_households/Rural/Outputs/Tier-3/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000) * (1-eff_impr_rur3*planning_horizon))) 
  
  assign(paste0('rur4' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_households/Rural/Outputs/Tier-4/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000) * (1-eff_impr_rur4*planning_horizon))) 
  
  assign(paste0('rur5' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_households/Rural/Outputs/Tier-5/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000) * (1-eff_impr_rur5*planning_horizon))) 
  
}

for (i in 1:12){
  assign(paste0('urb1' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_households/Urban/Outputs/Tier-1/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000) * (1-eff_impr_urb1*planning_horizon))) 
  
  assign(paste0('urb2' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_households/Urban/Outputs/Tier-2/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000) * (1-eff_impr_urb2*planning_horizon))) 
  
  assign(paste0('urb3' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_households/Urban/Outputs/Tier-3/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000) * (1-eff_impr_urb3*planning_horizon))) 
  
  assign(paste0('urb4' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_households/Urban/Outputs/Tier-4/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000) * (1-eff_impr_urb4*planning_horizon))) 
  
  assign(paste0('urb5' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_households/Urban/Outputs/Tier-5/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000) * (1-eff_impr_urb5*planning_horizon))) 
  
}

# healthcare and education appliances ownership and usage 

for (i in 1:12){
  assign(paste0('health1' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_services/1.Health/Dispensary/Outputs/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000))) 
  
  assign(paste0('health2' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_services/1.Health/HealthCentre/Outputs/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000))) 
  
  assign(paste0('health3' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_services/1.Health/SubCountyH/Outputs/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000))) 
  
  assign(paste0('health4' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_services/1.Health/SubCountyH/Outputs/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=mean(values)*1.3/1000)) 
  
  assign(paste0('health5' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_services/1.Health/SubCountyH/Outputs/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=mean(values)*1.6/1000)) 
  
}

for (i in 1:12){
  assign(paste0('edu' , "_" , as.character(i)), read.csv(paste0(input_folder , '/ramp/RAMP_services/2.School/Output/output_file_' , as.character(i) , '.csv')) %>% rename(values = X0, minutes = X) %>% mutate(hour=minutes%/%60%%24) %>% group_by(hour) %>% summarise(values=(mean(values)/1000))) #/10 schools simulated 
  
}

# Taxes on PV equipment
vat_import <- read.csv(find_it("vat_import.csv"), stringsAsFactors = F)
vat_import$ISO3 <- countrycode::countrycode(vat_import[,1], 'country.name', 'iso3c')

# Crop and harvest calendar
crops = readxl::read_xlsx(find_it('crops_cfs_ndays_months_ZWE.xlsx'))

# Read xlsx of spline surface for water pumps costing
x = read_xlsx(paste0(input_folder, "interp_surface_cost/smooth_q.xlsx"), col_names = T)
y = read_xlsx(paste0(input_folder, "interp_surface_cost/smooth_h.xlsx"), col_names = T)
z = read_xlsx(paste0(input_folder, "interp_surface_cost/smooth_c.xlsx"), col_names = T)

# Import csv of energy consumption by crop 
energy_crops = read.csv(find_it('crop_processing.csv'))

# Survey data
dhs <- empl_wealth <- read_sf(find_it("sdr_subnational_data_dhs_2018.shp"))
dhs <- empl_wealth <- filter(dhs, dhs$ISO==countrycode(countryiso3, "iso3c", "iso2c"))

# Classifying schools and healthcare facilities
health = read_sf(find_it('health.geojson'))

health$Tier <- ifelse(grepl("hosp", health$TYPEOFFACI , ignore.case = T), 4, NA)
health$Tier <- ifelse(grepl("clinic", health$TYPEOFFACI , ignore.case = T), 3, health$Tier)
health$Tier <- ifelse(grepl("centre|center|post", health$TYPEOFFACI , ignore.case = T), 2, health$Tier)
health$Tier <- ifelse(grepl("rural", health$TYPEOFFACI , ignore.case = T) | is.na(health$TYPEOFFACI), 1, health$Tier)

#Import primaryschools
primaryschools = read_sf(find_it('schools.geojson'))

##########
# SSA-wide data

field_size <- raster(find_it("field_size_10_40_cropland.img"))
field_size <- mask_raster_to_polygon(field_size, st_as_sfc(st_bbox(clusters)))
gc()

maxflow <- field_size
gc()
v <- scales::rescale(raster::values(maxflow), to = maxflow_boundaries)
raster::values(maxflow) <- v
rm(v); gc()

mining_sites <- read_sf(find_it("global_mining_polygons_v2.gpkg"))
mining_sites <- filter(mining_sites, COUNTRY_NAME == countryname)  

traveltime_market = ee$Image("Oxford/MAP/accessibility_to_cities_2015_v1_0")

# Import diesel price layer (In each pixel: 2015 prices baseline , cost per transporting it from large cities)
diesel_price = raster(find_it('diesel_price_baseline_countryspecific.tif'))
diesel_price <- mask_raster_to_polygon(diesel_price, gadm0)

DepthToGroundwater = read.delim(find_it('xyzASCII_dtwmap_v1.txt'), sep='\t')
GroundwaterStorage = read.delim(find_it('xyzASCII_gwstor_v1.txt'), sep='\t')
GroundwaterProductivity = read.delim(find_it('xyzASCII_gwprod_v1.txt'), sep='\t')

roads<-raster(find_it('grip4_total_dens_m_km2.asc'), crs="+proj=longlat +datum=WGS84")
roads <- mask_raster_to_polygon(roads, gadm0)

traveltime <- raster(find_it('travel.tif'))
traveltime <- mask_raster_to_polygon(traveltime, gadm0)

raster_tiers = raster(find_it('tiersofaccess_SSA_2018.nc'))
raster_tiers <- mask_raster_to_polygon(raster_tiers, gadm0)

friction <- raster(find_it("friction_cut_1209.tif")) # friction layer from Weiss et al. (minutes per meter)
friction <- mask_raster_to_polygon(friction, gadm0)

cities <- read_sf(find_it("cities.geojson")) %>% filter(cou_name_en==countryname)

#

#save.image(paste0(processed_folder, "scenario_zimbabwe.Rdata"))
