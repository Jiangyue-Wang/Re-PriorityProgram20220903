
library(prioritizr)
#combine global scenario 50
grid_cell<-read.csv("E:/Priority program/Re-220327/Input/GlobalCells_5km_v220408.csv")

grid_cell$country<-as.integer(grid_cell$country)
grid_cell$ecoregion<-as.integer(grid_cell$ecoregion)
grid_cell$carbon<-grid_cell$AGB/10+grid_cell$SOC*10
grid_cell$carbon<-grid_cell$carbon/10000
#delete PAKBA==1 PUs in grid_cell
grid_cell_UP<-grid_cell[-which(grid_cell$PAorKBA==1),]
head(grid_cell)

###x object preparation-------

x_5km_30<-grid_cell[,c("X","UParea","AGB","SOC")]
colnames(x_5km_30)<-c("id","UParea","AGB","SOC")
x_5km_30$carbon<-x_5km_30$AGB/10+x_5km_30$SOC*10
x_5km_30$carbon<-x_5km_30$carbon/10000
x_5km_30[x_5km_30$carbon<0.0005,"carbon"]<-0
#change AGB divided by 1e+06
# x_5km_30$AGB<-x_5km_30$AGB/1e+06
# x_5km_30$AGB[x_5km_30$AGB<0.05]<-0
# x_5km_30$SOC[x_5km_30$SOC<0.05]<-0
# summary(x_5km_30)

#delete PAKBAs
x_5km_30<-x_5km_30[-which(x_5km_30$UParea==0),]

### calculate area and budget----------------
allarea<-sum(grid_cell$area)
P_allarea<-sum(grid_cell$Parea)
UP_allarea<-sum(grid_cell$UParea)
allarea==P_allarea+UP_allarea
budget_area_5km_30<-allarea*0.525-P_allarea


# ### calculate country constraints ------------
# 
# #read previous country constraint file for name
# country_target_forname<-read.csv("E:/Priority program/TestCodeData/f_country_30_9km.csv")
# 
# #calculate each country's area
# country_area<-aggregate(grid_cell$area,by=list(grid_cell$country),FUN=sum)
# colnames(country_area)<-c("country","area")
# 
# #delete small countries,find "big" countries
# country_big<-country_area[country_area$area>=27000,]
# 
# #create country target dataframe
# country_target_5km<-data.frame(id=country_target_forname$id,area=0,name=country_target_forname$name)
# 
# #delete small countries
# country_target_5km<-country_target_5km[which(as.integer(country_target_5km$id%%1000)%in%country_big$country),]
# 
# #calculate country in Protected area
# country_Parea<-aggregate(grid_cell$Parea,by=list(grid_cell$country),FUN=sum)
# country_Parea<-country_Parea[country_Parea$Group.1 %in% country_big$country,]
# 
# #calculate country in UnProtected area
# country_UParea<-aggregate(grid_cell$UParea,by=list(grid_cell$country),FUN=sum)
# country_UParea<-country_UParea[country_UParea$Group.1 %in% country_big$country,]
# 
# #set constraint
# country_target_5km$area<-c(country_big$area*0.475-country_Parea$x,country_big$area*0.525-country_Parea$x)
# #negative country_lower <-0
# country_target_5km[country_target_5km$id%/%1000==2 & country_target_5km$area<0,"area"]<-0
# #negative country_higher uplift 2.5%
# idlist<-country_target_5km[country_target_5km$id%/%1000==3 & country_target_5km$area<0,"id"]
# country_target_5km[country_target_5km$id %in% idlist,"area"]<-country_big[country_big$country %in% as.integer(idlist%%1000),"area"]*0.025
# 

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
feature_carbon<-data.frame(id=1,name="carbon",spf=1)
rij_carbon<-data.frame(pu=x_5km_30$id,species=1,amount=x_5km_30$carbon)
target_carbon<-data.frame(feature="carbon",sense="=",target=1,type="relative")

###create rij,feature and target used for prioritizr problem initiation--------

