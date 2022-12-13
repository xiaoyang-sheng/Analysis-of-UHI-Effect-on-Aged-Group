# STATS 506 Project - Analysis of UHI Effect on Aged Group

## Group Member

- Xiaoyang Sheng (shengxy@umich.edu)
- Zicong Xiao (zicongx@umich.edu)
- Yulin Gao (yulingao@umich.edu)
- Qianang Chen (qianang@umich.edu)

## Description

We use different models (linear regression, Bayesian hierarchical model, random forest) to make vulnerability assessment towards the health of older adults.

## Data

- [Aggregated Climate Data (ERA5), from Earth Engine](https://developers.google.com/earth-engine/datasets/catalog/ECMWF_ERA5_MONTHLY)
- [Surface Urban Heat Islands Data, from Earth Engine](https://developers.google.com/earth-engine/datasets/catalog/YALE_YCEO_UHI_UHI_all_averaged_v4)
- [Insurance Rate of Each County, from US Census](http://data.ctdata.org/dataset/health-insurance-coverage)
- [Elderly Population Data, from US Census](https://www.census.gov/data/developers/data-sets/decennial-census.2010.html#list-tab-99P2A1SGILQAEXII31)
- [Elderly Death Data, from CDC](https://wonder.cdc.gov/ucd-icd10.html)
- [Stroke/Asthma Data, from CDC](https://ephtracking.cdc.gov/DataExplorer/?query=51ED8370-BE00-4813-A4F8-AE641EF61672&fips=26161&G5=9999)

## Setup

```
.
│  analysis_all.R
│  database_server_info.txt
│  data_loading_all.R
│  README.md
│  requirements.txt
│  sql_server_info.txt
│  STATS_506_Project_Proposal.pdf
│  STATS_506_Project_Report.pdf
│
├─data
│  │  asthma.csv
│  │  CDC_elderly_death.csv
│  │  Census_UHI_US_Urbanized_recalculated.csv
│  │  county_elderly_population.csv
│  │  ee_cb_climate.csv
│  │  ee_cb_uhi.csv
│  │  insurance.csv
│  │  stroke.csv
│  │  uscity_info.csv
│  │  us_cities.csv
│  │
│  ├─cb_2018_us_county_500k
│  │      cb_2018_us_county_500k.cpg
│  │      cb_2018_us_county_500k.dbf
│  │      cb_2018_us_county_500k.prj
│  │      cb_2018_us_county_500k.shp
│  │      cb_2018_us_county_500k.shp.ea.iso.xml
│  │      cb_2018_us_county_500k.shp.iso.xml
│  │      cb_2018_us_county_500k.shx
│  │
│  └─CDC_Rawdata
│          .gitkeep
│          Alabama_2010-2012.txt
│          Alabama_2013-2015.txt
│          Alabama_2016-2018.txt
│          Alabama_2019-2020.txt
│          ...
│          Wisconsin_2010-2012.txt
│          Wisconsin_2013-2015.txt
│          Wisconsin_2016-2018.txt
│          Wisconsin_2019-2020.txt
│          Wyoming.txt
│
├─sample_results
│      uhi_insurance_random_forest.png
│      uhi_stroke_random_forest.png
│
└─src
     Bayesian_Linear_Model.R
     CDC_import.R
     CDC_import.sbat
     component_analysis.R
     ee_extract.R
     ex_insurance.R
     load_census_uhi.R
     load_elderly_health_db.R
     load_elderly_pop.R
     load_us_cities.R
     uhi_death.R
     uhi_insurance.R
     uhi_stroke.R
```

## Quick start

### Data Loading to SQL

R CMD BATCH data_loading_all.R

### Data Analysis

R CMD BATCH analysis_all.R

## Other Tools

### SQL

We rent a A-Liyun SQL server (available to UM IP address, if you need to run the server and IP is not allowed, please contact Xiaoyang Sheng) that is used to manipulate data from different sources and share the database among the group. Server configuration saved in **sql_server_info.txt**.

```
Tables
│  asthma
│  cdc_elderly_death
│  country_elderly_population
│  ee_cb_climate
│  ee_cb_uhi
│  insurance
│  stroke
│  census_uhi_us_urbanized_recalculated
│  uscity_info
```

### HPC

Great Lakes HPC helps to reduce elapsed time. Run **SBATCH CDC_import.sbat** to load CDC data efficiently.

