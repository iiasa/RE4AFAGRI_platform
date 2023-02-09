
## This R-script:
##      1) applies some constraints specified in the main M-LED file to cap electricity demand

##      2) generate a summary figure of total electricity load per sector at each time step
##      3) renames demand fields

if (no_productive_demand_in_small_clusters == T){
  
  clusters <- clusters %>% mutate_at(vars(contains("residual_productive" )), funs(ifelse(population<pop_threshold_productive_loads, 0, .)))
  
  clusters <- clusters %>% mutate_at(vars(contains("kwh_cp" )), funs(ifelse(population<pop_threshold_productive_loads, 0, .)))
  
  clusters <- clusters %>% mutate_at(vars(contains("mining_kwh" )), funs(ifelse(population<pop_threshold_productive_loads, 0, .)))
  
}


# add other demand

other_demand <- electr_final_demand_tot - (sum(clusters$PerHHD_tt_2020, na.rm=T) + sum(clusters$residual_productive_tt_2020, na.rm=T) + sum(clusters$mining_kwh_tt_2020, na.rm=T)) 

other_demand <- ifelse(other_demand<0, 0, other_demand)

aa <- clusters
aa$geom=NULL
aa$geometry=NULL

clusters[paste0('other_tt' , "_", "2020")] <- (pull(aa[paste0('residual_productive_tt' , "_", "2020")]) / sum(pull(aa[paste0('residual_productive_tt' , "_", "2020")]), na.rm=T)) * other_demand


for (timestep in planning_year[-1]){
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL

  clusters[paste0('other_tt' , "_", timestep)] <- (pull(aa[paste0('other_tt' , "_", as.character(timestep-10))])) * (1 + ((pull(aa[paste0("gdp_capita_", timestep)]) - pull(aa[paste0("gdp_capita_", (timestep-10))])) / pull(aa[paste0("gdp_capita_", (timestep-10))])))

}

# make mining and other "monthly"

for (timestep in planning_year){
for (m in 1:12){
  
  aa <- clusters
  aa$geometry=NULL
  aa$geom=NULL
  
  clusters[paste0('mining_kwh_tt' ,"_monthly_" , as.character(m), "_",  timestep)] = pull(aa[paste0('mining_kwh_tt_',  timestep)]) * share_demand_by_month_other_sectors[m]
  
  clusters[paste0('other_tt' ,"_monthly_" , as.character(m), "_",  timestep)] = pull(aa[paste0('other_tt_',  timestep)]) * share_demand_by_month_other_sectors[m]
  
  
}}


####

aa <- clusters
aa$geometry=NULL
aa$geom=NULL

PerHHD_tt <- melt(as.vector(aa %>% dplyr::select(starts_with("PerHHD_tt") & !contains("monthly")) %>% summarise_all(.funs = "sum", na.rm=T)))
residual_productive_tt <- melt(as.vector(aa %>% dplyr::select(starts_with("residual_productive_tt") & !contains("monthly")) %>% summarise_all(.funs = "sum", na.rm=T)))
er_hc_tt <- melt(as.vector(aa %>% dplyr::select(starts_with("er_hc_tt") & !contains("monthly")) %>% summarise_all(.funs = "sum", na.rm=T)))
er_sch_tt <- melt(as.vector(aa %>% dplyr::select(starts_with("er_sch_tt") & !contains("monthly")) %>% summarise_all(.funs = "sum", na.rm=T)))
er_kwh_tt <- melt(as.vector(aa %>% dplyr::select(starts_with("er_kwh_tt") & !contains("monthly") & !contains("offgrid")) %>% summarise_all(.funs = "sum", na.rm=T)))

er_kwh_tt_offgrid <- melt(as.vector(aa %>% dplyr::select(starts_with("er_kwh_tt") & !contains("monthly") & contains("offgrid")) %>% summarise_all(.funs = "sum", na.rm=T)))

