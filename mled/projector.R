# gridded population 
population_fut <- stack(find_it(paste0("population_", scenarios$ssp[scenario], "soc_0p5deg_annual_2006-2100.nc")))[[-c(1:14)]]
population_fut <- exact_extract(brick(population_fut), gadm2, "sum")
population_fut <- dplyr::select(population_fut, 1:((last(planning_year)-2020)+1))

colnames(population_fut) <- paste0("pop_", 2020:last(planning_year))

population_fut_gr <- population_fut

for (i in 2:ncol(population_fut)){
  
  population_fut_gr[,i] <- ( population_fut[,i] -  population_fut[,i-1]) / population_fut[,i-1]
  
}

population_fut_gr[,1] <- NULL
colnames(population_fut_gr) <- paste0("pop_gr_", 2021:last(planning_year))

population_fut_gr$geometry <- gadm2$geometry
population_fut_gr <- st_as_sf(population_fut_gr)

# fasterize all layers and extract them into clusters !

template <- stack(find_it("population_ssp2soc_0p5deg_annual_2006-2100.nc"))[[1]]

out <- list()
j = 0

list_cols <- colnames(population_fut_gr)

for (i in list_cols[1:((last(planning_year)-2020))]){

  j = j+1
  
  out[[j]] <- fasterize(st_collection_extract(population_fut_gr, "POLYGON"), template, i, "first")
  
}

population_fut_gr <- exact_extract(stack(out), clusters, "mean")
colnames(population_fut_gr) <- list_cols[1:((last(planning_year)-2020))]

population_fut_gr <- population_fut_gr %>% mutate_all(~ifelse(is.na(.x), mean(.x, na.rm = TRUE), .x)) 

clusters <- bind_cols(clusters, population_fut_gr)

######################################

# gridded gdp (planning year)
gdp_future <- stack(find_it(paste0("gdp_", scenarios$ssp[scenario], "soc_10km_2010-2100.nc")))[[2:(2 + ((last(planning_year) - 2020) / 10))]]
gdp_fut <- exact_extract(brick(gdp_future), gadm2, "sum")

colnames(gdp_fut) <- paste0("gdp_", seq(2020, last(planning_year), 10))

gdp_fut_gr <- gdp_fut

population_fut <- dplyr::select(population_fut, matches(paste(planning_year, collapse="|")))

for (i in 2:ncol(gdp_fut)){
  
  gdp_fut_gr[,i] <- ( (gdp_fut[,i] / population_fut[,i]) -  (gdp_fut[,i-1] / population_fut[,i-1])) / (gdp_fut[,i-1] / population_fut[,i-1])
  
}

gdp_fut_gr[,1] <- NULL
colnames(gdp_fut_gr) <- paste0("gdp_gr_", seq(planning_year[2], last(planning_year), 10))

#

gdp_fut_gr$geometry <- gadm2$geometry
gdp_fut_gr <- st_as_sf(gdp_fut_gr)

#

wealth_baseline_r <- rasterize(wealth_baseline, gdp_future[[1]], "awi")
wealth_baseline <- exact_extract(wealth_baseline_r, clusters, "mean")

gdp_fut_gr_r <- list()

for (i in 1:(ncol(gdp_fut_gr)-1)){
  
  gdp_fut_gr_r[[i]] <- rasterize(gdp_fut_gr, gdp_future[[1]],  colnames(gdp_fut_gr)[i])
  
}

gdp_fut_gr_r <- stack(gdp_fut_gr_r)
gdp_fut_gr_r <- exact_extract(gdp_fut_gr_r, clusters, "mean")
gdp_fut_gr_r <- as.data.frame(gdp_fut_gr_r)

colnames(gdp_fut_gr_r) <- paste0("gdp_gr_", seq(planning_year[2], last(planning_year), 10))

gdp_fut_gr_r <- gdp_fut_gr_r %>% mutate_all(~ifelse(is.na(.x), mean(.x, na.rm = TRUE), .x)) 

wealth_baseline <- data.frame(gdp_capita_2020 = wealth_baseline)
wealth_baseline <- wealth_baseline %>% mutate_all(~ifelse(is.na(.x), mean(.x, na.rm = TRUE), .x)) 

for (year in seq(planning_year[2], last(planning_year), 10)){

wealth_baseline[paste0("gdp_capita_", year)] <- wealth_baseline[paste0("gdp_capita_", (year - 10))] * (1+(gdp_fut_gr_r[paste0("gdp_gr_", year)]))

}

clusters <- bind_cols(clusters, wealth_baseline)
