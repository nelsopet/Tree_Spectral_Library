####################Calculates the resampled bands for the spectral library developed from headwall's bandpases####
library(spectrolab)
library(tidyverse)
library(hsdar)

##Lets read in all the locatiosn where there are tree species and shadows
MSGC_IMG     <-brick("Original_data/Headwall/MSGC_TST_IMG")    %>%rasterToPoints()%>%as.data.frame()%>%dplyr::select(x,y,everything())

##Reads in bandpasses for imagery to be used later
HDW_ng_wv<-scan("Original_data/Headwall/Headwall_wv", numeric())

##lets remove all those bads that had noise
MSGC_IMG[275:328]<-NULL

##change colnames to correct band names
colnames(MSGC_IMG)[-1:-2]<-HDW_ng_wv

##Now lets check the range of the values in the image
test<-lapply(MSGC_IMG[,-1:-2],range)%>%as.data.frame%>%t()%>%as.data.frame
#test%>%View()
test%>%lapply(range) ### All values fall between 0 and 1.2 and there are no NA values

##Lets change all NA values to 0s
##Now we have our groud truth data and we can build our models
MSGC_IMG[is.na(MSGC_IMG)] <- 0

##create a datframe with the coordinates for imagery to be used later
cords<-MSGC_IMG%>%dplyr::select(x,y)

##Now we can resample the dataset
MSGC_IMG_005nm<-MSGC_IMG%>%dplyr::select(-x,-y)%>%spectrolab::as.spectra()%>%spectrolab::resample(seq(399.444,899.424,5  ))%>%as.data.frame()%>%cbind(cords)%>%dplyr::select(x,y,everything())%>%dplyr::select(-sample_name)
MSGC_IMG_010nm<-MSGC_IMG%>%dplyr::select(-x,-y)%>%spectrolab::as.spectra()%>%spectrolab::resample(seq(399.444,899.424,10 ))%>%as.data.frame()%>%cbind(cords)%>%dplyr::select(x,y,everything())%>%dplyr::select(-sample_name)
MSGC_IMG_050nm<-MSGC_IMG%>%dplyr::select(-x,-y)%>%spectrolab::as.spectra()%>%spectrolab::resample(seq(399.444,899.424,50 ))%>%as.data.frame()%>%cbind(cords)%>%dplyr::select(x,y,everything())%>%dplyr::select(-sample_name)
MSGC_IMG_100nm<-MSGC_IMG%>%dplyr::select(-x,-y)%>%spectrolab::as.spectra()%>%spectrolab::resample(seq(399.444,899.424,100))%>%as.data.frame()%>%cbind(cords)%>%dplyr::select(x,y,everything())%>%dplyr::select(-sample_name)

###Lets run logical test for all dataframes
tst2<-lapply(MSGC_IMG_005nm[-1:-3],range)%>%as.data.frame%>%t()%>%as.data.frame
tst2$V1%>%range()##There are no weird values, those are values outside of 0 and 2
tst2$V2%>%range()##There are no weird values, those are values outside of 0 and 2
#tst2%>%subset(V1<0)%>%view()

MSGC_IMG_005nm[,-c(1,2,3)][MSGC_IMG_005nm[, -c(1,2,3)] < 0] <- 0
MSGC_IMG_010nm[,-c(1,2,3)][MSGC_IMG_010nm[, -c(1,2,3)] < 0] <- 0
MSGC_IMG_050nm[,-c(1,2,3)][MSGC_IMG_050nm[, -c(1,2,3)] < 0] <- 0
MSGC_IMG_100nm[,-c(1,2,3)][MSGC_IMG_100nm[, -c(1,2,3)] < 0] <- 0

###Lets save our new dfs
write.csv(MSGC_IMG,       "Outputs/2_Imagery/Headwall/Processing/MSGC_IMG_GtRUTH.csv", row.names = FALSE)
write.csv(MSGC_IMG_005nm ,"Outputs/2_Imagery/Headwall/Processing/MSGC_IMG_005nm.csv" ,row.names = FALSE)
write.csv(MSGC_IMG_010nm ,"Outputs/2_Imagery/Headwall/Processing/MSGC_IMG_010nm.csv" ,row.names = FALSE)
write.csv(MSGC_IMG_050nm ,"Outputs/2_Imagery/Headwall/Processing/MSGC_IMG_050nm.csv" ,row.names = FALSE)
write.csv(MSGC_IMG_100nm ,"Outputs/2_Imagery/Headwall/Processing/MSGC_IMG_100nm.csv" ,row.names = FALSE)















