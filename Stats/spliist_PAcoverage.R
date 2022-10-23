library(data.table)
library(stringr)
rm(list=ls())
gc()
s_grid_cell<-as.data.frame(fread("Input/GlobalCells_5km_v221011.csv",header=TRUE))

tmpsel<-s_grid_cell[,c("X","PA")]
PASel<-tmpsel[tmpsel$PA==1,"X"]
rm(tmpsel)
rm(s_grid_cell)
gc()

fourlist<-read.csv("Input/SPList_32599.csv")
fourlist<-fourlist[fourlist$rijid!=301910,]
fourlist$PAselect<-NA

pb<-txtProgressBar(min=1,max=nrow(fourlist),char = "=",style = 3,width=50)
##rij don't have PA distribution data,don't use for absolute allarea calculation
for(i in 1:nrow(fourlist)){
  
  rm(spe_table)
  gc()
  spe_table<-fread(fourlist$sp.file[i],header = TRUE)
  fourlist$PAselect[i]<-sum(spe_table[spe_table$id%in%PASel,"area"],na.rm=TRUE)
  setTxtProgressBar(pb,i)
}
close(pb)


write.csv(fourlist,"Stats/SPList_PAcoverage.csv",row.names=F)
nrow(fourlist[fourlist$PAselect>=fourlist$target,])
