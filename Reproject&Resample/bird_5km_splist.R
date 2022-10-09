rm(list=ls())
gc()
library(raster)
library(rgdal)
library(stringr)
library(dplyr)
library(readr)
SPList <- read.csv("E:/Priority program/Re-220327/Input/SPList_32600_220428.csv")
SPList <- SPList[SPList$taxa=="bird",]
grid_cell<-read_csv("E:/Priority program/Re-220327/Input/GlobalCells_5km_v220408.csv")
bird<-read.csv("E:/Priority program/Re-PriorityProgram20220903/ReAOH/bird_spp_list.csv")
BIRDS <- "E:/Priority program/Re-PriorityProgram20220903/ReAOH/BIRDS"
PAKBAlist <- grid_cell[grid_cell$PAorKBA==1,]$X

for(i in 857:length(dir(BIRDS))){
  
  name <- bird[paste0(bird$filename,".tif")==dir(BIRDS)[i],"binomial"]
  season <- bird[paste0(bird$filename,".tif")==dir(BIRDS)[i],"seasonal"]
  tlist <- read_csv(paste0("E:/Priority program/Re-PriorityProgram20220903/Reproject&Resample/Species_table/bird/",name,"_",season,".csv"))
  print(paste(i,name))
  
  ifelse(nrow(SPList[SPList$originalname==name,])==1,SPID <- which(SPList$originalname==name),SPID <-which(SPList$scientific.name==paste0(name,"_",season)) )
  SPList$area[SPID] <- sum(tlist$area)
  SPList$target[SPID] <- set_target(SPList$area[SPID])
  SPList$sp.file[SPID] <- paste0("E:/Priority program/Re-PriorityProgram20220903/Reproject&Resample/Species_table/bird/",name,"_",season,".csv")
  SPList$InPA[SPID] <- sum(tlist[tlist$id%in%PAKBAlist,"area"])
  SPList$OutPA[SPID] <- sum(tlist[!tlist$id%in%PAKBAlist,"area"])
  SPList$prop[SPID] <- (SPList$target[SPID]-SPList$InPA[SPID])/SPList$OutPA[SPID]
  rm(tlist)
  rm(name)
  rm(season)
  rm(SPID)
  gc()
}

write.csv(SPList,"Reproject&Resample/SPList_bird_5km.csv",row.names=F)

# No.57 103881981_4 doesn't exist in SPList, skip this
# No.573 22711244_2



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
