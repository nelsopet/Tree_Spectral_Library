source("./Functions/lecospectR.R")

#test_path <- "./Original_data/Headwall/MSGC_TST_IMG"
test_path <- "./Data/raw_0_rd_rf_or"

terra::rast(test_path)

#model_path <- "./mle/models/gs/b41093de-95ef-4bbc-927e-3e2483eb7e79.rda"

print(date())
quad_results <- estimate_land_cover(
  test_path, 
  output_filepath = "./Outputs/raw_0_tst.grd",
  use_external_bands = TRUE)
closeAllConnections()
print(date())



print(date())
closeAllConnections()
big_results <- estimate_land_cover(
  big_test,
  output_filepath = "./Output/dev_FullCube/bc_north_6425_fncgrp1_PREDICTIONS_grd_corrected_balanced_10tree.grd")
print(date())

test_path_tile<-"./tiles/tile_hQlKJ3NPVHP5zWWD.envi"
test_path_subtile<-"./tiles/tile_1lM1ACWgERzzTdDf.envi"
terra::rast(test_path_subtile) %>% plot()

ml_model<-"./mle/models/gs/62f07a30-dd1e-4621-8752-abafe2803378.rda"
model<-load_model(ml_model)
table(model$predictions)

#band_names<-read.csv("./assets/bands.csv")
        input_raster = raster(test_path_subtile)
        band_count <- raster::nlayers(input_raster)
        bandnames <- read.csv(config$external_bands)$x[1:band_count] %>% as.vector()
        names(input_raster) <- bandnames
terra::rast(test_path_tile) %>% plot()
dev.off()
print(date())
#profvis::profvis(band_count <- raster::nlayers(input_raster)
        bandnames <- read.csv("assets/bands.csv")$x[1:band_count] %>% as.vector()
        names(input_raster) <- bandnames
  tile_results <- process_tile(
    test_path_subtile, 
    ml_model, 
    5,
    cluster = NULL, 
    return_raster = TRUE, 
    band_names = bandnames,
    save_path = "./Outputs/test_path_subtile_save.grd", 
    suppress_output = FALSE)#,
  #interval = 0.01
#)
print(date())

