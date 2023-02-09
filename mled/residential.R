
## This R-script:
##      1) assesses current and future predominant tier of electricity access at each cluster using data from Falchetta et al. (2019) Scientific Data's paper and a multinomial logistic regression model trained on current data (population density, urbanisation, GDP per capita) and used to make projections of future tiers based on future data
##      2) project future residential demand at each time step
##      2.1) for household who already have electricity access at the baseline period, it projects future demand based on per-capita GDP growth rate and income elasticities of electricity demand
##      2.2) for household who are set to gain electricity access (based on the electricity access objective set in the main M-LED file), it assigns RAMP-generated appliance-based loads based on the predicted tier at each time step
##      3) calculates total future residential electricity demand 


###

# Calculate the number of people in each tier in each cluster
clusters$popdens <- clusters$population / clusters$area

#plot_raster_tiers <- rasterVis::levelplot(ratify(raster_tiers))

#raster::values(raster_tiers) <- ifelse(raster::values(raster_tiers)==0, NA, raster::values(raster_tiers))

clusters$tier <- exact_extract(raster_tiers, clusters, "max")

#

set.seed(123)

clusters_rf <- dplyr::select(clusters, tier, gdp_capita_2020, popdens, isurban)
clusters_rf <- na.omit(clusters_rf)

clusters_rf$tier <- as.factor(clusters_rf$tier)
clusters_rf$isurban <- as.factor(clusters_rf$isurban)

clusters_rf$geometry <- NULL
clusters_rf$geom <- NULL

train_data <- clusters_rf %>%
  group_by(tier, isurban) %>%
  slice_sample(prop = 0.7) 

test_data <- clusters_rf %>%  anti_join(train_data)

metric <- "Accuracy"
mtry <- sqrt(ncol(clusters_rf))
tunegrid <- expand.grid(.mtry=mtry)

if (length(unique(train_data$tier))==5){

w <- 1/table(train_data$tier)
w <- w/sum(w)
weights <- rep(0, nrow(train_data))
weights[train_data$tier == 0] <- w['0']
weights[train_data$tier == 1] <- w['1']
weights[train_data$tier == 2] <- w['2']
weights[train_data$tier == 3] <- w['3']
weights[train_data$tier == 4] <- w['4']

model <- multinom(tier ~ gdp_capita_2020*popdens*isurban, train_data, weights = weights) } else {
  
  train_data$tier = as.numeric(as.character(train_data$tier))
  
  model <- lm(tier ~ gdp_capita_2020*popdens*isurban, train_data) }



# testing accuracy
#confusionMatrix(predict(model, newdata=test_data), test_data$tier)

##########################################

# Calculate number of households in each cluster
clusters$HHs = ifelse(clusters$isurban>0, clusters$population/urban_hh_size, clusters$population/rural_hh_size)

# Assign elasticity
clusters$elasticity <- ifelse(clusters$tier==1, 0.69, ifelse(clusters$tier==2, 0.637, ifelse(clusters$tier==3, 0.41, ifelse(clusters$tier==4, 0.32, 1))))

# If ely access > 0, consumption of electrified x% grows with gdp_capita growth, mediated byelasticity linked to tiers

clusters$PerHHD_ely <- clusters$current_consumption_kWh / (clusters$HHs * clusters$elrate)

clusters$PerHHD_ely <- ifelse(is.na(clusters$PerHHD_ely) | is.infinite(clusters$PerHHD_ely), 0, clusters$PerHHD_ely)

diff <- sum(clusters$current_consumption_kWh[(clusters$HHs * clusters$elrate)==0])

clusters$w <- clusters$PerHHD_ely / sum(clusters$PerHHD_ely, na.rm=T)

diff_v <- ((diff*clusters$w ))

clusters$current_consumption_kWh_edit <- ifelse((clusters$HHs * clusters$elrate)==0, 0, clusters$current_consumption_kWh)

clusters$current_consumption_kWh <- clusters$current_consumption_kWh_edit + diff_v

clusters[paste0('PerHHD_ely_', first(planning_year))] <- clusters$PerHHD_ely 

clusters[paste0('PerHHD_tt_', first(planning_year))] <-  clusters[paste0('PerHHD_ely_tt_', first(planning_year))] <-  clusters$current_consumption_kWh

