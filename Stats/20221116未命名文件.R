rm(list=ls())
gc()
library(stringr)
library(tidyverse)
splist <- fread("Input/SPList_15441.csv")
all(abs(splist$prop*splist$OutPA-(splist$target-splist$InPA))<1)
all(abs(splist$area-splist$InPA-splist$OutPA)<1)

s_grid_cell <- fread("Output/solve_cou30_0.2.csv")
summary(s_grid_cell$area)

allarea <- sum(s_grid_cell$area)
hist(splist$target/allarea)
max(splist$target/allarea)
head(splist)

spnew <- splist[str_detect(splist$sp.file,"20220903"),]

summary(spnew)

for(i in 1:nrow(spnew)){
  sp.file<-fread(spnew$sp.file[i])
  spnew$coverage[i]<-nrow(sp.file)*25
}
spnew$MeaninPU<-spnew$area/spnew$coverage
summary(spnew)
hist(spnew$MeaninPU,breaks=1000)
nrow(spnew[spnew$MeaninPU<=0.001,]) # 5
spnew[spnew$MeaninPU<=0.001,]$area


sp30 <- fread("Output/SPlist_all_glo30_0.csv")
nrow(sp30[sp30$Reached==0,])
sp30[sp30$Reached==0,]

sp30 <- fread("Output/SPlist_all_glo30_0.2.csv")
nrow(sp30[sp30$Reached==0,])
sp30[sp30$Reached==0,]

unreached <- which(sp30$Reached==0)

library(raster)

library(dplyr)

coord <- s_grid_cell[,c("X","x","y")]
coord$spnum <-0
for(i in 1:length(unreached)){
  spcsv <- read.csv(sp30[unreached[i],]$sp.file)[,-1]
  
  
  coord[coord$X%in%spcsv$id,"spnum"] <- coord[coord$X%in%spcsv$id,"spnum"] +spcsv[,"area"]
  
}

plot(rasterFromXYZ(coord[,c("x","y","spnum")]))



sp50 <- fread("Output/SPlist_all_glo50_0.csv")
nrow(sp50[sp50$Reached==0,])
sp50[sp50$Reached==0,]
