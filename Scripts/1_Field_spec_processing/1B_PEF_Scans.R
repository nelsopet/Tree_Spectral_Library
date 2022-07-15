library(spectrolab)
library(tidyverse)
library(Polychrome)
library(gplots)
library(OpenImageR)

####################

source("Functions/Scan_Metadata_Reader.R")

####################
path = "Original_data/Field_spec/Maine/PEF_scans_06182019/"
PEF_06182019_spectra <- read_spectra(paste(path), format = "sed")
PEF_06182019_files <- read_files(path)
PEF_06182019_names <- scan_names(PEF_06182019_files)
PEF_06182019_batch <- read_batch(PEF_06182019_files)

# combine into metadata
PEF_06182019_meta <- cbind(PEF_06182019_names, PEF_06182019_batch) %>% as.data.frame()
rownames(PEF_06182019_meta) <- NULL  

# set metadata
meta(PEF_06182019_spectra) = data.frame(PEF_06182019_meta, stringsAsFactors = FALSE)

# save spectral object
saveRDS(PEF_06182019_spectra, "Outputs/PEF_06182019_spectra.rds")


####################
path = "Original_data/Field_spec/Maine/PEF_scans_06192019/"
PEF_06192019_spectra <- read_spectra(paste(path), format="sed")
PEF_06192019_files <- read_files(path)
PEF_06192019_names <- scan_names(PEF_06192019_files)
PEF_06192019_batch <- read_batch(PEF_06192019_files)

# combine into metadata
PEF_06192019_meta <- cbind(PEF_06192019_names, PEF_06192019_batch) %>% as.data.frame()
rownames(PEF_06192019_meta) <- NULL  

# set metadata
meta(PEF_06192019_spectra) = data.frame(PEF_06192019_meta, stringsAsFactors = FALSE)

# save spectral object
saveRDS(PEF_06192019_spectra, "Outputs/PEF_06192019_spectra.rds")


####################
path = "Original_data/Field_spec/Maine/PEF_scans_07082019/"
PEF_07082019_spectra <- read_spectra(paste(path), format="sed")
PEF_07082019_files <- read_files(path)
PEF_07082019_names <- scan_names(PEF_07082019_files)
PEF_07082019_batch <- read_batch(PEF_07082019_files)

# combine into metadata
PEF_07082019_meta <- cbind(PEF_07082019_names, PEF_07082019_batch) %>% as.data.frame()
rownames(PEF_07082019_meta) <- NULL

# set metadata
meta(PEF_07082019_spectra) = data.frame(PEF_07082019_meta, stringsAsFactors = FALSE)

# save spectral object
saveRDS(PEF_07082019_spectra, "Outputs/PEF_07082019_spectra.rds")


####################     
path = "Original_data/Field_spec/Maine/PEF_Scans/"
PEF_spectra <- read_spectra(paste(path), format="sed")
PEF_Scans_files <- read_files(path)
PEF_Scans_names <- scan_names(PEF_Scans_files)
PEF_Scans_batch <- read_batch(PEF_Scans_files)

# combine into metadata
PEF_Scans_meta <- cbind(PEF_Scans_names, PEF_Scans_batch) %>% as.data.frame()
rownames(PEF_Scans_meta) <- NULL  

# set metadata
meta(PEF_spectra) = data.frame(PEF_Scans_meta, stringsAsFactors = FALSE)

# save spectral object
saveRDS(PEF_spectra, "Outputs/PEF_spectra.rds")


##############
# combine spectra
tst <- c(PEF_07082019_spectra, PEF_06182019_spectra, PEF_06192019_spectra)

tst <- spectrolab::combine(PEF_07082019_spectra, PEF_06182019_spectra)

PEF_dates_spectra <- spectrolab::combine(tst, PEF_07082019_spectra)

# # import file path names of .rds files into character list (spectral libraries based on each location in Alaska) 
# tst_list <- list.files("Outputs", pattern = ".rds", full.names = T) 
# 
# # reads in the spectral libraries for each location in a list...list of 13 spectral objects
# tst_list_of_SpecLib <- lapply(tst_list, readRDS) %>% # reads in the spectral library for each site 
#   setNames(gsub("Outputs/", "", tst_list)) # removes dir path from the name
# 
# PEF_dates_spectra <- Reduce(spectrolab::combine, tst_list_of_SpecLib)

saveRDS(PEF_dates_spectra, "Outputs/PEF_dates_spectra.rds")


##############
# check to see if the separate PEF folders have the same scans as the full PEF folder
PEF_dates_meta <- rbind(PEF_06192019_meta, PEF_06182019_meta, PEF_07082019_meta) %>% as.data.frame()

#colnames(PEF_dates_meta)
#colnames(PEF_Scans_meta)
PEF_dates_meta %>% dplyr::group_by(`GPS Time`) %>% tally()
PEF_Scans_meta %>% dplyr::group_by(`GPS Time`) %>% tally()
PEF_dates_meta %>%
  #anti_join(PEF_Scans_meta, by=c("taxon_code","scan_num","Latitude","Longitude")) %>% 
  anti_join(PEF_Scans_meta, by=c("File Name")) %>% dim