kwh_cp_tt <- melt(as.vector(aa %>% dplyr::select(starts_with("kwh_cp_tt") & !contains("monthly")) %>% summarise_all(.funs = "sum", na.rm=T)))
mining_kwh_tt <- melt(as.vector(aa %>% dplyr::select(starts_with("mining_kwh_tt") & !contains("monthly")) %>% summarise_all(.funs = "sum", na.rm=T)))
other_kwh_tt <- melt(as.vector(aa %>% dplyr::select(starts_with("other_tt") & !contains("monthly")) %>% summarise_all(.funs = "sum", na.rm=T)))

#

all_sectors <- bind_rows(PerHHD_tt, residual_productive_tt, er_hc_tt, er_sch_tt, er_kwh_tt, kwh_cp_tt, mining_kwh_tt, other_kwh_tt, er_kwh_tt_offgrid)

colnames(all_sectors)[2] <- "variable"

all_sectors$variable <- as.character(all_sectors$variable)
all_sectors$variable[41:45] <- gsub("_offgrid", "", all_sectors$variable[41:45])
substrRight <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}

all_sectors$year <- as.numeric(substrRight(all_sectors$variable, 4))
all_sectors$variable <- sub('_[^_]*$', "", all_sectors$variable )
all_sectors$variable[41:45] <- paste0(all_sectors$variable[41:45], "_offgrid")

#

all_sectors$variable <- gsub("PerHHD", "residential", all_sectors$variable)
all_sectors$variable <- gsub("residual_productive", "nonfarm_smes", all_sectors$variable)
all_sectors$variable <- gsub("er_hc", "healthcare", all_sectors$variable)
all_sectors$variable <- gsub("er_sch", "education", all_sectors$variable)
all_sectors$variable <- gsub("er_kwh", "water_pumping", all_sectors$variable)
all_sectors$variable <- gsub("kwh_cp", "crop_processing", all_sectors$variable)
all_sectors$variable <- gsub("mining", "mining", all_sectors$variable)
all_sectors$variable <- gsub("other", "other", all_sectors$variable)

#

colnames(all_sectors) <- c("value", "variable","year")

ggplot(all_sectors)+
  geom_line(aes(x=year, y=value/1e9, colour=variable, group=variable), size=1)+
  xlab("Year")+
  ylab("National electricity demand (TWh)")

ggsave( paste0("results/", countrystudy, "_demand_lines_", paste(scenarios[scenario,], collapse = "_"), ".png"))

ggplot(all_sectors)+
  geom_col(aes(x=year, y=value/1e9, fill=variable))+
  xlab("Year")+
  ylab("National electricity demand (TWh)")+
  facet_wrap(vars(variable), scales = "free")

ggsave( paste0("results/", countrystudy, "_demand_bars_", paste(scenarios[scenario,], collapse = "_"), ".png"))

demand_summary <- all_sectors
demand_summary$value <- demand_summary$value/1e9
write.csv(demand_summary, paste0("results/", countrystudy, "_summary_national_", paste(scenarios[scenario,], collapse = "_"), ".csv"))

###

# rename demand fields

colnames(clusters) <- gsub("PerHHD", "residential", colnames(clusters))
colnames(clusters) <- gsub("residual_productive", "nonfarm_smes", colnames(clusters))
colnames(clusters) <- gsub("er_hc", "healthcare", colnames(clusters))
colnames(clusters) <- gsub("er_sch", "education", colnames(clusters))
colnames(clusters) <- gsub("er_kwh", "water_pumping_monthly_", colnames(clusters))
colnames(clusters) <- gsub("monthly__", "", colnames(clusters))
colnames(clusters) <- gsub("kwh_cp", "crop_processing", colnames(clusters))
colnames(clusters) <- gsub("mining", "mining", colnames(clusters))
colnames(clusters) <- gsub("other", "other", colnames(clusters))

###############
##############

# which(clusters$PerHHD_tt_2030 > clusters$PerHHD_tt_2050)
# 
# clusters[2,]$population_2020
# clusters[2,]$population_2050
# 
# clusters[2,]$PerHHD_tt_2030
# clusters[2,]$PerHHD_tt_2050

