require(rgdal)
require(sp)
require(sf)

library(tidyverse)
library(raster)
library(itcSegment)


# Load the data
input_file_path <- "Data/MSGC_TST_IMG"

data_brick <- raster::stack(input_file_path)
data_crs <- raster::projection(data_brick, asText = FALSE)
data_res <- raster::res(data_brick)
print(data_crs)

# select 812nm band & plot it
layer_id <- 225
print(names(data_brick[[layer_id]]))
raster::plot(as(data_brick[[layer_id]], "RasterLayer"))

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
    data_brick[[layer_id]],
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
    DIST = min_distance)


plot(projected_raster)
plot(tree_segments, add = TRUE)
