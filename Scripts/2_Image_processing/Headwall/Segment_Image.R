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
library(SpaDES)
library(doParallel)
library(parallel)
library(randomForest)
#View images
#path="./Original_data/Headwall/MSGC_TST_IMG.png"
path1 <- "Data/MSGC_TST_IMG" # This works
path2 <- "M:/MSGC_DATA/Howland/Imagery/100043_Howland_plot_7b_110m_2019_07_09_16_35_19/Orthos/raw_0_rd_rf_or"
#path ="M:/MSGC_DATA/MSGC_Report/Images/MSGCIMAGE.tif"
#raster(path)

tst<-brick(path1)
  tst_rgb<-tst[[c(160,80,25)]]

tst2<-brick(path2)
  tst2_rgb<-tst2[[c(160,80,25)]]
    tst_rgb<-as(tst2_rgb, "RasterLayer")
      tst2_rgb_proj<-projectRaster(tst2_rgb, crs=new_prj)
        tst2_rgb_tiles<-splitRaster(tst2_rgb_proj[[1]], nx=3, ny=5)
          tst2_rgb_tiles[[2]]
            plot(tst2_rgb_tiles[[2]])
        
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

tst_812<-tst$Resize..Band.225.raw_0_rd_rf_or...812.390000.Nanometers.
tst_812_proj<-projectRaster(tst_812, crs=new_prj)
  
  
tst2_812<-tst2$X812.39.nm
  tst2_812_proj<-projectRaster(tst2_812, crs=new_prj)
    tst2_812_tiles<-splitRaster(tst2_812_proj, nx=3, ny=5)
      tst2_812_tiles

#tst_proj_crs42310<-projectRaster(tst, crs=crs())
tst_proj_812<-as(tst_proj$Resize..Band.225.raw_0_rd_rf_or...812.390000.Nanometers.,"RasterLayer")

tst2_812_proj<-as(tst2_812_proj,"RasterLayer")

#tst_seg_26983_winSize3_Dist50   <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 3, DIST = 50) #Works with error
#tst_seg_26983_winSize9_Dist50   <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 9, DIST = 50) #Works with error
#tst_seg_26983_winSize21_Dist50  <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 21, DIST = 50) #Works with error
#tst_seg_26983_winSize51_Dist500 <-itcIMG(tst_proj_812, epsg = 26983, searchWinSize = 51, DIST = 500) #Works with error


##Very slow to run
tst_seg_4326_winSize51_Dist500 <-itcIMG(
  tst_812_proj,
  epsg = 26983,
  searchWinSize = 51,
  DIST = 500) #Works with error
##Very very slow to run .. hours
#tst2_seg_4326_winSize51_Dist500 <-itcIMG(tst2_812_proj, epsg = 4326, searchWinSize = 51, DIST = 500) #

#tst2_tile1_seg_4326_winSize51_Dist500 <-itcIMG(tst2_812_tiles[[1]], epsg = 4326, searchWinSize = 51, DIST = 500) #Throws projection error
  #Error in `proj4string<-`(`*tmp*`, value = sp::CRS(paste("+init=epsg:",  : Geographical CRS given to non-conformant data:   69427.2832844 -218911.3310360
tst2_tile1_seg_26983_winSize51_Dist500 <-itcIMG(tst_812_proj, epsg = 26983, searchWinSize = 51, DIST = 500) #Throws projection error
  plot(tst2_tile1_seg_26983_winSize51_Dist500)

tst2_tile2_seg_26983_winSize51_Dist500 <-itcIMG(tst2_812_tiles[[2]], epsg = 26983, searchWinSize = 51, DIST = 500) #Throws projection error
  plot(tst2_tile2_seg_26983_winSize51_Dist500)
    plot(tst2_812_tiles[[2]])
#tst2_tile1_seg_4326_winSize51_Dist500<-spTransform(tst2_tile1_seg_4326_winSize51_Dist500, CRS ="+proj=longlat +datum=WGS84")

#tst_seg_4326_winSize3<-spTransform(tst_seg_26983_winSize3_Dist50, CRS ="+proj=longlat +datum=WGS84")

seg_fnc<- function(x)
{
tile_seg<-list()
tile_seg[x] <-itcIMG(tst2_812_tiles[[x]], epsg = 26983, searchWinSize = 51, DIST = 500) #Throws projection error
}
    
tst2_segments<-lapply(1:length(tst2_812_tiles), seg_fnc)


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
,tst_seg_26983_winSize9_Dist50   
,tst_seg_26983_winSize21_Dist50  
,tst_seg_26983_winSize51_Dist500)
str(seg_group)
plot(seg_group)
seg_names<-c(
  
  "tst_seg_26983_winSize3_Dist50  "
  ,"tst_seg_26983_winSize9_Dist50  "
  ,"tst_seg_26983_winSize21_Dist50 "
  ,"tst_seg_26983_winSize51_Dist500"
)

list.files("Outputs/2_Imagery/Headwall/Segments/")

writeOGR(tst_seg_4326_winSize3, dsn = "Outputs/2_Imagery/Headwall/Segments/tst_seg_4325_winSize3.shp", driver="ESRI Shapefile" , layer="tst_seg_4325_winSize3")
writeOGR(tst2_seg_4326_winSize51_Dist500, dsn = "Outputs/2_Imagery/Headwall/Segments/tst2_seg_4326_winSize51_Dist500.shp", driver="ESRI Shapefile" , layer="tst2_seg_4326_winSize51_Dist500")

#seg_group[1]
#writeOGR(tst_seg_26983_winSize3_Dist50, dsn = "./Outputs/2_Imagery/Headwall/Segments/", driver="ESRI Shapefile" , layer="tst_seg_26983_winSize3_Dist50")

lapply(1:length(seg_group), function(x){
writeOGR(seg_group[[x]], dsn = paste("Outputs/2_Imagery/Headwall/Segments/",x,".shp",sep=""), driver="ESRI Shapefile" , layer=x)
})


pdf("./Outputs/2_Imagery/Headwall/Segments/test_forest_canopy_segments.pdf")
lapply(1:length(seg_group),
function(x){
plot(seg_group[[x]])
title(main = seg_names[x])
})
  #plotRGB(tst, r=160, g=80, b=25, stretch="lin")
#ggplot(seg_group[[1]],aes(X,Y))+geom_polygon()
dev.off()


lapply(1:length(tst2_segments), function(x){
  writeOGR(tst2_segments[[x]], dsn = paste("Outputs/2_Imagery/Headwall/Segments/full_cube_test/",x,".shp",sep=""), driver="ESRI Shapefile" , layer=x)
})

jpeg("./Outputs/2_Imagery/Headwall/Segments/full_cube_test/full_cube_test_forest_canopy_segments.jpeg")
lapply(1:length(tst2_segments),
       function(x){
         plot(tst2_segments[[x]])
         title(main =paste("segment", x))
       })
dev.off(
  
)
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
