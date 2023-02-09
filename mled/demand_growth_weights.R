
gdp_capita_evolution <- as.numeric(colSums(gdp_fut) / colSums(population_fut))
gdp_capita_evolution <- gdp_capita_evolution / last(gdp_capita_evolution)

demand_growth_weights <- gdp_capita_evolution

