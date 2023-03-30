
## This R-script:
##      1) estimates electricity demand from schools and healthcare facilities in each cluster to meet RAMP-generated appliance-based loads based on the predicted tier/size of each facility at each time step

##

# Estimate the yearly electric demand from healthcare and education facilities
# define consumption of facility types (kWh/facility/year)
clusters <- st_as_sf(clusters)

clusters$beds_1 <- lengths(st_intersects(clusters_voronoi, health %>% filter(Tier==1)))
clusters$beds_2 <- lengths(st_intersects(clusters_voronoi, health %>% filter(Tier==2)))
clusters$beds_3 <- lengths(st_intersects(clusters_voronoi, health %>% filter(Tier==3)))
clusters$beds_4 <- lengths(st_intersects(clusters_voronoi, health %>% filter(Tier==4)))

# adjust to fill (potential) missing data

clusters$beds_1 <- ifelse(clusters$population>50 & clusters$beds_1==0, 1, clusters$beds_1)
clusters$beds_2 <- ifelse(clusters$population>100 & clusters$beds_2==0, 1, clusters$beds_2)
clusters$beds_3 <- ifelse(clusters$population>1000 & clusters$beds_3==0 & clusters$isurban==1, 1, clusters$beds_3)
clusters$beds_4 <- ifelse(clusters$population>5000 & clusters$beds_4==0 & clusters$isurban==1, 1, clusters$beds_4)

#

clusters$beds_1 <- clusters$beds_1 * 1  
clusters$beds_2 <- clusters$beds_2 * beds_tier2
clusters$beds_3 <- clusters$beds_3 * beds_tier3
clusters$beds_4 <- clusters$beds_4 * beds_tier4

clusters$schools <- lengths(st_intersects(clusters_voronoi, primaryschools)) 

# adjust to fill (potential) missing data

clusters$schools <- ifelse(clusters$population>100 & clusters$schools==0, 1, clusters$schools)

clusters$schools <- clusters$schools * pupils_per_school

#

for (timestep in planning_year){
  
  
  if(timestep>=planning_year[2]){
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
    
    clusters$schools = ifelse(clusters$schools==0 & pull(aa[paste0("population_", timestep)]) > 100, 1, round(clusters$schools*((1+pull(aa[paste0("pop_gr_", timestep)]))^10)))
    
    clusters$beds_1 = ifelse(clusters$beds_1==0 & pull(aa[paste0("population_", timestep)]) > 50, 1, round(clusters$beds_1*((1+pull(aa[paste0("pop_gr_", timestep)]))^10)))
    
    clusters$beds_2 = ifelse(clusters$beds_2==0 & pull(aa[paste0("population_", timestep)]) > 100, 1, round(clusters$beds_2*((1+pull(aa[paste0("pop_gr_", timestep)]))^10)))
    
    clusters$beds_3 = ifelse(clusters$beds_3==0 & pull(aa[paste0("population_", timestep)]) > 1000, 1, round(clusters$beds_3*((1+pull(aa[paste0("pop_gr_", timestep)]))^10)))
    
    clusters$beds_4 = ifelse(clusters$beds_4==0 & pull(aa[paste0("population_", timestep)]) > 5000, 1, round(clusters$beds_4*((1+pull(aa[paste0("pop_gr_", timestep)]))^10)))
    
  }
    
for (m in 1:12){
  for (i in 1:24){
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
    clusters = mutate(clusters, !!paste0('er_hc_' , as.character(m) , "_" , as.character(i)) := (pull(!!as.name(paste0('health1', "_" , as.character(m))))[i] * clusters$beds_1 + pull(!!as.name(paste0('health2', "_" , as.character(m))))[i] * clusters$beds_2 + pull(!!as.name(paste0('health3', "_" , as.character(m))))[i] * clusters$beds_3 + pull(!!as.name(paste0('health4', "_" , as.character(m))))[i] * clusters$beds_4) * scenarios$el_access_share_target[scenario] * demand_growth_weights[match(timestep, planning_year)]) 
    
    aa <- clusters
    aa$geom=NULL

    clusters = mutate(clusters, !!paste0('er_sch_' , as.character(m) , "_" , as.character(i)) := ( pull(!!as.name(paste0('edu', "_" , as.character(m))))[i] / pupils_per_school * clusters$schools) * scenarios$el_access_share_target[scenario] * demand_growth_weights[match(timestep, planning_year)]) 
    
    aa <- clusters
    aa$geom=NULL
    aa$geometry=NULL
    
  }}

for (m in 1:12){
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL
  
  out = aa %>% dplyr::select(starts_with(paste0("er_hc_", as.character(m), "_"))) %>% rowSums(.)
  clusters[paste0('er_hc_tt' ,"_monthly_" , as.character(m), "_", timestep)] = out
  
}

aa <- clusters
aa$geom=NULL
aa$geometry=NULL

# Generate variable for total daily demand and variables as shares of the daily demand
out = aa %>% dplyr::select(starts_with("er_hc_tt_monthly_") & contains(as.character(timestep))) %>% rowSums(.)
clusters[paste0('er_hc_tt_', timestep)] = as.numeric(out)

for (m in 1:12){
  
  aa <- clusters
  aa$geom=NULL
  aa$geometry=NULL
  
  out = aa %>% dplyr::select(starts_with(paste0("er_sch_", as.character(m), "_"))) %>% rowSums(.)
  clusters[paste0('er_sch_tt' ,"_monthly_" , as.character(m), "_", timestep)] = out
  
}


aa <- clusters
aa$geom=NULL
aa$geometry=NULL

out = aa %>% dplyr::select(starts_with("er_sch_tt_monthly_") & contains(as.character(timestep))) %>% rowSums(.)
clusters[paste0('er_sch_tt_', timestep)] = out

}


#save.image(paste0(processed_folder, "clusters_healthedu.Rdata"))