clusters$HHs <- ifelse((clusters$HHs * clusters$elrate)<1, 0, clusters$HHs)

clusters$PerHHD_ely  <- NULL

############


for (timestep in planning_year[-1]){
  
aa <- clusters
aa$geom=NULL
aa$geometry=NULL

clusters[paste0('PerHHD_ely' , "_", timestep)] <- pull(aa[paste0('PerHHD_ely' , "_", (timestep-10))]) * (1 + clusters$elasticity * ((pull(aa[paste0("gdp_capita_", timestep)]) - pull(aa[paste0('gdp_capita' , "_", (timestep - 10))])) / pull(aa[paste0('gdp_capita' , "_", (timestep - 10))])))

aa <- clusters
aa$geom=NULL
aa$geometry=NULL


# if ely access == 0 AND the consumption of unelectrified x%, consumption determined by tiers

# make predictions bases on future data

clusters[paste0('population' , "_", planning_year[1])] <- clusters$population
clusters$population_future <- clusters$population

for (i in (planning_year[1]+1):timestep){
  
  aa <- clusters
  aa$geometry <- NULL
  aa$geom <- NULL
  
  clusters$population_future <-  clusters$population_future*(1+pull(aa[paste0("pop_gr_", i)]))
  clusters[paste0('population' , "_", timestep)] <- clusters$population_future
}

clusters$popdens_future <- clusters$population_future / clusters$area

newdata <- clusters %>% dplyr::select(paste0("gdp_capita_", timestep), popdens_future, paste0("isurban_future_", timestep)) %>%  as.data.frame() 

newdata$geometry <- NULL
newdata$geom <- NULL
colnames(newdata) <- c("gdp_capita_2020", "popdens", "isurban")
newdata$isurban <- as.factor(newdata$isurban)


if (length(unique(train_data$tier))==5){
  
clusters[complete.cases(newdata), paste0("predicted_tier_", timestep)] <- predict(model, newdata=newdata[complete.cases(newdata),]) 

} else{

clusters[complete.cases(newdata), paste0("predicted_tier_", timestep)] <- round(predict(model, newdata=newdata[complete.cases(newdata),]))

}

aa <- clusters
aa$geom=NULL
aa$geometry=NULL

clusters$HHs = ifelse(pull(aa[paste0("isurban_future_", timestep)])>0, clusters$population_future/urban_hh_size, clusters$population_future/rural_hh_size)

clusters[paste0('PerHHD_ely_tt' , "_", timestep)] <- clusters[paste0('PerHHD_ely' , "_", timestep)] * clusters$HHs * ifelse(latent_d_tot == T, 1, pmax((scenarios$el_access_share_target[scenario]  - clusters$elrate)))

clusters$acc_pop_t1_new =  (clusters$HHs * as.numeric(pull(aa[paste0("predicted_tier_", timestep)])==0) + clusters$HHs * as.numeric(pull(aa[paste0("predicted_tier_", timestep)])==1)) * ifelse(latent_d_tot == T, 1, pmax((scenarios$el_access_share_target[scenario]  - clusters$elrate) * demand_growth_weights[match(timestep, planning_year)], 0))

clusters$acc_pop_t1_new = ifelse(clusters$acc_pop_t1_new <0, 0, clusters$acc_pop_t1_new)

clusters$acc_pop_t2_new =  clusters$HHs * as.numeric(pull(aa[paste0("predicted_tier_", timestep)])==2) * ifelse(latent_d_tot == T, 1, pmax((scenarios$el_access_share_target[scenario]  - clusters$elrate) * demand_growth_weights[match(timestep, planning_year)], 0))

clusters$acc_pop_t2_new = ifelse(clusters$acc_pop_t2_new <0, 0, clusters$acc_pop_t2_new)


clusters$acc_pop_t3_new =  clusters$HHs * as.numeric(pull(aa[paste0("predicted_tier_", timestep)])==3) * ifelse(latent_d_tot == T, 1, pmax((scenarios$el_access_share_target[scenario]  - clusters$elrate) * demand_growth_weights[match(timestep, planning_year)], 0))

clusters$acc_pop_t3_new = ifelse(clusters$acc_pop_t3_new <0, 0, clusters$acc_pop_t3_new)


clusters$acc_pop_t4_new =  clusters$HHs * as.numeric(pull(aa[paste0("predicted_tier_", timestep)])==4) * ifelse(latent_d_tot == T, 1, pmax((scenarios$el_access_share_target[scenario]  - clusters$elrate) * demand_growth_weights[match(timestep, planning_year)], 0))

clusters$acc_pop_t4_new = ifelse(clusters$acc_pop_t4_new <0, 0, clusters$acc_pop_t4_new)


for (m in 1:12){
  for (i in 1:24){

    aa <- clusters
    aa$geometry=NULL
    aa$geom=NULL
    
    aa$isurban_future <- pull(aa[ paste0("isurban_future_", timestep)])
    
    clusters = mutate(clusters, !!paste0('PerHHD_' , as.character(m) , "_" , as.character(i)) := ifelse(aa$isurban_future > 0,  pull(!!as.name(paste0('urb1', "_" , as.character(m))))[i] * aa$acc_pop_t1_new +  pull(!!as.name(paste0('urb2', "_" , as.character(m))))[i] * aa$acc_pop_t2_new +  pull(!!as.name(paste0('urb3', "_" , as.character(m))))[i] * aa$acc_pop_t3_new +  pull(!!as.name(paste0('urb4', "_" , as.character(m))))[i] * aa$acc_pop_t4_new * 0.75 +  pull(!!as.name(paste0('urb5', "_" , as.character(m))))[i] * aa$acc_pop_t4_new * 0.25, ifelse(aa$isurban_future == 0,  pull(!!as.name(paste0('rur1', "_" , as.character(m))))[i] * aa$acc_pop_t1_new +  pull(!!as.name(paste0('rur2', "_" , as.character(m))))[i] * aa$acc_pop_t2_new +  pull(!!as.name(paste0('rur3', "_" , as.character(m))))[i] * aa$acc_pop_t3_new +  pull(!!as.name(paste0('rur4', "_" , as.character(m))))[i] * aa$acc_pop_t4_new * 0.75 +  pull(!!as.name(paste0('rur5', "_" , as.character(m))))[i] * aa$acc_pop_t4_new * 0.25 , 0)))
  }}

aa <- clusters
aa$geometry=NULL
aa$geom=NULL

for (m in 1:12){
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  out = aa %>% dplyr::select(starts_with(paste0("PerHHD_", as.character(m), "_"))) %>% rowSums(.)
  clusters[paste0('PerHHD_tt' ,"_monthly_" , as.character(m), "_", timestep)] = out
}

aa <- clusters
aa$geometry=NULL
aa$geom=NULL

out = aa %>% dplyr::select(starts_with("PerHHD_tt_monthly_") & contains(as.character(timestep))) %>% rowSums(.)

clusters[paste0('PerHHD_nely_tt' , "_", timestep)] <- as.numeric(out)



clusters[paste0('PerHHD_tt' , "_", timestep)] <- pull(aa[paste0('PerHHD_ely_tt' , "_", timestep)]) + as.numeric(out)

}

#

fracs <- vector()
for (m in 1:12){
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  fracs[m] <- sum(aa[paste0('PerHHD_tt' ,"_monthly_" , as.character(m), "_",  planning_year[2])], na.rm=T) / sum(aa[paste0('PerHHD_nely_tt_',  planning_year[2])], na.rm=T)
    

  }
  

for (timestep in planning_year){
  for (m in 1:12){
    
    aa <- clusters
    aa$geometry=NULL
    aa$geom=NULL
    
    clusters[paste0('PerHHD_tt' ,"_monthly_" , as.character(m), "_",  timestep)] = pull(aa[paste0('PerHHD_tt_', timestep)]) * fracs[m]
    
  }}

###############################################


if (output_hourly_resolution==F){
  
  ### remove the hourly fields
  
  clusters <- dplyr::select(clusters, -colnames(clusters)[grepl("PerHHD", colnames(clusters)) & !grepl("tt", colnames(clusters))])
  
 }


clusters <- st_as_sf(clusters)

rm(aa)

#save.image(paste0(processed_folder, "clusters_residential.Rdata"))
