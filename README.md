# Re-PriorityProgram20220903
This repo contains codes and data for priority program, which is under review of One Earth of Cell Press. I need to rerun AOH to generate correct species data to do prioritization.

## Rerun AOH
### Try amphibians first
I have downloaded species range data from [IUCN Red List Resources](https://www.iucnredlist.org/resources/spatial-data-download), and get the file(this file is not uploaded here, see workstation209 directory) [AMPHIBIANS.zip](ReAOH/AMPHIBIANS.zip). Trying to generate AOH using [AmphibianAOH.R](ReAOH/AmphibianAOH.R) code.

All goes well. Now we have 8861 rows in amphi_range_data and 6989 rows in amphi_info_data. I will check the difference between them after all AOHs have been generated. Estimated time is 2d.
2 days passed and all goes well. We have generated 6771 amphibian tifs. The difference happens from 8861 to 6989 is because one species have different sources. The difference happens from 6989 to 6771 is because some habitat code in not included in Lumbierres dataset.

The final amphibian list data [amphi_spp_list.csv](ReAOH/amphi_spp_list.csv) and amphibian aoh [raster tifs](ReAOH/AMPHIBIANS/520_1.tif) are stored in workstation 209, [amphi_spp_list.csv](ReAOH/amphi_spp_list.csv) also uploaded. The processing rds files are in the same directory with [amphi_spp_list.csv](ReAOH/amphi_spp_list.csv), but not uploaded here.

### Processing reptiles
I downloaded species range data from [IUCN Red List Resources](https://www.iucnredlist.org/resources/spatial-data-download), and the hydrobasin one only includes a csv file, without any spatial information, so I dropped it. The file [REPTILES.zip](ReAOH/REPTILES.zip) is also in workstation209 directory. Code is [ReptileAOH.R](ReAOH/ReptileAOH.R).

The workstation's memory only supports processing one taxa at one time. Running reptiles' aoh now.

A lot of problems arise.
1. There are some species whose AOH cannot be generated, because the create_spp_aoh() step need more memory than our workstation's RAM(128G). This problem has been fixed after the update of [aoh package](https://prioritizr.github.io/aoh/).

2. We cannot generate reptile's spp_info_data, because this step still needs much memory. So we are trying to split the reptile taxa into a few groups, and process each group one by one. Unfortunately, it still failed to work when there is only one species each group. It's confusing and I don't know what to do.

### Processing mammals whose geometry range covers the narrow NA band in Lumbierres(2021) last edition
I use the code [MammalAOH_narrow.R](ReAOH/MammalAOH_narrow.R) to generate the AOH of error mammals. The error list is generated in April, 2022, using geometry attribute in MAMMALS.rds sent from Jeff. Hope this will work.

