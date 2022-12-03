
rm(list=ls())
gc()

library(prioritizr)
library(dplyr)
#combine global scenario 50
library(readr)
grid_cell<-read_csv("Input/GlobalCells_5km_v221011.csv")
grid_cell$VulC <- grid_cell$VulC/100000
grid_cell$country<-as.integer(grid_cell$country)
grid_cell$ecoregion<-as.integer(grid_cell$ecoregion)
grid_cell$X <- as.integer(grid_cell$X)
#delete PAKBA==1 PUs in grid_cell
grid_cell_UP<-grid_cell[-which(grid_cell$PAorKBA==1),]
head(grid_cell)

###x object preparation-------

x_5km_30<-grid_cell[,c("X","UParea","VulC")]
colnames(x_5km_30)[1]<-"id"


#delete PAKBAs
x_5km_30<-x_5km_30[-which(x_5km_30$UParea==0),]

### calculate area and budget----------------
allarea<-sum(grid_cell$area)
P_allarea<-sum(grid_cell$Parea)
UP_allarea<-sum(grid_cell$UParea)
allarea==P_allarea+UP_allarea
budget_area_5km_30<-allarea*0.525-P_allarea


### calculate country constraints ------------

#read previous country constraint file for name
country_target_forname<-read.csv("E:/Priority program/GeeodataFrom204/layers/country/Country_ID.csv")
colnames(country_target_forname)<-c("name","id")
#calculate each country's area
country_area<-aggregate(grid_cell$area,by=list(grid_cell$country),FUN=sum)
colnames(country_area)<-c("country","area")

#delete small countries,find "big" countries
country_big<-country_area[country_area$area>=(25/0.03),]

#create country target dataframe
country_target_5km<-data.frame(id=c(country_target_forname$id+2000,country_target_forname$id+3000),area=0,name=c(paste(country_target_forname$name,"lower",sep="_"),paste(country_target_forname$name,"higher",sep="_")))

#delete small countries
country_target_5km<-country_target_5km[which(as.integer(country_target_5km$id%%1000)%in%country_big$country),]
library(dplyr)
country_target_5km<-arrange(country_target_5km,id)
#calculate country in Protected area
country_Parea<-aggregate(grid_cell$Parea,by=list(grid_cell$country),FUN=sum)
country_Parea<-country_Parea[country_Parea$Group.1 %in% country_big$country,]

#calculate country in UnProtected area
country_UParea<-aggregate(grid_cell$UParea,by=list(grid_cell$country),FUN=sum)
country_UParea<-country_UParea[country_UParea$Group.1 %in% country_big$country,]

#set constraint
country_target_5km$area<-c(country_big$area*0.475-country_Parea$x,country_big$area*0.525-country_Parea$x)
#negative country_lower <-0
country_target_5km[country_target_5km$id%/%1000==2 & country_target_5km$area<0,"area"]<-0
#negative country_higher uplift 2.5%
idlist<-country_target_5km[country_target_5km$id%/%1000==3 & country_target_5km$area<0,"id"]
country_target_5km[country_target_5km$id %in% idlist,"area"]<-country_big[country_big$country %in% as.integer(idlist%%1000),"area"]*0.025


### calculate ecoregion constraints ------------

#read the ecoregion table to get name
eco_target_forname<-read.csv("E:/Priority program/TestCodeData/Ecoregion2017.csv")

#calculate eco area
eco_area<-aggregate(grid_cell$area,by=list(grid_cell$ecoregion),FUN=sum)

#create ecoregion target dataframe
eco_target_5km<-data.frame(id=eco_area$Group.1,area=0,name=0)

#calculate ecoregion in Parea
eco_Parea<-aggregate(grid_cell$Parea,by=list(grid_cell$ecoregion),FUN=sum)

#calculate ecoregion in UParea
eco_UParea<-aggregate(grid_cell$UParea,by=list(grid_cell$ecoregion),FUN=sum)

#set ecoregion constraint
eco_target_5km$area<-eco_area$x*0.17-eco_Parea$x

#delete already reaached target objects
eco_target_5km<-eco_target_5km[eco_target_5km$area>0,]

