Reproject_resample <- function(number){
  
  i <- number
  require(raster)
  require(rgdal)
  require(stringr)
  require(dplyr)
  require(readr)
  
  
  Mollweide<-"+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
  grid_cell<-read_csv("E:/Priority program/Re-220327/Input/GlobalCells_5km_v220408.csv")
  bird<-read.csv("E:/Priority program/Re-PriorityProgram20220903/ReAOH/bird_spp_list.csv")
  BIRDS <- "E:/Priority program/Re-PriorityProgram20220903/ReAOH/BIRDS"
  spraster <- raster(paste0(BIRDS,"/",dir(BIRDS)[i]))
  spraster_5km_tmp<-raster::aggregate(spraster,fact=50,fun=sum,na.rm=TRUE)
  
  rm(spraster)
  gc()
  
  spraster_moll <- projectRaster(from = spraster_5km_tmp, crs = Mollweide)
  rm(spraster_5km_tmp)
  gc()
  
  values(spraster_moll)[values(spraster_moll)<0] <- 0
  
  spraster_5km<-extract(spraster_moll,grid_cell[,c("x","y")],method="simple")
  rm(spraster_moll)
  
  gc()
  
  tlist<-data.frame(id=grid_cell$X,area=spraster_5km)
  rm(grid_cell)
  gc()
  tlist<-tlist[!is.na(tlist$area),]
  tlist$area <- tlist$area/100
  
  name <- bird[paste0(bird$filename,".tif")==dir(BIRDS)[i],"binomial"]
  season <- bird[paste0(bird$filename,".tif")==dir(BIRDS)[i],"seasonal"]
  write.csv(tlist,paste0("E:/Priority program/Re-PriorityProgram20220903/Reproject&Resample/Species_table/bird/",name,"_",season,".csv"))
}