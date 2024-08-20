# LEAP-RE post-processing scripts for figures

library(tidyverse)
library(poorman)
library(xlsx)
library(rworldmap)
library(sf)

rm(list=ls())

in_path = paste0(getwd(),"/outputs")
# setwd(in_path)
iso3 = "ZMB"
country = "Zambia"
# this might eb wrong
# get parent path of getwd
data_path = paste0(dirname(getwd()),"/data/ZMB/")
basin.sf = st_read( paste0(data_path,country, '_NEST_delineation/',country,'_NEST_delineation.shp'))
# map plotting
regions <- st_as_sf(rworldmap::countriesLow)

csv_files = list.files(path = in_path,pattern = 'leap-re.csv')

marker_output = NULL

for (x in csv_files){
  temp_xls = read.csv(paste0(in_path,"/",x),check.names = FALSE)
  marker_output = rbind(marker_output,temp_xls)
  
}
out_path = paste0(getwd(),"/out_figures")

# water inv global
vars_costs = c("Infrastructure|Water|Cooling",
               # "Infrastructure|Water|Other",
               "Infrastructure|Water|Irrigation",  
               "Infrastructure|Water| Distribution",
               "Infrastructure|Water|Unconnected",
               "Infrastructure|Water|Desalination",
               "Infrastructure|Water|Extraction",
               "Infrastructure|Water|Treatment & Recycling",
               "Energy Supply|Electricity"  ,
               "Energy Supply|Extraction",
               "Energy Supply|Gas",
               "Energy Supply|Hydrogen",                                 
               "Energy Supply|Liquids" 
               )

# clean scenario names
marker_output = marker_output %>% 
  mutate(scenario = gsub("MLED_|_nexus_full",'',scenario))


# investments
inv.df = marker_output %>% filter(grepl('Investment\\|',variable)) %>% 
  mutate(variable = gsub('Investment\\|','',variable)) %>% 
  filter(variable %in% vars_costs) %>% 
  filter(region == "Zambia",
         year >= 2020, year < 2060,
         value > 0) %>% 
  mutate(value = value * 1000,
         unit = "million US$2010/y") %>% 
  group_by(scenario,region, variable, unit, subannual) %>% 
  summarise(value = mean(value)) %>% ungroup()

ggplot(data = inv.df)+
  geom_bar(aes(x = factor(variable),
               y = value,
               fill = factor(variable)),
           stat = 'identity', position = 'stack')+
  facet_wrap(~scenario)+
  theme_classic()

# elec investments
elec_cost.df = marker_output %>% filter(grepl("Energy Supply\\|Electricity", variable)) %>% 
  mutate(tec = gsub(".+\\|([^\\|]+)$", "\\1", variable),
         inv_oem = if_else(grepl("Investment", variable),"Investment","Operational"),
         tec = if_else(grepl("Distribution",tec),"Transmission and Distribution", tec)) %>% 
  filter(!tec %in% c("Electricity")) %>% 
  group_by(scenario,tec, inv_oem,year, unit) %>% 
  summarise(value = sum(value)) %>% ungroup()

# plot
el_inv = ggplot(data = elec_cost.df %>% filter(year >= 2020, year < 2060,
                                      value != 0
                                      # ,!grepl("Distribution", tec)
                                      ))+
  geom_bar(aes(x = year,
               y = value,
               fill = tec),
           stat = 'identity', position = 'stack',
           alpha = 0.6, color = "grey20", linewidth = 0.2)+
  scale_fill_brewer(name = "Sectors",palette = "Set3")+
  scale_y_continuous(expand=c(0,0))+
  theme_classic()+
  facet_wrap(inv_oem~factor(scenario, levels =c("baseline","improved","ambitious")))+
  xlab("")+ylab("billion US$2010/y")+
  ggtitle("Average expenditure for electricity generation")

# save as png
ggsave(paste0("out_figures/Electricity_investments_OM_",country,".png"), el_inv, scale=1, height = 4.5, width = 7)

en_inv.df = inv.df %>% filter(grepl("Energy Supply|Cooling", variable)) %>% 
  mutate(variable = gsub(".+\\|([^\\|]+)$", "\\1", variable),
         variable = if_else(variable %in% c("Extraction","Gas","Liquids"), "Fossil fuels", variable)) %>% 
  group_by(scenario,region,variable,unit,subannual) %>% 
  summarise(value = sum(value)) %>% ungroup() %>% 
  mutate(cost = "Investment")

