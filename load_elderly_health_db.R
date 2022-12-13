# this function is to load asthma, insurance and stroke data.
# input: "asthma.csv","insurance.csv","stroke.csv"


load_elderly_health = function(filename){
  library(RMySQL)
  setwd("../data")
  # df1 = read.csv("asthma.csv")
  # df2 = read.csv("insurance.csv")
  # df3 = read.csv("stroke.csv")
  df = read.csv(filename)
  # read the database server infomation from the file
  server_info = read.table("database_server_info.txt")
  
  # set up the connection to the database server
  mysqlconnection = dbConnect(RMySQL::MySQL(),
                              dbname=server_info[5,],
                              host=server_info[1,],
                              port=as.integer(server_info[2,]),
                              user=server_info[3,],
                              password=server_info[4,])
  title = substr(filename,1,nchar(filename)-4)
  dbWriteTable(conn=mysqlconnection, name=title, value=df, overwrite=TRUE)
  query = paste("ALTER TABLE ",title,sep = '')
  query = paste(query," MODIFY row_names INTEGER;",sep = '')
  dbSendQuery(mysqlconnection,query)
  query = paste("alter table ",title,sep = '')
  query = paste(query," add primary key(row_names);",sep = '')
  dbSendQuery(mysqlconnection,query)
  
  # need to delete duplicate for stroke data
  if(filename == "stroke.csv"){
    dbSendQuery(mysqlconnection,"DELETE E
  FROM stroke E
  INNER JOIN
(
  SELECT *,
  RANK() OVER(PARTITION BY county_fips,`start.year`,`end.year`,`age`
              ORDER BY row_names) r 
  FROM stroke
  --                 order by r desc
) T ON E.row_names = T.row_names
WHERE r > 1;")
  }
  print(paste("successfully load ", title,sep = ''))
}

