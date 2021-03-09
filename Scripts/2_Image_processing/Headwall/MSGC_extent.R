#Get extent of an object


#Get all the images in a directory for which extents are needed
stuff<-list_files_with_exts(dir="./Original_data/Headwall/", exts = "hdr")


#UNIT TEST: get_extents<- function(path)
#path<-"./Original_data/Headwall/MSGC_TST_IMG"
tst<-brick(path)
tst_proj<-proj4string(tst)
tst_extent<-extent(tst) %>% as("SpatialPolygons")
proj4string(tst_extent)<-tst_proj
#mapview(tst_extent)

get_extents<- function(path)
{
tst<-brick(path)
tst_proj<-proj4string(tst)
tst_extent<-extent(tst) %>% as("SpatialPolygons")
proj4string(tst_extent)<-tst_proj
return(tst_extent)
}

lapply(stuff,get_extents)


