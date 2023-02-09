library(tidyverse)

l <- list.files(pattern="summary_national", recursive = T)
l_ap <- lapply(l, read.csv)

for (i in 1:length(l)){
  l_ap[[i]]$scenario <- rep(basename(l[i]), nrow(l_ap[[i]]))
}

l_ap <- bind_rows(l_ap)

ggplot(l_ap)+
  geom_col(aes(x=year, y=value, fill=scenario, group=scenario), position = "dodge", colour="black")+
  xlab("Year")+
  ylab("National electricity demand (TWh)")+
  facet_wrap(vars(variable), scales = "free")
