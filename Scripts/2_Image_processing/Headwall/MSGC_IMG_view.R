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

#View images
path="./Original_data/Headwall/MSGC_TST_IMG"
tst<-brick(path)
tst_rgb<-tst[[c(160,80,25)]]
plotRGB(tst, r=160, g=80, b=25, stretch="lin")
writeTIFF(as.matrix(tst_rgb), "./Original_data/Headwall/MSGC_TST_IMG_RGB.tiff")



