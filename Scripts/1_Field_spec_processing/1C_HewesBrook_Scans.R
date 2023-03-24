library(spectrolab)
library(tidyverse)

##Hewes Brook 1
source("./Functions/Scan_Metadata_Reader.R")

path= "./Original_data/Field_Spec/Maine/hb1/"
read_spectra_fix_missing_spec= function(x)
{
  tst<-read_delim(hb1_files[x], skip =26, show_col_types = FALSE) %>% 
    as.data.frame() %>% 
    dplyr::rename(Refl = `Reflect. %`) %>% 
    mutate(Wvl = as.numeric(Wvl),
           Refl = as.numeric(Refl)) %>% 
    pivot_wider(values_from = Refl, names_from = Wvl) %>%
    as_spectra()
  names(tst)<-hb1_files[x]
  return(tst)
}

#hb1_spectra<-read_spectra(paste(path),format="sed")
hb1_files<-read_files(path)
hb1_spectra_fix<-lapply(1:length(hb1_files),read_spectra_fix_missing_spec)
hb1_spectra_fix<-Reduce(spectrolab::combine, hb1_spectra_fix)                        
#hb1_names<-scan_names(hb1_files)
#fpond_files<-gsub("__","_",hb3_files)
            #scan_names_new<-
            y<-strsplit(hb1_files,".sed")  %>% 
                unlist() #%>% 
            z<- strsplit(y,"_") %>% 
                as.data.frame() %>% 
                t() %>% as.data.frame() %>% dplyr::select(V4,V5)
            colnames(z)<-c("taxon_code","scan_num")
            z$location_prefix<-"hb1"
            hb1_names<-z %>% dplyr::select(location_prefix,taxon_code,scan_num)

hb1_batch<-read_batch(hb1_files)
##Combine into metadata
hb1_meta<-cbind(hb1_names,hb1_batch) %>% as.data.frame()
rownames(hb1_meta)<-NULL  
###Set metadata
spectrolab::meta(hb1_spectra_fix) = data.frame(hb1_meta, stringsAsFactors = FALSE)
#save spectral object
saveRDS(hb1_spectra_fix      ,"Outputs/HB1_spectra.rds")


###Hewes Brook 3
path= "./Original_data/Field_Spec/Maine/hb3/"
hb3_files<-read_files(path)

#hb3_spectra<-read_spectra(paste(path),format="sed")
hb3_spectra_fix<-lapply(1:length(hb3_files), function(x)
{
  tst<-read_delim(hb3_files[x], skip =26, show_col_types = FALSE) %>% 
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
hb3_spectra_fix<-Reduce(spectrolab::combine,hb3_spectra_fix)

#hb3_files<-gsub("__","_",hb3_files)
            #scan_names_new<-
                y<-strsplit(hb3_files,".sed")  %>%
                  unlist() #%>%
                z<- strsplit(y,"_") %>%
                  as.data.frame() %>%
                  t() %>% as.data.frame() %>% dplyr::select(V4,V7)
                colnames(z)<-c("taxon_code","scan_num")
                z$location_prefix<-"hb3"
                rownames(z)<-NULL
                hb3_names<-z
            #colnames(df)<-c("taxon_code","scan_num","location_prefix")
  #hb3_names<-df %>% dplyr::select(location_prefix,taxon_code,scan_num)
  hb3_batch<-read_batch(hb3_files)
##Combine into metadata
hb3_meta<-cbind(hb3_names,hb3_batch) %>% as.data.frame()
rownames(hb3_meta)<-NULL  
###Set metadata
meta(hb3_spectra_fix) = data.frame(hb3_meta, stringsAsFactors = FALSE)
#save spectral object
saveRDS(hb3_spectra_fix      ,"Outputs/hb3_spectra.rds")


###Forbs pond
path= "./Original_data/Field_Spec/Maine/Forbes_pond/"

fpond_spectra<-read_spectra(paste(path),format="sed")
fpond_files<-read_files(path)
#fpond_files<-gsub("__","_",fpond_files)
            #scan_names_new<-
            y<-strsplit(fpond_files,".sed")  %>% 
                unlist() #%>% 
            z<- strsplit(y,"_") #%>% 
                #as.data.frame() %>% 
                #t()
            b<-as.data.frame(do.call(rbind, lapply(z,unlist)))
            b[77:87,7]<-b[77:87,6]
            df<-b %>% dplyr::select(V4,V7)
            colnames(df)<-c("taxon_code","scan_num")
            df$location_prefix<-"fpond"
            #colnames(df)<-c("taxon_code","scan_num","location_prefix")
  fpond_names<-df %>% dplyr::select(location_prefix,taxon_code,scan_num)
  fpond_batch<-read_batch(fpond_files)
##Combine into metadata
fpond_meta<-cbind(fpond_names,fpond_batch) %>% as.data.frame()
rownames(fpond_meta)<-NULL  
###Set metadata
meta(fpond_spectra) = data.frame(fpond_meta, stringsAsFactors = FALSE)
#save spectral object
saveRDS(fpond_spectra      ,"Outputs/fpond_spectra.rds")