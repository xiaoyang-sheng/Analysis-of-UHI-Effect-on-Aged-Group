library(tidyr)
# export the stroke data on a county level
f1 <- file.choose()
stroke <- read.csv(f1)
g1 <- file.choose()
cont <- read.csv(g1)
stroke <- stroke[stroke$Start.Year=="2017",]
stroke <- stroke[,c(3,7,9)]
names(stroke) <- c("county_fips","value","age")
df1 <- merge(cont,stroke,by=c("county_fips"))
df1 <- df1 %>% drop_na()
write.csv(df1,"desktop/STATS 506/project/insurance.csv")

# export the asthma data on a county level
f2 <- file.choose()
asthma <- read.csv(f2)
asthma <- asthma[asthma$Year=="2018",]
asthma <- asthma[,c(3,8)]
names(asthma) <- c("county_fips","value")
df2 <- merge(cont,asthma,by=c("county_fips"))
df2 <- df2 %>% drop_na()
write.csv(df2,"desktop/STATS 506/project/asthma.csv")

# export the insurance data on a county level
ins = read.csv("desktop/STATS 506/insurance.csv")
ins = subset(ins,select = -c(1,2,3,4,9))
names(ins)[2] <- paste("county_fips")
county = read.csv("desktop/STATS 506/us_cities.csv")
ins = merge(county,ins,by=c("county_fips"))
write.csv(ins,"desktop/STATS 506/us_insurance.csv")