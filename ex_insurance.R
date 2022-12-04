# export data of insurance
ins = read.csv("desktop/STATS 506/insurance.csv")
ins = subset(ins,select = -c(1,2,3,4,9))
names(ins)[2] <- paste("county_fips")
View(ins)
county = read.csv("desktop/STATS 506/us_cities.csv")
ins = merge(county,ins,by=c("county_fips"))
View(ins)
write.csv(ins,"desktop/STATS 506/us_insurance.csv")