rij_amphibian<-read.csv("E:/Priority program/Re-220327/Input/rij_amphibian_220426.csv")[,-1]
rij_reptile<-read.csv("E:/Priority program/Re-220327/Input/rij_reptile_220426.csv")
# rij_bird_p1<-read.csv("E:/Priority program/WJY/AOH/rij_bird_p1.csv")
# rij_bird_p2<-read.csv("E:/Priority program/WJY/AOH/rij_bird_p2.csv")
rij_bird<-read.csv("E:/Priority program/Re-220327/Input/rij_bird_220426.csv")
rij_mammal<-read.csv("E:/Priority program/Re-220327/Input/rij_mammal_220426.csv")
# taxalist<-list(rij_amphibian,rij_reptile,rij_bird_p1,rij_bird_p2,rij_mammal)
# rij_species<-do.call(rbind,taxalist)
taxalist<-list(rij_amphibian,rij_reptile,rij_bird,rij_mammal)

rij_species<-do.call(rbind,taxalist)
rij_species<-rij_species[rij_species$species!=301910,]
rm(taxalist)
rm(rij_mammal)
rm(rij_bird)
rm(rij_reptile)
rm(rij_amphibian)
gc()




# SPlist_amphibian<-read.csv("E:/Priority program/WJY/AOH/SPList_amphibian_full_5km.csv")
# SPlist_reptile<-read.csv("E:/Priority program/WJY/AOH/SPList_reptile_full_5km.csv")
# # SPlist_bird_p1<-read.csv("E:/Priority program/WJY/AOH/SPList_bird_p1_full_5km.csv")
# # SPlist_bird_p2<-read.csv("E:/Priority program/WJY/AOH/SPList_bird_p2_full_5km.csv")
# SPlist_bird<-read.csv("E:/Priority program/WJY/AOH/SPList_bird_merge_full_5km.csv")
# SPlist_mammal<-read.csv("E:/Priority program/WJY/AOH/SPList_mammal_full_5km.csv")

SPList<-read.csv("E:/Priority program/Re-220327/Input/SPList_15454_220428.csv")[,-1]
SPList<-SPList[SPList$rijid!=301910,]
all(SPList$prop<=1 & SPList$prop>0 & !is.na(SPList$prop) & is.finite(SPList$prop))
#TRUE






#13693 obs
# >=25 modified on Jan 22 2022

# SPlist_amphibian_target<-SPlist_amphibian[SPlist_amphibian$prop<=1&SPlist_amphibian$prop>0&!is.na(SPlist_amphibian$prop)&SPlist_amphibian$target>=25,][,-1]
# SPlist_reptile_target<-SPlist_reptile[SPlist_reptile$prop<=1&SPlist_reptile$prop>0&!is.na(SPlist_reptile$prop)&SPlist_reptile$target>=25,][,-1]
# # SPlist_bird_p1_target<-SPlist_bird_p1[SPlist_bird_p1$prop<1&SPlist_bird_p1$prop>0&!is.na(SPlist_bird_p1$prop),][,-1]
# # SPlist_bird_p2_target<-SPlist_bird_p2[SPlist_bird_p2$prop<1&SPlist_bird_p2$prop>0&!is.na(SPlist_bird_p2$prop),][,-1]
# SPlist_bird_target<-SPlist_bird[SPlist_bird$prop<=1&SPlist_bird$prop>0&!is.na(SPlist_bird$prop)&SPlist_bird$target>=25,][,-1]
# SPlist_mammal_target<-SPlist_mammal[SPlist_mammal$prop<=1&SPlist_mammal$prop>0&!is.na(SPlist_mammal$prop)&SPlist_mammal$target>=25,][,-1]


# dupname<-c()
# for (i in 1:length(SPlist_bird_p1$scientific.name)){
#   if (SPlist_bird_p1[i,"scientific.name"]%in%SPlist_bird_p2$scientific.name){
#     dupname<-c(dupname,SPlist_bird_p1[i,"scientific.name"])
#   }
# }



# feature_5km_30_sp<-data.frame(id=c(SPlist_amphibian$rijid,SPlist_reptile$rijid,
#                                    SPlist_bird_p1$rijid,SPlist_bird_p2$rijid,
#                                    SPlist_mammal$rijid),
#                               name=c(SPlist_amphibian$scientific.name,
#                                      SPlist_reptile$scientific.name,
#                                      SPlist_bird_p1$scientific.name,
#                                      SPlist_bird_p2$scientific.name,
#                                      SPlist_mammal$scientific.name),spf=1)
# feature_5km_30_sp<-data.frame(id=c(SPlist_amphibian$rijid,SPlist_reptile$rijid,
#                                    SPlist_bird$rijid,
#                                    SPlist_mammal$rijid),
#                               name=c(SPlist_amphibian$scientific.name,
#                                      SPlist_reptile$scientific.name,
#                                      SPlist_bird$scientific.name,
#                                      SPlist_mammal$scientific.name),spf=1)
feature_5km_30_sp<-data.frame(id=SPList$rijid,name=SPList$scientific.name,spf=1)
feature_5km_30_sp<-rbind(feature_carbon,feature_5km_30_sp)
#name dup name as Leptasthenura pallida_dup??40029is actually season 1 of a species, target reached already
# feature_5km_30_sp[feature_5km_30_sp$id==400029,"name"]<-"Leptasthenura pallida_dup"
# feature_5km_30_sp[feature_5km_30_sp$id==400139,"name"]<-"Ficedula elisae_dup"