test_out<-terra::rast("./tiles/prediction_hQlKJ3NPVHP5zWWD.envi")
range(test_out)

        raster_obj <- raster::brick(test_path_subtile)
                raster_obj <- terra::rast(test_path_subtile)

        input_crs <- raster::crs(raster_obj)
        print(paste0("preprocessing raster at ", test_path_tile))
        #base_df <- preprocess_raster_to_df(raster_obj, ml_model, band_names=band_names)

                         filter_value <- mean(raster::values(raster_obj), na.rm = TRUE)# NA or 0 is bad

                            if( filter_value == 0 || is.na(filter_value)){
                                return(data.frame())
                            }

                            saved_names <- names(raster_obj)

                        # imputed_raster <- raster::approxNA(
                        #     raster_obj,
                        #     rule = 1
                        # )


                            if(!is.null(band_names)){
                                #try assigning the names to the bands (ignoring extras)
                                try({
                                    names(raster_obj) <- c("x","y",band_names$x)#[1:(length(names(raster_obj))-2),2])
                                    names(raster_obj) <- bandnames[1:(length(names(raster_obj)))]

                                })
                            } else {
                                names(raster_obj) <- saved_names
                            }

                            #print(names(imputed_raster))

                            #rm(raster_obj)

                            df <- raster::rasterToPoints(raster_obj[[3:328]]) %>% as.data.frame()
                            df<-terra::as.points(raster_obj)
                            if(nrow(df) < 1){
                                #return df here as filtering fails later
                                return (df)
                            }
                            print("Converted to Data frame?")
                            print(is.data.frame(df))
                            print(colnames(df))
                            df <- remove_noisy_cols(df, max_index = 326) %>% as.data.frame()
                            print("Noisy columns removed")
                            print(is.data.frame(df))
                            df <- filter_bands(df)
                            print(colnames(df))
        #print(input_crs)
        
        #if(nrow(base_df) < 2){
            #print("The tile has no rows!")
            #print(dim(base_df))
            handle_empty_tile(
                raster_obj,
                save_path = save_path,
                target_crs = input_crs)

            if(!suppress_output){
                if(return_raster){
                    return(raster_obj)
                } else {
                    return(base_df)
                } 

            } 
            #print(save_path)
            return(unlist(save_path))
            # add return value if output is suppressed
        } else {
            # this runs if and only if there is sufficient data
        

                #if there is no data, return the empty tile in the specified format
base_df<-df
            rm(raster_obj)
            gc()
            print(colnames(base_df))
            cleaned_df <- drop_zero_rows(base_df)
            rm(base_df)
            gc()

            cleaned_df_no_empty_cols <- drop_empty_columns(cleaned_df) 
            str(cleaned_df_no_empty_cols)
            veg_indices <- get_vegetation_indices(cleaned_df_no_empty_cols, NULL)#, cluster = cluster)
            head(cleaned_df_no_empty_cols)
            #veg_indices <- get_vegetation_indices(base_df, NULL)#, cluster = cluster)

            try(
                rm(cleaned_df)
            )# sometimes garbage collection gets there first, which is fine
            gc()

            # drop rows that are uniformly zero
          
            resampled_df <- resample_df(
                cleaned_df_no_empty_cols,
                normalize = FALSE,
                max_wavelength = 995.716,
                drop_existing=TRUE)
            gc()

            
            #print("Resampled Dataframe Dimensions:")
            #print(dim(resampled_df))
            #print("Index Dataframe Dimensions:")
            #print(dim(veg_indices))

            df_full <- cbind(
                subset(cleaned_df_no_empty_cols, select=c("x","y")),
                resampled_df,
                veg_indices)
            #print("Input Data Columns")
            #print(summary(df_full))
            imputed_df <- impute_spectra(df_full, method="median", cluster = cluster) %>% as.data.frame()
            #print(colnames(df))
            #df <- df %>% dplyr::select(x, y, dplyr::all_of(target_model_cols)) 
            # above line should not be needed, testing then deleting
            rm(veg_indices)
            rm(resampled_df)
            rm(cleaned_df_no_empty_cols)
            gc()

            if(!is.function(outlier_processing)){
                print(paste0("Handling Outliers with method: ", outlier_processing))
            } else {
                print("Handling Outliers with User supplied function")
            }
            df_no_outliers <- handle_outliers(
                imputed_df,
                outlier_processing=NULL,
                ignore_cols = c("x", "y")
            )
            rm(df_full)

            # replace Inf and NaN values with NA (to be imputed later)
            df_no_outliers <- inf_to_na(df_no_outliers)
                        df_no_outliers <- inf_to_na(imputed_df)

            df_no_outliers[is.nan(df_no_outliers)] <- NA

            if(!is.function(outlier_processing)){
                print(paste0("Transforming the data with transform: ", transform_type))
            } else {
                print("Transforming Data with user supplied functions")
            }
            df_preprocessed <- apply_transform(
                df_no_outliers,
                transform_type,
                ignore_cols = c("x", "y")
            )
            rm(df_no_outliers)
            gc()

            
            #print(summary(df_preprocessed))
            imputed_df_2 <- impute_spectra(
                    #inf_to_na(df_preprocessed),
                    inf_to_na(df_no_outliers),

                    method="median")
            #print(summary(imputed_df_2))

            prediction <- apply_model(
                imputed_df_2,
                model)
            
            prediction <- postprocess_prediction(prediction,df_no_outliers)#df_preprocessed)
            rm(df_preprocessed)
            gc()

            prediction <- convert_and_save_output(
                prediction,
                4,
                save_path = save_path,
                return_raster = TRUE,
                target_crs = input_crs)

            
            raster::crs(prediction) <- input_crs

            if(suppress_output){
                #print(save_path)
                return(unlist(save_path))
            }
            return(prediction)