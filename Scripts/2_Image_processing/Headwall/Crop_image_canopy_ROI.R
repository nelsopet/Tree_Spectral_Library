#This script crops and masks an image by a shapefile. The output is a raster of each tree canopy for that image.


#source("Functions/lecospectR.R")
library(terra)
library(raster)
library(rgdal)
library(sf)
library(hsdar)

#Define file paths
image_path = "M:\\MSGC_DATA\\PEF-Demerit\\Imagery\\100038_PEF_SM_4_110m_2019_06_18_15_16_13\\ortho\\raw_7492_rd_rf_or"
canopies_path = "M:\\MSGC_DATA\\PEF-Demerit\\Digitize_Canopies\\100038_PEF_SM_4_110m_2019_06_18_15_16_13_ortho_raw_7492_rd_rf_or.shp"

#bring in vector of canopies
img <- brick(image_path)
#canopies_vec<-st_read(canopies_path)
canopies_vec <- readOGR(dsn = canopies_path)



lapply(1:length(canopies_vec),  
       function(x) {
         tst_img <- brick(image_path)
         tst_names<-names(tst_img)
         tst_quads<-canopies_vec[x,]
         tst_crop <- raster::crop(tst_img, tst_quads)
         tst_mask <- raster::mask(tst_crop, tst_quads)
         metadata(tst_mask)<-as.list(canopies_vec[x,]$CLASS_NAME)
         bandnames(tst_mask)<-tst_names
         writeRaster(tst_mask, paste("M:\\MSGC_DATA\\PEF-Demerit\\Test_output\\", canopies_vec[x,]$CLASS_NAME, sep=""), format = "raster", overwrite = TRUE)
       })
