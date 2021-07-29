require(raster)
require(rgdal)
require(sp)
require(sf)

crop_raster_to_shape <- function(raster_obj, spdf, epsg = NA) {
    if(!is.na(epsg)) {
        target_wkt <- sf::st_crs(epsg)[[2]]
        target_crs <- sp::CRS(target_wkt)
        projected_ras <- raster::projectRaster(
            raster_obj, 
            crs = target_crs,
            method = "bilinear")
        projected_spdf <- sp::spTransform(spdf, target_crs)
        cropped_ras <- raster::crop(projected_ras, projected_spdf)
        return(cropped_ras)
    } else {
        return(raster::crop(raster_obj, spdf))
    }
}

crop_raster_to_shapes <- function(raster_obj, spdf, epsg = NA) {
    num_polygons <- nrow(spdf)
    cropped_rasters <- list()
    if (!is.na(epsg)) {
        target_wkt <- sf::st_crs(epsg)[[2]]
        target_crs <- sp::CRS(target_wkt)
        projected_ras <- raster::projectRaster(
            raster_obj, 
            crs = target_crs,
            method = "bilinear")

        projected_spdf <- sp::spTransform(spdf, target_crs)
        
        for (i in seq_len(num_polygons)) {
            cropped_ras <- crop_raster_to_shape(
                projected_ras,
                projected_spdf[i,])
            append(cropped_rasters, cropped_ras)
        }
    } else {
        for (i in seq_len(num_polygons)) {
            cropped_ras <- crop_raster_to_shape(
                raster_obj,
                spdf[i,])
            append(cropped_rasters, cropped_ras)
    
        }
    }
    return(cropped_rasters)
}

get_raster_uniform_acc <- function(
    raster_obj,
    ground_truth_label
    ) {
    # convert raster to data.frame
    # compare each entry to target
    # return num_correct / nrows(df)
    df <- raster::rasterToPoints(raster_obj)
    num_pts <- nrow(df)
    target_col_name <- colnames(df)[[3]] 
    num_correct <- nrow(dplyr::filter(
        df, 
        target_col_name == ground_truth_label)
        )
    return(num_correct / num_pts)
}