# target_5km_30_sp<-data.frame(feature=c(SPlist_amphibian_target$scientific.name,
#                                        SPlist_reptile_target$scientific.name,
#                                        SPlist_bird_p1_target$scientific.name,
#                                        SPlist_bird_p2_target$scientific.name,
#                                        SPlist_mammal_target$scientific.name),
#                              sense=">=",target=c(SPlist_amphibian_target$prop,
#                                                  SPlist_reptile_target$prop,
#                                                  SPlist_bird_p1_target$prop,
#                                                  SPlist_bird_p2_target$prop,
#                                                  SPlist_mammal_target$prop),type="relative")
# target_5km_30_sp<-data.frame(feature=c(SPlist_amphibian_target$scientific.name,
#                                        SPlist_reptile_target$scientific.name,
#                                        SPlist_bird_target$scientific.name,
#                                        SPlist_mammal_target$scientific.name),
#                              sense=">=",target=c(SPlist_amphibian_target$prop,
#                                                  SPlist_reptile_target$prop,
#                                                  SPlist_bird_target$prop,
#                                                  SPlist_mammal_target$prop),type="relative")
target_5km_30_sp<-data.frame(feature=SPList$scientific.name,sense=">=",target=SPList$prop,type="relative")
target_5km_30_sp<-rbind(target_carbon,target_5km_30_sp)


# target_5km_30_sp<-target_5km_30_sp[target_5km_30_sp$target>0 & !is.infinite(target_5km_30_sp$target) & !is.na(target_5km_30_sp$target),]


# <0.05 to 0.05 modified on Apr 2nd
rij_species[which(rij_species$amount<0.05),"amount"]<-0.05
##add carbon rij
rij_species<-rbind(rij_carbon,rij_species)

rij_5km_30_sp<-rij_species
rm(rij_species)


feature_5km_30_sp<-feature_5km_30_sp[feature_5km_30_sp$name%in%target_5km_30_sp$feature,]
# rij_5km_30_sp<-rij_5km_30_sp[rij_5km_30_sp$species%in%feature_5km_30_sp$id,]


#nrow(target_5km_30_sp)-1

### carbon modify------
##change carbon target sense to ">=", doesn't work
# target_5km_30_sp$sense[1]<-">=" 
##divide carbon values by 10000, and remove <=0.05 records,it works
# rij_5km_30_sp_cd<-rij_5km_30_sp
# rij_5km_30_sp_cd[1:4325664,"amount"]<-rij_5km_30_sp_cd[1:4325664,"amount"]/10000
# rij_5km_30_sp_cd[rij_5km_30_sp_cd$amount<0.05,"amount"]<-0

###initiate a problem-------------
p_5km_30_sp<-problem(x = x_5km_30 , feature = feature_5km_30_sp, cost_column = "UParea", rij = rij_5km_30_sp) %>%         
  add_min_set_objective() %>% 
  add_manual_targets(targets = target_5km_30_sp) %>%
  add_gurobi_solver(gap = 0.005,time_limit = 60000,threads = 28) %>% 
  add_binary_decisions() 
# add_locked_out_constraints(as.logical(grid_cell_UP$urban)) %>%
# add_feature_weights(weight_5km_30_sp)
presolve_check(p_5km_30_sp)



###add ecoregion constraints---------

for(i in unique(eco_target_5km$id)){
  rm(tmp)
  rm(pulist)
  gc()
  
  #create a tmp dataframe to show each ecoregion's distribution
  tmp<-data.frame(pu=x_5km_30$id,eco_area=0)
  
  #pulist is the row id of each ecoregion
  pulist<-grid_cell_UP[which(grid_cell_UP$ecoregion==i),"X"]
  
  #write ecoregion area in tmp
  tmp[which(tmp$pu%in%pulist),"eco_area"]<-grid_cell_UP[which(grid_cell_UP$ecoregion==i),"UParea"]
  
  #add constraints
  p_5km_30_sp<-p_5km_30_sp %>% add_linear_constraints(threshold=eco_target_5km[eco_target_5km$id==i,"area"],sense=">=",data=as.vector(tmp$eco_area))
  
  #to show me how it progress
  print(i)
}

