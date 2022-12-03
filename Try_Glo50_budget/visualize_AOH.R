dirfold<-"E:/Priority program/Re-PriorityProgram20220903/Reproject&Resample/Species_table/bird"
dirfile<-dir(dirfold)
library(raster)
library(data.table)
s_grid_cell <- fread("E:/Priority program/Re-PriorityProgram20220903/Input/GlobalCells_5km_v221011.csv")
sxy<-s_grid_cell[,c("X","x","y")]
library(dplyr)
for(i in 597:length(dirfile)){
  spfile<-fread(paste0(dirfold,"/",dirfile[i]))[,c(2,3)]
  colnames(spfile)<-c("X","area")
  # spfile$X<-as.numeric(spfile$X)
  spfile<-left_join(spfile,sxy,by="X")
  plot(rasterFromXYZ(spfile[,c("x","y","area")]))
  Sys.sleep(0.1)
  rm(spfile)
  gc()
}
