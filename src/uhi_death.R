uhi_death_analysis = function(){
  # For the UHI: The ideal configuration is LST_urb_all-LST_rur_all for 
  # the entire urbanized area (from the US_Urbanized file) and 
  # LST_urb_CT_act-LST_rur_all for individual census tracts within 
  # the urbanized areas (from the census file)
  library(RMySQL)
  server_info = read.table("database_server_info.txt")
  mysqlconnection = dbConnect(RMySQL::MySQL(),
                              dbname=server_info[5,],
                              host=server_info[1,],
                              port=as.integer(server_info[2,]),
                              user=server_info[3,],
                              password=server_info[4,])
  df = dbReadTable(conn = mysqlconnection, name = "census_uhi_us_urbanized_recalculated")
  
  # Select UHI related info from the dataframe
  index = sapply(colnames(df), function(x) grepl("UHI", x, fixed = TRUE))
  uhi_df = df[index]
  uhi_df["city"] = df["Urban_name"]
  head(uhi_df)

  # Add the county column
  county_table = dbReadTable(conn = mysqlconnection, name = "uscity_info")
  suppressWarnings({
    city_state = strsplit(uhi_df$city, ",", fixed = TRUE)
    city = sapply(city_state, "[", 1)
    city = strsplit(city, "-|/|\\(")
    city = sapply(city, "[", 1)
    state = sapply(city_state, "[", 2)
    state = strsplit(state, " |-")
    state = sapply(state, "[", 2)
    uhi_df["ct"] = city
    uhi_df["state"] = state
    county_vec = rep("null", nrow(uhi_df))
    fips_vec = rep(0, nrow(uhi_df))
  })
  for (i in 1:nrow(uhi_df)) {
    ct = uhi_df$ct[i]
    state = uhi_df$state[i]
    city_info = county_table[county_table$city == ct & county_table$state_id == state,]
    if (dim(city_info)[1] != 0) {
      county = city_info$county_name[1]
      county_fips = city_info$county_fips[1]
      county_vec[i] = county
      fips_vec[i] = county_fips
    }
  }
  uhi_df["county"] = county_vec
  uhi_df["county_fips"] = fips_vec
  
  # Generate the city names with strong heat island effects from the uhi table
  city_uhi = uhi_df[!duplicated(uhi_df[, "county_fips"]),]
  urbanized_county = city_uhi[, c("county", "state", "county_fips")]
  urbanized_county = urbanized_county[urbanized_county$county_fips != 0,]
  # If you need to generate the selected cities, don't comment it.
  # write_csv(urbanized_county, "selected_us_cities.csv")
  
  # Select county-level uhi data
  city_uhi = uhi_df[!duplicated(uhi_df[, "county_fips"]),]
  city_uhi = city_uhi[, c("county", "state", "county_fips", colnames(city_uhi)[7:12])]
  colnames(city_uhi)[3] = "County.Code"
  city_uhi = city_uhi[city_uhi$County.Code != "35013",]
  colnames(city_uhi)[3] = "county_code"
  
  # import the death data
  death_df = dbReadTable(conn = mysqlconnection, name = "cdc_elderly_death")
  population_df = dbReadTable(conn = mysqlconnection, name = "county_elderly_population")
  
  library(dplyr)
  death_df$county_code = as.character(death_df$county_code)
  death_df$age_group = as.factor(death_df$age_group)
  death_all_age_all_time = death_df %>% group_by(county_code) %>% summarise(total_Death = sum(death))
  
  death_age1 = death_df[death_df$age_group == "55-64", ]
  death_age1_all_time = death_age1 %>% group_by(county_code) %>% summarise(total_Death = sum(death))
  
  death_age2 = death_df[death_df$age_group == "65-74", ]
  death_age2_all_time = death_age2 %>% group_by(county_code) %>% summarise(total_Death = sum(death))
  
  death_age3 = death_df[death_df$age_group == "75-84", ]
  death_age3_all_time = death_age3 %>% group_by(county_code) %>% summarise(total_Death = sum(death))
  
  death_age4 = death_df[death_df$age_group == "85+", ]
  death_age4_all_time = death_age4 %>% group_by(county_code) %>% summarise(total_Death = sum(death))
  
  uhi_death_all = merge(city_uhi, death_all_age_all_time, by="county_code")
  print("The linear model of death tolls on the four kinds of UHI intensities:")
  lm.all = lm(total_Death~.-county_code-county-state, data = uhi_death_all)
  print(summary(lm.all))
  print("The linear model of death tolls on the UHI intensities in summer daytime:")
  lm.all = lm(total_Death~UHI_annual_day_city, data = uhi_death_all)
  print(summary(lm.all))
  
  # calculate the death ratio
  colnames(population_df)[1] = "county_code"
  population_allage_df = population_df %>% group_by(county_code) %>% summarise(population = sum(population))
  uhi_death_ratio_all = merge(uhi_death_all, population_allage_df, by="county_code")
  uhi_death_ratio_all[, "death_ratio"] = uhi_death_ratio_all$total_Death / uhi_death_ratio_all$population
  county_death_ratio = uhi_death_ratio_all[, -c(4:9)]
  
  print("The linear model of death ratios on the UHI intensities in summer daytime:")
  lm.ratio = lm(death_ratio~UHI_summer_day_city, data = uhi_death_ratio_all)
  print(summary(lm.ratio))
  
  # random forest regression
  library(randomForest)
  print("RandomForest model summary:")
  rf.fit = randomForest(death_ratio~.-county_code-county-state-total_Death-population, data = uhi_death_ratio_all, ntree=1000, keep.forest=FALSE, importance=TRUE)
  print(rf.fit)
  
  # load the yearly UHI data
  uhi_data = dbReadTable(conn = mysqlconnection, name = "ee_cb_uhi")
  uhi_avg = uhi_data %>% group_by(county) %>% summarize(su_day = mean(su_daytime), su_night = mean(su_nighttime), wt_day = mean(win_daytime), wt_night = mean(win_nighttime))
  death_ratio_df = county_death_ratio[, c("county_code", "total_Death", "death_ratio")]
  colnames(death_ratio_df)[1] = "county"
  uhi_ratio_df = merge(uhi_avg, death_ratio_df, by="county")
  lm.death = lm(total_Death~.-county-death_ratio, data = uhi_ratio_df)
  print("The linear model of death tolls on yearly UHI intensities:")
  print(summary(lm.death))
  lm.ratio = lm(death_ratio~.-county-total_Death, data = uhi_ratio_df)
  print("The linear model of death ratios on yearly UHI intensities:")
  print(summary(lm.ratio))
  
  # analyze the UHI data in 2010
  uhi_2010 = uhi_data[uhi_data$yyyymm == "2010", ]
  death_2010 = death_df[grepl("2010", death_df$month), ]
  death_2010_all = death_2010 %>% group_by(county_code) %>% summarize(total_death = sum(death))
  ratio_2010 = merge(death_2010_all, population_allage_df, by="county_code")
  colnames(ratio_2010)[1] = "county"
  uhi_ratio_2010 = merge(uhi_2010, ratio_2010, by="county")
  uhi_ratio_2010[, "death_ratio"] = uhi_ratio_2010$total_death / uhi_ratio_2010$population
  data_fit_2010 = uhi_ratio_2010[, c(3,4,5,6,9)]
  lm.2010 = lm(death_ratio~., data=data_fit_2010)
  print("The linear model of death ratios on yearly UHI intensities in 2010")
  print(summary(lm.2010))
  library(randomForest)
  rf.fit = randomForest(death_ratio~., data = data_fit_2010, ntree=1000, keep.forest=FALSE, importance=TRUE)
  print("The random forest model of death ratios on yearly UHI intensities in 2010:")
  print(rf.fit)
  dbDisconnect(mysqlconnection)
  
  # plot the importance image
  library(ggplot2)
  # Get variable importance from the model fit
  ImpData <- as.data.frame(importance(rf.fit))
  ImpData$Var.Names <- row.names(ImpData)
  
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
  ggsave("sample_results/imp.png")
}


