#################################PCA modesl for headwall imagery######################################################
###Inputs from this model were made in Scripts/2_Image_processing/2_var_pca/Headwall_pca
library(randomForest)
library(raster)
library(tidyverse)

##Reads in test imagery
Clayton_test_HDW<-brick("Original_data/Test_imagery_HDW/Clayton_test_HDW")%>%rasterToPoints()%>%as.data.frame()

##Reads in PCA for specctral library each functional group has a total of 25 scans and imagery 
HDW_PCAspeclib<-read.csv("Outputs/2_HDW_Imagery/1_Processing/HDW_PCAspeclib.csv")
HDW_PCAimage  <-read.csv("Outputs/2_HDW_Imagery/1_Processing/HDW_PCAimage.csv"  )

##Remove unwanted metadata from spectral library
HDW_PCAspeclib [c("ScanID","PFT","PFT_2","area","Freq1","Freq2")] = NULL

##We can build randomforest model
rf_HDW_PCA         <-randomForest(PFT_3~.,data=HDW_PCAspeclib  ,mtry=3,ntree=301,importance=TRUE)

##Lets create a dataframe that shows the importance of each variable
feat_imp_df <- importance(rf_HDW_PCA) %>% 
  data.frame() %>% 
  mutate(feature = row.names(.)) 

#now let's visualize that dataframe plot dataframe
jpeg('Outputs/2_HDW_Imagery/2_Models/PC Feature importance_HDW.jpg',width=1000, height=700)
ggplot(feat_imp_df, aes(x = reorder(feature, MeanDecreaseGini), 
                        y = MeanDecreaseGini)) +
  geom_bar(stat='identity') +
  coord_flip() +
  theme_classic() +
  labs(
    x     = "Feature",
    y     = "Importance",
    title = "Feature Importance: HDW Randomforest_MOD using PCs as predictors"
  )
dev.off()

##Uses model from spectral library to predict images
Results_HDW_PCA    <-predict(rf_HDW_PCA        ,HDW_PCAimage[-(1:2)])

##Converts prediction from rf model to dataframe and changes column name to predicted
Results_HDW_PCA<-as.data.frame(Results_HDW_PCA)%>%'names<-'("predicted")

## Grabs x, y values from original image and combines with unique values from prediction 
Results_HDW_PCA<-cbind(Results_HDW_PCA,HDW_PCAimage) %>% dplyr::select(predicted,x,y)

###Creates Unique PFT_IDs
Unique_HDW_PCA<-unique(as.data.frame(Results_HDW_PCA$predicted)) 
Unique_HDW_PCA$PFT_ID<-seq(1:nrow(Unique_HDW_PCA))
names(Unique_HDW_PCA)[1]<-"predicted"

###Create dataframe with unique PFT_ID values and location info
Results_HDW_PCA<-merge(Results_HDW_PCA,Unique_HDW_PCA, by="predicted")%>% dplyr::select(x,y,PFT_ID)

##Converts dataframe to a raster for predicted layer....and use as.factor to arrange my original raster layer
Results_HDW_PCA_raster<-rasterFromXYZ(Results_HDW_PCA, crs = crs(Clayton_test_HDW))

###sHDWe plot as a jpeg
jpeg('Outputs/2_HDW_Imagery/2_Models/Plot of PCA Model Prediction_HDW.jpg',width=1000, height=700)
par(xpd = FALSE)
plot(
  Results_HDW_PCA_raster,
  legend = FALSE,
  col = c(
    "lightcyan3",
    "royalblue",
    "forestgreen",
    "coral3",
    "papayawhip",
    "yellow",
    "orange"
  ),
  xaxt = 'n',
  yaxt = 'n',
  main = "Plot of PCA Model Prediction - HDW"
)

par(xpd = TRUE)
legend(
  "right",
  legend = c("Dwarf Shrub","Shrub","moss","Lichen","Tree","Forb","Graminoid"),
  fill = c(
    "lightcyan3",
    "royalblue",
    "forestgreen",
    "coral3",
    "papayawhip",
    "yellow",
    "orange"
  ),
  cex=1,
  xjust =1,
  horiz = FALSE,
  inset = -0.09,
  par(cex=0.4)
  
)             
dev.off()

###writes out Rater layer created
writeRaster(Results_HDW_PCA_raster,
            filename ="Outputs/2_HDW_Imagery/2_Models/Results_HDW_PCA_raster", 
            format="GTiff", overwrite=TRUE)

