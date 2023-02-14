##Functions
read_files<-function(path) {list.files(paste(path),pattern = ".sed", full.names = TRUE)}

read_header<-function(files) {read_delim(paste(path,files[1],sep=""), n_max=24, delim=":") %>% 
    as.data.frame() %>% 
    dplyr::select(2)}

read_header_cols<-function(files) {read_delim(paste(path,files[1],sep=""), n_max=24, delim=":") %>% 
    as.data.frame() %>% 
    dplyr::select(1)}

scan_names<-function(x){
  y<-strsplit(x,".sed")  %>% 
    unlist() #%>% 
  z<- strsplit(y,"_") %>% 
    as.data.frame() %>% 
    t()
  colnames(z)<-c("location_prefix","taxon_code","scan_num")
  rownames(z)<-NULL
  return(z)
}

read_batch<-function(files){
  files_batch<-lapply(files,read_header)
  files_batch<-files_batch %>% as.data.frame() %>% t
  #Make a list of header names
  files_cols<-lapply(files, read_header_cols) %>% as.data.frame()
  ##Make header names the column names
  colnames(files_batch)<-files_cols[,1]
  return(files_batch)
}