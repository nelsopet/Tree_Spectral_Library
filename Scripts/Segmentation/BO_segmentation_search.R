require(rgdal)
require(sf)
require(sp)
require(raster)
require(itcSegment)
source("./Scripts/Segmentation/crop_and_classify.R")

delta_t <- 0.2


training_step <- function(params) {
    segments <- itcSegment::itcIMG(
                    imagery = image_data,
                    epsg = 26983,
                    TRESHSeed = thresh_base,
                    TRESHCrown = (thresh_base + delta_t),
                    searchWinSize = window,
                    DIST = dist
                )

    filtered_segments <- filter_segmentation()

    cropped_rasters_auto <- crop_raster_to_shapes(base_raster, filtered_segments)
    cropped_rasters_man <- crop_raster_to_shapes(base_raster, manual_segmentation)

    jaccard_val <- listwise_jaccard(cropped_rasters_auto, cropped_rasters_man)

    return(jaccard_val)
}

num_steps <- 10

for(i = 1:num_steps) {
    params <- 0#fill this in
    Ji <- training_step(params)

    
}