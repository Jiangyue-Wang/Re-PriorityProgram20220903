library(raster)
C3<-raster("Stats/GlobalC3.tif")
library(data.table)
s_grid_cell <- fread("Output/solve_glo50_1.csv")
cr<-extract(C3,s_grid_cell[,c("x","y")])
cr<-cr[s_grid_cell$selection!=0]
sum(table(cr)/length(cr))

s_grid_cell <- fread("Output/solve_glo30_1.csv")
IPL<-raster("E:/Priority program/Re-220327/layers/IPL_IndigenousPeoplesLands_2017/IPL_2017_PolygonToRaster1.tif")
crs(IPL)

summary(values(IPL))
plot(IPL)
values(IPL)[!is.na(values(IPL))]<-1

s_grid_cell <- fread("Output/solve_glo30_1.csv")
ir<-extract(IPL,s_grid_cell[,c("x","y")])
ir<-ir[s_grid_cell$selection!=0]
table(ir)/length(ir)

cr<-extract(C3,s_grid_cell[,c("x","y")])
cr<-cr[s_grid_cell$selection!=0]
icr<-cr[!is.na(ir)]
table(icr)/length(icr)


#Bhutan 21 Rwanda 149 Colombia 38
s_grid_cell <- fread("Output/solve_glo30_1.csv")
s_grid_cell[s_grid_cell$selection==2,"selection"]<-1
sum(s_grid_cell[s_grid_cell$country==38,"selection"])/nrow(s_grid_cell[s_grid_cell$country==38,])


cr<-extract(C3,s_grid_cell[,c("x","y")])
cr<-cr[s_grid_cell$selection==1&s_grid_cell$country==38]
table(cr)/length(cr)

s_grid_cell <- fread("Output/solve_glo30_1.csv")




selfile<-dir("output")[1:24]
stat3c<-data.frame(Scenario=c("PAKBA","Cou30W20","Cou30W40","Cou30W60","Cou30W80","Cou30W0","Cou30W100","Cou50W20","Cou50W40","Cou50W60","Cou50W80","Cou50W0","Cou50W100","Glo30W20","Glo30W40","Glo30W60","Glo30W80","Glo30W0","Glo30W100","Glo50W20","Glo50W40","Glo50W60","Glo50W80","Glo50W0","Glo50W100"),C1=NA,C2=NA,C3=NA)
cr<-extract(C3,s_grid_cell[,c("x","y")])
cr<-cr[s_grid_cell$PA==1]
stat3c[1,2:4]<-(table(cr)/length(cr))
for(i in 1:24){
  s_grid_cell<-fread(paste0("Output/",selfile[i]))
  cr<-extract(C3,s_grid_cell[,c("x","y")])
  cr<-cr[s_grid_cell$selection==1|s_grid_cell$KBA==1]
  stat3c[i+1,2:4]<-table(cr)/length(cr)
  rm(s_grid_cell)
  gc()
}
write.csv(stat3c,"Stats/Stat3C1107.csv",row.names=F)


s_grid_cell<-fread("Output/solve_glo30_1.csv")
cr<-extract(C3,s_grid_cell[,c("x","y")])
table(cr)*25
crs<-cr[s_grid_cell$PA==1]
table(crs)*25
cr30<-cr[s_grid_cell$selection!=0]
table(cr30)*25
s_grid_cell<-fread("Output/solve_glo50_1.csv")
cr50<-cr[s_grid_cell$selection!=0]
table(cr50)*25

s_grid_cell<-fread("Output/solve_glo30_1.csv")
s_grid_cell<-s_grid_cell[s_grid_cell$country==21,]
cr<-extract(C3,s_grid_cell[,c("x","y")])
table(cr)*25
crs<-cr[s_grid_cell$PA==1]
table(crs)*25
cr30<-cr[s_grid_cell$selection!=0]
table(cr30)*25
s_grid_cell<-fread("Output/solve_glo50_1.csv")
s_grid_cell<-s_grid_cell[s_grid_cell$country==21,]
cr50<-cr[s_grid_cell$selection!=0]
table(cr50)*25
