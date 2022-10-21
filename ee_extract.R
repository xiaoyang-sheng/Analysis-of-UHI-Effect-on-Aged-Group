library(tidyverse)
library(rgee)
library(sf)

ee_Initialize()

nc <- st_read(system.file("shape/nc.shp", package = "sf"), quiet = TRUE)

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

selected_bands = c("mean_2m_air_temperature", "dewpoint_2m_temperature", "total_precipitation",
                   "surface_pressure", "u_component_of_wind_10m", "v_component_of_wind_10m")

data_climate <- ee$ImageCollection("ECMWF/ERA5/MONTHLY") %>%
  ee$ImageCollection$filterDate("2001-01-01", "2021-01-01") %>%
  ee$ImageCollection$map(function(x) x$select(selected_bands)) %>%
  ee$ImageCollection$toBands()

ee_nc_climate <- ee_extract(x = data_climate, y = nc["NAME"], sf = FALSE)

# ee_nc_joint <- merge(ee_nc_temp_mean, ee_nc_temp_dp, by = c('NAME'))

## YALE/YCEO/UHI/Summer_UHI_yearly_pixel/v4 \ YALE/YCEO/UHI/Winter_UHI_yearly_pixel/v4
# UHI is measured as a synchronous air temperature difference between urban and rural, or non-urbanized, areas.

# Daytime                     ***
# Nighttime                   ***

data_s_uhi <- ee$ImageCollection("YALE/YCEO/UHI/Summer_UHI_yearly_pixel/v4")

ee_nc_s_uhi <- na.omit(ee_extract(x = data_s_uhi, y = nc["NAME"], sf = FALSE))

data_w_uhi <- ee$ImageCollection("YALE/YCEO/UHI/Winter_UHI_yearly_pixel/v4")

ee_nc_w_uhi <- na.omit(ee_extract(x = data_w_uhi, y = nc["NAME"], sf = FALSE))