# water investments
wat_inv.df = inv.df %>% filter(!grepl("Energy Supply|Cooling", variable)) %>% 
  mutate(variable = gsub(".+\\|([^\\|]+)$", "\\1", variable),
         variable = if_else(variable == "Extraction", "Distribution & Pumping", variable)) %>% 
  filter(variable != "Desalination") %>% 
  group_by(scenario,region,variable,unit,subannual) %>%
  summarise(value = sum(value)) %>% ungroup() %>% 
  mutate(cost = "Investment")

# variable costs
var.df = marker_output %>% filter(grepl('Total Operation Management Cost\\|',variable)) %>% 
  mutate(variable = gsub('Total Operation Management Cost\\|','',variable)) %>%
  filter(variable %in% vars_costs) %>% 
  filter(region == "Zambia",
         year >= 2020, year < 2060,
         value > 0) %>% 
  mutate(value = if_else(unit == "billion US$2010/yr" ,value*1000 ,value ),
         unit = "million US$2010/y") %>% 
  group_by(scenario,region, variable, unit, subannual) %>% 
  summarise(value = mean(value)) %>% ungroup()

en_var.df = var.df %>% filter(grepl("Energy Supply|Cooling", variable)) %>% 
  mutate(variable = gsub(".+\\|([^\\|]+)$", "\\1", variable),
         variable = if_else(variable %in% c("Extraction","Gas","Liquids"), "Fossil fuels", variable)) %>% 
  group_by(scenario,region,variable,unit,subannual) %>% 
  summarise(value = sum(value)) %>% ungroup() %>% 
  mutate(cost = "Operational")

en1 = ggplot(data = en_inv.df %>% bind_rows(en_var.df))+
  geom_bar(aes(x = factor(scenario, levels =c("baseline","improved","ambitious")),
               y = value,
               fill = factor(variable,levels = c("Electricity","Fossil fuels","Cooling"))),
           stat = 'identity', position = 'stack',
           width = 0.5, size = 0.05, color = 'black')+
  scale_fill_brewer(name = "Sectors",palette = "Accent")+
  scale_y_continuous(expand=c(0,0))+
  theme_classic()+
  theme(strip.text = element_text(size = 11),
        axis.text.x = element_text(size = 12))+
  facet_wrap(~cost)+
  xlab("")+ylab(unique(en_inv.df$unit))+
  ggtitle("Energy average annual expenditure")

ggsave(paste0("out_figures/Energy_investments_OM_",country,".png"), en1, scale=1, height = 5, width = 7)

# summary
en_inv_sum.df = en_inv.df %>% group_by(scenario,region,unit) %>% 
  summarise(value = sum(value)) %>% ungroup()
en_var_sum.df = en_var.df %>% group_by(scenario,region,unit) %>% 
  summarise(value = sum(value)) %>% ungroup()

wat_var.df = var.df %>% filter(!grepl("Energy Supply|Cooling", variable)) %>% 
  mutate(variable = gsub(".+\\|([^\\|]+)$", "\\1", variable),
         variable = if_else(variable %in% c("Extraction","Desalination"), "Non renewable water Pumping", variable),
         variable = if_else(variable %in%  c("Unconnected"," Distribution"), "Distribution & Pumping", variable) ) %>% 
  # filter(variable != "Desalination") %>% 
  group_by(scenario,region,variable,unit,subannual) %>%
  summarise(value = sum(value)) %>% ungroup() %>% 
  mutate(cost = "Operational") %>% 
  filter(variable != "Non renewable water Pumping")

# plot water costs
wat1 = ggplot(data = wat_inv.df %>% bind_rows(wat_var.df))+
  geom_bar(aes(x = factor(scenario, levels =c("baseline","improved","ambitious")),
               y = value,
               fill = variable),# factor(variable,levels = c("Electricity","Fossil fuels","Cooling"))),
           stat = 'identity', position = 'stack',
           width = 0.5, size = 0.05, color = 'black')+
  scale_fill_brewer(name = "Sectors",palette = "Pastel1", direction = -3)+
  theme_classic()+
  facet_wrap(~cost)+
  xlab("")+ylab(unique(wat_inv.df$unit))+
  ggtitle("Water infrastructure average annual expenditure")

ggsave(paste0("out_figures/water_investments_OM_",country,".png"), wat1, scale=1, height = 7, width = 7)

#summaries
irr_summ.df = wat_inv.df %>% bind_rows(wat_var.df) %>% 
  filter(variable == "Irrigation")
wat_summ.df = wat_inv.df %>% bind_rows(wat_var.df) %>% 
  filter(variable != "Irrigation") %>% 
  group_by(scenario,region,unit,cost) %>% 
  summarise(value = sum(value)) %>% ungroup()

