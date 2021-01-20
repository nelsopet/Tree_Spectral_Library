#################################Models for headwall imagery######################################################
###Inputs from this model were made in Scripts/2_Image_processing/Headwall_Predictors/MSGC_IMG_IMG_ALL_Preds_HDW
library(spectrolab)
library(randomForest)
library(raster)
library(tidyverse)
library(hsdar)
library(randomcoloR)
library(randomForestExplainer)

##Reads in imagery so we can grab the crs to create our raster later
MSGC_IMG     <-brick("Original_data/Headwall/MSGC_TST_IMG")
MSGC_IMG_latlong<-MSGC_IMG%>%rasterToPoints()%>%as.data.frame()

##This is a dataframe with all predictors to be used in model building
MSGC_IMG_data_HDW<-read.csv("Outputs/2_Imagery/Headwall/Processing/MSGC_IMGt_data.csv")

##Lets load our random Forest model with the 50 most important variables (PFT_3)
load("Outputs/2_Imagery/Headwall/Models/rf_MSGC   .rda")
##rf_MSGC

##This function uses the model built on the  from spectral 50 most important variables
##to predict the observations of each pixel in the imagery
Results_HDW    <-predict(rf_MSGC,MSGC_IMG_data_HDW[-1:-2])

##Converts prediction from rf model to dataframe and changes column name to predicted
Results_HDW<-as.data.frame(Results_HDW)%>%'names<-'("predicted")

## Grabs x, y values from original image and combines with unique values from prediction 
Results_HDW<-cbind(Results_HDW,MSGC_IMG_latlong[1:2]) %>% dplyr::select(predicted,x,y)

###Creates Unique PFT_IDs
Unique_HDW<-unique(as.data.frame(Results_HDW$predicted)) 
Unique_HDW$PFT_ID<-seq(1:nrow(Unique_HDW))
names(Unique_HDW)[1]<-"predicted"

###Create dataframe with unique PFT_ID values and location info
Results_HDW<-merge(Results_HDW,Unique_HDW, by="predicted")%>% dplyr::select(x,y,PFT_ID)

##Converts dataframe to a raster for predicted layer....and use as.factor to arrange my original raster layer
MSGC_raster<-rasterFromXYZ(Results_HDW, crs = crs(MSGC_IMG)) 

##################################################Raster #1#####################################################
##LETS READ IN OUR POLYGON SHAPEFILES
BF_SHAPE<-readOGR("Original_data/Headwall","BF_TreePoly")    
BE_SHAPE<-readOGR("Original_data/Headwall","BE_TreesPoly")    
RM_SHAPE<-readOGR("Original_data/Headwall","RM_TreesPoly")    
QA_SHAPE<-readOGR("Original_data/Headwall","QA_TreePoly")    

BF    <-subset(Unique_HDW,Unique_HDW$predicted=="BF"    )%>%as.data.frame()%>%dplyr::select("PFT_ID")
BE    <-subset(Unique_HDW,Unique_HDW$predicted=="BE"    )%>%as.data.frame()%>%dplyr::select("PFT_ID")
Shadow<-subset(Unique_HDW,Unique_HDW$predicted=="Shadow")%>%as.data.frame()%>%dplyr::select("PFT_ID")
RM    <-subset(Unique_HDW,Unique_HDW$predicted=="RM"    )%>%as.data.frame()%>%dplyr::select("PFT_ID")
QA    <-subset(Unique_HDW,Unique_HDW$predicted=="QA"    )%>%as.data.frame()%>%dplyr::select("PFT_ID")

###Filters the image on each functional group
MSGC_BF    <-MSGC_raster==BF    [1,1]
MSGC_BE    <-MSGC_raster==BE    [1,1]
MSGC_Shadow<-MSGC_raster==Shadow[1,1]
MSGC_RM    <-MSGC_raster==RM    [1,1]
MSGC_QA    <-MSGC_raster==QA    [1,1]


##We need to change all those values within the raster to 1, 
##so the sum of all the pixels in each quadrat can be calculated later
MSGC_denom  <-MSGC_raster>=1

##DF OF METEDATA
MSGC_IMG_meta  <-BF_SHAPE@data%>%as.data.frame()

#Creates object with the total Pixels for each quadrat
MSGC_IMG_Quad_totals  <-raster::extract(x=MSGC_denom ,y=BF_SHAPE  ,fun=sum)%>%as.data.frame()

#####################################Accuracy assesment#################################################
##Reads in Shapefile for quadrat locations (this step is used for accuray assesment)
#MSGC_IMG_quadrats  <- readOGR("Original_data/Headwall","EightMile_TESTQUADS"  )

