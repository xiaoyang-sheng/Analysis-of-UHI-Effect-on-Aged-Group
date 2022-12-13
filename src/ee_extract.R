library(tidyverse)
library(RMySQL)
library(rgee)
library(sf)

import_load_ee = function() {
  ee_Initialize()
  
  # nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE) # north cali
  
  ## ECMWF/ERA5/MONTHLY (climate)
  
  # mean_2m_air_temperature     ***
  # minimum_2m_air_temperature  
  # maximum_2m_air_temperature  
  # dewpoint_2m_temperature     ***
  # total_precipitation         ***
  # surface_pressure            ***
  # mean_sea_level_pressure
  # u_component_of_wind_10m     ***
  # v_component_of_wind_10m     ***
  
  ## YALE/YCEO/UHI/Summer_UHI_yearly_pixel/v4 \ YALE/YCEO/UHI/Winter_UHI_yearly_pixel/v4
  
  # UHI is measured as a synchronous air temperature difference between urban and rural, or non-urbanized, areas.
  
  # Daytime                     ***
  # Nighttime                   ***
  
  fips_clean <- function(fips) {
    if (nchar(fips) < 5) {
      return(paste("0", fips, sep = ""))
    } else {
      return(as.character(fips))
    }
  }
  
  us_cities = read.csv("data/us_cities.csv")
  
  cb = read_sf("data/cb_2018_us_county_500k/cb_2018_us_county_500k.shp")
  
  selected_fips = lapply(us_cities$county_fips, FUN = fips_clean)
  
  cb_sub = cb[which(cb$GEOID %in% selected_fips),]
  
  selected_bands = c("mean_2m_air_temperature", 
                     "dewpoint_2m_temperature", 
                     "total_precipitation",
                     "surface_pressure", 
                     "u_component_of_wind_10m", 
                     "v_component_of_wind_10m",
                     "Daytime",
                     "Nighttime")
  
  ee_collect_cl = function(dataset, bands, s = "2011-01-01", e = "2021-01-01") {
    data <- ee$ImageCollection(dataset) %>%
      ee$ImageCollection$filterDate(s, e) %>%
      ee$ImageCollection$map(function(x) x$select(bands)) %>%
      ee$ImageCollection$toBands()
    df <- ee_extract(x = data, y = cb_sub["GEOID"], sf = FALSE)
    return(df)
  }
  
  ee_cb_m_temp = ee_collect_cl("ECMWF/ERA5/MONTHLY", selected_bands[1])
  ee_cb_d_temp = ee_collect_cl("ECMWF/ERA5/MONTHLY", selected_bands[2])
  ee_cb_precip = ee_collect_cl("ECMWF/ERA5/MONTHLY", selected_bands[3])
  ee_cb_surf_p = ee_collect_cl("ECMWF/ERA5/MONTHLY", selected_bands[4])
  ee_cb_u_wind = ee_collect_cl("ECMWF/ERA5/MONTHLY", selected_bands[5])
  ee_cb_v_wind = ee_collect_cl("ECMWF/ERA5/MONTHLY", selected_bands[6])
  
  ee_cb_climate  <- data.frame(matrix(ncol = 8, nrow = 0))
  colnames(ee_cb_climate) <- c('county', 'yyyymm', selected_bands[1:6])
  r = nrow(ee_cb_m_temp)
  c = ncol(ee_cb_m_temp)
  colname = colnames(ee_cb_m_temp)
  for (i in (1:r)) {
    for (j in (2:c)) {
      ee_cb_climate[nrow(ee_cb_climate) + 1,] = c(ee_cb_m_temp[i,1],
                                                  substr(colname[j],2,7),
                                                  ee_cb_m_temp[i,j],
                                                  ee_cb_d_temp[i,j],
                                                  ee_cb_precip[i,j],
                                                  ee_cb_surf_p[i,j],
                                                  ee_cb_u_wind[i,j],
                                                  ee_cb_v_wind[i,j])
    }
  }
  
  ee_collect_uhi = function(dataset, bands) {
    data <- ee$ImageCollection(dataset) %>%
      ee$ImageCollection$map(function(x) x$select(bands)) %>%
      ee$ImageCollection$toBands()
    df <- na.omit(ee_extract(x = data, y = cb_sub["GEOID"], sf = FALSE))
    return(df)
  }
  
  ee_cb_uhi_sd = ee_collect_uhi("YALE/YCEO/UHI/Summer_UHI_yearly_pixel/v4", selected_bands[7])
  ee_cb_uhi_sn = ee_collect_uhi("YALE/YCEO/UHI/Summer_UHI_yearly_pixel/v4", selected_bands[8])
  ee_cb_uhi_wd = ee_collect_uhi("YALE/YCEO/UHI/Winter_UHI_yearly_pixel/v4", selected_bands[7])
  ee_cb_uhi_wn = ee_collect_uhi("YALE/YCEO/UHI/Winter_UHI_yearly_pixel/v4", selected_bands[8])
  
  ee_cb_uhi  <- data.frame(matrix(ncol = 6, nrow = 0))
  colnames(ee_cb_uhi) <- c('county', 'yyyymm', "su_daytime", "su_nighttime", "win_daytime", "win_nighttime")
  r = nrow(ee_cb_uhi_sd)
  c = ncol(ee_cb_uhi_sd)
  colname = colnames(ee_cb_uhi_sd)
  for (i in (1:r)) {
    for (j in (2:c)) {
      ee_cb_uhi[nrow(ee_cb_uhi) + 1,] = c(ee_cb_uhi_sd[i,1],
                                          substr(colname[j],2,5),
                                          ee_cb_uhi_sd[i,j],
                                          ee_cb_uhi_sn[i,j],
                                          ee_cb_uhi_wd[i,j],
                                          ee_cb_uhi_wn[i,j])
    }
  }
  
  # read the database server information from the file
  server_info = read.table("../database_server_info.txt")
  
  # set up the connection to the database server
  mysqlconnection = dbConnect(RMySQL::MySQL(),
                              dbname=server_info[5,],
                              host=server_info[1,],
                              port=as.integer(server_info[2,]),
                              user=server_info[3,],
                              password=server_info[4,])
  
  dbWriteTable(conn=mysqlconnection, name="ee_cb_climate", value=ee_cb_climate, overwrite=TRUE)
  dbWriteTable(conn=mysqlconnection, name="ee_cb_uhi", value=ee_cb_uhi, overwrite=TRUE)
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_climate MODIFY row_names INTEGER;")
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_uhi MODIFY row_names INTEGER;")
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_climate add primary key(row_names);")
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_uhi add primary key(row_names);")
  
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_climate MODIFY mean_2m_air_temperature double;")
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_climate MODIFY dewpoint_2m_temperature double;")
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_climate MODIFY total_precipitation double;")
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_climate MODIFY surface_pressure double;")
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_climate MODIFY u_component_of_wind_10m double;")
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_climate MODIFY v_component_of_wind_10m double;")
  
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_uhi MODIFY su_daytime double;")
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_uhi MODIFY su_nighttime double;")
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_uhi MODIFY win_daytime double;")
  dbSendQuery(mysqlconnection,"ALTER TABLE ee_cb_uhi MODIFY win_nighttime double;")
}







