# This function is to load 2010 county-level elderly population of several
# age groups by Census API.

load_elderly_pop = function(){
  remotes::install_github("walkerke/tidycensus")
  library(tidycensus)
  library(sf)
  library(stringr)
  library(RMySQL)
  county_info = read.csv("data/us_cities.csv",header = T)
  print(nrow(county_info))
  state_fips_list = c()
  county_fips_list = c()
  for (i in 1:nrow(county_info)) {
    fips = as.character(county_info[i,]$county_fips)
    county_fips_list = c(county_fips_list,str_sub(fips,-3,-1))
    state_fips_list = c(state_fips_list,str_sub(fips,-nchar(fips),-4))
  }
  # the different varaibles for the age group of census
  # 55-64: PCT012058 - PCT012067, PCT012162 - PCT012171
  # 65-74: PCT012068 - PCT012077, PCT012172 - PCT012181
  # 75-84: PCT012078 - PCT012087, PCT012182 - PCT012191
  # 84-  ：PCT012088 - PCT012105，PCT012192 - PCT012209
  var_55_64_list = c()
  var_65_74_list = c()
  var_75_84_list = c()
  var_85_list = c()
  for (i in 58:67) {
    var_55_64_list = c(var_55_64_list, paste("PCT0120", as.character(i), sep=""))
    var_65_74_list = c(var_65_74_list, paste("PCT0120", as.character(i+10), sep=""))
    var_75_84_list = c(var_75_84_list, paste("PCT0120", as.character(i+20), sep=""))
  }
  for (i in 162:171){
    var_55_64_list = c(var_55_64_list, paste("PCT012", as.character(i), sep=""))
    var_65_74_list = c(var_65_74_list, paste("PCT012", as.character(i+10), sep=""))
    var_75_84_list = c(var_75_84_list, paste("PCT012", as.character(i+20), sep=""))
  }
  for (i in 88:105){
    if (i>99) {
      var_85_list = c(var_85_list,paste("PCT012", as.character(i), sep=""))
      var_85_list = c(var_85_list,paste("PCT012", as.character(i+104), sep=""))
    }else{
      var_85_list = c(var_85_list,paste("PCT0120", as.character(i), sep=""))
      var_85_list = c(var_85_list,paste("PCT012", as.character(i+104), sep=""))
    }

  }

  var_list = list(var_55_64_list, var_65_74_list, var_75_84_list, var_85_list)
  age_group = c("55-64","65-74","75-84","85+")

  df = data.frame(matrix(ncol = 5, nrow = 0))
  colnames(df) <- c('county_fips', 'population', 'age_group', 'county', 'year')
  for (i in 1:nrow(county_info)) {
    for (h in 1:4) {
      df_age = get_decennial(geography = 'county', variables = var_list[[h]],
                             year = 2010, summary_var = 'P001001',
                             state = state_fips_list[i], county = county_fips_list[i]
                             , geometry = FALSE)
      county_name = df_age[1,2]
      df_age = aggregate(x= df_age$value, by = list(df_age$GEOID), FUN = sum)
      colnames(df_age) = c("county_fips","population")
      df_age["age_group"] = age_group[h]
      df_age["county"] = county_name
      df_age["year"] = 2010
      df = rbind(df,df_age)
    }
  }

  # write.csv(df,"county_elderly_population.csv")

  # read the database server infomation from the file
  server_info = read.table("database_server_info.txt")

  # set up the connection to the database server
  mysqlconnection = dbConnect(RMySQL::MySQL(),
                              dbname=server_info[5,],
                              host=server_info[1,],
                              port=as.integer(server_info[2,]),
                              user=server_info[3,],
                              password=server_info[4,])

  dbWriteTable(conn=mysqlconnection, name="county_elderly_population", value=df, overwrite=TRUE)
  dbSendQuery(mysqlconnection,"
ALTER TABLE county_elderly_population MODIFY row_names INTEGER;")
  dbSendQuery(mysqlconnection,"alter table county_elderly_population add primary key(row_names);")
}

