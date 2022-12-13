# This function is used to analysis the relation between uhi intensity
# and insurance rate

uhi_insurance = function(){
  library(RMySQL)
  # read the database server infomation from the file
  server_info = read.table("database_server_info.txt")
  
  # set up the connection to the database server
  mysqlconnection = dbConnect(RMySQL::MySQL(),
                              dbname=server_info[5,],
                              host=server_info[1,],
                              port=as.integer(server_info[2,]),
                              user=server_info[3,],
                              password=server_info[4,])
  filter_statements = paste0('SELECT ee_cb_uhi.county as fips,
ee_cb_uhi.su_daytime,ee_cb_uhi.su_nighttime,ee_cb_uhi.win_daytime,
ee_cb_uhi.win_nighttime,insurance.county,insurance.state,insurance.`year`,
insurance.`uninsured.rate` FROM
ee_cb_uhi
INNER JOIN insurance
ON ee_cb_uhi.county=insurance.county_fips AND ee_cb_uhi.yyyymm=insurance.`year`')
  res = dbSendQuery(mysqlconnection, filter_statements)
  dat = dbFetch(res, -1)   #-1 for all data, 3 for top three records
  dbClearResult(dbListResults(mysqlconnection)[[1]])
  dbDisconnect(mysqlconnection)
  
  dat$uninsured.rate = 100-dat$uninsured.rate
  names(dat)[names(dat) == 'uninsured.rate'] <- 'insured_rate'
  
  # apply the linear regression
  fit_insurance_4_uhi = lm(insured_rate~su_daytime+su_nighttime+win_daytime+
                             win_nighttime,data=dat)
  print(summary(fit_insurance_4_uhi))
  
  library(randomForest)
  library(ggplot2)
  # apply the random forest
  rf.fit = randomForest(insured_rate~su_daytime+su_nighttime+win_daytime+
                          win_nighttime, data = dat, 
                        ntree=1000, keep.forest=FALSE, importance=TRUE)
  ImpData = as.data.frame(importance(rf.fit))
  ImpData$Var.Names = row.names(ImpData)
  
  # save the plot of the summary of random forest
  png("uhi_insurance_random_forest.png")
  plot = ggplot(ImpData, aes(x=Var.Names, y=`%IncMSE`)) +
    geom_segment( aes(x=Var.Names, xend=Var.Names, y=0, yend=`%IncMSE`), color="skyblue") +
    geom_point(aes(size = IncNodePurity), color="blue", alpha=0.6) +
    theme_light() +
    coord_flip() +
    theme(
      legend.position="bottom",
      panel.grid.major.y = element_blank(),
      panel.border = element_blank(),
      axis.ticks.y = element_blank()
    )
  print(plot)
  dev.off()
  print("successfully analyze the uhi and insurance!")
  
}
