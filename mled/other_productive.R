
## This R-script:
##      1) calculates SMEs / non-farm micro enterprises electricity demand at each time step based on an adjustment factor of residential demand based on roads availability, market accessibility, and employment rates at each cluster


# calculate paved road density in each cluster 
clusters$roadslenght = exact_extract(roads, clusters, "mean")

# calculate travel time to 50 k in each cluster
clusters$traveltime = exact_extract(traveltime, clusters, 'mean')

# calculate employment rate in each cluster
empl_wealth <- dplyr::select(empl_wealth, (starts_with("EM") | starts_with("id")))

if(nrow(empl_wealth)>0){

empl_wealth_1 <- fasterize::fasterize(empl_wealth, traveltime, "EMEMPLWEMC", "first")
empl_wealth_2 <- fasterize::fasterize(empl_wealth, traveltime, "EMEMPLMEMC", "first")

clusters$EMEMPLWEMC = exact_extract(traveltime, clusters, 'mean') / 100
clusters$EMEMPLMEMC = exact_extract(traveltime, clusters, 'mean') / 100

clusters$EMEMPLWEMC <- ifelse(clusters$EMEMPLWEMC>1, 1, clusters$EMEMPLWEMC)
clusters$EMEMPLMEMC <- ifelse(clusters$EMEMPLMEMC>1, 1, clusters$EMEMPLMEMC)

# run PCA
clusters$employment = (clusters$EMEMPLMEMC + clusters$EMEMPLWEMC)/2

} else{
  
  clusters$employment = 1
}

data_pca = dplyr::select(clusters, employment, popdens_future, traveltime)
data_pca$geom=NULL
data_pca$geometry=NULL

data_pca[] <- future_lapply(data_pca, function(x) { 
x[is.na(x)] <- mean(x, na.rm = TRUE)
x
}, future.seed=TRUE)

data_pca <- future_lapply(data_pca, function(x) round((x-min(x, na.rm=T))/(max(x, na.rm=T)-min(x, na.rm=T)), 2), future.seed=TRUE) %>% bind_cols()

data_pca <- data_pca[ , colSums(is.na(data_pca)) == 0]

data_pca_bk <- data_pca

data_pca <- prcomp(data_pca)

PCs <- as.data.frame(data_pca$x)
PCs$PCav <- PCs$PC1

# scales::rescale PCA to markup range

PCs$PCav <- scales::rescale(PCs$PCav, to = range_smes_markup)


#########

for (timestep in planning_year){

clusters_productive = dplyr::select(clusters, id, (starts_with("PerHHD_") & contains(as.character(timestep)))) %>% as.data.frame()
clusters_productive$geom= NULL
clusters_productive$geometry=NULL

clusters_productive = dplyr::select(clusters_productive, contains("monthly"))

clusters_productive = PCs$PCav * clusters_productive

colnames(clusters_productive) <- gsub("PerHHD_tt", "residual_productive_tt", colnames(clusters_productive))

aa <- clusters_productive
aa$geom=NULL
aa$geometry=NULL

clusters_productive[paste0('residual_productive_tt_', timestep)] <- rowSums(aa, na.rm=T)

clusters <- bind_cols(clusters, clusters_productive)

}

#save.image(paste0(processed_folder, "clusters_other_productive.Rdata"))

