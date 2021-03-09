require(raster)
require(spectrolab)
require(tidyverse)
require(hsdar)
require(sf)
require(mapview)
require(caTools)
require(terra)
require(tools)
#View images
tst<-brick("./Original_data/Headwall/MSGC_TST_IMG")
plotRGB(tst, r=160, g=80, b=25, stretch="lin")

