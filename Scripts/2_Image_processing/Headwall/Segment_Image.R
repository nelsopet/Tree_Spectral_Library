require(raster)
require(spectrolab)
require(tidyverse)
require(hsdar)
require(sf)
require(mapview)
require(caTools)
require(terra)
require(tools)
require(OpenImageR)
require(tiff)
require(itcSegment)
require(rgdal)

#View images
#path="./Original_data/Headwall/MSGC_TST_IMG.png"
path="./Original_data/Headwall/MSGC_TST_IMG"

tst<-brick(path)

tst_rgb<-tst[[c(160,80,25)]]

#writeTIFF(as.matrix(tst_rgb), "./Original_data/Headwall/MSGC_TST_IMG_RGB.tiff")
plotRGB(tst, r=160, g=80, b=25, stretch="lin")

##Project 
projection(tst)
#[1] "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"

new_prj<-"+proj=aea +lon_0=-69.609375 +lat_1=43.0460393 +lat_2=51.3106043 +lat_0=47.1783218 +datum=WGS84 +units=m +no_defss"
new_prj<-crs(new_prj)
#26983 NAD83 Maine East
#42310 NAD83 Mercator projection
help(CRS)

tst_proj<-projectRaster(tst, crs=new_prj)
#tst_proj_crs42310<-projectRaster(tst, crs=crs())
tst_proj_812<-as(tst_proj$Resize..Band.225.raw_0_rd_rf_or...812.390000.Nanometers.,"RasterLayer")

tst_seg_26983_winSize3_Dist50   <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 3, DIST = 50) #Works with error
#tst_seg_26983_winSize3_Dist100  <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 3, DIST = 100) #Works with error
#tst_seg_26983_winSize3_Dist500  <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 3, DIST = 500) #Works with error
#tst_seg_26983_winSize9_Dist100  <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 9, DIST = 100) #Works with error
#tst_seg_26983_winSize9_Dist500  <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 9, DIST = 500) #Works with error
tst_seg_26983_winSize9_Dist50   <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 9, DIST = 50) #Works with error
tst_seg_26983_winSize21_Dist50  <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 21, DIST = 50) #Works with error
#tst_seg_26983_winSize21_Dist100 <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 21, DIST = 100) #Works with error
#tst_seg_26983_winSize21_Dist500 <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 21, DIST = 500) #Works with error
#tst_seg_26983_winSize51_Dist100 <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 51, DIST = 100) #Works with error
tst_seg_26983_winSize51_Dist500 <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 51, DIST = 500) #Works with error
tst_seg_26983_winSize51_Dist1000<-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 51, DIST = 1000) #Works with error


#WinSizeTry = c(3,9,21,51,101)
#DIST_Try = c(50, 100, 500, 1000)

#function(x,y) {
#canopy_seg<-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = x, DIST = y) #Works with error
#}


#tst_seg_26983_winSize3_Dist100<-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 9, DIST = 100) #Works with error

    #Warning message:
    #In `proj4string<-`(`*tmp*`, value = sp::CRS(paste("+init=epsg:",  :
    # A new CRS was assigned to an object with an existing CRS:
    # +proj=aea +lon_0=-69.609375 +lat_1=43.0460393 +lat_2=51.3106043 +lat_0=47.1783218 +datum=WGS84 +units=m +ellps=WGS84 +towgs84=0,0,0
    #without reprojecting.
    #For reprojection, use function spTransform

plot(tst_rgb)

seg_group<-c(
tst_seg_26983_winSize3_Dist50   
,tst_seg_26983_winSize3_Dist100  
,tst_seg_26983_winSize3_Dist500  
,tst_seg_26983_winSize9_Dist100  
,tst_seg_26983_winSize9_Dist500  
,tst_seg_26983_winSize9_Dist50   
,tst_seg_26983_winSize21_Dist50  
,tst_seg_26983_winSize21_Dist100 
,tst_seg_26983_winSize21_Dist500 
,tst_seg_26983_winSize51_Dist100 
,tst_seg_26983_winSize51_Dist500 
,tst_seg_26983_winSize51_Dist1000)

str(seg_group)
plot(seg_group)
seg_names<-c("tst_seg_26983_winSize3_Dist50   "
,"tst_seg_26983_winSize3_Dist100  "
,"tst_seg_26983_winSize3_Dist500  "
,"tst_seg_26983_winSize9_Dist100  "
,"tst_seg_26983_winSize9_Dist500  "
,"tst_seg_26983_winSize9_Dist50   "
,"tst_seg_26983_winSize21_Dist50  "
,"tst_seg_26983_winSize21_Dist100 "
,"tst_seg_26983_winSize21_Dist500 "
  ,"tst_seg_26983_winSize51_Dist100 "
  ,"tst_seg_26983_winSize51_Dist500 "
  ,"tst_seg_26983_winSize51_Dist1000")



#writeOGR(tst_seg_26983, dsn = "./Outputs/2_Imagery/Headwall/Segments/", driver="ESRI Shapefile" , layer="tst_seg_26983")
#seg_group[1]
#lapply(1:dim(seg_group[1]), function(x){
#writeOGR(seg_group[x], dsn = "./Outputs/2_Imagery/Headwall/Segments/", driver="ESRI Shapefile" , layer=paste(seg_group[x]))
#})

pdf("./Outputs/2_Imagery/Headwall/Segments/test_forest_canopy_segments.pdf")
lapply(1:length(seg_group),
function(x){
plot(seg_group[[x]])
title(main =seg_names[x])
})
  #plotRGB(tst, r=160, g=80, b=25, stretch="lin")
#ggplot(seg_group[[1]],aes(X,Y))+geom_polygon()
dev.off()

#tst_seg_42310<-itcIMG(tst_proj_812, epsg = 42310) #Fail ... I need to reproject first 
  #Error in sp::CRS(paste("+init=epsg:", epsg, sep = "")) : 
  #no arguments in initialization list
  #writeOGR(tst_seg_42310, )
#tst_seg<-itcIMG(tst_proj_812, epsg = 4326) #FAIL. 
    #Error in sp::CRS(paste("+init=epsg:", epsg, sep = "")) : 
    #  no arguments in initialization list

##################### APPROACH BELOW CRASHES R EACH TIME
#path = system.file("tmp_images", "slic_im.png", package = "OpenImageR")
#im = readImage("./Original_data/Headwall/MSGC_TST_IMG_RGB.tiff")
#
#im_mat<-as.matrix(im)
##--------------
## "slic" method
##--------------
#
#res_slic = superpixels(input_image = im,
#                       method = "slic",
#                       superpixel = 200, 
#                       compactness = 20,
#                       return_slic_data = TRUE,
#                       return_labels = TRUE, 
#                       write_slic = "", 
#                       verbose = TRUE)
#
#res_slico = superpixels(input_image = im_mat,
#                        method = "slico",
#                        superpixel = 200, 
#                        return_slic_data = TRUE,
#                        return_labels = TRUE, 
#                        write_slic = "", 
#                        verbose = TRUE)
#
