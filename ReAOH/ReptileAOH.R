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
# dir.create("E:/Priority program/Re-PriorityProgram20220903/ReAOH/repcache")
cache_dir<-"E:/Priority program/Re-PriorityProgram20220903/ReAOH/repcache"

# prepare information
reptl_info_data <- create_spp_info_data(reptl_range_data, cache_dir = cache_dir)

print(reptl_info_data)

## Generate area of habitat
# specify a folder to save area of habitat
# dir.create("ReAOH/REPTILES")
output_dir <- "E:/Priority program/Re-PriorityProgram20220903/ReAOH/REPTILES"

reptl_aoh_data <- create_spp_aoh_data(reptl_info_data, output_dir = output_dir, cache_dir = cache_dir)