ee_climate = read.csv("ee_cb_climate.csv")
ee_uhi = read.csv("ee_cb_uhi.csv")

View(ee_climate)
View(ee_uhi)

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
summary(fit_sd)

fit_sn = lm(su_nighttime ~ ., summer_merge[-c(1:2,3)])
summary(fit_sn)

fit_wd = lm(win_daytime ~ ., winter_merge[-c(1:2,4)])
summary(fit_sd)

fit_wn = lm(win_nighttime ~ ., winter_merge[-c(1:2,3)])
summary(fit_sn)