##Creates object with the total Pixels for each Functional group
#MSGC_IMG_Graminoid_Sedge_sum   <-raster::extract(x=MSGC_IMG_Graminoid_Sedge   ,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Graminoid_Sedge_p"    )
#MSGC_IMG_Lichen_Yellow_sum     <-raster::extract(x=MSGC_IMG_Lichen_Yellow     ,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Lichen_Yellow_p"      )
#MSGC_IMG_Shrub_Other_sum       <-raster::extract(x=MSGC_IMG_Shrub_Other       ,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Shrub_Other_p"        )
#MSGC_IMG_Dwarf_Shrub_Needle_sum<-raster::extract(x=MSGC_IMG_Dwarf_Shrub_Needle,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Dwarf_Shrub_Needle_p" )
#MSGC_IMG_Dwarf_Shrub_Broad5_sum<-raster::extract(x=MSGC_IMG_Dwarf_Shrub_Broad5,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Dwarf_Shrub_Broad5_p" )
#MSGC_IMG_Lichen_Dark_sum       <-raster::extract(x=MSGC_IMG_Lichen_Dark       ,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Lichen_Dark_p"        )
#MSGC_IMG_Shrub_Salix_sum       <-raster::extract(x=MSGC_IMG_Shrub_Salix       ,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Shrub_Salix_p"        )
#MSGC_IMG_Forb_sum              <-raster::extract(x=MSGC_IMG_Forb              ,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Forb_p"               )
#MSGC_IMG_Tree_Needle_sum       <-raster::extract(x=MSGC_IMG_Tree_Needle       ,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Tree_Needle_p"        )
#MSGC_IMG_Moss_Pleurocarp_sum   <-raster::extract(x=MSGC_IMG_Moss_Pleurocarp   ,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Moss_Pleurocarp_p"    )
#MSGC_IMG_Shrub_Alder_sum       <-raster::extract(x=MSGC_IMG_Shrub_Alder       ,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Shrub_Alder_p"        )
#MSGC_IMG_Graminoid_Grass_sum   <-raster::extract(x=MSGC_IMG_Graminoid_Grass   ,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Graminoid_Grass_p"    )
#MSGC_IMG_Lichen_Light_sum      <-raster::extract(x=MSGC_IMG_Lichen_Light      ,y=MSGC_IMG_quadrats,fun=sum)%>%as.data.frame()%>%'names<-'("Lichen_Light_p"       )
#
#
###Lets combine the datframes created above
#MSGC_IMG_pixeltotals<-Reduce(cbind,list(MSGC_IMG_Quad_totals
#                                                ,MSGC_IMG_Graminoid_Sedge_sum   
#                                                ,MSGC_IMG_Lichen_Yellow_sum     
#                                                ,MSGC_IMG_Shrub_Other_sum       
#                                                ,MSGC_IMG_Dwarf_Shrub_Needle_sum
#                                                ,MSGC_IMG_Dwarf_Shrub_Broad5_sum
#                                                ,MSGC_IMG_Lichen_Dark_sum       
#                                                ,MSGC_IMG_Shrub_Salix_sum       
#                                                ,MSGC_IMG_Forb_sum              
#                                                ,MSGC_IMG_Tree_Needle_sum       
#                                                ,MSGC_IMG_Moss_Pleurocarp_sum   
#                                                ,MSGC_IMG_Shrub_Alder_sum       
#                                                ,MSGC_IMG_Graminoid_Grass_sum   
#                                                ,MSGC_IMG_Lichen_Light_sum      ))
#
###Now we want to calculate the % cover for each Functional group in each quadrat
#MSGC_IMG_PercentCover<-MSGC_IMG_pixeltotals[,2:14]/(MSGC_IMG_pixeltotals[,1])*100
#MSGC_IMG_PercentCover<-MSGC_IMG_PercentCover%>%
#  mutate(CLASS_ID=rownames(MSGC_IMG_PercentCover))%>%
#  dplyr::select(CLASS_ID,everything())
#
###Lets merge the metadata with these new dataframes
#MSGC_IMG_PercentCover <-merge(MSGC_IMG_meta,  MSGC_IMG_PercentCover  ,by="CLASS_ID")
#MSGC_IMG_PercentCover<-MSGC_IMG_PercentCover%>%
#  arrange(CLASS_NAME)%>%
#  dplyr::select(-CLASS_CLRS,-CLASS_ID)%>%
#  mutate(CLASS_ID=rownames(MSGC_IMG_PercentCover))%>%dplyr::select(CLASS_ID,everything())
#
#write.csv(MSGC_IMG_PercentCover ,"Outputs/2_Imagery/Headwall/Prediction/MSGC_IMG_PercentCover_TST50.csv")

###save plot as a jpeg
##chm_colors <- c("darkgreen","mediumvioletred","gold","deepskyblue","saddlebrown","orange2","ivory3","darkorange4","khaki1","lightcyan1","mediumorchid3","yellow1","slateblue2")
chm_colors <-distinctColorPalette(nrow(Unique_HDW))
jpeg('Outputs/2_Imagery/Headwall/Prediction/MSGC_IMG_Accuracy.jpg',width=1200, height=700)
plot(
  MSGC_raster,
  legend = FALSE,
  axes=FALSE,
  col = chm_colors[-8],
  box= FALSE,
  xlab="Longitude", 
  ylab="Latitude"
)
plot(BF_SHAPE,border="Black",lwd=7,add=TRUE)
legend(
  "right",
  legend = c(paste(Unique_HDW$predicted)),
  fill =chm_colors,
  border = FALSE,
  bty = "n",
  cex=1.5,
  xjust =1,
  horiz = FALSE,
  inset = -0.009,
  par(cex=0.4)
  
)             
dev.off()

writeRaster(MSGC_raster, "Outputs/2_Imagery/Headwall/Prediction/MSGC_raster.tif")

#######################Plot without Accuracy assesment##########################
chm_colors <-distinctColorPalette(nrow(Unique_HDW))
jpeg('Outputs/2_Imagery/Headwall/Prediction/MSGC_IMG_Pred50.jpg',width=1200, height=700)
plot(
  MSGC_raster,
  legend = FALSE,
  axes=FALSE,
  col = chm_colors[-8],
  box= FALSE,
  xlab="Longitude", 
  ylab="Latitude"
)
legend(
  "right",
  legend = c(paste(Unique_HDW$predicted)),
  fill =chm_colors,
  border = FALSE,
  bty = "n",
  cex=1.5,
  xjust =1,
  horiz = FALSE,
  inset = -0.009,
  par(cex=0.4)
  
)             
dev.off()

