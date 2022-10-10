rm(list=ls())
gc()
# dir.create("Input")
mammal<-read.csv("E:/Priority program/Re-PriorityProgram20220903/Reproject&Resample/SPList_mammal_5km.csv")


library(stringr)

# add species targets-------------------

rij_mammal<-data.frame(pu=NA,species=NA,amount=NA)
rij_mammal<-rij_mammal[-1,]
library(readr)
c_grid_cell<-read_csv("E:/Priority program/Re-220327/Input/GlobalCells_5km_v220408.csv")
library(dplyr)

for (i in 1:nrow(mammal)){
  rm(spe)
  rm(spe_tmp)
  rm(spe_5km)
  rm(tmpspe_list)
  gc()
  
  
  # mammal[i,"pass"]<-(mammal[i,"target"]*0.95-sum(spe_tmp[spe_tmp$Parea==25,"allarea"],na.rm=TRUE))/sum(spe_tmp$"spUParea",na.rm=TRUE)
  
  if(mammal[i,"prop"]>0 & is.finite(mammal[i,"prop"]) & !is.na(mammal[i,"prop"])){
    spe<-read.csv(mammal[i,"sp.file"])[,-1]
    colnames(spe)<-c("X","allarea")
    spe_tmp<-dplyr::left_join(spe,c_grid_cell[,c("X","Parea")],by="X")
    spe_5km<-spe_tmp[spe_tmp$Parea==0,]
    spe_5km<-spe_5km[,c("X","allarea")]
    colnames(spe_5km)<-c("pu","amount")
    spe_5km$species<-mammal$rijid[i]
    rij_mammal<-bind_rows(rij_mammal,spe_5km)
    print(i)
    print(Sys.time())
  }
  
}
write.csv(rij_mammal,"E:/Priority program/Re-PriorityProgram20220903/Input/rij_mammal.csv",row.names=F)

