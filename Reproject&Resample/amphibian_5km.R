rm(list=ls())
gc()
library(raster)
library(rgdal)
library(stringr)
library(dplyr)
library(readr)
### AMPHIBIANS ---------------

grid_cell<-read_csv("E:/Priority program/Re-220327/Input/GlobalCells_5km_v220408.csv")


Mollweide<-"+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"

amphibian<-read.csv("E:/Priority program/Re-PriorityProgram20220903/ReAOH/amphi_spp_list.csv")
AMPHIBIANS <- "E:/Priority program/Re-PriorityProgram20220903/ReAOH/AMPHIBIANS_narrow"
SPList <- read.csv("E:/Priority program/Re-220327/Input/SPList_32600_220428.csv")
SPList <- SPList[SPList$taxa=="amphibian",]

PAKBAlist <- grid_cell[grid_cell$PAorKBA==1,]$X


for(i in 2:length(dir(AMPHIBIANS))){
  spraster <- raster(paste0(AMPHIBIANS,"/",dir(AMPHIBIANS)[i]))
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
  tlist<-tlist[!is.na(tlist$area),]
  tlist$area <- tlist$area/100
  
  name <- amphibian[paste0(amphibian$filename,".tif")==dir(AMPHIBIANS)[i],"binomial"]
  season <- amphibian[paste0(amphibian$filename,".tif")==dir(AMPHIBIANS)[i],"seasonal"]
  write.csv(tlist,paste0("E:/Priority program/Re-PriorityProgram20220903/Reproject&Resample/Species_table/amphibian/",name,"_",season,".csv"))
  print(paste(i,name))
  
  ifelse(nrow(SPList[SPList$originalname==name,])==1,SPID <- which(SPList$originalname==name),SPID <-which(SPList$scientific.name==paste0(name,"_",season)) )
  SPList$area[SPID] <- sum(tlist$area)
  SPList$target[SPID] <- set_target(SPList$area[SPID])
  SPList$sp.file[SPID] <- paste0("E:/Priority program/Re-PriorityProgram20220903/Reproject&Resample/Species_table/amphibian/",name,"_",season,".csv")
  SPList$InPA[SPID] <- sum(tlist[tlist$id%in%PAKBAlist,"area"])
  SPList$OutPA[SPID] <- sum(tlist[!tlist$id%in%PAKBAlist,"area"])
  SPList$prop[SPID] <- (SPList$target[SPID]-SPList$InPA[SPID])/SPList$OutPA[SPID]
  rm(tlist)
  rm(spraster_5km)
  rm(name)
  rm(season)
  rm(SPID)
  gc()
}



### set targets ------------------
a<-(0.1-1)/(log(250000)-log(1000))
b<-1-log(1000)*a
set_target<-function(input){
  if (typeof(input)=="double"){
    if (input<=1000){
      target_value<-input
    }
    if(input>=250000 & input <10000000){
      target_value<-input*0.1
    }
    if(input>1000 & input<250000){
      target_value<-(log(input)*a+b)*input
    }
    if(input>=10000000){
      target_value<-1000000
    }
    return(target_value)
  }
  else {
    return("type of input error")
  }
}



