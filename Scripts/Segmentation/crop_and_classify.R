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
#' @param raster_obj: A raster object
#' (RasterLayer, RasterStack, or RasterBrick).
#' @param spdf: A SpatialPolygonsDataFrame.
#' @param epsg: An epsg code for the output raster (optional).
#' If epsg is not given, the two inputs are assumed to have the same
#' projection/crs.
#'
#' If epsg is provided, the inputs will be projected to that epsg code
#' and then cropped.
#' 
#' @seealso None
#' @export 
#' @examples Not Yet Implmented
#'
crop_raster_to_shape <- function(
    raster_obj,
    spdf,
    epsg = NA,
    method="bilinear"
    ){
    if(!is.na(epsg)) {
        target_wkt <- sf::st_crs(epsg)[[2]]
        target_crs <- sp::CRS(target_wkt)
        projected_ras <- raster::projectRaster(
            raster_obj,
            crs = target_crs,
            method = method)
        projected_spdf <- sp::spTransform(spdf, target_crs)
        cropped_ras <- raster::crop(projected_ras, projected_spdf)
        return(cropped_ras)
    } else { #this is likely source of error; add CRS validation
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
            print(paste0("Cropping Raster to Polygon ", i))
            cropped_ras <- crop_raster_to_shape(
                projected_ras,
                projected_spdf[i,])
            cropped_rasters <- append(cropped_rasters, cropped_ras)
        }
        # if no EPSG is specified, just crop
    } else {
        for (i in seq_len(num_polygons)) {
            print(paste0("Cropping Raster to Polygon ", i))
            cropped_ras <- crop_raster_to_shape(
                raster_obj,
                spdf[i, ])
            cropped_rasters <- append(cropped_rasters, cropped_ras)
        }
    }
    print(paste0("Returning List of Rasters of length ", length(cropped_rasters)))
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
    # return num_correct / nrow(df)
    df <- raster::rasterToPoints(raster_obj, target_col = 3)
    num_pts <- nrow(df)
    target_col_name <- colnames(df)[[target_col]]
    num_correct <- nrow(dplyr::filter(
        df,
        target_col_name == ground_truth_label)
        )
    # ADD: confusion matrix for segemented tree
    return(num_correct / num_pts)
}

segmentation_mode <- function(raster_obj, target_col = 3) {
    df <- raster::rasterToPoints(raster_obj)
    majority_val <- mode(df[[target_col]])
    return(majority_val)
}

#' gets the centroids for a SpatialPolygonsDataFrame
#' 
#' this function is a wrapper on rgeos::gCentroid() that enables
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
    centroids <- rgeos::gCentroid(shapes, byid = TRUE)
    return(as.data.frame(centroids))
}


#' Calculates the Euclidian distance between two (x,y) points.
#' 
#' Calculates the PLANAR euclidean distance between two (x,y) points.
#' Assumes a planar (flat, distance-based) projection is used, 
#' NOT an angular, curved, or 3D one.
#' E.g. NO WSG!  Won't give the correct distances from degree-based measures
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
} # replace with something from geospatial packages?
# dist function is 

#' Finds the minimum of a column 
#' 
#' A helper function complementary to max.col.
#' Returns the minimum of a column from a data.frame.
#' See max.col for more information
#' 
#' @inheritParams None
#' @return explanation
#' @param m
#' @seealso max.col()
#' @export 
#' @examples Not Yet Implmented
#' 
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
            distances[[i, j]] <- euclidean_distance(#use dist instead?
                targets[[i, 1]],
                predicted[[j, 1]],
                targets[[i, 2]],
                predicted[[j, 2]]
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
    idxs <- match_centroids(
        predicted_centroids,
        target_centroids)
    return(predicted[idxs])
}


#' Extracts the spectra based on the center of the segmentation
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
extract_center_segments_spectra <- function(raster_obj, segments) {
    centroid_points <- get_centroids(segments)
    raster_points <- raster::rasterToPoints(raster_obj)
    closest_pixels_to_centroids <- match_centroids(
        centroid_points,
        raster_points)
    extracted_spectra <- raster_points[closest_pixels_to_centroids, ]

    return(extracted_spectra)
}

#' Extracts the spectra based on the center of the segmentation
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
assign_segments_to_mode_class <- function(raster_obj_list, target_col = 3) {
    
}

