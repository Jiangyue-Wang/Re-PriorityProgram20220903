rm(list=ls())
gc()
# dir.create("Input")
reptile<-read.csv("E:/Priority program/Re-PriorityProgram20220903/Reproject&Resample/SPList_reptile_5km.csv")


library(stringr)

# add species targets-------------------

rij_reptile<-data.frame(pu=NA,species=NA,amount=NA)
rij_reptile<-rij_reptile[-1,]
library(readr)
c_grid_cell<-read_csv("E:/Priority program/Re-220327/Input/GlobalCells_5km_v220408.csv")
library(dplyr)

for (i in 1:nrow(reptile)){
  rm(spe)
  rm(spe_tmp)
  rm(spe_5km)
  rm(tmpspe_list)
  gc()
  spe<-read.csv(reptile[i,"sp.file"])[,-1]
  colnames(spe)<-c("X","allarea")
  spe_tmp<-dplyr::left_join(spe,c_grid_cell[,c("X","Parea")],by="X")
  # reptile[i,"pass"]<-(reptile[i,"target"]*0.95-sum(spe_tmp[spe_tmp$Parea==25,"allarea"],na.rm=TRUE))/sum(spe_tmp$"spUParea",na.rm=TRUE)
  
  if(reptile[i,"prop"]>0 & is.finite(reptile[i,"prop"]) & !is.na(reptile[i,"prop"])){
    spe_5km<-spe_tmp[spe_tmp$Parea==0,]
    spe_5km<-spe_5km[,c("X","allarea")]
    colnames(spe_5km)<-c("pu","amount")
    spe_5km$species<-reptile$rijid[i]
    rij_reptile<-bind_rows(rij_reptile,spe_5km)
    print(i)
    print(Sys.time())
  }
  
}
write.csv(rij_reptile,"E:/Priority program/Re-PriorityProgram20220903/Input/rij_reptile.csv",row.names=F)