#  what is it?
ggplot(data = var.df)+
  geom_bar(aes(x = factor(variable),
               y = value,
               fill = factor(variable)),
           stat = 'identity', position = 'stack')+
  facet_wrap(~scenario)+
  theme_classic()

# secondary energy
sec_en.df = marker_output %>% filter(grepl('Secondary Energy\\|Electricity\\|',variable)) %>% 
  mutate(variable = gsub('Secondary Energy\\|Electricity\\|','',variable)) %>% 
  filter(region == "Zambia",
         subannual == 'year',
         year > 2010, year < 2060,
         value != 0)

# area energy mix
ggplot(data = sec_en.df )+# %>% filter(scenario == "baseline"))+
  geom_area(aes(x = year,y = value * 277.8,fill = variable),
            stat = 'identity', position = 'stack', color = "black",size = 0.005)+
  geom_hline(yintercept = 0, color = "black"  )+
  scale_fill_brewer(name = "sectors",palette = "RdYlBu",direction = -3)+
  theme_classic()+
  theme(axis.title.x=element_blank(),
        # axis.text.x = element_text(angle = 90),
        legend.position = "right",
        panel.spacing.x = unit(1, "lines"),
        axis.text = element_text(size = 9))+
  facet_wrap(~factor(scenario, levels =c("baseline","improved","ambitious")) )+
  ggtitle("Total electricity summply, by technology")+
  ylab("TWh" )

# check treament capacity
cap_treat.df = marker_output %>% 
  filter(grepl('Capacity Additions\\|Infrastructure\\|Water\\|Treatment & Recycling\\|',variable)) %>% 
  mutate(variable = gsub('Capacity Additions\\|Infrastructure\\|Water\\|Treatment & Recycling\\|','',variable)) %>% 
  filter(region == "Zambia",
         year >= 2020, year < 2060) 

ggplot(cap_treat.df)+
  geom_line(aes(x = year, y = value, color = variable) )+
  facet_wrap(~scenario)+
  theme_classic()

# water withdrawals

ww.df = marker_output

vars_w = c("Water Waste|Reuse",
           "Water Extraction|Seawater|Desalination",
           "Water Extraction|Brackish Water",
           "Water Extraction|Groundwater",
           "Water Extraction|Surface Water")

# water supply and withdrawals
# annual
wat_sup_t = marker_output %>% filter(variable %in% vars_w) %>% 
  mutate(variable = gsub('Water Waste\\|','',variable),
         variable = gsub('Water Extraction\\||Seawater\\|','',variable)) %>% 
  filter(!is.na(value)) %>% ungroup() %>% mutate(year = as.numeric(year)) 
  # filter(region == country) %>% 
  # group_by(scenario,region,variable,unit, year) %>% 
  # summarise(value = sum(value)) %>% ungroup()

wat_ww_all = c("Water Withdrawal|Energy techs & Irrigation",
               "Water Withdrawal|Extraction",
               "Water Withdrawal|Irrigation",
               "Water Withdrawal|Industrial Water",
               "Water Withdrawal|Municipal Water")

wat_ww_t = marker_output %>% filter(variable %in% wat_ww_all
                                        # region == country
                                    ) %>% 
  filter(!is.na(value)) %>% ungroup() %>% mutate(year = as.numeric(year)) %>% 
  mutate(variable = gsub("Water Withdrawal\\|","",variable),
         variable = gsub("Unconnected","",variable))
  # group_by(scenario,region,variable,unit, year) %>% 
  # summarise(value = sum(value)) %>% ungroup()

water_ts_plot = wat_sup_t %>% bind_rows(
  wat_ww_t %>% mutate(value = -value)) # set ww as negative

# plot
# water withdrawals from power plants/cooling is missing, it was in the old reporting
p = ggplot(data = water_ts_plot %>% mutate(subannual = as.numeric(subannual)) %>% 
         filter(
           (year %in% c(2030)) | (year == 2020 & scenario == "baseline")
           # year %in% c(2020,2050)
           , region %in% c("Zambia")
           ))+
  geom_area(aes(x = subannual,y = value,fill = variable),
            stat = 'identity', position = 'stack', color = "black",size = 0.005)+
  geom_hline(yintercept = 0, color = "black"  )+
  scale_fill_brewer(name = "sectors",palette = "RdYlBu",direction = -3)+
  theme_bw(base_size=8)+
  theme(axis.title.x=element_blank(),
        strip.text = element_text(size = 12),
        axis.ticks.x=element_blank(),
        legend.position = "bottom",
        legend.text = element_text(size = 12),
        legend.key.width = unit(0.4, "cm"), legend.key.height = unit(0.4, "cm"))+
  facet_wrap(factor(scenario, levels =c("baseline","improved","ambitious"))~year, nrow = 1)+
  ggtitle("Water supply and withdrawals")+
  ylab(paste0(unique(water_ts_plot$unit)) )

