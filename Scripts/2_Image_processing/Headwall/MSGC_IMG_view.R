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

all_files<-read.csv( "Outputs/INSPIRES_submission.csv")

#View images
path="./Original_data/Headwall/MSGC_TST_IMG"
tst<-brick(path)
tst_rgb<-tst[[c(160,80,25)]]
plotRGB(tst, r=160, g=80, b=25, stretch="lin")
writeTIFF(as.matrix(tst_rgb), "./Original_data/Headwall/MSGC_TST_IMG_RGB.tiff")

all_files_imgs<-all_files[grepl("rd_rf_or.hdr",all_files)]
all_files_imgs<-gsub(".hdr","",all_files_imgs)
all_files_df<-tidyr::separate(as.data.frame(all_files_imgs),col="all_files_imgs",sep="_", into = c("Root","Project","Site","Imagery","Flight_Line","Orthos","Image"))

#Test
path = all_files_imgs[3]
path2 = all_files_imgs[4]

tst1<-terra::rast(path)
tst2<-terra::rast(path2)
tst_1_rgb<-tst2[160,80,25]
#mosaic12<-terra::mosaic(tst1,tst2)
#terra::merge()
terra::plotRGB(mosaic12, r=160,g=80,b=25, a=NULL, stretch = "lin")
#jpeg(paste("./Outputs/Extents/quicklooks/image",x,".jpg",sep="_" ))
terra::plotRGB(tst, r=160,g=80,b=25, a=NULL, stretch = "lin")
#dev.off()

mosaic()
#Make quick looks for all images
lapply(1:length(all_files_imgs), function (x) 
{
path = all_files_imgs[x]
tst<-terra::rast(path)
jpeg(paste("./Outputs/Extents/quicklooks/image",x,".jpg",sep="_" ))
terra::plotRGB(tst, r=160,g=80,b=25, stretch = "lin")
dev.off()
})
