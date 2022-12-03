rij_5km_30_sp<-fread("Input/rij_species_221130.csv")
rij_5km_30_sp <- filter(rij_5km_30_sp, !is.na(amount))

rij_5km_30_sp <- rij_5km_30_sp[rij_5km_30_sp$species%in%feature_5km_30_sp$id,]

rij_gradient0<-rij_5km_30_sp %>% filter(amount>0.00001) 

spaoh <- grid_cell[,c("X","x","y")]

rij_abun <- rij_gradient0 %>% group_by(pu) %>% summarise(sumabun=sum(amount))
head(rij_abun)
colnames(rij_abun)[1]<-"X"
spaoh <- left_join(spaoh,rij_abun)
plot(rasterFromXYZ(spaoh[,c("x","y","sumabun")]))
writeRaster(rasterFromXYZ(spaoh[,c("x","y","sumabun")]),"TestRun/spaoh.tif")
