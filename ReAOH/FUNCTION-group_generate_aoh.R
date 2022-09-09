setwd("G:/Priority program/Re-PriorityProgram20220903/ReAOH")
group_generate_aoh <- function(taxa, number1,number2, groupcode){
  require(aoh)
  require(terra)
  require(rappdirs)
  require(dplyr)
  rm(spp_range_data)
  rm(spp_info_data)
  rm(spp_aoh_data)
  rm(spp_list)
  gc()
  # check if outdir exists
  ifelse(dir.exists(taxa),NA,dir.create(taxa))
  output_dir <- taxa
  n_threads <- parallel::detectCores() - 1 
  cache_dir<-"cache"
  path <- paste0(taxa,".zip")
  spp_range_data <- read_spp_range_data(path)
  spp_range_data <- spp_range_data[number1:number2,]
  spp_info_data <- create_spp_info_data(spp_range_data, cache_dir = cache_dir)
  spp_aoh_data <- create_spp_aoh_data(spp_info_data, output_dir = output_dir, cache_dir = cache_dir, n_threads = n_threads)
  saveRDS(spp_aoh_data,paste0(taxa,"_aoh_data",groupcode,".rds"))
  spp_list <- spp_aoh_data %>%
    mutate(filename=paste0(id_no,"_",seasonal)) %>%
    select(filename,id_no,seasonal,binomial,category,path)
  spp_list <- as.data.frame(spp_list)
  spp_list<-spp_list[,-ncol(spp_list)]
  write.csv(spp_list,paste0(taxa,"_spp_list",groupcode,".csv"),row.names=F)
  
}