#name the target
eco_target_5km$name<-eco_target_forname[eco_target_5km$id+1,"ECO_NAME"]





### create carbon feature,target and rij------
feature_carbon<-data.frame(id=1,name="VulC",spf=1)
rij_carbon<-data.frame(pu=x_5km_30$id,species=1,amount=x_5km_30$VulC)
target_carbon<-data.frame(feature="VulC",sense="=",target=1,type="relative")

feature_5km_30_sp<-feature_carbon
rij_5km_30_sp<-rij_carbon
target_5km_30_sp<-target_carbon

###create rij,feature and target used for prioritizr problem initiation--------


rij_species<-fread("Input/rij_species_221130.csv")
rij_species_group<-rij_species %>% group_by(species) %>% summarise(sumarea=sum(amount))
rij_species_filter<- rij_species %>% filter(amount>=0.00001)
riij_species_filter_group <- rij_species_filter %>% group_by(species) %>% summarise(sumarea=sum(amount))
head(rij_species_group)
colnames(riij_species_filter_group)[2]<-"sum2"
species_compare <- left_join(rij_species_group,riij_species_filter_group)
species_compare$diff <- abs(species_compare$sum2-species_compare$sumarea)
hist(species_compare$diff)
max(species_compare$diff,na.rm=T)



SPList <- read.csv("Input/SPList_15968.csv")
#15968 obs
all(SPList$prop<=1 & SPList$prop>0 & !is.na(SPList$prop) & is.finite(SPList$prop))
#TRUE
SPList$pass_floor <- floor(SPList$target*0.95-SPList$InPA)
SPList <- SPList[SPList$pass_floor>0,]
feature_5km_30_sp<-data.frame(id=SPList$rijid,name=SPList$scientific.name,spf=1)
feature_5km_30_sp<-rbind(feature_carbon,feature_5km_30_sp)
target_5km_30_sp<-data.frame(feature=SPList$scientific.name,sense=">=",target=SPList$prop,type="relative")
target_5km_30_sp<-rbind(target_carbon,target_5km_30_sp)
summary(target_5km_30_sp$target)#many small targets so change to prop
# rij_species[which(rij_species$amount<0.05),"amount"]<-0.05
##add carbon rij
rij_species<-bind_rows(rij_carbon,rij_species)

rij_5km_30_sp<-rij_species
# rij_5km_30_sp<-rij_5km_30_sp[rij_5km_30_sp$species!=301910,]
rm(rij_species)
rij_5km_30_sp <- filter(rij_5km_30_sp, !is.na(amount))

rij_5km_30_sp <- rij_5km_30_sp[rij_5km_30_sp$species%in%feature_5km_30_sp$id,]
rij_gradient0 <- rij_5km_30_sp
# rij_gradient1<-rij_5km_30_sp %>% filter(amount>=0.00001) 
length(unique(rij_5km_30_sp$species))#14544
length(unique(rij_gradient0$species))#14544
# feature_5km_30_sp<-feature_5km_30_sp[feature_5km_30_sp$name%in%target_5km_30_sp$feature,]
# rij_5km_30_sp <- rij_5km_30_sp[rij_5km_30_sp$species%in%feature_5km_30_sp$id,]
###initiate a problem-------------
# feature_5km_30_sp<-feature_5km_30_sp[feature_5km_30_sp$id!=1,]
# target_5km_30_sp<-target_5km_30_sp[target_5km_30_sp$feature!="VulC",]
# rij_5km_30_sp<-rij_5km_30_sp[rij_5km_30_sp$species!=1,]
# rij_gradient0<-rij_5km_30_sp %>% filter(amount>0.00001) 

p_5km_30_sp<-problem(x = x_5km_30 , feature = feature_5km_30_sp, cost_column = "UParea", rij = rij_gradient0) %>%         
  add_min_shortfall_objective(budget=budget_area_5km_30)%>%
  add_manual_targets(targets = target_5km_30_sp) %>%
  add_gurobi_solver(gap = 0.005,time_limit = 60000,threads = 28,numeric_focus = T) %>% 
  add_binary_decisions()
