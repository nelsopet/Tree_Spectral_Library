#Parse metadata and add to each raster of a single tree canopy
library(raster)
library(hsdar)
library(stringr)

source("M:\\lecospec\\lecospec\\Functions\\dataframe_operations.R")
source("M:\\lecospec\\lecospec\\Functions\\type_conversion.R")


#Set directory
path <- ("M:\\MSGC_DATA\\PEF-Demerit\\Cropped_ROIs_spectra\\")

#list all .grd files 
allfiles <- list.files(path) 
imgs <- grep(".grd$", allfiles, value = TRUE)


####TEST SPACE####
band_path<-brick(paste(path,imgs[1], sep=""))

band_count<-names(band_path) %>% length()

imgs_names<-str_match(imgs[1], "\\s*(.*?)\\s*.grd") %>%
  as.data.frame() %>% 
  dplyr::select(V2) %>% 
  as.data.frame()

tst<-brick(paste(path,imgs[1], sep=""))
band_count<-names(tst) %>% length()
df <- raster::rasterToPoints(tst) %>% 
  as.data.frame()%>%
  dplyr::select(-x,-y)

#extract_bands won't work because I can't find the referenced function "convert_wavelength_strings"
new_names<-extract_bands(df)

df <- filter_bands(df)

df <- df_to_speclib(df, type="spectrolab")

####PARSE LOOP####
Canopy_labeled<-lapply(1:length(imgs), function(x){ 
  #extract individual canopy names
  imgs_names<-str_match(imgs[x], "\\s*(.*?)\\s*.grd") %>%
    as.data.frame() %>% 
    dplyr::select(V2) %>% 
    as.data.frame()
  
  #bring in image
  tst<-brick(paste(path,imgs[x], sep=""))
  #count bands
  band_count<-names(tst) %>% length()
  #create df with bands and values
  df <- raster::rasterToPoints(tst) %>% 
    as.data.frame()%>%
    dplyr::select(-x,-y)
  new_names<-extract_bands(df)
  names(df)<-new_names
  df <- filter_bands(df)
  df <- df_to_speclib(df, type="spectrolab")
  #df<-spectrolab::resample(df, new_bands = seq(450, 850, 0.5), parallel = FALSE)
  df<-spectrolab::resample(df, new_bands = seq(398, 999, 1), parallel = FALSE)
  PFT<-separate(data.frame(A = imgs_names), col = "V2" , into = c("PFT", "ScanNum"), sep = "(?<=[a-zA-Z])\\s*(?=[0-9])")
  
  PFT$ScanNum<-ifelse(is.na(PFT$ScanNum)==TRUE,1,PFT$ScanNum)
  PFT<-as.data.frame(PFT)
  
  PFT$UID<-str_match(imgs[x], "(.*?)\\s*.envi") %>%
    as.data.frame() %>% 
    dplyr::select(V2) %>%
    dplyr::rename(PFT_UID=V2)
  #  as.data.frame() #%>%
  
  meta(df)<-rep(PFT,length(df))
  return(df)
})
