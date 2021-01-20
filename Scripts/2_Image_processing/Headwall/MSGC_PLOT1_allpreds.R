#######################Combines all predictiors into one dataframe######################################
library(spectrolab)
library(tidyverse)
library(hsdar)

###Reads in all predictors for Imagery
MSGC_PLOT1_005nm<-read.csv("Outputs/2_Imagery/Headwall/Processing/MSGC_PLOT1_005nm.csv")
MSGC_PLOT1_010nm<-read.csv("Outputs/2_Imagery/Headwall/Processing/MSGC_PLOT1_010nm.csv")
MSGC_PLOT1_050nm<-read.csv("Outputs/2_Imagery/Headwall/Processing/MSGC_PLOT1_050nm.csv")
MSGC_PLOT1_100nm<-read.csv("Outputs/2_Imagery/Headwall/Processing/MSGC_PLOT1_100nm.csv")
MSGC_PLOT1_VIs  <-read.csv("Outputs/2_Imagery/Headwall/Processing/MSGC_PLOT1_VIs.csv"  )

##Make names for colnames in each df unique
colnames(MSGC_PLOT1_005nm)[-1:-3]<-paste0(colnames(MSGC_PLOT1_005nm)[-1:-3],"_005nm")
colnames(MSGC_PLOT1_010nm)[-1:-3]<-paste0(colnames(MSGC_PLOT1_010nm)[-1:-3],"_010nm")
colnames(MSGC_PLOT1_050nm)[-1:-3]<-paste0(colnames(MSGC_PLOT1_050nm)[-1:-3],"_050nm")
colnames(MSGC_PLOT1_100nm)[-1:-3]<-paste0(colnames(MSGC_PLOT1_100nm)[-1:-3],"_100nm")
colnames(MSGC_PLOT1_VIs  )[-1:-3]<-paste0(colnames(MSGC_PLOT1_VIs  )[-1:-3],"_VIs"  )

##Let's merge these dataframes
MSGC_PLOT1_data<-Reduce(cbind,list(MSGC_PLOT1_005nm
                                          ,MSGC_PLOT1_010nm[-1:-3]
                                          ,MSGC_PLOT1_050nm[-1:-3]
                                          ,MSGC_PLOT1_100nm[-1:-3]
                                          ,MSGC_PLOT1_VIs  [-1:-3]))
###Lets save dataframe
write.csv(MSGC_PLOT1_data    ,"Outputs/2_Imagery/Headwall/Processing/MSGC_PLOT1t_data.csv",row.names = FALSE)


