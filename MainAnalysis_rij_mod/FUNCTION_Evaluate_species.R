SpeciesEvaluate<-function(filename){
  require(data.table)
  require(stringr)
  require(readr)
  s_grid_cell<-as.data.frame(fread(paste("Output_rij_mod/",filename,sep=""),header=TRUE))
  name<-substr(filename,start=1,stop = str_length(filename)-6)
  weight<-substr(filename,start = str_length(filename)-4,stop = 9999)
  tmpsel<-s_grid_cell[,c("X","selection")]
  AddSel<-tmpsel[tmpsel$selection==1,]$X
  rm(tmpsel)
  rm(s_grid_cell)
  gc()
  print(paste("Prepared selection",name,weight))
  fourlist<-read_csv("Input/SPList_32599.csv")
  fourlist$select<-NA
  # print("Prepared fourlist")
  # pb<-txtProgressBar(min=1,max=nrow(fourlist),char = "=",style = 3,width=50)
  ##rij don't have PA distribution data,don't use for absolute allarea calculation
  for(i in 1:nrow(fourlist)){
    
    rm(spe_table)
    gc()
    spe_table<-fread(fourlist$sp.file[i],header = TRUE)
    fourlist$select[i]<-sum(spe_table[spe_table$id%in%AddSel,"area"],na.rm=TRUE)
    # setTxtProgressBar(pb,i)
  }
  # close(pb)
  
  fourlist$pass_floor<-floor(fourlist$target*0.95-fourlist$InPA)
  
  fourlist[fourlist$select>=fourlist$pass_floor,"Reached"]<-1
  fourlist[fourlist$select<fourlist$pass_floor,"Reached"]<-0
  # fourlist$gap_floor<-floor(fourlist$target-fourlist$InPA)
  fourlist[fourlist$pass_floor<=0,"Reached"]<-2
  # print(paste(nrow(fourlist[fourlist$Reached==0,]),"unreached species"))
  write.csv(fourlist,paste("Output_rij_mod/SPlist_all_",name,"_",weight,sep=""),row.names=F)
  print("Output done")
  rm(fourlist)
  gc()
}
