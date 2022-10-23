rm(list=ls())
library(data.table)
grid_cell<-fread("Input/GlobalCells_5km_v221011.csv")
country_stat<-aggregate(grid_cell[,c("area","PA","PAorKBA")],by=list(grid_cell$country),FUN=sum)
colnames(country_stat)<-c("CountryID","Area","PA","PAandKBA")
country_stat$KBAoutPA<-country_stat$PAandKBA-country_stat$PA
country_stat<-country_stat[,c("CountryID","Area","PA","KBAoutPA")]
country_stat[,c("PA","KBAoutPA")]<-25*country_stat[,c("PA","KBAoutPA")]
country_stat$PAprop<-country_stat$PA/country_stat$Area
country_stat$KBAoutPAprop<-country_stat$KBAoutPA/country_stat$Area



sfile<-dir("Output")[1:24]

library(stringr)
for(i in 1:24){
  rm(s_grid_cell)
  gc()
  s_grid_cell<-fread(paste("Output/",sfile[i],sep=""))
  s_grid_cell[s_grid_cell$selection==2,"selection"]<-0
  name<-str_sub(sfile[i],start=7,end=11)
  weight<-str_sub(sfile[i],start=13,end=str_length(sfile[i])-4)
  weight<-paste("W",as.character(as.numeric(weight)*100),sep="")
  country_stat[,paste(name,weight,sep="")]<-aggregate(s_grid_cell$selection,by=list(s_grid_cell$country),FUN=sum)$x*25
  country_stat[,paste(name,weight,"prop",sep="")]<-country_stat[,paste(name,weight,sep="")]/country_stat$Area
  country_stat[,paste(name,weight,"Left",sep="")]<-country_stat$Area-country_stat$PA-country_stat$KBAoutPA-country_stat[,paste(name,weight,sep="")]
  country_stat[,paste(name,weight,"Leftprop",sep="")]<-1-country_stat$PAprop-country_stat$KBAoutPAprop-country_stat[,paste(name,weight,"prop",sep="")]
  print(all(country_stat[,paste(name,weight,"Left",sep="")]/country_stat$Area-country_stat[,paste(name,weight,"Leftprop",sep="")]<=0.001))
}






ecoregion_stat<-aggregate(grid_cell[,c("area","PA","PAorKBA")],by=list(grid_cell$ecoregion),FUN=sum)
colnames(ecoregion_stat)<-c("ecoregionID","Area","PA","PAandKBA")
ecoregion_stat$KBAoutPA<-ecoregion_stat$PAandKBA-ecoregion_stat$PA
ecoregion_stat<-ecoregion_stat[,c("ecoregionID","Area","PA","KBAoutPA")]
ecoregion_stat[,c("PA","KBAoutPA")]<-25*ecoregion_stat[,c("PA","KBAoutPA")]
ecoregion_stat$PAprop<-ecoregion_stat$PA/ecoregion_stat$Area
ecoregion_stat$KBAoutPAprop<-ecoregion_stat$KBAoutPA/ecoregion_stat$Area




for(i in 1:24){
  rm(s_grid_cell)
  gc()
  s_grid_cell<-fread(paste("Output/",sfile[i],sep=""))
  s_grid_cell[s_grid_cell$selection==2,"selection"]<-0
  name<-str_sub(sfile[i],start=7,end=11)
  weight<-str_sub(sfile[i],start=13,end=str_length(sfile[i])-4)
  weight<-paste("W",as.character(as.numeric(weight)*100),sep="")
  ecoregion_stat[,paste(name,weight,sep="")]<-aggregate(s_grid_cell$selection,by=list(s_grid_cell$ecoregion),FUN=sum)$x*25
  ecoregion_stat[,paste(name,weight,"prop",sep="")]<-ecoregion_stat[,paste(name,weight,sep="")]/ecoregion_stat$Area
  ecoregion_stat[,paste(name,weight,"Left",sep="")]<-ecoregion_stat$Area-ecoregion_stat$PA-ecoregion_stat$KBAoutPA-ecoregion_stat[,paste(name,weight,sep="")]
  ecoregion_stat[,paste(name,weight,"Leftprop",sep="")]<-1-ecoregion_stat$PAprop-ecoregion_stat$KBAoutPAprop-ecoregion_stat[,paste(name,weight,"prop",sep="")]
  print(all(ecoregion_stat[,paste(name,weight,"Left",sep="")]/ecoregion_stat$Area-ecoregion_stat[,paste(name,weight,"Leftprop",sep="")]<=0.001))
}



write.csv(country_stat,"Stats/country_stat_shuffle.csv",row.names=F)
write.csv(ecoregion_stat,"Stats/ecoregion_stat_shuffle.csv",row.names=F)
