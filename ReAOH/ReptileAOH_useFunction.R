source("ReAOH/FUNCTION-group_generate_aoh.R")
reptl_range_data <- read_spp_range_data(paste0("REPTILES",".zip"))


group_generate_aoh(taxa = "REPTILES", 3001, 3500, "4.1")
# Error: cannot allocate vector of size 159.5 Gb
# last ne is 61574_1
reptl_range_data[reptl_range_data$id_no==61574,]
which(reptl_range_data$id_no==61574)
# No.3149, so the error one is 3150
# so rerun 3001 to 3149 to generate spplist
group_generate_aoh(taxa = "REPTILES", 3001, 3149, "4.1_1")
# and run 3151 to 3500 
group_generate_aoh(taxa = "REPTILES", 3151, 3500, "4.1_2")
# Error: cannot allocate vector od size 159.5 Gb
max(file.info(paste0("ReAOH/REPTILES/",dir("ReAOH/REPTILES")))$mtime)
which(file.info(paste0("ReAOH/REPTILES/",dir("ReAOH/REPTILES")))$mtime==max(file.info(paste0("ReAOH/REPTILES/",dir("ReAOH/REPTILES")))$mtime))
file.info(paste0("ReAOH/REPTILES/",dir("ReAOH/REPTILES")))[1272,]
# still 61574, so skip one more
group_generate_aoh(taxa="REPTILES",3152,3500,"4.1_2")
# skipping one more makes it work!
group_generate_aoh(taxa = "REPTILES", 3501, 4000, "4.2")


