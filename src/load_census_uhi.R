load_census_uhi = function(){
  library(RMySQL)
  server_info = read.table("database_server_info.txt")
  mysqlconnection = dbConnect(RMySQL::MySQL(),
                              dbname=server_info[5,],
                              host=server_info[1,],
                              port=as.integer(server_info[2,]),
                              user=server_info[3,],
                              password=server_info[4,])
  df = read.csv("data/Census_UHI_US_Urbanized_recalculated.csv", header = TRUE)

  dbWriteTable(conn = mysqlconnection, name = "census_uhi_us_urbanized_recalculated", value = df, overwrite = TRUE)
  dbDisconnect(mysqlconnection)
}