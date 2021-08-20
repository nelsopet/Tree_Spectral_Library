require(raster)
require(rgdal)
require(sp)
require(sf)

#' crops a given raster opject to a shapefile
#'
#' Long Description here
#'
#' @inheritParams None
#' @return A raster object, cropped to fit inside the given
#' spatialPolygonsDataFrame
#' @param rsater_obj: A raster object
#' (RasterLayer, RasterStack, or RasterBrick).
#' @param spdf: A SpatialPolygonsDataFrame.
#' @param epsg: An epsg code for the output raster (optional).
#' If epsg is not given, the two inputs are assumed to have the same
#' projection/crs.
#'
#' If epsg is provided, the inputs will be projected to that epsg code
#' and then cropped.
#' @seealso None
#' @export 
#' @examples Not Yet Implmented
#'
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

#' crops a raster to each polygon in a SpatialPolygonsDataFrame individually
#' 
#' Crops a raster object to each polygon in a SpatialPolygonsDataFrame
#' individually, and returns the results in a list.  Raster objects
#' will tbe the same type as the input raster, except that RasterStacks may
#' be converted to other types.  Also handles projection of the inputs
#' to the same projection scheme if an EPSG code is provided.
#' 
#' @inheritParams None
#' @return list cropped raster objects
#' @param rsater_obj: A raster object 
#' (RasterLayer, RasterStack, or RasterBrick).  
#' @param spdf: A SpatialPolygonsDataFrame.  
#' @param epsg: An epsg code for the output raster (optional).
#' If epsg is not given, the two inputs are assumed to have the same 
#' projection/crs.  If epsg is provided, the inputs will be projected 
#' to that epsg code and then cropped.
#' @seealso None
#' @export 
#' @examples Not Yet Implmented
#' 
crop_raster_to_shapes <- function(raster_obj, spdf, epsg = NA) {
    num_polygons <- nrow(spdf)
    cropped_rasters <- list()
    # if an EPSG is specified, project the object to that CRS
    if (!is.na(epsg)) {
        target_wkt <- sf::st_crs(epsg)[[2]]
        target_crs <- sp::CRS(target_wkt)
        projected_ras <- raster::projectRaster(
            raster_obj,
            crs = target_crs,
            method = "bilinear")

        projected_spdf <- sp::spTransform(spdf, target_crs)
        # then add the cropped raster to the list
        for (i in seq_len(num_polygons)) {
            cropped_ras <- crop_raster_to_shape(
                projected_ras,
                projected_spdf[i,])
            append(cropped_rasters, cropped_ras)
        }
        # if no EPSG is specified, just crop
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

#' Calculates the simple accuracy of a raster object against
#' a sinlge target value
#' 
#' Long Description here
#' 
#' @inheritParams None
#' @return accuracy score (floating point number)
#' @param raster_obj: A rasterLayer object
#' @param ground_truth_label: the correct label; 
#' assumes that this applies to all of the pixels in the raster
#' @seealso None
#' @export 
#' @examples Not Yet Implmented
#' 
raster_uniform_acc <- function(
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

#' gets the centroids for a SpatialPolygonsDataFrame
#' 
#' this function is a wrapped on rgeos::gCentroid() that enables
#' faster computation and applies to each polygon in a 
#' SpatialPolygonsDataFrame individually
#' 
#' @inheritParams None
#' @return The center of each polygon in a SpatialPolygonsDataFrame
#' @param shapes: A SpatialPolygonsDataFrame of shapes
#' @seealso None
#' @export 
#' @examples Not Yet Implmented
#' 
get_centroids <- function(shapes) {
    centroids <- apply(
        shapes,
        FUN = rgeos::gCentroid
    )
    return(centroids)
}


#' Calculates the Euclidian 
#' 
#' Long Description here
#' 
#' @inheritParams None
#' @return explanation
#' @param
#' @seealso None
#' @export 
#' @examples Not Yet Implmented
#' 
euclidean_distance <- function(x1, x2, y1, y2) {
    delta_x_squared <- (x1 - x2)^2
    delta_y_squared <- (y1 - y2)^2
    distance <- sqrt(delta_x_squared + delta_y_squared)
    return(distance)
}


# define a helper function; finds minimum in each row of a matrix
min.col <- function(m, ...) max.col(-m, ...)

#' Finds the nearest neighbor centroids between two lists of centroids
#' 
#' Long Description here
#' 
#' @inheritParams None
#' @return explanation
#' @param
#' @seealso None
#' @export 
#' @examples Not Yet Implmented
#' 
match_centroids <- function(predicted, targets) {
    num_targets <- length(targets)
    num_pred <- length(predicted)
    distances <- matrix(nrow=num_targets, ncol=num_pred)

    for(i in seq_len(num_targets)){
        for(j in seq_len(num_pred)) {
            distances[[i,j]] <- euclidean_distance(
                targets[[i,1]],
                predicted[[j,1]],
                targets[[i,2]],
                predicted[[j,2]]
            )
        }
    }
    closest_polygon_idxs <- min.col(distances)
    return(closest_polygon_idxs)
}

#' filters tree segmentation to target list for comparison
#' 
#' Long Description here
#' 
#' @inheritParams None
#' @return explanation
#' @param
#' @seealso None
#' @export 
#' @examples Not Yet Implmented
#' 
filter_segmentation <- function(predicted, targets) {
    target_centroids <- get_centroids(targets)
    predicted_centroids <- get_centroids(predicted)
    idxs <- match_centroids(predicted_centroids, target_centroids)
    return(predicted[idxs])
}

extract_segments_spectra <- function(raster_obj, )