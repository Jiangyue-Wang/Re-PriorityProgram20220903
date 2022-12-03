rm(list=ls())
gc()
sfile<-dir("E:/Priority program/Re-PriorityProgram20220903/Output/")[1:24]
library(raster)
population<-raster("E:/Priority program/GeeodataFrom204/population/population_5km.tif")
# gHM<-raster("E:/Priority program/GeeodataFrom204/gHM/gHM_5km.tif")

popstat<-data.frame(ScW=NA,sum=NA,Mean=NA,ASs=NA,ASp=NA,ASm=NA,AFs=NA,AFp=NA,AFm=NA,SAs=NA,SAp=NA,SAm=NA,NAs=NA,NAp=NA,NAm=NA,EUs=NA,EUp=NA,EUm=NA,OAs=NA,OAp=NA,OAm=NA)

for(i in 1:24){
  rm(s_grid_cell)
  gc()
  s_grid_cell<-fread(paste("E:/Priority program/Re-PriorityProgram20220903/Output/",sfile[i],sep=""))
  s_grid_cell[s_grid_cell$country==10,"continent"]<-6
  s_grid_cell<-s_grid_cell[s_grid_cell$selection==1,]
  name<-str_sub(sfile[i],start=7,end=11)
  weight<-str_sub(sfile[i],start=13,end=str_length(sfile[i])-4)
  weight<-paste("W",as.character(as.numeric(weight)*100),sep="")
  popstat[i,"ScW"]<-paste(name,weight,sep="")
  
  tmp<-extract(population,s_grid_cell[,c("x","y")])
  popstat$Mean[i]<-mean(tmp,na.rm=T)/25
  popstat$sum[i]<- sum(tmp,na.rm=T)
  
  tmp1 <- tmp[s_grid_cell$continent==1]
  popstat$ASm[i]<-mean(tmp1,na.rm=T)/25
  popstat$ASs[i]<- sum(tmp1,na.rm=T)
  popstat$ASp[i]<-popstat$ASs[i]/popstat$sum[i]
  
  tmp1 <- tmp[s_grid_cell$continent==2]
  popstat$NAm[i]<-mean(tmp1,na.rm=T)/25
  popstat$NAs[i]<- sum(tmp1,na.rm=T)
  popstat$NAp[i]<-popstat$NAs[i]/popstat$sum[i]
  
  tmp1 <- tmp[s_grid_cell$continent==3]
  popstat$EUm[i]<-mean(tmp1,na.rm=T)/25
  popstat$EUs[i]<- sum(tmp1,na.rm=T)
  popstat$EUp[i]<-popstat$EUs[i]/popstat$sum[i]
  
  tmp1 <- tmp[s_grid_cell$continent==4]
  popstat$AFm[i]<-mean(tmp1,na.rm=T)/25
  popstat$AFs[i]<- sum(tmp1,na.rm=T)
  popstat$AFp[i]<-popstat$AFs[i]/popstat$sum[i]
  
  tmp1 <- tmp[s_grid_cell$continent==5]
  popstat$SAm[i]<-mean(tmp1,na.rm=T)/25
  popstat$SAs[i]<- sum(tmp1,na.rm=T)
  popstat$SAp[i]<-popstat$SAs[i]/popstat$sum[i]
  
  tmp1 <- tmp[s_grid_cell$continent==6]
  popstat$OAm[i]<-mean(tmp1,na.rm=T)/25
  popstat$OAs[i]<- sum(tmp1,na.rm=T)
  popstat$OAp[i]<-popstat$OAs[i]/popstat$sum[i]
  
}


write.csv(popstat,"E:/Priority program/Re-PriorityProgram20220903/Stats/popstat.csv",row.names = F)


