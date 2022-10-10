rm(list=ls())
gc()
# dir.create("Input")
amphibian<-read.csv("E:/Priority program/Re-PriorityProgram20220903/Reproject&Resample/SPList_amphibian_5km.csv")


library(stringr)

# add species targets-------------------

rij_amphibian<-data.frame(pu=NA,species=NA,amount=NA)
rij_amphibian<-rij_amphibian[-1,]
library(readr)
c_grid_cell<-read_csv("E:/Priority program/Re-220327/Input/GlobalCells_5km_v220408.csv")
library(dplyr)

for (i in 1:nrow(amphibian)){
  rm(spe)
  rm(spe_tmp)
  rm(spe_5km)
  rm(tmpspe_list)
  gc()
  spe<-read.csv(amphibian[i,"sp.file"])[,-1]
  colnames(spe)<-c("X","allarea")
  spe_tmp<-dplyr::left_join(spe,c_grid_cell[,c("X","Parea")],by="X")
  # amphibian[i,"pass"]<-(amphibian[i,"target"]*0.95-sum(spe_tmp[spe_tmp$Parea==25,"allarea"],na.rm=TRUE))/sum(spe_tmp$"spUParea",na.rm=TRUE)
  
  if(amphibian[i,"prop"]>0 & is.finite(amphibian[i,"prop"]) & !is.na(amphibian[i,"prop"])){
    spe_5km<-spe_tmp[spe_tmp$Parea==0,]
    spe_5km<-spe_5km[,c("X","allarea")]
    colnames(spe_5km)<-c("pu","amount")
    spe_5km$species<-amphibian$rijid[i]
    rij_amphibian<-bind_rows(rij_amphibian,spe_5km)
    print(i)
    print(Sys.time())
  }
  
}
write.csv(rij_amphibian,"E:/Priority program/Re-PriorityProgram20220903/Input/rij_amphibian.csv",row.names=F)

