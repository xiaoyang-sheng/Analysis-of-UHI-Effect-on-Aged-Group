library(RMySQL)
mysqlconnection = dbConnect(RMySQL::MySQL(),
                            dbname='stats506_project',
                            host='rm-uf63gt5o8xsxxhd9jpo.mysql.rds.aliyuncs.com',
                            port=3306,
                            user='stats506_proj',
                            password='UmichSTATS506')
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

