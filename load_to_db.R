library(RODBC)
install.packages("RMySQL")


library(RMySQL)

## All the CDC raw data files are manually downloaded from CDC Wonder Website
## service, since the API does not support the data grouped by county.

## Note: Due to the protection of privacy, CDC suppresses some small-scale data 
## Therefore, only non-suppressed data are downloaded.

## The data selection is based upon the county list with typical heat-island

filelist = list.files(pattern = ".*.txt")
## Only include the county name, county code, month and death number
datalist = lapply(filelist, function(x)read.delim
                  (x)[,c(-1,-4,-6,-9,-10)]) 

datafr = do.call("rbind", datalist) 
datafr = subset(datafr, Month.Code != '')

## us_cities.csv stores the county list with typical heat-island phenomenon
county_info = read.csv("us_cities.csv",header = T)
county_index = county_info["county_fips"]
datafr_sel = datafr[datafr$County.Code %in% county_index$county_fips,]
colnames(datafr_sel) = c("county","county_code","age_group","month","death")

mysqlconnection = dbConnect(RMySQL::MySQL(),
                            dbname='test',
                            host='localhost',
                            port=3306,
                            user='root',
                            password='1127sxy00')
dbListTables(mysqlconnection)


dbWriteTable(conn=mysqlconnection, name="CDC_elderly_death", value=datafr_sel, overwrite=TRUE)
dbSendQuery(mysqlconnection,"
ALTER TABLE CDC_elderly_death MODIFY row_names INTEGER;")
dbSendQuery(mysqlconnection,"
ALTER TABLE CDC_elderly_death MODIFY county VARCHAR(50);")
dbSendQuery(mysqlconnection,"
ALTER TABLE CDC_elderly_death MODIFY county_code INT;")
dbSendQuery(mysqlconnection,"
ALTER TABLE CDC_elderly_death MODIFY age_group VARCHAR(50);")
dbSendQuery(mysqlconnection,"
ALTER TABLE CDC_elderly_death MODIFY month VARCHAR(50);")
dbSendQuery(mysqlconnection,"
ALTER TABLE CDC_elderly_death MODIFY death INT;")
dbSendQuery(mysqlconnection,"alter table CDC_elderly_death add primary key(row_names);")
