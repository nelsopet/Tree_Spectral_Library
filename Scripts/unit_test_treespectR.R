# Starting up
source("./Functions/treespectR.R")


#------------------------------------------------# 
####           estimate_land_cover            ####
#------------------------------------------------#

input_filepath = "Data/test_data/tree_spec_lib_test_raw_14552_rd_rf_or_crop.dat"
config_path = "./config.json"
output_filepath =  paste("output-", format(Sys.time(), "%a-%b-%d-%H-%M-%S-%Y"), ".envi", sep = "")
use_external_bands = TRUE

path <- getwd()
config <- rjson::fromJSON(file = config_path)
model <- load_model(config$model_path)
input_raster <- raster::brick(input_filepath)

input_crs <- raster::crs(input_raster)

input_extent <- raster::extent(input_raster)

bandnames <- names(input_raster)

band_count <- raster::nlayers(input_raster)
  
bandnames <- read.csv(config$external_bands)$x[1:band_count] %>% as.vector()
  
names(input_raster) <- bandnames

num_tiles_x <- config$x_tiles

num_tiles_y <- config$y_tiles

tile_filenames <- make_tiles(
  input_raster,
  num_x = num_tiles_x,
  num_y = num_tiles_y,
  save_path = config$tile_path,
  #cluster = cl,
  verbose = FALSE)

gc()

prediction_filenames <- lapply(
  tile_filenames,
  function(tile_filename){
    
    return(.convert_tile_filename(tile_filename))
  }) %>% as.vector()

tile_results <- vector("list", length = length(tile_filenames))


# PROCESS TILE FAILS
tile_result <- process_tile(
    tile_filename = tile_filenames[[1]],
    ml_model = model, 
    aggregation = config$aggregation,
    #cluster = cl,
    return_raster = TRUE,
    band_names = bandnames,
    return_filename = TRUE,
    save_path = prediction_filenames[[1]],
    suppress_output = TRUE)
  
  
# Since process tile fails lets look at it specifically


#------------------------------------------------# 
####              process_tile                ####
#------------------------------------------------# 
  
tile_filename = tile_filenames[[1]]
ml_model = model
aggregation = config$aggregation
return_raster = TRUE
band_names = bandnames
return_filename = TRUE
save_path = prediction_filenames[[1]]
suppress_output = TRUE

  
  raster_obj <- raster::brick(tile_filename)
  input_crs <- raster::crs(raster_obj)
  base_df <- preprocess_raster_to_df(raster_obj, ml_model, band_names=band_names)

  
    
    gc()
    
    cleaned_df <- drop_zero_rows(base_df)
    
    #rm(base_df)
    
    gc()
    
    cleaned_df_no_empty_cols <- drop_empty_columns(cleaned_df)
    
    imputed_df <- impute_spectra(cleaned_df_no_empty_cols)
    
    gc()
    
    ## ADDED TO PIPELINE TO REMOVE X + Y cols by KAL
    # The next function, resample_df, will not run with these columns
    imputed_df <- imputed_df %>% dplyr::select(-c(x, y))
    # lgl_index <- substr(x = names(df), 
    #                     start = nchar(names(df)), 
    #                     stop  = nchar(names(df))) %in% c("1", "2", "3", "4", "5", "6", "7", "8", "9")
    # 
    # imputed_df <- imputed_df %>% dplyr::select(which(lgl_index))
    ## End of KAL addition
    
    resampled_df <- resample_df(imputed_df)
    
    gc()
    
    ## Runs, but NA rows produced for select columns!! Why??
    veg_indices <- get_vegetation_indices(resampled_df, ml_model)
    
    print("Resampled Dataframe Dimensions:")
    
    print(dim(resampled_df))
    
    print("Index Dataframe Dimensions:")
    
    print(dim(veg_indices))
    
    df <- cbind(resampled_df, veg_indices)
    
    #df <- df %>% dplyr::select(x, y, dplyr::all_of(target_model_cols)) 
    # above line should not be needed, testing then deleting
  
    
    gc()
    
    imputed_df_full <- impute_spectra(df, method="median")
    
    prediction <- apply_model(imputed_df_full, ml_model)
    
    rm(df)
    
    gc()
    
    prediction <- postprocess_prediction(prediction, imputed_df_full)
    
    prediction <- convert_and_save_output(
      prediction,
      aggregation,
      save_path = save_path,
      return_raster = return_raster,
      target_crs = input_crs)
    
    raster::crs(prediction) <- input_crs
    
    if(suppress_output){
      print(save_path)
      return(unlist(save_path))
    }
    return(prediction)
  }
}







get_vegetation_indices <- function(
    df,
    ml_model,
    cluster = NULL) {
  
  target_indices <- get_required_veg_indices(ml_model)
  # Creates a new model built on important variables
  # Initialize variable
  veg_indices <- NULL
  
  spec_library <- df_to_speclib(df)
    
    # sequential calculation
    veg_indices <- foreach(
      i = seq_along(target_indices),
      .combine = cbind,
      .packages = c("hsdar","spectrolab")) %do% {
        a <- hsdar::vegindex(
          spec_library,
          index = target_indices[[3]],
          weighted = FALSE)
      }

  #colnames(veg_indices) <- target_indices
  index_df <- veg_indices %>% as.data.frame()
  
  #print(veg_indices)
  colnames(index_df) <- clean_colnames(target_indices)


