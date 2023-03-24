library(spectrolab)
library(tidyverse)
require(Polychrome)
require(gplots)
require(OpenImageR)

source("./Functions/Scan_Metadata_Reader.R")

read_spectra_fix_missing_spec = function(x)
{
  tst<-read_delim(PEF_06182019_files[x], skip =26, show_col_types = FALSE) %>% 
    as.data.frame() %>% 
    dplyr::rename(Refl = `Reflect. %`) %>% 
    mutate(Wvl = as.numeric(Wvl),
           Refl = as.numeric(Refl)) %>% 
    pivot_wider(values_from = Refl, names_from = Wvl) %>%
    as_spectra()
  #names(tst)<-PEF_06182019_files[x]
  return(tst)
}
path = "Original_data/Field_spec/Maine/PEF_scans_06182019/"
#PEF_06182019_spectra<-read_spectra(paste(path),format="sed")

PEF_06182019_files<-read_files(path)

PEF_06182019_spectra_fix<-lapply(1:length(PEF_06182019_files),read_spectra_fix_missing_spec)
 
 y<-strsplit(PEF_06182019_files,".sed")  %>%
    unlist() #%>%
  z<- strsplit(y,"_") %>%
    as.data.frame() %>%
    t() %>% as.data.frame() %>% dplyr::select(V6,V7)
  colnames(z)<-c("ta xon_code","scan_num")
  z$location_prefix<-"PEF"
  rownames(z)<-NULL
PEF_06182019_names<-z
#PEF_06182019_names<-scan_names(PEF_06182019_files)
PEF_06182019_batch<-read_batch(PEF_06182019_files)
##Combine into metadata
PEF_06182019_meta<-cbind(PEF_06182019_names,PEF_06182019_batch) %>% as.data.frame()
rownames(PEF_06182019_meta)<-NULL  
###Set metadata
PEF_06182019_spectra_fix<-Reduce(spectrolab::combine,PEF_06182019_spectra_fix)
meta(PEF_06182019_spectra_fix) = data.frame(PEF_06182019_meta, stringsAsFactors = FALSE)
#save spectral object
saveRDS(PEF_06182019_spectra_fix      ,"Outputs/PEF_06182019_spectra.rds")

####################
path = "Original_data/Field_spec/Maine/PEF_scans_06192019/"
PEF_06192019_spectra<-read_spectra(paste(path),format="sed")
PEF_06192019_files<-read_files(path)
PEF_06192019_spectra_fix<-lapply(1:length(PEF_06192019_files), function(x)
{
  tst<-read_delim(PEF_06192019_files[x], skip =26, show_col_types = FALSE) %>% 
    as.data.frame() %>% 
    dplyr::rename(Refl = `Reflect. %`) %>% 
    mutate(Wvl = as.numeric(Wvl),
           Refl = as.numeric(Refl)) %>% 
    pivot_wider(values_from = Refl, names_from = Wvl) %>%
    as_spectra()
  #names(tst)<-PEF_06182019_files[x]
  return(tst)
}
)

#PEF_06192019_names<-scan_names(PEF_06192019_files)
y<-strsplit(PEF_06192019_files,".sed")  %>%
    unlist() #%>%
  z<- strsplit(y,"_") %>%
    as.data.frame() %>%
    t() %>% as.data.frame() %>% dplyr::select(V6,V7)
  colnames(z)<-c("taxon_code","scan_num")
  z$location_prefix<-"PEF"
  rownames(z)<-NULL
PEF_06192019_names<-z

PEF_06192019_batch<-read_batch(PEF_06192019_files)
PEF_06192019_meta<-cbind(PEF_06192019_names,PEF_06192019_batch) %>% as.data.frame()
rownames(PEF_06192019_meta)<-NULL  
###Set metadata
PEF_06192019_spectra_fix<-Reduce(spectrolab::combine,PEF_06192019_spectra_fix)

###Set metadata
meta(PEF_06192019_spectra_fix) = data.frame(PEF_06192019_meta, stringsAsFactors = FALSE)
#save spectral object
saveRDS(PEF_06192019_spectra_fix      ,"Outputs/PEF_06192019_spectra.rds")
 