#' Extracts the spectra based on the center of the segmentation
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
extract_pixels_near_center <- function(raster_obj, centroid_x, centroid_y, epsilon=999) {
    raster_df <- raster::rasterToPoints(raster_obj)
    raster_df$dist <- raster_df %>% apply(
        FUN = function(row){
            euclidean_distance(row[[1]], centroid_x, row[[2]], centroid_y)
    }) %>%

    raster_df <- dplyr::filter(raster_df, raster_df$dist < epsilon)
     
     return(raster_df)
}

spatial_filter_map <- function(raster_obj, centroids, epsilon=999) {
    centroid_df <- as.data.frame(centroids)
    num_points <- nrow(centroid_df)
    df_list <- list()
    for (point_index in seq(num_points)) {
        centroid_x <- centroid_df[[point_index, 1]]
        centroid_y <- centroid_df[[point_index, 2]]
        extracted_pixel_df <- extract_pixels_near_center(
            raster_obj = raster_obj, 
            centroid_x = centroid_x,
            centroid_y = centroid_y,
            epsilon = epsilon
            )
        append(df_list, extracted_pixel_df)
    }
    results_df <- condense_df_list(
        filter_empty_dfs(
            df_list
        )
    )
    return(results_df)
}

#' Returns the satistical mode of a vector/data.frame column
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
stat_mode <- function(vec) {
    mode_val <- names(which.max(table(vec)))
    # return the mode as the same data type as the input
    if(is.numeric(vec)) {
        return(as.numeric(mode_val))
    } else {
        return(mode_val)
    }
}

#' removes empty data.frames from a list of data frames.  
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
filter_empty_dfs <- function(list_of_dfs) {
    nonempty_dfs <- list()
    num_entries <- length(list_of_dfs)
    print(num_entries)
    for (list_index in seq(num_entries)) {
        print(list_of_dfs[[list_index]])
        if (nrow(list_of_dfs[[list_index]]) > 0) {
            append(nonempty_dfs, list_of_dfs[[list_index]])
        }
    }
}

#' Takes a list of data.frames and rbinds them into one data.frame.
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
condense_df_list <- function(list_of_dfs) {
    num_entries <- length(list_of_dfs)
    output_df <- list_of_dfs[[1]]
    for (list_index in seq(num_entries-1)) {
        output_df <- rbind(output_df, list_of_dfs[[(1+list_index)]])
    }
    return(output_df)
}

#' Extracts the spectra based on the center of the segmentation
#' 
#' Long Description here
#' 
#' @inheritParams None
#' @return explanation
#' @param raster_obj: a raster object (RasterLayer, RasterBrick, or RasterStack)
#' @param segments: segmentation results, a spatialPolygonsDataFrame
#' @seealso None
#' @export 
#' @examples Not Yet Implmented
#' 
extract_spectra_by_radius <- function(raster_obj, segments, threshold = 1000) {
    centroids <- get_centroids(segments)
    raster_list <- crop_raster_to_shapes(
        raster_obj = raster_obj, 
        spdf = segments)
    extracted_pixel_dfs <- list()
    for(c_index in seq(length(centroids))) {
        list_of_pixel_dfs <- lapply(raster_list, FUN = function(x) {
            return(
                spatial_filter_map(as.data.frame(
                    x,
                    centroids = centroids,
                    epsilon = threshold
                    )
                )
            )
        })
        nonempty_dfs <- filter_empty_dfs(list_of_pixel_dfs)
        pixels_extracted <- condense_df_list(nonempty_dfs)
        append(extracted_pixel_dfs, pixels_extracted)
    }
    pixel_df <- condense_df_list(extracted_pixel_dfs)
    return(pixel_df)
}


extract_spectra <- function(raster_obj, segments) {
    cropped_ras <- crop_raster_to_shapes(raster_obj, segments)
    print(paste0("List of Cropped Rasters has length ", length(cropped_ras)))
    spectra_df_list <- lapply(
        cropped_ras,
        raster::rasterToPoints
    )
    print(paste0("List of spectral data-frames has length", length(spectra_df_list)))
    spectra_df <- condense_df_list(spectra_df_list)
    return(spectra_df)
}

get_raster_mode <- function(raster_obj) {
    raster_df <- raster::rasterToPoints(raster_obj)
    mode_val <- stat_mode(raster_df[[3]])
    return(mode_val)
}
