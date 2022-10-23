rm(list=ls())
gc()
SPlist_amphibian<-read_csv("Reproject&Resample/SPList_amphibian_5km.csv")
SPlist_reptile<-read_csv("Reproject&Resample/SPList_reptile_5km.csv")
SPlist_bird<-read_csv("Reproject&Resample/SPList_bird_5km.csv")
SPlist_mammal<-read_csv("Reproject&Resample/SPList_mammal_5km.csv")
SPList <- bind_rows(SPlist_amphibian,SPlist_reptile,SPlist_bird,SPlist_mammal)
rm(SPlist_amphibian)
rm(SPlist_reptile)
rm(SPlist_bird)
rm(SPlist_mammal)
gc()
SPList<-SPList[SPList$rijid!=301910,]
write.csv(SPList,"Input/SPList_32599.csv",row.names=F)

file <- dir("Output")
library(parallel)
source("MainAnalysis/FUNCTION_Evaluate_species.R")
cl <- makeCluster(32)
parLapply(cl,file,SpeciesEvaluate)
stopCluster(cl)




spfile<-dir("Output")

### allstat inUP--------------
allstat<-data.frame(Scenario=c(rep("Country",12),rep("Global",12)),Budget=c(rep(0.315,6),rep(0.525,6),rep(0.315,6),rep(0.525,6)),CarbonWeight=rep(c(0.2,0.4,0.6,0.8,0,1),4),BudgetUsage=NA,CarbonProp=NA,AllspProp=NA,AmphibianProp=NA,ReptileProp=NA,BirdProp=NA,MammalProp=NA,ExAmphibian=NA,ExReptile=NA,ExBird=NA,ExMammal=NA,ExSp=NA)

library(data.table)
for(i in 1:(length(spfile)/2)){
  s_grid_cell<-fread(paste("Output/",spfile[i],sep=""))
  splist<-fread(paste("Output/",spfile[i+24],sep=""))
  allstat$BudgetUsage[i]<-sum(s_grid_cell[s_grid_cell$selection==1,"UParea"])/(sum(s_grid_cell$area)*allstat$Budget[i]-sum(s_grid_cell$Parea))
  allstat$CarbonProp[i]<-sum(s_grid_cell[s_grid_cell$selection==1 ,"VulC"],na.rm=T)/sum(s_grid_cell[s_grid_cell$selection!=2 ,"VulC"],na.rm=T)
  
  allstat$AllspProp[i]<-nrow(splist[splist$Reached==1,])/nrow(splist[splist$Reached!=2,])
  allstat$AmphibianProp[i]<-nrow(splist[splist$Reached==1&splist$taxa=="amphibian",])/nrow(splist[splist$Reached!=2&splist$taxa=="amphibian",])
  allstat$ReptileProp[i]<-nrow(splist[splist$Reached==1&splist$taxa=="reptile",])/nrow(splist[splist$Reached!=2&splist$taxa=="reptile",])
  allstat$BirdProp[i]<-nrow(splist[splist$Reached==1&splist$taxa=="bird",])/nrow(splist[splist$Reached!=2&splist$taxa=="bird",])
  allstat$MammalProp[i]<-nrow(splist[splist$Reached==1&splist$taxa=="mammal",])/nrow(splist[splist$Reached!=2&splist$taxa=="mammal",])
  
  allstat$ExAmphibian[i]<-nrow(splist[splist$Reached==1&splist$taxa=="amphibian"&splist$category%in%c("VU","EN","CR"),])/nrow(splist[splist$Reached!=2&splist$taxa=="amphibian"&splist$category%in%c("VU","EN","CR"),])
  allstat$ExReptile[i]<-nrow(splist[splist$Reached==1&splist$taxa=="reptile"&splist$category%in%c("VU","EN","CR"),])/nrow(splist[splist$Reached!=2&splist$taxa=="reptile"&splist$category%in%c("VU","EN","CR"),])
  allstat$ExBird[i]<-nrow(splist[splist$Reached==1&splist$taxa=="bird"&splist$category%in%c("VU","EN","CR"),])/nrow(splist[splist$Reached!=2&splist$taxa=="bird"&splist$category%in%c("VU","EN","CR"),])
  allstat$ExMammal[i]<-nrow(splist[splist$Reached==1&splist$taxa=="mammal"&splist$category%in%c("VU","EN","CR"),])/nrow(splist[splist$Reached!=2&splist$taxa=="mammal"&splist$category%in%c("VU","EN","CR"),])
  allstat$ExSp[i]<-nrow(splist[splist$Reached==1&splist$category%in%c("VU","EN","CR"),])/nrow(splist[splist$Reached!=2&splist$category%in%c("VU","EN","CR"),])
}

