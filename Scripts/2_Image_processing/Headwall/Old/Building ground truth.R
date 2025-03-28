####################Calculates the resampled bands for the spectral library developed from headwall's bandpases####
library(spectrolab)
library(tidyverse)
library(hsdar)

##Lets read in all the locatiosn where there are tree species and shadows
BE_1<-brick("Original_data/Headwall/BE_1")%>%rasterToPoints()%>%as.data.frame()%>%mutate(species="BE")%>%dplyr::select(x,y,species,everything())
BE_2<-brick("Original_data/Headwall/BE_2")%>%rasterToPoints()%>%as.data.frame()%>%mutate(species="BE")%>%dplyr::select(x,y,species,everything())
BF_1<-brick("Original_data/Headwall/BF_1")%>%rasterToPoints()%>%as.data.frame()%>%mutate(species="BF")%>%dplyr::select(x,y,species,everything())
QA_1<-brick("Original_data/Headwall/QA_1")%>%rasterToPoints()%>%as.data.frame()%>%mutate(species="QA")%>%dplyr::select(x,y,species,everything())
RM_1<-brick("Original_data/Headwall/RM_1")%>%rasterToPoints()%>%as.data.frame()%>%mutate(species="RM")%>%dplyr::select(x,y,species,everything())
RM_2<-brick("Original_data/Headwall/RM_2")%>%rasterToPoints()%>%as.data.frame()%>%mutate(species="RM")%>%dplyr::select(x,y,species,everything())
RM_3<-brick("Original_data/Headwall/RM_3")%>%rasterToPoints()%>%as.data.frame()%>%mutate(species="RM")%>%dplyr::select(x,y,species,everything())

##Lets merge these
MSGC_PLOT1<-rbind(BE_1
                 ,BE_2
                 ,BF_1
                 ,QA_1
                 ,RM_1
                 ,RM_2
                 ,RM_3)

##Reads in bandpasses for imagery to be used later
HDW_ng_wv<-scan("Original_data/Headwall/Headwall_wv", numeric())

##lets remove all those bads that had noise
MSGC_PLOT1[276:329]<-NULL

##change colnames to correct band names
colnames(MSGC_PLOT1)[-1:-3]<-HDW_ng_wv

##Now lets check the range of the values in the image
test<-lapply(MSGC_PLOT1[,-1:-3],range)%>%as.data.frame%>%t()%>%as.data.frame
#test%>%View()
test%>%lapply(range) ### All values fall between 0 and 1.2 and there are no NA values

##Lets change all NA values to 0s
##Now we have our groud truth data and we can build our models
MSGC_PLOT1[is.na(MSGC_PLOT1)] <- 0

##create a datframe with the coordinates for imagery to be used later
cords<-MSGC_PLOT1%>%dplyr::select(x,y,species)

##Now we can resample the dataset
MSGC_PLOT1_005nm<-MSGC_PLOT1%>%dplyr::select(-x,-y,-species)%>%spectrolab::as.spectra()%>%spectrolab::resample(seq(399.444,899.424,5  ))%>%as.data.frame()%>%cbind(cords)%>%dplyr::select(x,y,species,everything())%>%dplyr::select(-sample_name)
MSGC_PLOT1_010nm<-MSGC_PLOT1%>%dplyr::select(-x,-y,-species)%>%spectrolab::as.spectra()%>%spectrolab::resample(seq(399.444,899.424,10 ))%>%as.data.frame()%>%cbind(cords)%>%dplyr::select(x,y,species,everything())%>%dplyr::select(-sample_name)
MSGC_PLOT1_050nm<-MSGC_PLOT1%>%dplyr::select(-x,-y,-species)%>%spectrolab::as.spectra()%>%spectrolab::resample(seq(399.444,899.424,50 ))%>%as.data.frame()%>%cbind(cords)%>%dplyr::select(x,y,species,everything())%>%dplyr::select(-sample_name)
MSGC_PLOT1_100nm<-MSGC_PLOT1%>%dplyr::select(-x,-y,-species)%>%spectrolab::as.spectra()%>%spectrolab::resample(seq(399.444,899.424,100))%>%as.data.frame()%>%cbind(cords)%>%dplyr::select(x,y,species,everything())%>%dplyr::select(-sample_name)

###Lets run logical test for all dataframes
tst2<-lapply(MSGC_PLOT1_005nm[-1:-3],range)%>%as.data.frame%>%t()%>%as.data.frame
tst2$V1%>%range()##There are no weird values, those are values outside of 0 and 2
tst2$V2%>%range()##There are no weird values, those are values outside of 0 and 2
#tst2%>%subset(V1<0)%>%view()

MSGC_PLOT1_005nm<-MSGC_PLOT1_005nm%>%
  filter_at(vars(-x,-y,-species),all_vars(. >=0))
MSGC_PLOT1_010nm<-MSGC_PLOT1_010nm%>%
  filter_at(vars(-x,-y,-species),all_vars(. >=0))
MSGC_PLOT1_050nm<-MSGC_PLOT1_050nm%>%
  filter_at(vars(-x,-y,-species),all_vars(. >=0))
MSGC_PLOT1_100nm<-MSGC_PLOT1_100nm%>%
  filter_at(vars(-x,-y,-species),all_vars(. >=0))

###Lets save our new dfs
write.csv(MSGC_PLOT1,       "Outputs/2_Imagery/Headwall/Processing/MSGC_PLO1_GtRUTH.csv", row.names = FALSE)
write.csv(MSGC_PLOT1_005nm ,"Outputs/2_Imagery/Headwall/Processing/MSGC_PLOT1_005nm.csv" ,row.names = FALSE)
write.csv(MSGC_PLOT1_010nm ,"Outputs/2_Imagery/Headwall/Processing/MSGC_PLOT1_010nm.csv" ,row.names = FALSE)
write.csv(MSGC_PLOT1_050nm ,"Outputs/2_Imagery/Headwall/Processing/MSGC_PLOT1_050nm.csv" ,row.names = FALSE)
write.csv(MSGC_PLOT1_100nm ,"Outputs/2_Imagery/Headwall/Processing/MSGC_PLOT1_100nm.csv" ,row.names = FALSE)















