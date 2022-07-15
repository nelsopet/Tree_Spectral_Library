library(caret)
library(ranger)
library(randomForest)
library(tidyverse)


#------------------Building Model without identifying important variables --------------

# spectral Library
TreeSpecLib_derivs <- read.csv("./Outputs/D_002_SpecLib_Derivs.csv")
colnames(TreeSpecLib_derivs)

# Remove Unwanted columns
# Creates a string of possible names that will be removed
#remove_names<-c("ScanID","Class1","Class2","Class4","Area","Class2_Freq"
#                ,"Class3_Freq","Class4_Freq","Tree_numbe","x","y")
#remove_names<-c(colnames(SpecLib_derivs[,1:6]), colnames(SpecLib_derivs[,8:32]))

TreeSpecLib_derivs <- TreeSpecLib_derivs %>%
  dplyr::select(taxon_code, everything()) %>%
  dplyr::select(-sample_name:-`Columns..2.`) %>%
  rename(Classes = taxon_code) %>%
  mutate(Classes = as.factor(Classes)) %>% 
  as.data.frame()

# Remove Unwanted columns
#SpecLib_derivs[remove_names] = NULL

# Change column name with all the levels to "classes"
#names(SpecLib_derivs)[taxon_code]<-"Classes"
# Converts column to a fctor
#TreeSpecLib_derivs$Classes<-TreeSpecLib_derivs$Classes%>%as.factor()

#Create cal/val split
#rand_col<-sample(seq_len(nrow(TreeSpecLib_derivs)),size = floor(0.75*nrow(TreeSpecLib_derivs)))
#TreeSpecLib_derivs_cal<-TreeSpecLib_derivs[rand_col,]
#TreeSpecLib_derivs_val<-TreeSpecLib_derivs[-rand_col,]
#SpecLib_derivs_cal$randSel<-0
#SpecLib_derivs_val$randSel<-1
#dim(SpecLib_derivs_val)
#dim(SpecLib_derivs_cal)

#SpecLib_derivs_train<-rbind(SpecLib_derivs_val,SpecLib_derivs_cal) %>% as.data.frame()
#hist(SpecLib_derivs_train$randSel)



# Build Model
set.seed(123)

#rf_mod_ranger<- ranger::ranger(Classes ~ .,data = TreeSpecLib_derivs_cal, num.trees = 1000, local.importance = TRUE) # OOB prediction error:19.53 %   
rf_mod_ranger <- ranger::ranger(Classes ~ ., data = TreeSpecLib_derivs, num.trees = 1000, local.importance = TRUE) # OOB prediction error:10.42 %   

rf_mod_ranger

#rf_mod_randomforest<-randomForest(Classes ~ .,data = TreeSpecLib_derivs_cal, ntree=1000,importance=TRUE) # OOB prediction error 26.18%
rf_mod_randomforest <- randomForest(Classes ~ ., data = TreeSpecLib_derivs, ntree = 1000, importance = TRUE) # OOB prediction error 10.42 % 

# build models using 0.99 percent cutoff for correlated variables
# creates correlation matrix
CorelationMatrix <- cor(TreeSpecLib_derivs[-1])
 
# select most correlated variables 
caret_findCorr <- findCorrelation(CorelationMatrix, cutoff = 0.99, names = T)

# remove correlated vars
predictor_df_reduced <- TreeSpecLib_derivs %>%
 dplyr::select(-caret_findCorr)

# rebuild models after intercorrelated vars are removed
rf_mod_randomforest_reduced <- randomForest(Classes ~ ., data = predictor_df_reduced, ntree = 1000, importance = TRUE) # OOB prediction error 23.28%

# saves confusion matrix rf
RandomForest_reduced_confusionmatrix <- rf_mod_randomforest_reduced$confusion %>%
  as.data.frame()
write.csv(RandomForest_reduced_confusionmatrix, "Outputs/RandomForest_reduced_confusionmatrix.csv")

# saves confusion Matrix Ranger
rf_mod_ranger_reduced <- ranger(Classes ~ ., data = predictor_df_reduced,
                     num.trees = 1000,
                     local.importance = TRUE) # OOB prediction error:             17.97 % 

rf_mod_ranger_IMP <- ranger(Classes ~ ., data = predictor_df_reduced,
                     num.trees = 1000,
                     importance = "impurity_corrected",
                     local.importance = TRUE) # OOB prediction error:             23.76 %  

Ranger_reduced_confusionmatrix <- rf_mod_ranger_reduced$confusion.matrix %>%
  as.data.frame.matrix()
write.csv(Ranger_reduced_confusionmatrix,"Outputs/Ranger_reduced_confusionmatrix.csv")


#Make models with all predictors for prediction
rf_mod_ranger_pred <- ranger::ranger(Classes ~ ., data = TreeSpecLib_derivs, num.trees = 1000) # OOB prediction error:10.42 %   

rf_mod_ranger_pred

rf_mod_randomforest_pred <- randomForest(Classes ~ ., data = TreeSpecLib_derivs, ntree = 1000) # OOB prediction error 10.42 % 


# saves the model with the lowest error
save(rf_mod_randomforest_pred, file = "Outputs/Best_Model_RandomForest.rda")

# saves the model with the lowest error
save(rf_mod_ranger_pred, file = "Outputs/Best_Model_Ranger.rda")



#------------------------------ Select Important variables -----------------------------------

# creates a dataframe with all variables and their importance
ImportantVarsFrame <- enframe(rf_mod_ranger_IMP$variable.importance, 
                            name = "predictor", value = "importance")

# creates a plot of the 30 most important vars
ImportantVarsFrame25 <- ImportantVarsFrame[order(ImportantVarsFrame$importance, decreasing = TRUE), ][1:25, ]

# Lets R respect the order in dataframe
ImportantVarsFrame25$predictor <- factor(ImportantVarsFrame25$predictor,
                                         levels = ImportantVarsFrame25$predictor
                                         [order(ImportantVarsFrame25$importance)])

# Creates a plot of the 30 most important variables
ImportantVarsFrame25 %>%
  ggplot(aes(x  = predictor, y = importance)) +
  theme_bw() +
  geom_bar(stat = "identity") +
  coord_flip() +
  ggtitle("25 Most Important Varibles (Class_3)")

ggsave("Outputs/VarImp.png")








