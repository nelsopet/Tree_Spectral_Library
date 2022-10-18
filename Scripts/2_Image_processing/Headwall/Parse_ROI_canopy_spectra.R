#Parse metadata and add to each raster of a single PFT
library(raster)


path<-("M:\\MSGC_DATA\\PEF-Demerit\\Test_output\\")
allfiles<-list.files(path) 
imgs = grep(".envi$", allfiles, value = TRUE)
band_path<-brick(paste(path,imgs[1], sep=""))
band_count<-names(band_path) %>% length()
band_names <- read.csv("./assets/bands.csv")$x[1:band_count] %>% as.vector() #need to add csv of bands
band_count<-names(path) %>% length()

BisonPFT_labeled<-lapply(1:length(imgs), function(x){ 
  imgs_names<-str_match(imgs[x], "PFTs\\s*(.*?)\\s*.envi") %>%
    as.data.frame() %>% 
    dplyr::select(V2) %>% 
    as.data.frame()
  
  tst<-brick(paste(path,imgs[x], sep=""))
  band_count<-names(tst) %>% length()
  names(tst)<-band_names
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