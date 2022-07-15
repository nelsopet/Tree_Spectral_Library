
###Run LandCoverEstimator to generate Spectral Derivatives.
#source("Functions/LandCoverEstimator.R")
#source("Functions/1_LCE_derivs.R")
#source("Functions/2_LCE_veg_index.R")

# read functions
source("./Functions/tree_veg_index.R")

# make spectral derivatives
make_speclib_derivs("./Outputs/Cleaned_Tree_SpectralLib.csv", out_file = "Outputs/")

