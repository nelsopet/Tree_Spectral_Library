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

writeTIFF(as.matrix(tst_rgb), "./Original_data/Headwall/MSGC_TST_IMG_RGB.tiff")
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
tst_seg_26983<-itcIMG(tst_proj_812, epsg = 26983) #Works with error
    #Warning message:
    #In `proj4string<-`(`*tmp*`, value = sp::CRS(paste("+init=epsg:",  :
    # A new CRS was assigned to an object with an existing CRS:
    # +proj=aea +lon_0=-69.609375 +lat_1=43.0460393 +lat_2=51.3106043 +lat_0=47.1783218 +datum=WGS84 +units=m +ellps=WGS84 +towgs84=0,0,0
    #without reprojecting.
    #For reprojection, use function spTransform
plot(tst_seg_26983)
writeOGR(tst_seg_26983, dsn = "./Outputs/2_Imagery/Headwall/Segments/", driver="ESRI Shapefile" , layer="tst_seg_26983")

#tst_seg_42310<-itcIMG(tst_proj_812, epsg = 42310) #Fail ... I need to reproject first 
  #Error in sp::CRS(paste("+init=epsg:", epsg, sep = "")) : 
  #no arguments in initialization list
  writeOGR(tst_seg_42310, )
#tst_seg<-itcIMG(tst_proj_812, epsg = 4326) #FAIL. 
    #Error in sp::CRS(paste("+init=epsg:", epsg, sep = "")) : 
    #  no arguments in initialization list

###THIS APPROACH CRASHES R EACH TIME
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
