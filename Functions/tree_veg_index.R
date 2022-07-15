require(spectrolab)
require(tidyverse)
require(doParallel)
require(parallel)
require(hsdar)


#' This function performs vegetation index calculations
#'
#' Long description
#'
#' @return 
#' @param VI: A cleaned spectra dataframe
#' @seealso None
#' @export 
#' @examples Not yet implemented

calc_vegindex <- function(VI){
  
  print("Calculating Vegitation Indices")
  
  # converts dataframe to matrix before VIs can be applied
  matrix_a <- as.matrix(metaRemove(VI))
  
  # creates numeric vector of wavelengths
  namescolumn <- metaRemove(VI) %>%
    colnames() %>%
    as.numeric()
  
  # creates a spectralib object
  spec_library <- hsdar::speclib(matrix_a, namescolumn)
  
  # creates a vector of names of all the vegetation indices
  AVIRIS_VI <- hsdar::vegindex()[-58]
  Headwall_VI <- hsdar::vegindex()[-c(3,26,27,31,32,33,35,48,49,58,60,66,67,71,82,99,102,103,104,105)]
  
  # get amount of cores to use
  cores <- parallel::detectCores()-1
  
  # prepare for parallel process
  c1 <- parallel::makeCluster(cores, setup_timeout = 0.5)
  doParallel::registerDoParallel(c1)
  
  
  # creates dataframe with vegetation indices
  VI_CALC <- if(ncol(metaRemove(VI)) == 272){
    foreach(i = 1:length(Headwall_VI), .combine = cbind, .packages = 'hsdar') %dopar%{
      a <- hsdar::vegindex(spec_library, index = Headwall_VI[[i]])}
    
  } else {
    foreach(i = 1:length(AVIRIS_VI), .combine = cbind, .packages = 'hsdar') %dopar%{
      a <- hsdar::vegindex(spec_library, index = AVIRIS_VI[[i]])}
  }
  
  # stops cluster
  parallel::stopCluster(c1)
  
  # converts matrix to a dataframe 
  VI_CALC <- as.data.frame(VI_CALC)
  
  # function renames columns
  if(ncol(VI_CALC) == 95){
    names(VI_CALC) <- Headwall_VI
  } else {
    names(VI_CALC) <- AVIRIS_VI}
  
  # function removes spaces and special characters from column names
  # models will not run if these aren't removed
  names(VI_CALC) <- str_remove_all(names(VI_CALC), "[[:punct:]]| ")
  
  # combines VIs and Lat/long info
  VI_DF <- cbind(bandsRemove(VI), VI_CALC)
  
  print("Vegitation index calculations successful")
  
  return(VI_DF)
} # Func_VI ends




#' Function returns columns that are bandpasses
#'
#' Long description
#'
#' @return 
#' @param x: A cleaned spectra dataframe
#' @seealso None
#' @export 
#' @examples Not yet implemented

metaRemove <- function(x){
  
  meta <- c(grep("^[0-9][0-9][0-9]", colnames(x)))
  
  colremove <- x[ , meta]
  
  return(colremove)
}



#' Function returns columns that are not bandpasses
#'
#' Long description
#'
#' @return 
#' @param x: A cleaned spectra dataframe
#' @seealso None
#' @export 
#' @examples Not yet implemented

bandsRemove <- function(x){
  
  meta <- c(grep("[a-z A-Z]", colnames(x)))
  
  colremove <- x[ , meta]
  
  return(colremove)
}




#' Function performs resampling
#'
#' Long description
#'
#' @return 
#' @param x: A cleaned spectra dataframe
#' @seealso None
#' @export 
#' @examples Not yet implemented

spectra_resamp <- function(x){
  
  # removes metadata before function can be applied
  df <- metaRemove(x)
  
  # converts the dataframe to a spectral object
  SpeclibObj <- spectrolab::as_spectra(df)
  
  print("Resampling spectra every 5nm")
  
  # creates functions that will do the resampling every 5nm
  final <- spectrolab::resample(SpeclibObj, seq(397.593, 899.424, 5)) %>%
    as.data.frame() %>%
    dplyr::select(-sample_name)
  
  # rename columns
  colnames(final) <- paste(colnames(final), "5nm", sep = "_")
  
  # combines all the dataframes created into one df
  ResampledDF <- cbind(bandsRemove(x), final)
  
  print("Resampling sucessful")
  
  return(ResampledDF)
}





#' Function combines both derivatives that are calculated
#'
#' Long description
#'
#' @return 
#' @param x: A cleaned spectra dataframe
#' @seealso None
#' @export 
#' @examples Not yet implemented

deriv_combine <- function(x){
  
  # resampling data set
  resampled_data <- spectra_resamp(x)
  
  # calculating VIs for data set
  VegIndex_data <- calc_vegindex(x)
  
  output <- cbind(VegIndex_data, metaRemove(resampled_data))
  
  return(output)
}





# --------------------- Functions applied to Data cube/Spectral Library ---------------------


#' Function reads in the data and replace/removes weird values
#'
#' Long description
#'
#' @return 
#' @param filename: A cleaned spectra library in .csv format
#' @param out_file: directory where outputs from this function can be written
#' @seealso None
#' @export 
#' @examples Not yet implemented

make_speclib_derivs <- function(filename, out_file) { 
  
  # reads in spectral library as .csv
  # right now your spectral library would have already have weird values removed/replaced
  spectral_lib <- read.csv(filename, check.names = F)
  
  spectral_lib <- deriv_combine(spectral_lib)
  
  write.csv(spectral_lib, paste(out_file, "D_002_SpecLib_Derivs", ".csv", sep = ""), row.names = F)
  
  # normalize values here
  return(spectral_lib)
}
