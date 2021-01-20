#######################Creates models from field spec data resapmepled on headwall bandpasses######################################
library(tidyverse)
library(randomForest)
library(randomForestExplainer)

###Reads in all predictors for scans
MSGC_PLOT1_data<-read.csv("Outputs/2_Imagery/Headwall/Processing/MSGC_PLOT1t_data.csv")

##we'll need to apply a function to all dataframes that omits unwanted metadata
MSGC_PLOT1_data [c("x","y")] = NULL

set.seed(2017)
##Lets run some different models so we can asses whiich ones are the best for prediction later
rf_MSGC   <-randomForest(species~.,data=MSGC_PLOT1_data       ,mtry=sqrt(ncol(MSGC_PLOT1_data       )),ntree=1001,localImp = TRUE)

##lets save all these models
save(rf_MSGC   , file = "Outputs/2_Imagery/Headwall/Models/rf_MSGC   .rda")

##First we want to take a look at the distribution of minimal depth 
min_depth_frame_rf_MSGC    <- min_depth_distribution(rf_MSGC    )

##Lest grab the most relevant/ important variables
rf_VIs_plot50     <-plot_min_depth_distribution(min_depth_frame_rf_MSGC     , min_no_of_trees = 200, mean_sample = "relevant_trees", k= 50)

##Lets take the 10,25 and 50 most important variables and rebuild our models
rf_MSGC_plot50n     <-unique(rf_VIs_plot50$data$variable)%>%as.character()

##Lets subsET our spectral library to have just those variables
MSGC_PLOT1_data50<-MSGC_PLOT1_data %>%dplyr::select(species,rf_MSGC_plot50n     )

##Now we can rebuild our model
rf_MSGC50   <-randomForest(species~.,data=MSGC_PLOT1_data50       ,mtry=sqrt(ncol(MSGC_PLOT1_data50       )),ntree=1001,localImp = TRUE)

##lets save all these models
save(rf_MSGC50, file = "Outputs/2_Imagery/Headwall/Models/rf_MSGC50.rda")

##Lets create a data frame that will combine the class.error of all the categories of each model
rf_MSGC50_ConfusionMatrix   <-rf_MSGC50   $confusion%>%as.data.frame()

write.csv(rf_MSGC50_ConfusionMatrix,"Outputs/2_Imagery/Headwall/Models/rf_MSGC50_ConfusionMatrix.csv")





















