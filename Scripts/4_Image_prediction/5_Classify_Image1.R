# ------------------------------     Classify Image ------------------------------------------
# List of packages to install
# Need to find a way to easily install these
# library(spectrolab)
# library(tidyverse)
# library(raster)
# library(SpaDES)
# library(doParallel)
# library(parallel)
# library(hsdar)
# library(caret)
# library(ranger)
# library(tools)
# library(randomForest)

# Calls the function that will classify image
#source("./Functions/LandCoverEstimator.R")
#source("./Functions/lecospectR.R")
source("./Functions/treespectR.R")


# system.time(PredLayer <- LandCoverEstimator(
#     filename = "Data/test_data/tree_spec_lib_test_raw_14552_rd_rf_or_crop.xml",
#     out_file = "Outputs/test/",
#     #Classif_Model = "Output/E_003_Best_Model_RandomForest_86vars.rda",
#     Classif_Model = "Outputs/Best_Model_Ranger.rda",
#     datatype = "raster",
#     extension = FALSE))


test <- estimate_land_cover(
    input_filepath = "Data/test_data/tree_spec_lib_test_raw_14552_rd_rf_or_crop.dat"
)





