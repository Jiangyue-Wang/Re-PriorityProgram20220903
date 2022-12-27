rm(list=ls())
gc()
sfile<-dir("Output_rij_mod")[1:24]
library(raster)
library(data.table)
library(stringr)
population<-raster("E:/Priority program/GeeodataFrom204/population/population_5km.tif")
# gHM<-raster("E:/Priority program/GeeodataFrom204/gHM/gHM_5km.tif")

popstat<-data.frame(ScW=NA,sum=NA,Mean=NA,ASs=NA,ASp=NA,ASm=NA,AFs=NA,AFp=NA,AFm=NA,SAs=NA,SAp=NA,SAm=NA,NAs=NA,NAp=NA,NAm=NA,EUs=NA,EUp=NA,EUm=NA,OAs=NA,OAp=NA,OAm=NA)

for(i in 1:24){
  rm(s_grid_cell)
  gc()
  s_grid_cell<-fread(paste("Output_rij_mod/",sfile[i],sep=""))
  s_grid_cell[s_grid_cell$country==10,"continent"]<-6
  s_grid_cell<-s_grid_cell[s_grid_cell$selection==1,]
  name<-str_split_fixed(sfile[i],pattern="_",n=2)[1,1]
  weight<-str_sub(str_split_fixed(sfile[i],pattern="_",n=3)[1,3],start=1,end=str_length(str_split_fixed(sfile[i],pattern="_",n=3)[1,3])-4)
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
head(popstat)
popstat[25,1]<-"PA/KBA"
s_grid_cell<-fread(paste("Output_rij_mod/",sfile[1],sep=""))
s_grid_cell[s_grid_cell$country==10,"continent"]<-6
s_grid_cell<-s_grid_cell[s_grid_cell$selection==2,]
tmp<-extract(population,s_grid_cell[,c("x","y")])
popstat[25,2]<-sum(tmp,na.rm=T)
popstat[25,3]<-mean(tmp,na.rm=T)/25
tmp1<-tmp[s_grid_cell$continent==1]
popstat[25,4]<-sum(tmp1,na.rm=T)
popstat[25,5]<-popstat[25,4]/popstat[25,2]
popstat[25,6]<-mean(tmp1,na.rm=T)/25
tmp1<-tmp[s_grid_cell$continent==4]
popstat[25,7]<-sum(tmp1,na.rm=T)
popstat[25,8]<-popstat[25,7]/popstat[25,2]
popstat[25,9]<-mean(tmp1,na.rm=T)/25
tmp1<-tmp[s_grid_cell$continent==5]
popstat[25,10]<-sum(tmp1,na.rm=T)
popstat[25,11]<-popstat[25,10]/popstat[25,2]
popstat[25,12]<-mean(tmp1,na.rm=T)/25
tmp1<-tmp[s_grid_cell$continent==2]
popstat[25,13]<-sum(tmp1,na.rm=T)
popstat[25,14]<-popstat[25,13]/popstat[25,2]
popstat[25,15]<-mean(tmp1,na.rm=T)/25
tmp1<-tmp[s_grid_cell$continent==3]
popstat[25,16]<-sum(tmp1,na.rm=T)
popstat[25,17]<-popstat[25,16]/popstat[25,2]
popstat[25,18]<-mean(tmp1,na.rm=T)/25
tmp1<-tmp[s_grid_cell$continent==6]
popstat[25,19]<-sum(tmp1,na.rm=T)
popstat[25,20]<-popstat[25,19]/popstat[25,2]
popstat[25,21]<-mean(tmp1,na.rm=T)/25



write.csv(popstat,"Stat_rij_mod/popstat.csv",row.names = F)


