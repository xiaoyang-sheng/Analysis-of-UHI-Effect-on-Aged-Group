# STATS 506 Project - Analysis of UHI Effect on Aged Group

## Group Member

Xiaoyang Sheng, Zicong Xiao, Yulin Gao, Qianang Chen

## Description

Derive a relation model between UHI intensity and aged group health in US

## Data

- [Aggregated Climate Data (ERA5), from Earth Engine](https://developers.google.com/earth-engine/datasets/catalog/ECMWF_ERA5_MONTHLY)
- [Surface Urban Heat Islands Data, from Earth Engine](https://developers.google.com/earth-engine/datasets/catalog/YALE_YCEO_UHI_UHI_all_averaged_v4)
- [Elderly Death Data, from CDC](https://wonder.cdc.gov/ucd-icd10.html)

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

### Quick start

R CMD BATCH main.R

### Earth Engine data fetch

R CMD BATCH ee_extract.R

### CDC data fetch

R CMD BATCH CDC_import.R

## Other Tools

### SQL

SQL server (available to UM IP address) is used to manipulate data from different sources. Server configuration saved in **sql_server_info.txt**.

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

