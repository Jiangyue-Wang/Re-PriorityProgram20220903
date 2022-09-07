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
path <- "E:/Priority program/Re-PriorityProgram20220903/ReAOH/AMPHIBIANS.zip"
amphi_range_data <- read_spp_range_data(path) 
print(amphi_range_data)

# create cache directory
# dir.create("E:/Priority program/Re-PriorityProgram20220903/ReAOH/cache")
cache_dir<-"E:/Priority program/Re-PriorityProgram20220903/ReAOH/cache"

# prepare information
amphi_info_data <- create_spp_info_data(amphi_range_data, cache_dir = cache_dir)
# Error in get_spp_api_data(x = x, api_function = function(...) { : 
#     failed to download data for the following taxon identifiers: "76317568", "76317569", "76317570", "76317571", "76317572"
# Try run again
# No error
# v initializing [1.5s]
# v cleaning species range data [44m 33.2s]
# v importing species summary data [15s]                    
# v importing species habitat data [7h 8m 30.2s]            
# v collating species data [5.4s]
# v post-processing results [23ms]
# v finished
print(amphi_info_data)

## Generate area of habitat
# specify a folder to save area of habitat
# dir.create("ReAOH/AMPHIBIANS")
output_dir <- "E:/Priority program/Re-PriorityProgram20220903/ReAOH/AMPHIBIANS"

amphi_aoh_data <- create_spp_aoh_data(amphi_info_data, output_dir = output_dir, cache_dir = cache_dir)
# C:\Users\dell\AppData\Local\Temp\RtmpmQG2fi\raster this is cache directory, clear regularly
# Remember to set nthreads and cache limit next time

saveRDS(amphi_range_data,"ReAOH/amphi_range_data.rds")
saveRDS(amphi_info_data,"ReAOH/amphi_info_data.rds")
saveRDS(amphi_aoh_data,"ReAOH/amphi_aoh_data.rds")

head(amphi_aoh_data)
head(amphi_range_data)
head(amphi_info_data)

colnames(amphi_aoh_data)
amphi_aoh_data$path
library(dplyr)
amphi_spp_list <- amphi_aoh_data %>%
  mutate(filename=paste0(id_no,"_",seasonal)) %>%
  select(filename,id_no,seasonal,binomial,category,path)

# delete geometry to save space
amphi_spp_list <- as.data.frame(amphi_spp_list)
amphi_spp_list<-amphi_spp_list[,-ncol(amphi_spp_list)]

# inspect why only 6771 tifs, but 6989 obs
nrow(amphi_spp_list[is.na(amphi_spp_list$path),]) #218, just the number difference
unique(amphi_aoh_data[is.na(amphi_aoh_data$path),]$full_habitat_code) # they lack habitat code, or 18, 14.3, 7.1 14.6, which is not in Lumbierres dataset

#inspect why only 6989 obs in info, but 8861 obs in range
amphi_range_data[!amphi_range_data$binomial%in%amphi_info_data$binomial,] # only 276
nrow(amphi_range_data[amphi_range_data$terrestial=="false",]) # only 107
amphi_range_data[!amphi_range_data$id_no%in%amphi_info_data$id_no,] # still 276
length(unique(amphi_range_data$id_no)) # 7233
amphi_range_data[duplicated(amphi_range_data$id_no),] # they have different sources

# check if old version and current version same
library(raster)
plot(raster("E:/Priority program/WJY/AOH/amphibian/FRC_520_1.tif"))
plot(raster("E:/Priority program/Re-PriorityProgram20220903/ReAOH/AMPHIBIANS/520_1.tif"))

