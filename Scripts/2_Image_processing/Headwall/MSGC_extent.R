#Get extent of an object

#UNIT TEST: get_extents<- function(path)
path<-"./Original_data/Headwall/MSGC_TST_IMG"
path2<-"./Original_data/Headwall/"
  files<-list.files(path2)
  filenames<- subset(files,grepl(".hdr",files)==TRUE|grepl(".HDR",files)==TRUE)
  filenames<-file_path_sans_ext(filenames)  
  fileread<-lapply(1:length(filenames), function(x) {raster(paste("./Original_data/Headwall/",filenames[x],sep=""))})  
  ext_out<-lapply(fileread, extent)
  
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
  ext_out<-lapply(fileread, extent)
  #ext_out<-lapply(ext_out, as("SpatialPolygons"))
  return(ext_out)
}

file_extents<-lapply(path2,get_extents)

file_extents<-unlist(file_extents)

file_extents<-lapply(1:length(file_extents), function(x){ as(file_extents[[x]],"SpatialPolygons")})

str(file_extents)

##Need to assign CRS to these