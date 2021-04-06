library(caret)
library(ranger)
library(randomForest)
library(tidyverse)

#------------------Building Model without identifying important varibles --------------
# Spectral Library
SpecLib_derivs<-read.csv("Outputs/SpecLib_Derivs.csv")
colnames(SpecLib_derivs)


# Remove Unwanted columns
# Creates a string of possible names that will be removed
#remove_names<-c("ScanID","Class1","Class2","Class4","Area","Class2_Freq"
#                ,"Class3_Freq","Class4_Freq","Tree_numbe","x","y")
remove_names<-c(colnames(SpecLib_derivs[,1:6]), colnames(SpecLib_derivs[,8:32]))
# Remove Unwanted columns
SpecLib_derivs[remove_names] = NULL

# Change column name with all the levels to "classes"
names(SpecLib_derivs)[1]<-"Classes"

# Converts column to a fctor
SpecLib_derivs$Classes<-SpecLib_derivs$Classes%>%as.factor()

rand_col<-sample(seq_len(nrow(SpecLib_derivs)),size = floor(0.75*nrow(SpecLib_derivs)))
SpecLib_derivs_cal<-SpecLib_derivs[rand_col,]
SpecLib_derivs_val<-SpecLib_derivs[-rand_col,]
#SpecLib_derivs_cal$randSel<-0
#SpecLib_derivs_val$randSel<-1
dim(SpecLib_derivs_val)
dim(SpecLib_derivs_cal)

#SpecLib_derivs_train<-rbind(SpecLib_derivs_val,SpecLib_derivs_cal) %>% as.data.frame()
#hist(SpecLib_derivs_train$randSel)

set.seed(123)
# Build Model
rf_mod_ranger<- ranger::ranger(Classes ~ .,data = SpecLib_derivs_cal, num.trees = 1000, local.importance = TRUE) # OOB prediction error:             25.93 %

rf_mod_randomforest<-randomForest(Classes ~ .,data = SpecLib_derivs_cal, ntree=1000,importance=TRUE) # OOB prediction error 26.18%

 # Build models using 0.99 percent cutoff for corelated varibles
 # Creates corelation matrix
 CorelationMatrix<-cor(SpecLib_derivs_cal[-1])
 
 # Select most correlated varibles 
 caret_findCorr<-findCorrelation(CorelationMatrix, cutoff = 0.99, names = T)
 
 # Remove corelated vars
 predictor_df_reduced<-SpecLib_derivs %>%
   dplyr::select(-caret_findCorr)
 
 # Rebuild models after intercorelated vars are removed
 rf_mod_randomforest<-randomForest(Classes ~ .,data = predictor_df_reduced,ntree=1000,importance=TRUE) # OOB prediction error 23.28%
 # Saves confusion matrix rf
 RandomForest_confusionmatrix<-rf_mod_randomforest$confusion%>%as.data.frame()
 write.csv(RandomForest_confusionmatrix,"Outputs/RandomForest_confusionmatrix.csv")
 
 # Saves confuison Matrix Ranger
 rf_mod_ranger<-ranger(Classes ~ .,data = predictor_df_reduced,
                       num.trees = 1000,
                       local.importance = TRUE) # OOB prediction error:             23.76 %
 
 rf_mod_ranger_IMP<-ranger(Classes ~ .,data = predictor_df_reduced,
                       num.trees = 1000,
                       importance = "impurity_corrected",
                       local.importance = TRUE) # OOB prediction error:             23.76 %  
 
 Ranger_confusionmatrix<-rf_mod_ranger$confusion.matrix%>%as.data.frame.matrix()
 write.csv(Ranger_confusionmatrix,"Outputs/Ranger_confusionmatrix.csv")


# saves the model with the lowest error
save(rf_mod_randomforest, file = "Outputs/Best_Model_RandomForest.rda")

# saves the model with the lowest error
save(rf_mod_ranger      , file = "Outputs/Best_Model_Ranger.rda")


#------------------------------ Select Important varibles -----------------------------------
# Creates a dataframe with all varibles and their imoportance
ImportantVarsFrame<-enframe(rf_mod_ranger_IMP$variable.importance, 
                            name="predictor", value="importance")

# Function Creates a plot of the 30 most important vars
ImportantVarsFrame25<-ImportantVarsFrame[order(ImportantVarsFrame$importance,decreasing = TRUE),][1:25,]

# Lets R respect the order in data.frame.
ImportantVarsFrame25$predictor <- factor(ImportantVarsFrame25$predictor,
                                         levels = ImportantVarsFrame25$predictor
                                         [order(ImportantVarsFrame25$importance)])

# Creates a plot of the 30 most important varibles
ImportantVarsFrame25%>%
  ggplot(aes(x  = predictor, y = importance))+
  theme_bw()+
  geom_bar(stat = "identity")+
  coord_flip()+
  ggtitle("25 Most Important Varibles (Class_3)")

ggsave("Outputs/VarImp.jpg")