###add country constraints-----------

# for(i in unique(country_target_5km$id%%1000)){
#   rm(tmp)
#   rm(pulist)
#   gc()
#   
#   #create a tmp dataframe to show each country's distribution
#   tmp<-data.frame(pu=x_5km_30$id,coun_area=0)
#   
#   #pulist is the row id of each country
#   pulist<-grid_cell_UP[which(grid_cell_UP$country==i),"X"]
#   
#   #write country area in tmp
#   tmp[tmp$pu%in%pulist,"coun_area"]<-grid_cell_UP[which(grid_cell_UP$country==i),"UParea"]
#   
#   #add constraints, lower and higher
#   p_5km_30_sp<-p_5km_30_sp %>% add_linear_constraints(threshold=country_target_5km[country_target_5km$id==i+2000,"area"],sense=">=",data=as.vector(tmp$coun_area))
#   p_5km_30_sp<-p_5km_30_sp %>% add_linear_constraints(threshold=country_target_5km[country_target_5km$id==i+3000,"area"],sense="<=",data=as.vector(tmp$coun_area))
#   
#   #to show me how it progress
#   print(i)
# }
# 


###solve the problem------
gc()
#presolve check
presolve_check(p_5km_30_sp)#presolve takes a long long time, 30 min or so

weights<-c(0,0.2,0.4,0.6,0.8,1)
for(i in 1:1){
  weight_5km_30_sp<-c((nrow(target_5km_30_sp)-1)*weights[i],rep(1,nrow(target_5km_30_sp)-1))
  p_5km_30_sp_wt<-p_5km_30_sp%>%
    add_feature_weights(weight_5km_30_sp)
  #solve
  Sys.time()
  s_5km_30_sp<-solve(p_5km_30_sp_wt)#>30min to show text
  Sys.time()
  
  
  s_grid_cell<-grid_cell
  s_grid_cell[which(s_grid_cell$X%in%s_5km_30_sp[s_5km_30_sp$solution_1==1,"id"] & s_grid_cell$PAorKBA==0),"selection"]<-1
  s_grid_cell[s_grid_cell$PAorKBA==1,"selection"]<-2
  s_grid_cell[is.na(s_grid_cell[,"selection"]),"selection"]<-0
  # s_plot<-as.data.frame(s_grid_cell[,c("x","y","selection")])
  # s_plot$x<-round(s_plot$x)
  # s_plot$y<-round(s_plot$y)
  # plot_5km_30<-rasterFromXYZ(s_plot)
  # plot(plot_5km_30)
  
  
  print(sum(s_grid_cell[s_grid_cell$selection==1,"UParea"])/budget_area_5km_30)
  # sum(s_grid_cell[s_grid_cell$selection==1,"AGB"])/sum(s_grid_cell[s_grid_cell$selection!=2,"AGB"])
  # sum(s_grid_cell[s_grid_cell$selection==1,"SOC"])/sum(s_grid_cell[s_grid_cell$selection!=2,"SOC"])
  # sum(s_grid_cell[s_grid_cell$selection==1 ,"carbon"])/sum(s_grid_cell[s_grid_cell$selection!=2 ,"carbon"])
  
  
  # write.csv(s_grid_cell,paste("E:/Priority program/Re-220327/Output/220428ReSp/solve_glo50_combine_",weights[i],"perWeight.csv",sep=""))
}


# source("E:/Priority program/Re-220327/Code/target_evaluate_32600.R")

# fourlist$pass_floor<-floor(fourlist$target*0.95-fourlist$InPA)
# 
# fourlist[fourlist$select>=fourlist$pass_floor,"Reached"]<-1
# fourlist[fourlist$select<fourlist$pass_floor,"Reached"]<-0
# fourlist$gap_floor<-floor(fourlist$target-fourlist$InPA)
# fourlist[fourlist$gap_floor<=0,"Reached"]<-2
# write.csv(fourlist,"E:/Priority program/Re-220327/Output/220428ReSp/SPlist_all_glo50_combine_detail_0perWeight.csv")

