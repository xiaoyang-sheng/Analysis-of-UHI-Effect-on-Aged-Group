library(RMySQL)

df1 = read.csv("asthma.csv")
df2 = read.csv("insurance.csv")
df3 = read.csv("stroke.csv")

mysqlconnection = dbConnect(RMySQL::MySQL(),
                            dbname='test',
                            host='localhost',
                            port=3306,
                            user='root',
                            password='1127sxy00')

dbWriteTable(conn=mysqlconnection, name="asthma", value=df1, overwrite=TRUE)
dbWriteTable(conn=mysqlconnection, name="insurance", value=df2, overwrite=TRUE)
dbWriteTable(conn=mysqlconnection, name="stroke", value=df2, overwrite=TRUE)
dbSendQuery(mysqlconnection,"
ALTER TABLE asthma MODIFY row_names INTEGER;")
dbSendQuery(mysqlconnection,"
ALTER TABLE insurance MODIFY row_names INTEGER;")
dbSendQuery(mysqlconnection,"
ALTER TABLE stroke MODIFY row_names INTEGER;")
dbSendQuery(mysqlconnection,"alter table asthma add primary key(row_names);")
dbSendQuery(mysqlconnection,"alter table insurance add primary key(row_names);")
dbSendQuery(mysqlconnection,"alter table stroke add primary key(row_names);")
