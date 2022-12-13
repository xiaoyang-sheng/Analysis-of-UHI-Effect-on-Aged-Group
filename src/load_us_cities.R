load_census_uhi = function(){
  library(RMySQL)
  server_info = read.table("database_server_info.txt")
  mysqlconnection = dbConnect(RMySQL::MySQL(),
                              dbname=server_info[5,],
                              host=server_info[1,],
                              port=as.integer(server_info[2,]),
                              user=server_info[3,],
                              password=server_info[4,])
  df = read.csv("data/uscity_info", header = TRUE)
  
  dbWriteTable(conn = mysqlconnection, name = "uscity_info", value = df, overwrite = TRUE)
  dbDisconnect(mysqlconnection)
}