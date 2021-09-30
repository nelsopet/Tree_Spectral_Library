library(spectrolab)
library(tidyverse)
library(raster)
library(SpaDES)
library(doParallel)
library(parallel)
library(hsdar)
library(caret)
library(ranger)
library(tools)
library(randomForest)


##Make spectral derivatives
###Run LandCoverEstimator to generate Spectral Derivatives.
#source("Functions/LandCoverEstimator.R")
#source("Functions/1_LCE_derivs.R")
source("Functions/2_LCE_veg_index.R")

Make_Speclib_Derivs("./Outputs/Cleaned_Tree_SpectralLib.csv", out_file="Outputs/")