####################
path = "Original_data/Field_spec/Maine/PEF_scans_07082019/"
#PEF_07082019_spectra<-read_spectra(paste(path),format="sed")
PEF_07082019_files<-read_files(path)
PEF_07082019_spectra_fix<-lapply(1:length(PEF_07082019_files), function(x)
{
  tst<-read_delim(PEF_07082019_files[x], skip =26, show_col_types = FALSE) %>% 
    as.data.frame() %>% 
    dplyr::rename(Refl = `Reflect. %`) %>% 
    mutate(Wvl = as.numeric(Wvl),
           Refl = as.numeric(Refl)) %>% 
    pivot_wider(values_from = Refl, names_from = Wvl) %>%
    as_spectra()
  #names(tst)<-PEF_06182019_files[x]
  return(tst)
}
)
PEF_07082019_spectra_fix<-Reduce(spectrolab::combine,PEF_07082019_spectra_fix)

#PEF_07082019_names<-#scan_names(PEF_07082019_files)
y<-strsplit(PEF_07082019_files,".sed")  %>%
    unlist() #%>%
  z<- strsplit(y,"_") %>%
    as.data.frame() %>%
    t() %>% as.data.frame() %>% dplyr::select(V6,V7)
  colnames(z)<-c("taxon_code","scan_num")
  z$location_prefix<-"PEF"
  rownames(z)<-NULL
PEF_07082019_names<-z
PEF_07082019_batch<-read_batch(PEF_07082019_files)
##Combine into metadata
PEF_07082019_meta<-cbind(PEF_07082019_names,PEF_07082019_batch) %>% as.data.frame()
rownames(PEF_07082019_meta)<-NULL  
###Set metadata
meta(PEF_07082019_spectra_fix) = data.frame(PEF_07082019_meta, stringsAsFactors = FALSE)
#save spectral object
saveRDS(PEF_07082019_spectra_fix      ,"Outputs/PEF_07082019_spectra.rds")

####################     
path = "Original_data/Field_spec/Maine/PEF_Scans/"
####Read in data as spectra
#PEF_spectra<-read_spectra(paste(path),format="sed")
PEF_Scans_files<-read_files(path)

PEF_spectra_fix<-lapply(1:length(PEF_Scans_files), function(x)
{
  tst<-read_delim(PEF_Scans_files[x], skip =26, show_col_types = FALSE) %>% 
    as.data.frame() %>% 
    dplyr::rename(Refl = `Reflect. %`) %>% 
    mutate(Wvl = as.numeric(Wvl),
           Refl = as.numeric(Refl)) %>% 
    pivot_wider(values_from = Refl, names_from = Wvl) %>%
    as_spectra()
  #names(tst)<-PEF_06182019_files[x]
  return(tst)
}
)
PEF_spectra_fix<-Reduce(spectrolab::combine,PEF_spectra_fix)

#PEF_Scans_names<-scan_names(PEF_Scans_files)
y<-strsplit(PEF_Scans_files,".sed")  %>%
    unlist() #%>%
  z<- strsplit(y,"_") %>%
    as.data.frame() %>%
    t() %>% as.data.frame() %>% dplyr::select(V5,V6)
  colnames(z)<-c("taxon_code","scan_num")
  z$location_prefix<-"PEF"
  rownames(z)<-NULL
PEF_Scans_names<-z

PEF_Scans_batch<-read_batch(PEF_Scans_files)

##Combine into metadata
PEF_Scans_meta<-cbind(PEF_Scans_names,PEF_Scans_batch) %>% as.data.frame()
rownames(PEF_Scans_meta)<-NULL  

###Set metadata
meta(PEF_spectra_fix) = data.frame(PEF_Scans_meta, stringsAsFactors = FALSE)
#save spectral object
saveRDS(PEF_spectra_fix      ,"Outputs/PEF_spectra_root.rds")


##############
#Combine spectra
PEF_dates_spectra<-Reduce(spectrolab::combine,list(PEF_06182019_spectra_fix,PEF_06192019_spectra_fix,PEF_07082019_spectra_fix,PEF_spectra_fix))
saveRDS(PEF_dates_spectra     ,"Outputs/PEF_dates_spectra.rds")

##############
