# try to run reptiles one by one
rm(list=ls())
gc()
library(aoh)
library(dplyr)
Sys.setenv("GDAL_PYTHON" = "python")
Sys.setenv("GDAL_CALC" = "C:\\OSGeo4W\\apps\\Python39\\Scripts\\gdal_calc.py")
Sys.setenv("GDAL_ESCAPE" = "false")
reptl_narrow <- read.csv("E:/Priority program/WJY/AOH/AOH_errors/narrow_reptile.csv")
spp_range_data <- read_spp_range_data("ReAOH/REPTILES.zip")
spp_range_data <- spp_range_data[paste0(spp_range_data$id_no,"_",spp_range_data$seasonal) %in% paste0(reptl_narrow$id_no,"_",reptl_narrow$seasonal),]

cache_dir<-"ReAOH/cache"
output_dir <- "ReAOH/REPTILES"

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
reptl_range_data <- spp_range_data
for (i in 1:nrow(reptl_range_data)){
  
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
    
  }
  
  
  rm(reptl_range_data_tmp)
  rm(reptl_aoh_data)
  gc()
}
  
  
  
reptl_aoh_data <- create_spp_aoh_data(x=create_spp_info_data(reptl_range_data,cache_dir = "ReAOH/cache"),cache_dir = "ReAOH/cache",verbose = TRUE,output_dir = "ReAOH/REPTILES")
saveRDS(reptl_aoh_data,"ReAOH/reptl_narrow_aoh_data.rds")
library(dplyr)
reptl_spp_list <- reptl_aoh_data %>%
  mutate(filename=paste0(id_no,"_",seasonal)) %>%
  select(filename,id_no,seasonal,binomial,category,path)
reptl_spp_list <- as.data.frame(reptl_spp_list)
reptl_spp_list<-reptl_spp_list[,-ncol(reptl_spp_list)]
write.csv(reptl_spp_list,"ReAOH/reptl_spp_list.csv",row.names=F)
