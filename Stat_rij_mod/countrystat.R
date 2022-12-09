rm(list=ls())
gc()
# dir.create("Stat_rij_mod")
library(data.table)
grid_cell<-fread("Input/GlobalCells_5km_v221011.csv")
country_stat<-aggregate(grid_cell[,c("area","PA","PAorKBA")],by=list(grid_cell$country),FUN=sum)
colnames(country_stat)<-c("CountryID","Area","PA","PAandKBA")
country_stat$KBAoutPA<-country_stat$PAandKBA-country_stat$PA
country_stat<-country_stat[,c("CountryID","Area","PA","KBAoutPA")]
country_stat[,c("PA","KBAoutPA")]<-25*country_stat[,c("PA","KBAoutPA")]
country_stat$PAprop<-country_stat$PA/country_stat$Area
country_stat$KBAoutPAprop<-country_stat$KBAoutPA/country_stat$Area



sfile<-dir("Output_rij_mod")[1:4]

library(stringr)
for(i in 1:4){
  rm(s_grid_cell)
  gc()
  s_grid_cell<-fread(paste("Output_rij_mod/",sfile[i],sep=""))
  s_grid_cell[s_grid_cell$selection==2,"selection"]<-0
  name<-str_sub(sfile[i],start=1,end=str_length(sfile[i])-6)
  weight<-str_sub(sfile[i],start=str_length(sfile[i])-4,end=str_length(sfile[i])-4)
  weight<-paste("W",as.character(as.numeric(weight)*100),sep="")
  country_stat[,paste(name,weight,sep="")]<-aggregate(s_grid_cell$selection,by=list(s_grid_cell$country),FUN=sum)$x*25
  country_stat[,paste(name,weight,"prop",sep="")]<-country_stat[,paste(name,weight,sep="")]/country_stat$Area
  country_stat[,paste(name,weight,"Left",sep="")]<-country_stat$Area-country_stat$PA-country_stat$KBAoutPA-country_stat[,paste(name,weight,sep="")]
  country_stat[,paste(name,weight,"Leftprop",sep="")]<-1-country_stat$PAprop-country_stat$KBAoutPAprop-country_stat[,paste(name,weight,"prop",sep="")]
  print(all(country_stat[,paste(name,weight,"Left",sep="")]/country_stat$Area-country_stat[,paste(name,weight,"Leftprop",sep="")]<=0.001))
}


write.csv(country_stat,"Stat_rij_mod/CountryStat_W100.csv")