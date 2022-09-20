# this code is used to generate AOH of mammals whose geometry range covers the narrow NA band
library(aoh)
Sys.setenv("GDAL_PYTHON" = "python")
Sys.setenv("GDAL_CALC" = "C:\\OSGeo4W\\apps\\Python39\\Scripts\\gdal_calc.py")
Sys.setenv("GDAL_ESCAPE" = "false")
mammal_narrow <- read.csv("E:/Priority program/WJY/AOH/AOH_errors/narrow_mammal.csv")
spp_range_data <- read_spp_range_data("ReAOH/MAMMALS.zip")
spp_range_data <- spp_range_data[paste0(spp_range_data$id_no,"_",spp_range_data$seasonal) %in% paste0(mammal_narrow$id_no,"_",mammal_narrow$seasonal),]
# dir.create("ReAOH/MAMMALS")
cache_dir<-"ReAOH/cache"
output_dir <- "ReAOH/MAMMALS"
n_threads <- parallel::detectCores() - 1
spp_info_data <- create_spp_info_data(spp_range_data, cache_dir = cache_dir)
spp_aoh_data <- create_spp_aoh_data(spp_info_data, output_dir = output_dir, cache_dir = cache_dir, n_threads = n_threads)
