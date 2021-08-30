require(rgdal)
require(sp)
require(sf)

library(tidyverse)
require(raster)
require(itcSegment)


# Load the data
#input_file_path <- "Data/MSGC_TST_IMG"
input_file_path <- "Data/raw_15366_rd_rf_or/raw_15366_rd_rf_or_PredLayer.tif"

data_brick <- raster::stack(input_file_path)
data_crs <- raster::projection(data_brick, asText = FALSE)
data_res <- raster::res(data_brick)
print(data_crs)

# select 812nm band & plot it
layer_id <- 225
print(names(data_brick[[layer_id]]))
plot(data_brick)



# useful EPSG codes can be found in Data/useful_speg_codes.txt
# this code is for base WGS84;
# there are four other WGS84 codes and many Maine NAD83 codes
# be sure to select the correct one for your application
# equal-area projection 2163 for ITC segment
# NAD83 Maine: epsg:26983
epsg_code <- 26983
target_wkt <- sf::st_crs(epsg_code)[[2]]
print(target_wkt)
target_crs <- sp::CRS(target_wkt)
print(target_crs)

# projection from other script; appears to be inconsistent with ITC-Segment
# This line is too long but it's all one string
new_prj <- "+proj=aea +lon_0=-69.609375 +lat_1=43.0460393 +lat_2=51.3106043 +lat_0=47.1783218 +datum=WGS84 +units=m +no_defss"
new_prj <- crs(new_prj)


# project the data to the new CRS
projected_raster <- raster::projectRaster(
    data_brick,
    crs = target_crs,
    method = "bilinear")

# test that the resolutions are the same after projection
print("Old Resolution:")
print(raster::res(data_brick[[layer_id]]))
print("New Resolution:")
print(raster::res(projected_raster))

raster::plot(projected_raster)


# set the model parameters
search_window_size <- 21
min_distance <- 15

# run segmentation
tree_segments <- itcSegment::itcIMG(
    imagery = as(projected_raster, "RasterLayer"),
    epsg = epsg_code,
    searchWinSize = search_window_size,
    TRESHSeed = 0.5,
    TRESHCrown = 0.6,
    DIST = min_distance)


plot(projected_raster)
plot(tree_segments, add = TRUE)


# load the shapefile
shapefile_path <- "Data/Shapefiles/15366_crown_delins.shp"

human_tree_shapes <- rgdal::readOGR(
    dsn = shapefile_path,
    layer = "15366_crown_delins",
)

transformed_trees <- sp::spTransform(
    human_tree_shapes, target_crs)
plot(transformed_trees, add = TRUE)

merge_tiles <- function(input_files, output_path = NA) {

    master_raster <- as(raster::brick(input_files[[1]])[[225]], "RasterLayer")
        print("Extent of first tile:")
        print(raster::extent(master_raster))

    for (input_file in tail(input_files, -1)) {
        new_raster <- as(raster::brick(input_file)[[225]], "RasterLayer")
        print("Extent of tile:")
        print(raster::extent(new_raster))
        master_raster <- raster::merge(
            master_raster,
            new_raster,
            tolerance = 0.5)
        
    }
    if(!is.na(output_path)) {
        raster::writeRaster(master_raster, output_path)
    }

    return(master_raster)
}

base_tile_path <- paste0(
    getwd(),
    "/Data/raw_15366_rd_rf_or/Tiles/A_001_raw_15366_rd_rf_or_Tile_"
    )
tile_paths <- c(
    paste0(base_tile_path, 15, ".envi"),
    paste0(base_tile_path, 16, ".envi"),
    paste0(base_tile_path, 17, ".envi"),
    paste0(base_tile_path, 18, ".envi"),
    paste0(base_tile_path, 19, ".envi"),
    paste0(base_tile_path, 20, ".envi")
)

master_raster <- merge_tiles(tile_paths)
raster::writeRaster(master_raster, "merged_test_tiles_15366", overwrite = TRUE)


base_tile_path <- paste0(
    getwd(),
    "/Data/raw_15366_rd_rf_or/Tiles/A_001_raw_rd_rf_or_Tile_"
    )
tile_paths <- c(
    paste0(base_tile_path, 16, ".envi"),
    paste0(base_tile_path, 17, ".envi"),
    paste0(base_tile_path, 18, ".envi"),
    paste0(base_tile_path, 19, ".envi"),
    paste0(base_tile_path, 20, ".envi")
)

dev.off()
plot(master_raster)

transformed_master_raster <- raster::projectRaster(
    master_raster,
    crs = target_crs,
    method = "bilinear")


cropped_shape <- raster::crop(
    transformed_trees,
    raster::extent(transformed_master_raster))

plot(transformed_master_raster)
plot(cropped_shape, add = TRUE)

raster::writeRaster(
    transformed_master_raster,
    "merged_test_tiles_projected")

