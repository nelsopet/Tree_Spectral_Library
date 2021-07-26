require(rgdal)
require(sf)
require(sp)
require(raster)
require(itcSegment)

# load and project the target image

# plan: finish this and return to original plan
# reduce image size to something smaller with a few segments
# 
# Theme 4 cross-polination w/ theme 1
# week of July 19


# get relevant CRS
# comment of solving this problem
epsg_code <- 26983
target_wkt <- sf::st_crs(epsg_code)[[2]]
print(target_wkt)
target_crs <- sp::CRS(target_wkt)
print(target_crs)

# define tile files for the test
base_tile_path <- paste0(
    getwd(),
    "/Data/raw_15366_rd_rf_or/Tiles/A_001_raw_15366_rd_rf_or_Tile_"
    )
tile_paths <- c(
    paste0(base_tile_path, 16, ".envi"),
    paste0(base_tile_path, 17, ".envi"),
    paste0(base_tile_path, 18, ".envi"),
    paste0(base_tile_path, 19, ".envi"),
    paste0(base_tile_path, 20, ".envi")
)

# define function to merge the tiles and extract the correct band
# should live in general lecospec
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

# load the data from the relevant tiles
test_raster <- merge_tiles(tile_paths)

image_data <- raster::projectRaster(
    test_raster,
    crs = target_crs,
    method = "bilinear")



# should pre-load dataset as input_data object
epsg <- 26983
input_file_path <- "Data/Projected_Test_Raster"
#image_data <- raster::rasterStack(input_file_path)
shapefile_path <- "Data/Shapefiles/15366_crown_delins.shp"

human_tree_shapes <- rgdal::readOGR(
    dsn = shapefile_path,
    layer = "15366_crown_delins",
)

transformed_trees <- sp::spTransform(
    human_tree_shapes, target_crs)

cropped_shape <- raster::crop(
    transformed_trees,
    raster::extent(image_data))

rm(test_raster)
gc()

save_directory <- "Outputs/ImageSegmentationSearch/"
thresholds <- c(0.4, 0.5, 0.6)
threshold_delta <- c(0.05, 0.1, 0.15)
distances <- c(30, 35, 40)
window_sizes <- c(25, 35, 45)
# good question: other wavelengths;
# shelve for later
# could do gradient descent on linear functional from spectra to model input
# regression 
# st_transform (vector-based; shapefile)
# terra <- R raster-like package


for (dist in distances) {
    for (window in window_sizes) {
        for (thresh_base in thresholds) {
            for (delta_t in threshold_delta) {
                # create segmentation 
                segments <- itcSegment::itcIMG(
                    imagery = image_data,
                    epsg = 26983,
                    TRESHSeed = thresh_base,
                    TRESHCrown = (thresh_base + delta_t),
                    searchWinSize = window,
                    DIST = dist
                )

                # create filename for the plot
                plot_filename <- paste(
                    save_directory,
                    "img",
                    window,
                    dist,
                    thresh_base,
                    delta_t,
                    ".png",
                    sep = "_")

                # save plot image
                png(filename = plot_filename)
                plot(image_data)
                plot(segments, border = "blue", add = TRUE)
                plot(cropped_shape, border = "red", add = TRUE)
                dev.off()

                # note the memory management issue
                gc()

           }
        }
    }
}
