library(RMySQL)
mysqlconnection = dbConnect(RMySQL::MySQL(),
                            dbname='stats506_project',
                            host='rm-uf63gt5o8xsxxhd9jpo.mysql.rds.aliyuncs.com',
                            port=3306,
                            user='stats506_proj',
                            password='UmichSTATS506')
filter_statements = paste0('SELECT ee_cb_uhi.county as fips,
ee_cb_uhi.su_daytime,ee_cb_uhi.su_nighttime,ee_cb_uhi.win_daytime,
ee_cb_uhi.win_nighttime, asthma.county, asthma.state,asthma.`year`,
asthma.asthma as asthma_rate FROM
ee_cb_uhi
INNER JOIN asthma
ON ee_cb_uhi.county=asthma.county_fips AND ee_cb_uhi.yyyymm=asthma.`year`')
res = dbSendQuery(mysqlconnection, filter_statements)
dat = dbFetch(res, -1)   #-1 for all data, 3 for top three records
dbClearResult(dbListResults(mysqlconnection)[[1]])
dbDisconnect(mysqlconnection)

fit_asthma_uhi = lm(asthma_rate~su_daytime+su_nighttime+win_daytime+
                        win_nighttime,data=dat)
summary(fit_asthma_uhi)

library(randomForest)
rf.fit = randomForest(asthma_rate~su_daytime+su_nighttime+win_daytime+
                        win_nighttime, data = dat, 
                      ntree=1000, keep.forest=FALSE, importance=TRUE)
rf.fit

ImpData = as.data.frame(importance(rf.fit))
ImpData$Var.Names = row.names(ImpData)
ggplot(ImpData, aes(x=Var.Names, y=`%IncMSE`)) +
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
