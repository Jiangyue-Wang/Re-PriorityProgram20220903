# try to run reptiles one by one
rm(list=ls())
gc()
library(aoh)
library(dplyr)
Sys.setenv("GDAL_PYTHON" = "python")
Sys.setenv("GDAL_CALC" = "C:\\OSGeo4W\\apps\\Python39\\Scripts\\gdal_calc.py")
Sys.setenv("GDAL_ESCAPE" = "false")
reptl_range_data <- read_spp_range_data("ReAOH/REPTILES.zip")
data(crosswalk_lumb_cgls_data)
habitat_data <- get_lumb_cgls_habitat_data(
  dir = "ReAOH/cache",
  version = "latest",
  force = FALSE,
  verbose = TRUE
)
elev_data <- get_global_elevation_data(
  dir = "ReAOH/cache",
  version = "latest",
  force = FALSE,
  verbose = TRUE
)

errlist<-c()
errlistaoh<-c()
pb <- txtProgressBar(min=3501,max=nrow(reptl_range_data),char = "=",)
for (i in 3548:nrow(reptl_range_data)){
  setTxtProgressBar(pb,i)
  reptl_range_data_tmp <- reptl_range_data[i,]
  reptl_info_data <- try(create_spp_info_data(
    x = reptl_range_data_tmp,
    cache_dir = "ReAOH/cache",
    verbose = TRUE))
  if(inherits(reptl_info_data,"try-error")){
    errlist <- c(errlist, i)
    next
  }
  else{
    reptl_aoh_data <- try(create_spp_aoh_data(
      x = reptl_info_data,
      engine = "gdal",
      crosswalk_data = crosswalk_lumb_cgls_data,
      cache_dir = "ReAOH/cache",
      verbose = TRUE,
      output_dir = "ReAOH/REPTILES"))
    if(inherits(reptl_aoh_data,"try-error")){
      errlistaoh <- c(errlistaoh,i)
    }
    else{
      ifelse(i==3501,reptl_aoh_data_all <- reptl_aoh_data,reptl_aoh_data_all <- bind_rows(reptl_aoh_data_all,reptl_aoh_data))
    }
    
  }
 

rm(reptl_range_data_tmp)
rm(reptl_aoh_data)
gc()
}