# dir.create("Stats")
write.csv(allstat,"Stats/allstat_inUP.csv",row.names = F)
### all stat in all--------------
allstat<-data.frame(Scenario=c(rep("Country",12),rep("Global",12)),Budget=c(rep(0.315,6),rep(0.525,6),rep(0.315,6),rep(0.525,6)),CarbonWeight=rep(c(0.2,0.4,0.6,0.8,0,1),4),BudgetUsage=NA,CarbonProp=NA,AllspProp=NA,AmphibianProp=NA,ReptileProp=NA,BirdProp=NA,MammalProp=NA,ExAmphibian=NA,ExReptile=NA,ExBird=NA,ExMammal=NA,ExSp=NA)
for(i in 1:(length(spfile)/2)){
  s_grid_cell<-fread(paste("Output/",spfile[i],sep=""))
  splist<-fread(paste("Output/",spfile[i+24],sep=""))
  allstat$BudgetUsage[i]<-sum(s_grid_cell[s_grid_cell$selection==1,"UParea"])/(sum(s_grid_cell$area)*allstat$Budget[i]-sum(s_grid_cell$Parea))
  allstat$CarbonProp[i]<-sum(s_grid_cell[s_grid_cell$selection!=0 ,"VulC"],na.rm=T)/sum(s_grid_cell[ ,"VulC"],na.rm=T)
  
  allstat$AllspProp[i]<-nrow(splist[splist$Reached!=0,])/nrow(splist[,])
  allstat$AmphibianProp[i]<-nrow(splist[splist$Reached!=0&splist$taxa=="amphibian",])/nrow(splist[splist$taxa=="amphibian",])
  allstat$ReptileProp[i]<-nrow(splist[splist$Reached!=0&splist$taxa=="reptile",])/nrow(splist[splist$taxa=="reptile",])
  allstat$BirdProp[i]<-nrow(splist[splist$Reached!=0&splist$taxa=="bird",])/nrow(splist[splist$taxa=="bird",])
  allstat$MammalProp[i]<-nrow(splist[splist$Reached!=0&splist$taxa=="mammal",])/nrow(splist[splist$taxa=="mammal",])
  
  allstat$ExAmphibian[i]<-nrow(splist[splist$Reached!=0&splist$taxa=="amphibian"&splist$category%in%c("VU","EN","CR"),])/nrow(splist[splist$taxa=="amphibian"&splist$category%in%c("VU","EN","CR"),])
  allstat$ExReptile[i]<-nrow(splist[splist$Reached!=0&splist$taxa=="reptile"&splist$category%in%c("VU","EN","CR"),])/nrow(splist[splist$taxa=="reptile"&splist$category%in%c("VU","EN","CR"),])
  allstat$ExBird[i]<-nrow(splist[splist$Reached!=0&splist$taxa=="bird"&splist$category%in%c("VU","EN","CR"),])/nrow(splist[splist$taxa=="bird"&splist$category%in%c("VU","EN","CR"),])
  allstat$ExMammal[i]<-nrow(splist[splist$Reached!=0&splist$taxa=="mammal"&splist$category%in%c("VU","EN","CR"),])/nrow(splist[splist$taxa=="mammal"&splist$category%in%c("VU","EN","CR"),])
  allstat$ExSp[i]<-nrow(splist[splist$Reached!=0&splist$category%in%c("VU","EN","CR"),])/nrow(splist[splist$category%in%c("VU","EN","CR"),])
}
write.csv(allstat,"Stats/allstat_allarea.csv",row.names=F)

library(stringr)
# dir.create("rasters")
# dir.create("rastersSH")
for(i in 1:(length(spfile)/2)){
  
  s_grid_cell <- fread(paste0("Output/",spfile[i]))
  name <- substr(spfile[i],start=7,stop=str_length(spfile[i])-4)
  writeRaster(rasterFromXYZ(s_grid_cell[,c("x","y","selection")]),paste0("rastersSH/",name,".tif"))
}
dir.create("photosSH")
for(i in 1:(length(spfile)/2)){
  
  s_grid_cell <- fread(paste0("Output/",spfile[i]))
  name <- substr(spfile[i],start=7,stop=str_length(spfile[i])-4)
  png(paste0("photosSH/",name,".png"),width=7031,height=3045,units="px")
  plot(rasterFromXYZ(s_grid_cell[,c("x","y","selection")]))
  dev.off()
}
