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
path <- "E:/Priority program/Re-PriorityProgram20220903/ReAOH/REPTILES.zip"
reptl_range_data <- read_spp_range_data(path) 
print(reptl_range_data)

# create cache directory
# dir.create("E:/Priority program/Re-PriorityProgram20220903/ReAOH/cache")
cache_dir<-"E:/Priority program/Re-PriorityProgram20220903/ReAOH/cache"

#Not enough memory, so split into 14 groups, No.2 on workstation 204
reptl_range_data1 <- reptl_range_data[1:1000,]

# prepare information
reptl_info_data1 <- create_spp_info_data(reptl_range_data1, cache_dir = cache_dir)

print(reptl_info_data1)

## Generate area of habitat
# specify a folder to save area of habitat
# dir.create("ReAOH/REPTILES")
output_dir <- "E:/Priority program/Re-PriorityProgram20220903/ReAOH/REPTILES"
n_threads <- parallel::detectCores() - 1 
reptl_aoh_data1 <- create_spp_aoh_data(reptl_info_data1, output_dir = output_dir, cache_dir = cache_dir, n_threads = n_threads)

saveRDS(reptl_aoh_data1,"E:/Priority program/Re-PriorityProgram20220903/ReAOH/reptl_aoh_data1.rds")
library(dplyr)
reptl_spp_list1 <- reptl_aoh_data1 %>%
  mutate(filename=paste0(id_no,"_",seasonal)) %>%
  select(filename,id_no,seasonal,binomial,category,path)

# delete geometry to save space
reptl_spp_list1 <- as.data.frame(reptl_spp_list1)
reptl_spp_list1<-reptl_spp_list1[,-ncol(reptl_spp_list1)]
write.csv(reptl_spp_list1,"ReAOH/reptl_spp_list1.csv",row.names=F)


# 1000 per group won't blow up the memory

reptl_range_data3 <- reptl_range_data[2001:3000,]

# prepare information
reptl_info_data3 <- create_spp_info_data(reptl_range_data3, cache_dir = cache_dir)

print(reptl_info_data3)

## Generate area of habitat
# specify a folder to save area of habitat
# dir.create("ReAOH/REPTILES")
output_dir <- "E:/Priority program/Re-PriorityProgram20220903/ReAOH/REPTILES"
n_threads <- parallel::detectCores() - 1 
reptl_aoh_data3 <- create_spp_aoh_data(reptl_info_data3, output_dir = output_dir, cache_dir = cache_dir, n_threads = n_threads)

# Error in h(simpleError(msg, call)) : 
# 在为'mask'函数选择方法时评估'mask'参数出了错: cannot allocate vector of size 143.1 Gb
#There may be one species that needs much memory, soI checked how much it progresses,last one is 196953_1, it is the 106th row in reptl_info_data, so I will start with 108th, skiiping 107

reptl_info_data3_1 <- reptl_info_data3[108:nrow(reptl_info_data3),]
reptl_aoh_data3_1 <- create_spp_aoh_data(reptl_info_data3_1, output_dir = output_dir, cache_dir = cache_dir, n_threads = n_threads)
# It works, so the error one is Nactus pelagicus, 107th of reptl_info_data3, idno 176186, seasonal 1
saveRDS(reptl_aoh_data3_1,"E:/Priority program/Re-PriorityProgram20220903/ReAOH/reptl_aoh_data3_1.rds")
library(dplyr)
reptl_spp_list3_1 <- reptl_aoh_data3_1 %>%
  mutate(filename=paste0(id_no,"_",seasonal)) %>%
  select(filename,id_no,seasonal,binomial,category,path)

# delete geometry to save space
reptl_spp_list3_1 <- as.data.frame(reptl_spp_list3_1)
reptl_spp_list3_1<-reptl_spp_list3_1[,-ncol(reptl_spp_list3_1)]
write.csv(reptl_spp_list3_1,"ReAOH/reptl_spp_list3_1.csv",row.names=F)

