# Re-PriorityProgram20220903
This repo contains codes and data for priority program, which is under review of One Earth of Cell Press. I need to rerun AOH to generate correct species data to do prioritization.

## Rerun AOH
### Try amphibians first
I have downloaded species range data from [IUCN Red List Resources](https://www.iucnredlist.org/resources/spatial-data-download), and get the file(this file is not uploaded here, see workstation209 directory) [AMPHIBIANS.zip](ReAOH/AMPHIBIANS.zip). Trying to generate AOH using [AmphibianAOH.R](ReAOH/AmphibianAOH.R) code.
All goes well. Now we have 8861 rows in amphi_range_data and 6989 rows in amphi_info_data. I will check the difference between them after all AOHs have been generated. Estimated time is 2d.
### Processing reptiles
I downloaded species range data from [IUCN Red List Resources](https://www.iucnredlist.org/resources/spatial-data-download), and the hydrobasin one only includes a csv file, without any spatial information, so I dropped it. The file [REPTILES.zip](ReAOH/REPTILES.zip) is also in workstation209 directory. Code is [ReptileAOH.R](ReAOH/ReptileAOH.R).
The workstation's memory only supports processing one taxa at one time.
