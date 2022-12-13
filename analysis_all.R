source("src/component_analysis.R")
source("src/uhi_death.R")
source("src/uhi_insurance.R")
source("src/uhi_stroke.R")
source("src/Bayesian_Linear_Model.R")

# This main function is to perform all the analysis in the project.
analysis_all = function(){
  # to analyze the relationship between climate features and UHI intensities
  ee_climate_component_analysis()

  # analyze the relationship between UHI intensities and elderly death statistics
  uhi_death_analysis()

  # analyze the relationship between UHI intensity and health insurance rate
  uhi_insurance()

  # analyze the relationship between UHI intensity and stroke indicator
  uhi_stroke()

  # to analyze the relationship between prevalence of stroke and UHI intensities
  posterior()
}

analysis_all()
