rm(list=ls())
gc()
vulC <- raster("Input/Vulnerable_C_Total_2018/Vulnerable_C_Total_2018.tif")
crs(vulC)
Mollweide<-"+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
vulCMoll <- projectRaster(from = vulC, crs=Mollweide, method = "bilinear")
# fail to project in R
# project and focal in arcgis
vulCMoll <- raster("Input/VulC_MollFocal/VulCMoll_focal5km.tif")
library(readr)
grid_cell <- read_csv("E:/Priority program/Re-220327/Input/GlobalCells_5km_v220408.csv")
vulC5km <- extract(vulCMoll,grid_cell[,c("x","y")],method="simple")
library(dplyr)
grid_cell <- bind_cols(grid_cell,vulC5km)
head(grid_cell)
colnames(grid_cell)[16] <- "VulC"
# grid_cell <- grid_cell[,-c(8:9)]
write.csv(grid_cell,"Input/GlobalCells_5km_v221011.csv",row.names=F)
library(raster)
plot(rasterFromXYZ(grid_cell[,c("x","y","VulC")]))
min(grid_cell$VulC[grid_cell$VulC>0],na.rm=T)# minimum non-zero value is 1,largest 228306