
urbproj = dplyr::select(urbproj, Scenario, Region, starts_with("2"))
urbproj$Scenario = substr(urbproj$Scenario, 1, 4)

urbproj = filter(urbproj, Region==countryiso3, Scenario==toupper(scenarios$ssp[scenario]))


for(timestep in planning_year[-1]){
  
  aa = clusters
  aa$geometry <- NULL
  aa$geom <- NULL
  
    clusters[paste0("population_", timestep)] <-  aa[ifelse(timestep==planning_year[2], "population" , paste0("population_", (timestep - 10)))] * (1 + aa[paste0("pop_gr_", timestep)])^10
  
}

for(timestep in planning_year){

  aa = clusters
  aa$geometry <- NULL
  aa$geom <- NULL
  
pops = aa[ifelse(timestep==planning_year[1], "population" , paste0("population_", timestep))]
pops = data.frame(pops)
pops = dplyr::arrange(pops, -pops)
  
urb_rate =   pull(urbproj[,as.character(timestep)]) / 100

i = 1

pops[paste0(ifelse(timestep > planning_year[1], "isurban_future_", "isurban_"), timestep)] = 0

repeat{
  
  pops[i,paste0(ifelse(timestep > planning_year[1], "isurban_future_", "isurban_"), timestep)] = 1
  
  urb_rate_est = sum( pops[ifelse(timestep==planning_year[1], "population" , paste0("population_", timestep))][pops[paste0(ifelse(timestep > planning_year[1], "isurban_future_", "isurban_"), timestep)]==1], na.rm=T) / sum(pops[ifelse(timestep==planning_year[1], "population" , paste0("population_", timestep))], na.rm=T)
  
    i = i + 1
    
  if (urb_rate_est >= urb_rate) break
}

clusters[,paste0(ifelse(timestep > 2020, "isurban_future_", "isurban_"), timestep)] = pops[,paste0(ifelse(timestep > 2020, "isurban_future_", "isurban_"), timestep)]

}


