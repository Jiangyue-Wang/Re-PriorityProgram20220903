rm(list=ls())
gc()
library(data.table)
SPListUR<-read.csv("Input/SPList_32599.csv")
SPListUR<-SPListUR[SPListUR$rijid!=301910,]
grid_cell<-fread("Input/GlobalCells_5km_v221011.csv")
grid_cell$spR<-0

SpRichness<-grid_cell[,c("X","spR")]
pb<-txtProgressBar(min=1,max=nrow(SPListUR),char = "=",style = 3,width=50)
for(i in 1:nrow(SPListUR)){
  tmp<-fread(SPListUR$sp.file[i],header = T)
  tmp<-tmp[tmp$area>0,]
  SpRichness[SpRichness$X%in%tmp$id,"spR"]<-SpRichness[SpRichness$X%in%tmp$id,"spR"]+1
  rm(tmp)
  gc()
  setTxtProgressBar(pb,i)
}
close(pb)
summary(SpRichness$spR)
write.csv(SpRichness,"Stats/SpeciesRichness32599.csv",row.names=F)
grid_cell$spR<-SpRichness$spR
library(raster)
plot(rasterFromXYZ(grid_cell[,c("x","y","spR")]))
writeRaster(rasterFromXYZ(grid_cell[,c("x","y","spR")],crs=Mollweide),"rasters/SpeciesRichness32599.tif")
