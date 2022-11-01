#This script crops and masks an image by a shapefile. The output is a raster of each tree canopy for that image.

#source("Functions/lecospectR.R")
library(terra)
library(raster)
library(rgdal)
library(hsdar)
library(rgeos)
library(sf)

#Define file paths
image_path = "M:/MSGC_DATA/PEF-Demerit/Imagery/100047_PEF_SM_12a_110m_2019_06_16_15_25_41/Orthos/raw_15568_rd_rf_or"
canopies_path = "M:\\MSGC_DATA\\PEF-Demerit\\Digitize_Canopies\\100047_15568\\"

#bring in test image
img <- brick(image_path)

#bring in vector of canopies
#canopies_vec <- readOGR(dsn = paste0(canopies_path, "100038_PEF_SM_4_110m_2019_06_18_15_16_13_ortho_raw_7492_rd_rf_or.shp"))
canopies_full <- readOGR(dsn = paste0(canopies_path, "full_PEF_100047_15568.shp"))
canopies_light <- readOGR(dsn = paste0(canopies_path, "light_PEF_100047_15568.shp"))
canopies_shadow <- readOGR(dsn = paste0(canopies_path, "shadow_PEF_100047_15568.shp"))

#Now, crop and mask image by each canopy shapefile. Functions are split into
  #full canopies, illuminated only, and shadowed only
#FULL CANOPIES#
lapply(1:length(canopies_full),  
       function(x) {
         tst_img <- brick(image_path)
         tst_names<-names(tst_img)
         tst_quads<-canopies_full[x,]
         tst_crop <- raster::crop(tst_img, tst_quads)
         tst_mask <- raster::mask(tst_crop, tst_quads)
         metadata(tst_mask)<-as.list(canopies_full[x,]$CLASS_NAME)
         bandnames(tst_mask)<-tst_names
         writeRaster(tst_mask, paste("M:\\MSGC_DATA\\PEF-Demerit\\Cropped_ROIs_spectra\\", canopies_full[x,]$CLASS_NAME, sep=""), format = "raster", overwrite = TRUE)
       })

#ILLUMINATED CANOPIES ONLY#
lapply(1:length(canopies_light),  
       function(x) {
         tst_img <- brick(image_path)
         tst_names<-names(tst_img)
         tst_quads<-canopies_light[x,]
         tst_crop <- raster::crop(tst_img, tst_quads)
         tst_mask <- raster::mask(tst_crop, tst_quads)
         metadata(tst_mask)<-as.list(canopies_light[x,]$CLASS_NAME)
         bandnames(tst_mask)<-tst_names
         writeRaster(tst_mask, paste("M:\\MSGC_DATA\\PEF-Demerit\\Cropped_ROIs_spectra\\", canopies_light[x,]$CLASS_NAME, sep=""), format = "raster", overwrite = TRUE)
       })

#SHADOWED CANOPIES ONLY#
lapply(1:length(canopies_shadow),  
       function(x) {
         tst_img <- brick(image_path)
         tst_names<-names(tst_img)
         tst_quads<-canopies_shadow[x,]
         tst_crop <- raster::crop(tst_img, tst_quads)
         tst_mask <- raster::mask(tst_crop, tst_quads)
         metadata(tst_mask)<-as.list(canopies_shadow[x,]$CLASS_NAME)
         bandnames(tst_mask)<-tst_names
         writeRaster(tst_mask, paste("M:\\MSGC_DATA\\PEF-Demerit\\Cropped_ROIs_spectra\\", canopies_shadow[x,]$CLASS_NAME, sep=""), format = "raster", overwrite = TRUE)
       })