wbp = p + guides(fill = guide_legend(ncol = 3))
ggsave(paste0("out_figures/water_balance_",country,".png"), wbp, scale=1, height = 6, width = 9)
# basins detail
# ggplot(data = water_ts_plot %>% mutate(subannual = as.numeric(subannual)) %>% 
#          filter(
#            # scenario == 'baseline',
#            year %in% c(2050)
#            , !region %in% c("Zambia")
#          ))+
#   geom_area(aes(x = subannual,y = value,fill = variable),
#             stat = 'identity', position = 'stack', color = "black",size = 0.005)+
#   geom_hline(yintercept = 0, color = "black"  )+
#   scale_fill_brewer(name = "sectors",palette = "RdYlBu",direction = -3)+
#   theme_bw(base_size=8)+
#   theme(axis.title.x=element_blank(),
#         # axis.text.x = element_text(angle = 90),
#         axis.ticks.x=element_blank(),
#         legend.position = "right")+
#   facet_wrap(factor(scenario, levels =c("baseline","improved","ambitious"))~region)+
#   ggtitle("Water supply and withdrawals")+
#   ylab(paste0(unique(water_ts_plot$unit)) )

#### Onsset shares of electricity ####
ONSET_xls = read.csv(paste0( data_path,
                            "/OnSSET/shares_grid/energy_allocation_results_for_nest.csv"),
                    check.names = FALSE)
# group in grid, offgrid and unconnected, sum urban rural
shares_elec.df = ONSET_xls %>% 
  mutate(tec = if_else(grepl("grid",tec),"grid",
                        if_else(tec == "unelectrified", tec,"off-grid")) ) %>% 
  group_by(BCU, tec, year, scenario, unit) %>% 
  summarise(value = sum(value)) %>% ungroup() %>% 
  group_by(BCU, year, scenario, unit) %>% 
  mutate(tot_group = sum(value)) %>% ungroup() %>% 
  mutate(share_en = round(value / tot_group, digits = 2) )

ele_share.sf =  st_as_sf(
  shares_elec.df %>% 
  left_join(basin.sf %>% select(BCU,geometry )) )

# map share of electrification by scenarios, 2020 and 2050
a1 = ggplot()+
  theme_classic()+
  geom_sf(data=regions, fill="#f5efdf")+
  geom_sf(data=ele_share.sf %>% filter(#(year %in% c(2030)) | (year == 2020 & scenario == "baseline"),
                                  tec == "unelectrified"), 
          aes(fill=cut(1-share_en,breaks=c(0,0.25,0.5,0.75,1))) )+
  facet_wrap( factor(scenario, levels =c("baseline","improved_access","ambitious_development"))~year, ncol = 3)+
  scale_fill_brewer(name="Share", palette = "Reds")+
  coord_sf(xlim=c(21, 35), ylim=c(-18, -7))+
  ggtitle("")+
  theme(legend.position = "bottom", 
        legend.direction = "horizontal", 
        # aspect.ratio = 3/4, 
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(), 
        axis.text.y=element_blank(), 
        axis.ticks.y=element_blank(),
        strip.text = element_text(size = 12))+
  ggtitle("Electrification rate of Zambia for different scenarios")

ggsave(paste0("out_figures/electrification_OnSSET_NEST_",country,".png"), a1, scale=1, height = 5, width = 10)

# horizontal 4 scen

a3 =ggplot()+
  theme_classic()+
  geom_sf(data=regions, fill="#f5efdf")+
  geom_sf(data=ele_share.sf %>% filter((year %in% c(2030)) | (year == 2020 & scenario == "baseline"),
    tec == "unelectrified"), 
    aes(fill=cut(1-share_en,breaks=c(0,0.25,0.5,0.75,1))) )+
  facet_wrap( factor(scenario, levels =c("baseline","improved_access","ambitious_development"))~year, ncol = 4)+
  scale_fill_brewer(name="Share", palette = "Reds")+
  coord_sf(xlim=c(21, 35), ylim=c(-18, -7))+
  ggtitle("")+
  theme(legend.position = "bottom", 
        legend.direction = "horizontal", 
        # aspect.ratio = 3/4, 
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(), 
        axis.text.y=element_blank(), 
        axis.ticks.y=element_blank(),
        strip.text = element_text(size = 12))+
  ggtitle("Electrification rate of Zambia for different scenarios")
ggsave(paste0("out_figures/electrification_OnSSET_NEST_",country,"_2030.png"), a3, scale=1, height = 5, width = 10)

