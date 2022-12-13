source("src/load_us_cities.R")
source("src/load_census_uhi.R")
source("src/ee_extract.R")
source("src/CDC_import.R")
source("src/load_elderly_health_db.R")
source("src/load_elderly_pop.R")


# This main function is to upload all the necessary data downloaded from 
# website or API to the database.
data_loading_all = function(){
  # load us city information from downloaded csv file to the database
  load_city_info()
  
  # load recent census-level UHI data to the database
  load_census_uhi()
  
  # upload climate and uhi data from earth engine to the database SQL server
  import_load_ee()

  # upload CDC elderly death data from downloaded txt file to the database
  import_load_CDC_death()

  # run three times to upload the asthma, insurance and stroke data from
  # downloaded csv files to the database
  for (name in c("asthma.csv","insurance.csv","stroke.csv")) {
    load_elderly_health(name)
  }

  # upload elderly population data from US Census API to database
  load_elderly_pop()
}

data_loading_all()