rm(list=ls())
gc()
library(tidyverse)
library(stringr)
library(data.table)
SPListur <- read_csv("Input/SPList_15968.csv")
c_grid_cell<-read_csv("Input/GlobalCells_5km_v221011.csv")
head(c_grid_cell)

rij_species<-NULL
for (i in 1:nrow(SPListur)){
  rm(spe)
  rm(spe_tmp)
  rm(spe_5km)
  rm(tmpspe_list)
  gc()
  spe<-fread(SPListur$sp.file[i])[,-1]
  colnames(spe)<-c("X","allarea")
  spe_tmp<-left_join(spe,c_grid_cell[,c("X","Parea")],by="X")

  spe_5km<-spe_tmp[spe_tmp$Parea==0,]
  spe_5km<-spe_5km[,c("X","allarea")]
  colnames(spe_5km)<-c("pu","amount")
  spe_5km$species<-SPListur$rijid[i]
  rij_species<-bind_rows(rij_species,spe_5km)
  print(i)
  print(Sys.time())
  
  
}
write.csv(rij_species,"Input/rij_species.csv",row.names=F)
