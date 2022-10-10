rm(list=ls())
gc()
# dir.create("Input")
bird<-read.csv("E:/Priority program/Re-PriorityProgram20220903/Reproject&Resample/SPList_bird_5km.csv")


library(stringr)

# add species targets-------------------

rij_bird<-data.frame(pu=NA,species=NA,amount=NA)
rij_bird<-rij_bird[-1,]
library(readr)
c_grid_cell<-read_csv("E:/Priority program/Re-220327/Input/GlobalCells_5km_v220408.csv")
library(dplyr)

for (i in 1:nrow(bird)){
  rm(spe)
  rm(spe_tmp)
  rm(spe_5km)
  rm(tmpspe_list)
  gc()
  
  
  # bird[i,"pass"]<-(bird[i,"target"]*0.95-sum(spe_tmp[spe_tmp$Parea==25,"allarea"],na.rm=TRUE))/sum(spe_tmp$"spUParea",na.rm=TRUE)
  
  if(bird[i,"prop"]>0 & is.finite(bird[i,"prop"]) & !is.na(bird[i,"prop"])){
    spe<-read.csv(bird[i,"sp.file"])[,-1]
    colnames(spe)<-c("X","allarea")
    spe_tmp<-dplyr::left_join(spe,c_grid_cell[,c("X","Parea")],by="X")
    spe_5km<-spe_tmp[spe_tmp$Parea==0,]
    spe_5km<-spe_5km[,c("X","allarea")]
    colnames(spe_5km)<-c("pu","amount")
    spe_5km$species<-bird$rijid[i]
    rij_bird<-bind_rows(rij_bird,spe_5km)
    print(i)
    print(Sys.time())
  }
  
}
write.csv(rij_bird,"E:/Priority program/Re-PriorityProgram20220903/Input/rij_bird.csv",row.names=F)

