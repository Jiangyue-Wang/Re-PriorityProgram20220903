## fix the target problem, before we all used ln, but not log10, so we should correct all target
library(data.table)
SPList <- fread("Input/SPList_32599.csv")
head(SPList)
## set target
a<-(0.1-1)/(log10(250000)-log10(1000))
b<-1-log10(1000)*a
set_target<-function(input){
  if (typeof(input)=="double"){
    if (input<=1000){
      target_value<-input
    }
    if(input>=250000 & input <10000000){
      target_value<-input*0.1
    }
    if(input>1000 & input<250000){
      target_value<-(log10(input)*a+b)*input
    }
    if(input>=10000000){
      target_value<-1000000
    }
    return(target_value)
  }
  else {
    return("type of input error")
  }
}

for(i in 1:nrow(SPList)){
  SPList$target[i]<-set_target(SPList$area[i])
}
head(SPList)
SPList$target_absolute<-SPList$target-SPList$InPA

SPList$prop<-SPList$target_absolute/SPList$OutPA
SPList[SPList$prop>1,"prop"]<-1

nrow(SPList[SPList$prop<=1&SPList$prop>0&!is.na(SPList$prop),])
nrow(SPList[SPList$target_absolute>0,])
# all equals to 15968


write.csv(SPList,"Input/SPList_32599.csv",row.names=F)
SPList_15968 <- SPList[SPList$target_absolute>0,]
write.csv(SPList_15968,"SPList_15968.csv",row.names=F)