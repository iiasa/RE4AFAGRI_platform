# linear regression of gdp-capita on stats evolution

el_acc = read_xlsx(find_it("sdg-7.1.1-access_to_electricity.xlsx"))
el_acc = filter(el_acc, grepl(countrystudy, gsub(" ", "", el_acc$Country), ignore.case = T))

el_acc_trend = as.numeric(el_acc[,13:23])
el_acc_y = as.numeric(names(el_acc[,13:23]))

el_acc_model <- glm(el_acc_trend/100 ~ el_acc_y + I(el_acc_y^2), family = "binomial")

el_acc_pred = predict(el_acc_model, data.frame(el_acc_y=planning_year), type="response")

el_acc_baseline = c(el_acc_trend[-11], el_acc_pred)
names(el_acc_baseline) = c(as.numeric(names(el_acc[,13:23])), seq(2030, 2060, 10))

write.csv(el_acc_baseline, paste0("results/", countrystudy, "_el_acc_baseline_trend.csv"))

el_access_share_target[1] <- last(el_acc_pred)

######

irr_acc = read_xlsx(find_it("power_irr_area.xlsx"))
irr_acc = filter(irr_acc, grepl(countrystudy, gsub(" ", "", irr_acc$Area), ignore.case = T))
irr_acc = filter(irr_acc, `Variable Name` =="% of area equipped for irrigation power irrigated")

irr_acc_trend = irr_acc$Value
irr_acc_y = irr_acc$Year

if(length(irr_acc_y)>0){

irr_acc_modirr <- glm(irr_acc_trend/100 ~ irr_acc_y + I(irr_acc_y^2), family = "binomial")

irr_acc_pred = predict(irr_acc_modirr, data.frame(irr_acc_y=planning_year), type="response")

irrigated_cropland_share_target[1] <- as.numeric(last(irr_acc_pred))

} else{
  
  irrigated_cropland_share_target[1] <- irrigated_cropland_share_target[1]
  
}
