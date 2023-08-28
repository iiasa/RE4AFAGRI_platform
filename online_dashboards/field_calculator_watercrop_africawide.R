
setwd("C:/Users/falchetta/OneDrive - IIASA/IIASA_official_RE4AFAGRI_platform/online_dashboards/") # path of the cloned M-LED GitHub repository

crops_list <- read.csv("supporting_files/crops_list.csv", header = F)
crop <- as.character(crops_list$V1)
crop[1] <- "barl"
crop <- c("total", crop)
months <- c("Yearly", 1:12)
scen <- c("baseline", "improved_access", "ambitious_development")
year <- seq(2020, 2050, 10)
regime <- c("irrigated", "rainfed")

###############

l <- expand.grid(months, year, regime, crop, scen, stringsAsFactors = F)

out <- paste0('ELSEIF
[Month]=="', l$Var1,
              '" \nAND
[Crop]=="', l$Var4,
              '" \nAND
[regime]=="', l$Var3,
              '" \nAND
[Year]=="', l$Var2,
              '"\nAND
[Scenario]=="', l$Var5, paste0('"
THEN',
                                                        '\n[IRREQ_', l$Var3, '_', l$Var4, '_', l$Var1, '_', l$Var2, '_', l$Var5,  '] / 1000 \n'))

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/watercrop_africa_wide_water.txt")

####

crops_list <- read.csv("supporting_files/crops_list.csv", header = F)
crop <- as.character(crops_list$V1)
crop[1] <- "barl"
scen <- c("baseline", "improved_access", "ambitious_development")
year <- seq(2020, 2050, 10)
regime <- c("yield", "yg_potential")

###############

l <- expand.grid(year, regime, crop, scen, stringsAsFactors = F)

out <- paste0('ELSEIF
[Crop]=="', l$Var3,
              '" \nAND
[yield_regime]=="', l$Var2,
              '" \nAND
[Year]=="', l$Var1,
              '"\nAND
[Scenario]=="', l$Var4, paste0('"
THEN',
                               '\n[', l$Var2, '_', l$Var3, '_', l$Var1, '_', l$Var4,  '] \n'))

out[1] <- gsub("ELSE", "", out[1])
out[length(out)+1] <- "END"

write(out, "field_calculators/watercrop_africa_wide_yield.txt")
