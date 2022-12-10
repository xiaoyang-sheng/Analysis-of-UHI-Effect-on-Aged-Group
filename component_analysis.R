library(carData)
library(car)
library(RMySQL)
library(alr4)

ee_climate_component_analysis = function() {
  # read the database server information from the file
  server_info = read.table("database_server_info.txt")
  
  # set up the connection to the database server
  mysqlconnection = dbConnect(RMySQL::MySQL(),
                              dbname=server_info[5,],
                              host=server_info[1,],
                              port=as.integer(server_info[2,]),
                              user=server_info[3,],
                              password=server_info[4,])
  
  ee_climate = dbFetch(dbSendQuery(mysqlconnection, "SELECT * FROM stats506_project.ee_cb_climate;"), n = -1)[,-1]
  ee_uhi = dbFetch(dbSendQuery(mysqlconnection, "SELECT * FROM stats506_project.ee_cb_uhi;"), n = -1)[,-1]
  
  # View(ee_climate)
  # View(ee_uhi)
  
  # Summer: June, July, Aug
  # Winter: Dec,  Jan,  Feb
  
  ee_climate_summer = ee_climate[substr(ee_climate$yyyymm,5,6) %in% c("06","07","08"),]
  ee_climate_winter = ee_climate[substr(ee_climate$yyyymm,5,6) %in% c("12","01","02"),]
  
  ee_climate_summer$yyyymm = substr(ee_climate_summer$yyyymm,1,4)
  ee_climate_winter$yyyymm = substr(ee_climate_winter$yyyymm,1,4)
  
  summer_stats = aggregate(x = ee_climate_summer[5:8], by = list(ee_climate_summer$county, ee_climate_summer$yyyymm), FUN = "mean")
  winter_stats = aggregate(x = ee_climate_winter[5:8], by = list(ee_climate_winter$county, ee_climate_winter$yyyymm), FUN = "mean")
  
  colnames(summer_stats)[1:2] = c("county", "yyyymm")
  colnames(winter_stats)[1:2] = c("county", "yyyymm")
  
  summer_merge = merge(ee_uhi[1:4], summer_stats, by = c("county","yyyymm"))
  winter_merge = merge(ee_uhi[c(1:2,5:6)], winter_stats, by = c("county","yyyymm"))
  
  fit_sd = lm(su_daytime ~ ., summer_merge[-c(1:2,4)])
  # Type II ANOVA
  print(summary(fit_sd))
  residualPlot(fit_sd)
  # Type I ANOVA
  anova(fit_sd)
  
  fit_sn = lm(su_nighttime ~ ., summer_merge[-c(1:2,3)])
  print(summary(fit_sn))
  residualPlot(fit_sn)
  anova(fit_sn)
  
  fit_wd = lm(win_daytime ~ ., winter_merge[-c(1:2,4)])
  print(summary(fit_wd))
  residualPlot(fit_wd)
  anova(fit_wd)
  
  fit_wn = lm(win_nighttime ~ ., winter_merge[-c(1:2,3)])
  print(summary(fit_wn))
  residualPlot(fit_wn)
  anova(fit_wn)
  
  # Transformation (Summer daytime)
  
  pairs(summer_merge[-c(1:2,3)])
  
  itp_tp <- invTranPlot(su_nighttime~total_precipitation, data=summer_merge[-c(1:2,3)])
  print(itp_tp)
  # l = 0.5
  
  itp_sp <- invTranPlot(su_nighttime~surface_pressure, data=summer_merge[-c(1:2,3)])
  print(itp_sp)
  # l = 10
  
  fit_sn_update = lm(su_nighttime ~ sqrt(total_precipitation)
                     + I(surface_pressure^10)
                     + u_component_of_wind_10m
                     + v_component_of_wind_10m
                     , summer_merge[-c(1:2,3)])
  print(summary(fit_sn_update))
  residualPlot(fit_sn_update)
  anova(fit_sn_update)
}





