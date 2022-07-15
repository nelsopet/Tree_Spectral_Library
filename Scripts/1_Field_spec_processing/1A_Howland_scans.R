library(spectrolab)
library(tidyverse)

################

source("Functions/Scan_Metadata_Reader.R")

################
path = "Original_data/Field_Spec/Maine/HOW_scans_07042019/"
HOW_07042019_spectra <- read_spectra(paste(path), format="sed")
HOW_07042019_files <- read_files(path)
HOW_07042019_names <- scan_names(HOW_07042019_files)
HOW_07042019_batch <- read_batch(HOW_07042019_files)

# combine into metadata
HOW_07042019_meta <- cbind(HOW_07042019_names, HOW_07042019_batch) %>% as.data.frame()
rownames(HOW_07042019_meta) <- NULL  

# set metadata
meta(HOW_07042019_spectra) = data.frame(HOW_07042019_meta, stringsAsFactors = FALSE)

# save spectral object
saveRDS(HOW_07042019_spectra, "Outputs/HOW_07042019_spectra.rds")


################
path = "Original_data/Field_Spec/Maine/HOW_scans_07092019/"
HOW_07092019_spectra <- read_spectra(paste(path), format="sed")
HOW_07092019_files <- read_files(path)
HOW_07092019_names <- scan_names(HOW_07092019_files)
HOW_07092019_batch <- read_batch(HOW_07092019_files)

# combine into metadata
HOW_07092019_meta <- cbind(HOW_07092019_names, HOW_07092019_batch) %>% as.data.frame()
rownames(HOW_07092019_meta) <- NULL  

# set metadata
meta(HOW_07092019_spectra) = data.frame(HOW_07092019_meta, stringsAsFactors = FALSE)

# save spectral object
saveRDS(HOW_07092019_spectra, "Outputs/HOW_07092019_spectra.rds")


##############
#Combine spectra
HOW_dates_spectra <- spectrolab::combine(HOW_07042019_spectra, HOW_07092019_spectra)

saveRDS(HOW_dates_spectra, "Outputs/HOW_dates_spectra.rds")


##############
# read in data as spectra
path = "Original_data/Field_spec/Maine/Howland_Scans/"
HOW_Scans_spectra <- read_spectra(paste(path), format="sed")
HOW_Scans_files <- read_files(path)
HOW_Scans_names <- scan_names(HOW_Scans_files)
HOW_Scans_batch <- read_batch(HOW_Scans_files)

# combine into metadata
HOW_Scans_meta <- cbind(HOW_Scans_names, HOW_Scans_batch) %>% as.data.frame()
rownames(HOW_Scans_meta) <- NULL  

# set metadata
meta(HOW_Scans_spectra) = data.frame(HOW_Scans_meta, stringsAsFactors = FALSE)

# save spectral object
saveRDS(HOW_Scans_spectra, "Outputs/HOW_Scans_spectra.rds")


##############
##Check to see if the separate PEF folders have the same scans as the full PEF folder
HOW_dates_meta <- rbind(HOW_07042019_meta, HOW_07092019_meta) %>% as.data.frame()
HOW_dates_meta %>%
  anti_join(HOW_Scans_meta, by=c("File Name")) %>% dim
