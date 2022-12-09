## All the CDC raw data files are manually downloaded from CDC Wonder Website
## service, since the API does not support the data grouped by county.

## Note: Due to the protection of privacy, CDC suppresses some small-scale data 
## Therefore, only non-suppressed data are downloaded.

## The data selection is based upon the county list with typical heat-island


import_load_CDC_death = function(){
  setwd("CDC_Rawdata")
  filelist = list.files(pattern = "*.txt")
  ## Only include the county name, county code, month and death number
  datalist = lapply(filelist, function(x)read.delim
                    (x)[,c(-1,-4,-6,-9,-10)]) 
  
  datafr = do.call("rbind", datalist) 
  datafr = subset(datafr, Month.Code != '')
  ## us_cities.csv stores the county list with typical heat-island phenomenon
  county_info = read.csv("us_cities.csv",header = T)
  county_index = county_info["county_fips"]
  datafr_sel = datafr[datafr$County.Code %in% county_index$county_fips,]
  
  # write.csv(datafr_sel,"CDC_elderly_death.csv")
  
  library(RMySQL)
  
  colnames(datafr_sel) = c("county","county_code","age_group","month","death")
  
  # read the database server infomation from the file
  server_info = read.table("database_server_info.txt")
  
  # set up the connection to the database server
  mysqlconnection = dbConnect(RMySQL::MySQL(),
                              dbname=server_info[5,],
                              host=server_info[1,],
                              port=as.integer(server_info[2,]),
                              user=server_info[3,],
                              password=server_info[4,])
  #  create a table and and the dataframe to the table
  dbWriteTable(conn=mysqlconnection, name="CDC_elderly_death", value=datafr_sel, overwrite=TRUE)
  # change some of the types
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
  print("Successfully load CDC elderly death data to database!")
}



