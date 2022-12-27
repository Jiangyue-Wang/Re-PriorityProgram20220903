# dir.create("MainAnalysis_rij_mod")
# dir.create("Output_rij_mod")

rm(list=ls())
gc()

### parameter setting----------
BUDGET=30 #or 30
SCENARIO="Global" #or "Global"
set.seed(20221227)
### load library------
library(prioritizr)
library(tidyverse)
library(readr)
library(data.table)
library(raster)
library(stringr)

### read in Global Cell features and prepare x object---------
grid_cell<-fread("Input/GlobalCells_5km_v221011.csv")

# make carbon values in the same range as species, categorical columns(country, ecoregion, id of PU) as integer
grid_cell <- grid_cell %>% mutate(VulC=VulC/100000, country=as.integer(country),ecoregion=as.integer(ecoregion),X=as.integer(X))

# get non-PA PUs
grid_cell_UP<-grid_cell %>% filter(UParea!=0)


# x object preparation

x_5km<-grid_cell_UP %>% dplyr::select(X,UParea,VulC)
colnames(x_5km)[1]<-"id"


### calculate area and budget----------------
allarea<-sum(grid_cell$area)
P_allarea<-sum(grid_cell$Parea)

budget_up<-0.01*(BUDGET+0.05*BUDGET)
budget_lw<-0.01*(BUDGET-0.05*BUDGET)
budget_area_5km<-allarea*budget_up-P_allarea


### calculate country constraints ------------

# read previous country constraint file for name
country_target_forname<-read.csv("E:/Priority program/GeeodataFrom204/layers/country/Country_ID.csv")
colnames(country_target_forname)<-c("name","id")
# calculate each country's area
country_area<-aggregate(grid_cell$area,by=list(grid_cell$country),FUN=sum)
colnames(country_area)<-c("country","area")

# find "big" countries, threshold 25/0.03 setting as PU area/country constraint up-lw in 30% budget
country_big<-country_area[country_area$area>=(25/0.03),]

#create country target dataframe, id within range of [2000,3000) as lower constraint, [3000,4000) as higher constraint
country_target_5km<-data.frame(id=c(country_target_forname$id+2000,country_target_forname$id+3000),area=0,name=c(paste(country_target_forname$name,"lower",sep="_"),paste(country_target_forname$name,"higher",sep="_")))

#delete small countries
country_target_5km<-country_target_5km[which(as.integer(country_target_5km$id%%1000)%in%country_big$country),]

country_target_5km<-arrange(country_target_5km,id)

#calculate country in Protected area
country_Parea<-aggregate(grid_cell$Parea,by=list(grid_cell$country),FUN=sum)
country_Parea<-country_Parea[country_Parea$Group.1 %in% country_big$country,]

#calculate country in Unprotected area
country_UParea<-aggregate(grid_cell$UParea,by=list(grid_cell$country),FUN=sum)
country_UParea<-country_UParea[country_UParea$Group.1 %in% country_big$country,]

#set constraint
country_target_5km$area<-c(country_big$area*budget_lw-country_Parea$x,country_big$area*budget_up-country_Parea$x)

#negative country_lower <-0
country_target_5km[country_target_5km$id%/%1000==2 & country_target_5km$area<0,"area"]<-0
#negative country_higher <-country area * 2.5%
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

#delete already reached target objects
eco_target_5km<-eco_target_5km[eco_target_5km$area>0,]

#name the target
eco_target_5km$name<-eco_target_forname[eco_target_5km$id+1,"ECO_NAME"]





### create carbon feature,target and rij------
feature_carbon<-data.frame(id=1,name="VulC",spf=1)
rij_carbon<-data.frame(pu=x_5km$id,species=1,amount=x_5km$VulC)
target_carbon<-data.frame(feature="VulC",sense="=",target=1,type="relative")


### create rij,feature and target used for prioritizr problem initiation--------

SPList <- read.csv("Input/SPList_15968.csv")
all(SPList$prop<=1 & SPList$prop>0 & !is.na(SPList$prop) & is.finite(SPList$prop))

SPList$pass_floor <- floor(SPList$target*0.95-SPList$InPA)
SPList <- SPList[SPList$pass_floor>0,]#14543 obs

feature_5km_sp <- data.frame(id=SPList$rijid,name=SPList$scientific.name,spf=1)
feature_5km <- rbind(feature_carbon,feature_5km_sp)

