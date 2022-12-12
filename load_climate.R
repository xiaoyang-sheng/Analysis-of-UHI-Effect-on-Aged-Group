
load_climate_uhi = function(){
  library(RMySQL)
  
  df1 = read.csv("ee_cb_climate.csv")
  df2 = read.csv("ee_cb_uhi.csv")
  
  mysqlconnection = dbConnect(RMySQL::MySQL(),
                              dbname='stats506_project',
                              host='rm-uf63gt5o8xsxxhd9jpo.mysql.rds.aliyuncs.com',
                              port=3306,
                              user='stats506_proj',
                              password='UmichSTATS506')
  
  dbWriteTable(conn=mysqlconnection, name="ee_cb_climate", value=df1, overwrite=TRUE)
  dbWriteTable(conn=mysqlconnection, name="ee_cb_uhi", value=df2, overwrite=TRUE)
  dbSendQuery(mysqlconnection,"
ALTER TABLE ee_cb_climate MODIFY row_names INTEGER;")
  dbSendQuery(mysqlconnection,"
ALTER TABLE ee_cb_uhi MODIFY row_names INTEGER;")
  dbSendQuery(mysqlconnection,"alter table ee_cb_climate add primary key(row_names);")
  dbSendQuery(mysqlconnection,"alter table ee_cb_uhi add primary key(row_names);")
  print("Successfully load climate and uhi data!")
}
