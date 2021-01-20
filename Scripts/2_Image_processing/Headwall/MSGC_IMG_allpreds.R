#######################Combines all predictiors into one dataframe######################################
library(spectrolab)
library(tidyverse)
library(hsdar)

###Reads in all predictors for Imagery
MSGC_IMG_005nm<-read.csv("Outputs/2_Imagery/Headwall/Processing/MSGC_IMG_005nm.csv")
MSGC_IMG_010nm<-read.csv("Outputs/2_Imagery/Headwall/Processing/MSGC_IMG_010nm.csv")
MSGC_IMG_050nm<-read.csv("Outputs/2_Imagery/Headwall/Processing/MSGC_IMG_050nm.csv")
MSGC_IMG_100nm<-read.csv("Outputs/2_Imagery/Headwall/Processing/MSGC_IMG_100nm.csv")
MSGC_IMG_VIs  <-read.csv("Outputs/2_Imagery/Headwall/Processing/MSGC_IMG_VIs.csv"  )

##Make names for colnames in each df unique
colnames(MSGC_IMG_005nm)[-1:-2]<-paste0(colnames(MSGC_IMG_005nm)[-1:-2],"_005nm")
colnames(MSGC_IMG_010nm)[-1:-2]<-paste0(colnames(MSGC_IMG_010nm)[-1:-2],"_010nm")
colnames(MSGC_IMG_050nm)[-1:-2]<-paste0(colnames(MSGC_IMG_050nm)[-1:-2],"_050nm")
colnames(MSGC_IMG_100nm)[-1:-2]<-paste0(colnames(MSGC_IMG_100nm)[-1:-2],"_100nm")
colnames(MSGC_IMG_VIs  )[-1:-2]<-paste0(colnames(MSGC_IMG_VIs  )[-1:-2],"_VIs"  )

##Let's merge these dataframes
MSGC_IMG_data<-Reduce(cbind,list(MSGC_IMG_005nm
                                   ,MSGC_IMG_010nm[-1:-2]
                                   ,MSGC_IMG_050nm[-1:-2]
                                   ,MSGC_IMG_100nm[-1:-2]
                                   ,MSGC_IMG_VIs  [-1:-2]))
###Lets save dataframe
write.csv(MSGC_IMG_data    ,"Outputs/2_Imagery/Headwall/Processing/MSGC_IMGt_data.csv",row.names = FALSE)


