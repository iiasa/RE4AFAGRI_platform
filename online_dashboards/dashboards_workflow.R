# dashboards workflow

setwd("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/online_dashboards")

ctrs <- c("nigeria", "kenya", "rwanda", "zimbabwe", "zambia") 

# Country dashboards

source("scenarios_merger_AND_region_splitter_script.R")
source("prepare_onsset_output_dashboards.R")
source("prepare_nest_output_dashboards.R")
source("field_calculator.R")

# Africa dashboard

source("watercrop_africawide.R")
source("field_calculator_watercrop_africawide.R")
