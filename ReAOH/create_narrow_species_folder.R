reptl_spp_list
dir.create("ReAOH/REPTILES_narrow")
reptl_aoh_data<-readRDS("ReAOH/reptl_narrow_aoh_data.rds")
for(i in 1:nrow(reptl_spp_list)){
  file.copy(paste0("ReAOH/REPTILES/",reptl_spp_list[i,"filename"],".tif"),paste0("ReAOH/REPTILES_narrow/",reptl_spp_list[i,"filename"],".tif"))
}

amphi_aoh_data <- readRDS("ReAOH/amphi_aoh_data.rds")
amphi_narrow <- read.csv("E:/Priority program/WJY/AOH/AOH_errors/narrow_amphibian.csv")
head(amphi_narrow)
dir.create("ReAOH/AMPHIBIANS_narrow")
for(i in 1:nrow(amphi_narrow)){
  file.copy(paste0("ReAOH/AMPHIBIANS/",amphi_narrow$id_no[i],"_",amphi_narrow$seasonal[i],".tif"),paste0("ReAOH/AMPHIBIANS_narrow/",amphi_narrow$id_no[i],"_",amphi_narrow$seasonal[i],".tif"))
}
amphi_aoh_data <- amphi_aoh_data[amphi_aoh_data$id_no%in%amphi_narrow$id_no,]
saveRDS(amphi_aoh_data,"ReAOH/amphi_narrow_aoh_data.rds")
