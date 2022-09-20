library(remotes)
remotes::install_github("prioritizr/aoh")
library(aoh)
packageVersion("aoh")
f <- "ReAOH/REPTILES.zip"
cd <- "ReAOH/cache"
d <- read_spp_range_data(f)
d <- d[d$id_no==176186,]
Sys.setenv("GDAL_PYTHON" = "python")
Sys.setenv("GDAL_CALC" = "C:\\OSGeo4W\\apps\\Python39\\Scripts\\gdal_calc.py")
Sys.setenv("GDAL_ESCAPE" = "false")
x <- create_spp_aoh_data(x=create_spp_info_data(x=d,cache_dir = cd,verbose=interactive()),output_dir = "ReAOH/REPTILES", engine="gdal", verbose=interactive())

