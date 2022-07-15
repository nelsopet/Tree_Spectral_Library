 
########### Function Func_VI

  # function responsible for VegIndex calculations
  Func_VI <- function(VI){
    
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
  
  
  
########### Function Deriv_combine
  
  # function combines both derivatives that are calculated
  Deriv_combine <- function(x){
    
    # resampling data set
    Resampled_data <- Func_Resamp(x)
    
    # calculating VIs for data set
    VegIndex_data <- Func_VI(x)
    
    DF <- cbind(VegIndex_data, metaRemove(Resampled_data))
    
    return(DF)
  } # Deriv_combine ends
  
  
  
  # --------------------- Functions applied to Data cube/Spectral Library ---------------------
  
  
  # function reads in the data and replace/removes weird values
    Make_Speclib_Derivs <- function(filename, out_file)
    {  
    # reads in spectral library as .csv
    # right now your spectral library would have already have weird values removed/replaced
    Spectral_lib <- read.csv(filename, check.names = F)
    
    Spectral_lib <- Deriv_combine(Spectral_lib)
    
    write.csv(Spectral_lib, paste(out_file, "D_002_SpecLib_Derivs", ".csv", sep=""), row.names = F)
    
    # normalize values here
    return(Spectral_lib)
    }
