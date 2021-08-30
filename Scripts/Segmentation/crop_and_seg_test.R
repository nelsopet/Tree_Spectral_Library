source("Scripts/Segmentation/crop_and_classify.R")


## Messy data loading
# get relevant CRS
# comment of solving this problem
epsg_code <- 26983
target_wkt <- sf::st_crs(epsg_code)[[2]]
target_crs <- sp::CRS(target_wkt)

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


#### Run the Pipeline ####

# define parameters based on grid search
dist <- 40
window <- 41
thresh_base <- 0.6
delta_t <- 0.15

# Perform segmentation
segments <- itcSegment::itcIMG(
    imagery = image_data,
    epsg = 26983,
    TRESHSeed = thresh_base,
    TRESHCrown = (thresh_base + delta_t),
    searchWinSize = window,
    DIST = dist
)

# filter the segmentation
filtered_segments <- filter_segmentation(segments, cropped_shape)



merge_brick <- function(input_files, output_path = NA) {

    master_raster <- as(raster::brick(input_files[[1]]), "RasterBrick")
        print("Extent of first tile:")
        print(raster::extent(master_raster))

    for (input_file in tail(input_files, -1)) {
        new_raster <- as(raster::brick(input_file), "RasterBrick")
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


base_raster_brick <- merge_brick(tile_paths)
projected_brick <- raster::projectRaster(
    base_raster_brick,
    crs = target_crs,
    method = "bilinear"
)
spectra <- extract_segments_spectra(projected_brick, filtered_segments)

plot(spectra[[1]])


## To do: Move lecospec funcitonality to move
# 1. Pull tree reposito