# map share of offgrid generation
ele_share_gen.sf = st_as_sf( shares_elec.df %>% 
  select(-tot_group,-share_en- geometry) %>% 
  filter(tec != "unelectrified") %>% 
  group_by(BCU, year, scenario, unit) %>% 
  mutate(tot_group = sum(value)) %>% ungroup() %>% 
  mutate(share_en = round(value / tot_group, digits = 2) ) %>% 
  left_join(basin.sf %>% select(BCU,geometry )) )

a2 = ggplot()+
  theme_classic()+
  geom_sf(data=regions, fill="#f5efdf")+
  geom_sf(data=ele_share_gen.sf %>% filter(#(year %in% c(2040)) | (year == 2020 & scenario == "baseline"),
                                       tec == "off-grid"), 
          aes(fill=cut(share_en,breaks=c(0,0.25,0.5,0.75))) )+
  facet_wrap(factor(scenario, levels =c("baseline","improved_access","ambitious_development"))~year, ncol = 3)+
  scale_fill_brewer(name="Share", palette = "PuRd")+
  coord_sf(xlim=c(21, 35), ylim=c(-18, -7))+
  ggtitle("")+
  theme(legend.position = "bottom", 
        legend.direction = "horizontal", 
        # aspect.ratio = 3/4, 
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(), 
        axis.text.y=element_blank(), 
        axis.ticks.y=element_blank(),
        strip.text = element_text(size = 12))+
  ggtitle("Share of off-grid electricity generation for different scenarios")

ggsave(paste0("out_figures/offgrid_generation_OnSSET_NEST_",country,".png"), a2, scale=1, height = 5, width = 10)
# 2030 short version
a4 = ggplot()+
  theme_classic()+
  geom_sf(data=regions, fill="#f5efdf")+
  geom_sf(data=ele_share_gen.sf %>% filter((year %in% c(2030)) | (year == 2020 & scenario == "baseline"),
    tec == "off-grid"), 
    aes(fill=cut(share_en,breaks=c(0,0.25,0.5,0.75))) )+
  facet_wrap(factor(scenario, levels =c("baseline","improved_access","ambitious_development"))~year, ncol = 4)+
  scale_fill_brewer(name="Share", palette = "PuRd")+
  coord_sf(xlim=c(21, 35), ylim=c(-18, -7))+
  ggtitle("")+
  theme(legend.position = "bottom", 
        legend.direction = "horizontal", 
        # aspect.ratio = 3/4, 
        axis.text.x=element_blank(),
        axis.ticks.x=element_blank(), 
        axis.text.y=element_blank(), 
        axis.ticks.y=element_blank(),
        strip.text = element_text(size = 12))+
  ggtitle("Share of off-grid electricity generation for different scenarios")

ggsave(paste0("out_figures/offgrid_generation_OnSSET_NEST_",country,"_2030.png"), a4, scale=1, height = 5, width = 10)


# check investment costs
#read excel
library(readxl)
# inv cost: million $/GW and million $/km3
inv_costs = read_excel(paste0(getwd(),"/paper_review_analysis.xlsx"), sheet = 3) %>% 
  select(region, tec, unit, everything()) %>% 
  gather(year, invc, -region, -tec, -unit)
# cap in GWa and Km3
cap_new = read_excel(paste0(getwd(),"/paper_review_analysis.xlsx"), sheet = 4) %>% 
  gather(year, capn,-region,-tec) %>% 
  drop_na()

cap_new2 = cap_new %>% left_join(inv_costs %>% filter(region != "all_reg")) %>% 
  left_join(inv_costs %>% filter(region == "all_reg") %>% select(-region,-unit) %>%  
              rename(invc_all_reg = invc) ) %>% 
  mutate(invc = if_else(is.na(invc), invc_all_reg, invc) ) %>% 
  select(-invc_all_reg,-unit) %>% drop_na() # temp just on hydro, offgrid and irr

capn_agg = cap_new2 %>% mutate(tot_inv = capn * invc, # million $
                               region = "Zambia") %>% 
  group_by(region, tec, year) %>% 
  summarise(capn = sum(capn),
            tot_inv = sum(tot_inv)) %>% ungroup() %>% 
  mutate(avg_cap_cost = tot_inv / capn) 

# huge ratio hydro/other is confirmed
# orger of magnitudes different
# energy is billion
# water is million, lower than plotted

# hydro reported inv
hydro_inv = marker_output %>% 
  filter(grepl('Investment\\|Energy Supply\\|Electricity\\|Hydro', variable),
         year >= 2020) %>% 
  mutate(value = value * 1000,
         unit = "million US$2010/y")
