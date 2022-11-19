library(RMySQL)
mysqlconnection = dbConnect(RMySQL::MySQL(),
                            dbname='stats506_project',
                            host='rm-uf63gt5o8xsxxhd9jpo.mysql.rds.aliyuncs.com',
                            port=3306,
                            user='stats506_proj',
                            password='UmichSTATS506')
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
fit_insurance_4_uhi = lm(insured_rate~su_daytime+su_nighttime+win_daytime+
                        win_nighttime,data=dat)
summary(fit_insurance_4_uhi)

