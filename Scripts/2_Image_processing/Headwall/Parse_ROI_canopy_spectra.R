#Parse metadata and add to each raster of a single tree canopy
library(raster)
library(hsdar)
library(stringr)
library(tidyr)
library(spectrolab)


#source("M:\\lecospec\\lecospec\\Functions\\spectral_operations.R")
##^^this needs to be run manually PJB 11/1/22##

source("M:\\lecospec\\lecospec\\Functions\\raster_operations.R")
source("M:\\lecospec\\lecospec\\Functions\\dataframe_operations.R")
source("M:\\lecospec\\lecospec\\Functions\\model_support.R")
source("M:\\lecospec\\lecospec\\Functions\\utilities.R")
source("M:\\lecospec\\lecospec\\Functions\\validation.R")
source("M:\\lecospec\\lecospec\\Functions\\visualization.R")
source("M:\\lecospec\\lecospec\\Functions\\pfts.R")
source("M:\\lecospec\\lecospec\\Functions\\type_conversion.R")
source("M:\\lecospec\\lecospec\\Functions\\training_utilities.R")


#Set directory
path <- ("M:\\MSGC_DATA\\PEF-Demerit\\Cropped_ROIs_spectra\\")

#list all .grd files of full canopies
allfiles <- list.files(path) 
imgs <- subset(allfiles, grepl(".grd$", allfiles)==TRUE & grepl("full", allfiles)==TRUE)

imgs_names<-str_match(imgs[1], ".*grd") %>% as.data.frame()

####PARSE LOOP####
Canopy_labeled<-lapply(1:length(imgs), function(x){ 
  #extract individual canopy names
  imgs_names<-str_match(imgs[x], ".*grd") %>%
    as.data.frame()
  
  #bring in image
  tst<-brick(paste(path,imgs[x], sep=""))
  #count bands
  band_count<-names(tst) %>% length()
  #create df with bands and values
  df <- raster::rasterToPoints(tst) %>% 
    as.data.frame()%>%
    dplyr::select(-x,-y)
  #extract and apply band names to expand df
  new_names<-extract_bands(df)
  names(df)<-new_names
  df <- filter_bands(df)
  df <- df_to_speclib(df, type="spectrolab")
  df<-spectrolab::resample(df, new_bands = seq(398, 999, 1), parallel = FALSE)
  
  #parse metadata from file name
  TrID<-separate(data.frame(A = imgs_names), col = "V1" , into = c("Species", "HT", "DBH", "Cnpy_Type", "Site", "Mission_ID", "ScanNum"), sep = "_")
  TrID<-as.data.frame(TrID)
  TrID$File <- paste0(path, imgs[x])
  #apply metadata to df
  meta(df)<-rep(TrID,length(df))
  return(df)
})

Canopy_image_spectra<-Reduce(spectrolab::combine,Canopy_labeled)

write.csv(as.data.frame(Canopy_image_spectra), "M:/MSGC_DATA/PEF-Demerit/Spectral_libraries/PEF_spec_lib.csv")

saveRDS(Canopy_image_spectra,"M:/MSGC_DATA/PEF-Demerit/Spectral_libraries/PEF_spec_lib.rds")

