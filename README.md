# STATS 506 Project - Analysis of UHI Effect on Aged Group

## Group Member

- Xiaoyang Sheng (shengxy@umich.edu)
- Zicong Xiao (zicongx@umich.edu)
- Yulin Gao (yulingao@umich.edu)
- Qianang Chen (qianang@umich.edu)

## Description

Derive a relation model between UHI intensity and aged group health in US

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
│  CDC_elderly_death.csv
│  CDC_import.R
│  component_analysis.R
│  county_elderly_population.csv
│  database_server_info.txt
│  ee_cb_climate.csv
│  ee_cb_uhi.csv
│  ee_extract.R
│  load_climate.R
│  load_elderly_health_db.R
│  load_elderly_pop.R
│  load_to_db.R
│  README.md
│  sql_server_info.txt
│  stats_506_project_proposal.tex
│  uhi_asthma.R
│  uhi_insurance.R
│  uhi_stroke.R
│  us_cities.csv
└─CDC_Rawdata
     .gitkeep
     Alabama_2010-2012.txt
     Alabama_2013-2015.txt
     Alabama_2016-2018.txt
     Alabama_2019-2020.txt
     ...
     Wisconsin_2010-2012.txt
     Wisconsin_2013-2015.txt
     Wisconsin_2016-2018.txt
     Wisconsin_2019-2020.txt
     Wyoming.txt
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
```

### HPC

Great Lakes HPC helps to reduce elapsed time. Run **SBATCH CDC_import.sbat** to load CDC data efficiently.

