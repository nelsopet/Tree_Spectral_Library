#Get extent of an object

#UNIT TEST: get_extents<- function(path)
path<-"./Original_data/Headwall/MSGC_TST_IMG"
path2<-"./Original_data/Headwall/"
  
  files<-list.files(path2)
  filenames<- subset(files,grepl(".hdr",files)==TRUE|grepl(".HDR",files)==TRUE)
  filenames<-file_path_sans_ext(filenames)  
  #file_df<-data.frame()  
  fileread<-lapply(1:length(filenames), function(x) {raster(paste("./Original_data/Headwall/",filenames[x],sep=""))})  
  file_crs<-lapply(fileread,crs)  #%>% unlist() 
  ext_out<-lapply(fileread, extent) #%>% unlist() %>%
  file_list<-list(file_crs,ext_out)
  #file_df<-data.frame(matrix(ncol = 2, nrow = length(filenames)))
    
raster(path) %>% extent()
tst<-brick(path)
tst_proj<-proj4string(tst)
tst_extent<-extent(tst) %>% as("SpatialPolygons")
proj4string(tst_extent)<-tst_proj


get_extents<- function(path)
{
  files<-list.files(path)
  filenames<- subset(files,grepl(".hdr",files)==TRUE|grepl(".HDR",files)==TRUE)
  filenames<-file_path_sans_ext(filenames)  
  fileread<-lapply(1:length(filenames), function(x) {raster(paste(path,filenames[x],sep=""))})  
  file_crs<-lapply(fileread,crs)  #%>% unlist() 
  ext_out<-lapply(fileread, extent)
  file_list<-list(file_crs,ext_out)
  return(file_list)
}

file_extents<-lapply(path2,get_extents)

#UNIT TEST PASSES
file_extents<-unlist(file_extents, recursive = FALSE)
file_crs<-file_extents[[1]] %>% unlist()
file_extents[[2]][[1]] %>% unlist() %>% class()
tst<-as(unlist(file_extents[[2]][[1]]),"SpatialPolygons")
tst_crs<-unlist(file_extents[[1]][[1]])
crs(tst)<-tst_crs
mapview(tst)
plot(tst)
str(tst)

file_extents<-lapply(1:length(file_extents[[2]]), function(x){ as(file_extents[[2]][[x]],"SpatialPolygons")})

#Add CRS
#UNIT TEST
length(file_extents)
crs(file_extents[[1]], value=)

str(file_extents)

