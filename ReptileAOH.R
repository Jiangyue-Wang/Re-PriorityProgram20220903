# install packages
# remotes::install_github("prioritizr/aoh@osgeo4w")

# load packages
library(aoh)
library(terra)
library(rappdirs)
library(ggplot2)

# IUCN Red List key
# usethis::edit_r_environ()
# IUCN_REDLIST_KEY="074f76c8df75a1575489ddab78d7df8a24e7e47476d53beb783829ac0da2362b"
# is_iucn_rl_api_available()
# TRUE

# set environmental variables
Sys.setenv("GDAL_PYTHON" = "python")
Sys.setenv("GDAL_CALC" = "C:\\OSGeo4W\\apps\\Python39\\Scripts\\gdal_calc.py")
Sys.setenv("GDAL_ESCAPE" = "false")

# import species range data
# download data from https://www.iucnredlist.org/resources/spatial-data-download
# dir.create("E:/Priority program/Re-PriorityProgram20220903/ReAOH")
path <- "G:/Priority program/Re-PriorityProgram20220903/ReAOH/REPTILES.zip"
reptl_range_data <- read_spp_range_data(path) 
# print(reptl_range_data)
reptl_range_data2.1 <- reptl_range_data[1001:1500,] 
# create cache directory
# dir.create("G:/Priority program/Re-PriorityProgram20220903/ReAOH/cache")
cache_dir<-"G:/Priority program/Re-PriorityProgram20220903/ReAOH/cache"

# prepare information
reptl_info_data2.1 <- create_spp_info_data(reptl_range_data2.1, cache_dir = cache_dir)

print(reptl_info_data2.1)

## Generate area of habitat
# specify a folder to save area of habitat
# dir.create("G:/Priority program/Re-PriorityProgram20220903/ReAOH/REPTILES")
output_dir <- "G:/Priority program/Re-PriorityProgram20220903/ReAOH/REPTILES"
n_threads <- parallel::detectCores() - 1 
reptl_aoh_data2.1 <- create_spp_aoh_data(reptl_info_data2.1, output_dir = output_dir, cache_dir = cache_dir, n_threads = n_threads)

saveRDS(reptl_aoh_data2.1,"G:/Priority program/Re-PriorityProgram20220903/ReAOH/reptl_aoh_data2.1.rds")
library(dplyr)
reptl_spp_list2.1 <- reptl_aoh_data2.1 %>%
  mutate(filename=paste0(id_no,"_",seasonal)) %>%
  select(filename,id_no,seasonal,binomial,category,path)
reptl_spp_list2.1 <- as.data.frame(reptl_spp_list2.1)
reptl_spp_list2.1<-reptl_spp_list2.1[,-ncol(reptl_spp_list2.1)]
write.csv(reptl_spp_list2.1,"G:/Priority program/Re-PriorityProgram20220903/ReAOH/reptl_spp_list2.1.csv",row.names=F)


# Group2.2.1
reptl_range_data2.2.1 <- reptl_range_data[1501:1600,] 
reptl_info_data2.2.1 <- create_spp_info_data(reptl_range_data2.2.1, cache_dir = cache_dir)
reptl_aoh_data2.2.1 <- create_spp_aoh_data(reptl_info_data2.2.1, output_dir = output_dir, cache_dir = cache_dir, n_threads = n_threads)

reptl_spp_list2.2.1 <- reptl_aoh_data2.2.1 %>%
  mutate(filename=paste0(id_no,"_",seasonal)) %>%
  select(filename,id_no,seasonal,binomial,category,path)
reptl_spp_list2.2.1 <- as.data.frame(reptl_spp_list2.2.1)
reptl_spp_list2.2.1<-reptl_spp_list2.2.1[,-ncol(reptl_spp_list2.2.1)]
write.csv(reptl_spp_list2.2.1,"G:/Priority program/Re-PriorityProgram20220903/ReAOH/reptl_spp_list2.2.1.csv",row.names=F)
# Group 2.2.2 and so on
source("G:/Priority program/Re-PriorityProgram20220903/ReAOH/FUNCTION-group_generate_aoh.R")
group_generate_aoh("REPTILES",1601,1700,"2.2.2")
group_generate_aoh("REPTILES",1701,1800,"2.2.3")
group_generate_aoh("REPTILES",1801,1900,"2.2.4")
group_generate_aoh("REPTILES",1901,2000,"2.2.5")