target_5km_sp <- data.frame(feature=SPList$scientific.name,sense=">=",target=SPList$prop,type="relative")
target_5km <- rbind(target_carbon,target_5km_sp)

rij_species <- fread("Input/rij_species_221130.csv")
rij_species <- rij_species %>% filter(amount>0.00001, species%in%feature_5km_sp$id)
rij_5km <- bind_rows(rij_carbon,rij_species) %>% filter(!is.na(amount))
length(unique(rij_5km$species))# 14544

### initiate a problem-------------


p_5km<-problem(x = x_5km , feature = feature_5km, cost_column = "UParea", rij = rij_5km) %>%     
  add_min_shortfall_objective(budget=budget_area_5km)%>%
  add_manual_targets(targets = target_5km) %>%
  add_gurobi_solver(gap = 0.005,time_limit = 60000,threads = 28,numeric_focus = T) %>% 
  add_binary_decisions()




###add ecoregion constraints---------

for(i in unique(eco_target_5km$id)){
  rm(tmp)
  rm(pulist)
  gc()
  
  #create a tmp dataframe to show each ecoregion's distribution
  tmp<-data.frame(pu=as.integer(x_5km$id),eco_area=0)
  
  #pulist is the row id of each ecoregion
  pulist<-grid_cell_UP[which(grid_cell_UP$ecoregion==i),]$X
  
  #write ecoregion area in tmp
  tmp[tmp$pu%in%pulist,"eco_area"]<-grid_cell_UP[which(grid_cell_UP$ecoregion==i),"UParea"]
  
  #add constraints
  p_5km<-p_5km %>% add_linear_constraints(threshold=eco_target_5km[eco_target_5km$id==i,"area"],sense=">=",data=as.vector(tmp$eco_area))
  
  #to show me how it progress
  print(i)
}

###add country constraints-----------
if(SCENARIO=="Country"){
  for(i in unique(country_target_5km$id%%1000)){
    rm(tmp)
    rm(pulist)
    gc()
    
    #create a tmp dataframe to show each country's distribution
    tmp<-data.frame(pu=x_5km$id,coun_area=0)
    
    #pulist is the row id of each country
    pulist<-grid_cell_UP[which(grid_cell_UP$country==i),]$X
    
    #write country area in tmp
    tmp[tmp$pu%in%pulist,"coun_area"]<-grid_cell_UP[which(grid_cell_UP$country==i),"UParea"]
    
    #add constraints, lower and higher
    p_5km<-p_5km %>% add_linear_constraints(threshold=country_target_5km[country_target_5km$id==i+2000,"area"],sense=">=",data=as.vector(tmp$coun_area)) %>% add_linear_constraints(threshold=country_target_5km[country_target_5km$id==i+3000,"area"],sense="<=",data=as.vector(tmp$coun_area))
    
    #to show me how it progress
    print(i)
  }
}


###solve the problem------

presolve_check(p_5km)#presolve takes a long long time, 30 min or so

for(i in c(0)){
  p_5km_wt <- p_5km %>% add_shuffle_portfolio(number_solutions = 1, threads=28) %>%
    add_feature_weights(c(i*(nrow(feature_5km)-1),rep(1,nrow(feature_5km)-1))) %>%
    add_linear_constraint(threshold=budget_lw, sense=">=",data=x_5km$UParea)
  #solve
  Sys.time()
  s_5km<-solve(p_5km_wt)#>30min to show text
  Sys.time()
  
  s_grid_cell<-grid_cell
  s_grid_cell[which(s_grid_cell$X%in%s_5km[s_5km$solution_1==1,]$id & s_grid_cell$PAorKBA==0),"selection"]<-1
  s_grid_cell[s_grid_cell$PAorKBA==1,"selection"]<-2
  s_grid_cell[is.na(s_grid_cell$selection),"selection"]<-0
  write.csv(s_grid_cell,paste0("Output_rij_mod/",SCENARIO,"_",BUDGET,"_",i,".csv"),row.names=F)
  Mollweide<-"+proj=moll +lon_0=0 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
  writeRaster(rasterFromXYZ(s_grid_cell[,c("x","y","selection")]),paste0("Raster_rij_mod/",SCENARIO,"_",BUDGET,"_",i,".tif"),crs=Mollweide,overwrite=TRUE)
  print(sum(s_grid_cell[s_grid_cell$selection!=0,]$area)/allarea)
  print(sum(s_grid_cell[s_grid_cell$selection==1,]$area)/budget_area_5km)
  
}






