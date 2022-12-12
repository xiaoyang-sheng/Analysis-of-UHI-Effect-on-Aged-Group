# This function is used to analysis the relation between uhi intensity
# and stroke indicator

uhi_stroke = function(){
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
  
  # here since the time unit of the stroke data is three years, calculate 
  # the average of the uhi intensity in 3 years to match the stroke data
  filter_statements = paste0("SELECT ROUND(AVG(ee_cb_uhi.su_daytime),7) as avg_su_day,
ROUND(AVG(ee_cb_uhi.su_nighttime),7) as avg_su_night,
ROUND(AVG(ee_cb_uhi.win_daytime),7) as avg_win_day,
ROUND(AVG(ee_cb_uhi.win_nighttime),7) as avg_win_night, 
stroke.county_fips,stroke.county, stroke.state, stroke.`start.year` as start_year,
stroke.`end.year` as end_year ,stroke.age,stroke.stroke as stroke_value FROM
ee_cb_uhi
INNER JOIN
stroke
ON
ee_cb_uhi.county=stroke.county_fips AND ee_cb_uhi.yyyymm>=stroke.`start.year` 
AND ee_cb_uhi.yyyymm<=stroke.`end.year`
WHERE stroke.age = '>= 65'
GROUP BY  stroke.county_fips,stroke.county, stroke.state, stroke.`start.year`,
                           stroke.`end.year`,stroke.stroke")
  
  res = dbSendQuery(mysqlconnection, filter_statements)
  dat = dbFetch(res, -1)   #-1 for all data, 3 for top three records
  dbClearResult(dbListResults(mysqlconnection)[[1]])
  dbDisconnect(mysqlconnection)
  
  fit_stroke_uhi = lm(stroke_value~avg_su_day + avg_su_night+avg_win_day+avg_win_night,data=dat)
  summary(fit_stroke_uhi)
  
  library(randomForest)
  library(ggplot2)
  rf.fit = randomForest(stroke_value~avg_su_day + avg_su_night+avg_win_day+avg_win_night, data = dat, 
                        ntree=1000, keep.forest=FALSE, importance=TRUE)
  ImpData = as.data.frame(importance(rf.fit))
  ImpData$Var.Names = row.names(ImpData)
  png("uhi_stroke_random_forest.png")
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
  print("successfully analyze the uhi and stroke!")
  
}
