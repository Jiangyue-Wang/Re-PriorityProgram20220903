file <- dir("Output_rij_mod")[c(17,23)]
library(parallel)
source("MainAnalysis_rij_mod/FUNCTION_Evaluate_species.R")
cl <- makeCluster(12)
parLapply(cl,file,SpeciesEvaluate)
stopCluster(cl)




spfile<-dir("Output_rij_mod")

### allstat inUP--------------
allstat<-data.frame(Scenario=c(rep("Country",12),rep("Global",12)),Budget=c(rep(0.315,6),rep(0.525,6),rep(0.315,6),rep(0.525,6)),CarbonWeight=rep(c(0.2,0.4,0.6,0.8,0,1),4),BudgetUsage=NA,CarbonProp=NA,AllspProp=NA,AmphibianProp=NA,ReptileProp=NA,BirdProp=NA,MammalProp=NA,ExAmphibian=NA,ExReptile=NA,ExBird=NA,ExMammal=NA,ExSp=NA)

library(data.table)
for(i in 1:(length(spfile)/2)){
  s_grid_cell<-fread(paste("Output_rij_mod/",spfile[i],sep=""))
  splist<-fread(paste("Output_rij_mod/",spfile[i+24],sep=""))
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
write.csv(allstat,"Stat_rij_mod/allstat_inUP.csv",row.names = F)
### all stat in all--------------
allstat<-data.frame(Scenario=c(rep("Country",12),rep("Global",12)),Budget=c(rep(0.315,6),rep(0.525,6),rep(0.315,6),rep(0.525,6)),CarbonWeight=rep(c(0.2,0.4,0.6,0.8,0,1),4),BudgetUsage=NA,CarbonProp=NA,AllspProp=NA,AmphibianProp=NA,ReptileProp=NA,BirdProp=NA,MammalProp=NA,ExAmphibian=NA,ExReptile=NA,ExBird=NA,ExMammal=NA,ExSp=NA)
for(i in 1:(length(spfile)/2)){
  s_grid_cell<-fread(paste("Output_rij_mod/",spfile[i],sep=""))
  splist<-fread(paste("Output_rij_mod/",spfile[i+24],sep=""))
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
write.csv(allstat,"Stat_rij_mod/allstat_allarea.csv",row.names=F)