# add_locked_out_constraints(as.logical(grid_cell_UP$urban)) %>%
# add_feature_weights(weight_5km_30_sp)
# presolve_check(p_5km_30_sp)



###add ecoregion constraints---------

for(i in unique(eco_target_5km$id)){
  rm(tmp)
  rm(pulist)
  gc()
  
  #create a tmp dataframe to show each ecoregion's distribution
  tmp<-data.frame(pu=as.integer(x_5km_30$id),eco_area=0)
  
  #pulist is the row id of each ecoregion
  pulist<-grid_cell_UP[which(grid_cell_UP$ecoregion==i),]$X
  
  #write ecoregion area in tmp
  tmp[tmp$pu%in%pulist,"eco_area"]<-grid_cell_UP[which(grid_cell_UP$ecoregion==i),"UParea"]
  
  #add constraints
  p_5km_30_sp<-p_5km_30_sp %>% add_linear_constraints(threshold=eco_target_5km[eco_target_5km$id==i,"area"],sense=">=",data=as.vector(tmp$eco_area))
  
  #to show me how it progress
  print(i)
}

###add country constraints-----------

for(i in unique(country_target_5km$id%%1000)){
  rm(tmp)
  rm(pulist)
  gc()

  #create a tmp dataframe to show each country's distribution
  tmp<-data.frame(pu=x_5km_30$id,coun_area=0)

  #pulist is the row id of each country
  pulist<-grid_cell_UP[which(grid_cell_UP$country==i),]$X

  #write country area in tmp
  tmp[tmp$pu%in%pulist,"coun_area"]<-grid_cell_UP[which(grid_cell_UP$country==i),"UParea"]

  #add constraints, lower and higher
  p_5km_30_sp<-p_5km_30_sp %>% add_linear_constraints(threshold=country_target_5km[country_target_5km$id==i+2000,"area"],sense=">=",data=as.vector(tmp$coun_area))
  p_5km_30_sp<-p_5km_30_sp %>% add_linear_constraints(threshold=country_target_5km[country_target_5km$id==i+3000,"area"],sense="<=",data=as.vector(tmp$coun_area))

  #to show me how it progress
  print(i)
}

# rare<-SPList[SPList$area<=1000,"rijid"]
# lockrare<-rij_5km_30_sp[rij_5km_30_sp$species%in%rare,"pu"]
# lockrare<-unique(lockrare)
###solve the problem------
gc()
#presolve check
presolve_check(p_5km_30_sp)#presolve takes a long long time, 30 min or so


p_5km_30_sp <- p_5km_30_sp %>% add_shuffle_portfolio(number_solutions = 1, threads=28) %>%
  add_feature_weights(c(0.2*(nrow(feature_5km_30_sp)-1),rep(1,nrow(feature_5km_30_sp)-1)))
#solve
Sys.time()
s_5km_30_sp<-solve(p_5km_30_sp)#>30min to show text
Sys.time()


s_grid_cell<-grid_cell
s_grid_cell[which(s_grid_cell$X%in%s_5km_30_sp[s_5km_30_sp$solution_1==1,"id"] & s_grid_cell$PAorKBA==0),"selection"]<-1
s_grid_cell[s_grid_cell$PAorKBA==1,"selection"]<-2
s_grid_cell[is.na(s_grid_cell[,"selection"]),"selection"]<-0
s_plot<-as.data.frame(s_grid_cell[,c("x","y","selection")])
s_plot$x<-round(s_plot$x)
s_plot$y<-round(s_plot$y)
plot(rasterFromXYZ(s_plot))


sum(s_grid_cell[s_grid_cell$selection==1,"UParea"])/budget_area_5km_30
sum(s_grid_cell[s_grid_cell$selection!=0,"area"])/allarea
sum(s_grid_cell[s_grid_cell$selection==1 ,"VulC"],na.rm = T)/sum(s_grid_cell[s_grid_cell$selection!=2 ,"VulC"],na.rm=T)
sum(s_grid_cell[s_grid_cell$selection!=0 ,"VulC"],na.rm=T)/sum(s_grid_cell[ ,"VulC"],na.rm=T)






