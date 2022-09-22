# try to run reptiles one by one
rm(list=ls())
gc()
library(aoh)
library(dplyr)
Sys.setenv("GDAL_PYTHON" = "python")
Sys.setenv("GDAL_CALC" = "C:\\OSGeo4W\\apps\\Python39\\Scripts\\gdal_calc.py")
Sys.setenv("GDAL_ESCAPE" = "false")
mammal_narrow <- read.csv("E:/Priority program/WJY/AOH/AOH_errors/narrow_mammal.csv")
spp_range_data <- read_spp_range_data("ReAOH/MAMMALS.zip")
spp_range_data <- spp_range_data[paste0(spp_range_data$id_no,"_",spp_range_data$seasonal) %in% paste0(mammal_narrow$id_no,"_",mammal_narrow$seasonal),]
# dir.create("ReAOH/MAMMALS")
cache_dir<-"ReAOH/cache"
output_dir <- "ReAOH/MAMMALS"

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


max(file.info(paste0("ReAOH/MAMMALS/",dir("ReAOH/MAMMALS")))$mtime)
which(file.info(paste0("ReAOH/MAMMALS/",dir("ReAOH/MAMMALS")))$mtime==max(file.info(paste0("ReAOH/MAMMALS/",dir("ReAOH/MAMMALS")))$mtime))
file.info(paste0("ReAOH/MAMMALS/",dir("ReAOH/MAMMALS")))[32,]
spp_info_data[spp_info_data$id_no==18702,]
which(spp_info_data$id_no==18702)

errlist<-c()
errlistaoh<-c()
pb <- txtProgressBar(min=51,max=nrow(spp_info_data),char = "=",)
for (i in 51:nrow(spp_info_data)){
  setTxtProgressBar(pb,i)
  spp_info_data_tmp <- spp_info_data[i,]
    spp_aoh_data <- try(create_spp_aoh_data(
      x = spp_info_data_tmp,
      engine = "gdal",
      crosswalk_data = crosswalk_lumb_cgls_data,
      cache_dir = "ReAOH/cache",
      verbose = TRUE,
      output_dir = "ReAOH/MAMMALS"))
    if(inherits(spp_aoh_data,"try-error")){
      errlistaoh <- c(errlistaoh,i)
    }
   
  
  
  
  rm(spp_info_data_tmp)
  rm(spp_aoh_data)
  gc()
}

