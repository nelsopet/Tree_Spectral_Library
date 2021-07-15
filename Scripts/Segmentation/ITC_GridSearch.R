require(rgdal)
require(sf)
require(sp)
require(raster)
require(itcSegment)

# assumes that the file is projected and ready to go



# should pre-load dataset as input_data object
epsg <- 26983
input_file_path <- "Data/Projected_Test_Raster"
image_data <- raster::rasterStack(input_file_path)

ash_seg_path <- "Data/Segmentation"
ash_segs <- rgdal::readOGR(ash_seg_path)

save_directory <- "Outputs/ImageSegmentationSearch/"
thresholds <- c(0.4, 0.5, 0.6)
threshold_delta <- c(0.05, 0.1, 0.15)
distances <- c(10, 20,  30)
windows_sizes <- c(11, 27, 35, 43, 51)

for (thresh in thresholds) {
    for (delta in threshold_delta) {
        for (dist in distances) {
            for (window in window_sizes) {
                # create segmentation 
                segments <- itcSegment::itcIMG(
                    imagery = image_data,
                    epsg = 26983,
                    searchWinSize = window,
                    THRESHSeed = thresh,
                    THRESHCrown = (thresh + delta),
                    DIST = dist
                )

                # create filename for the plot
                plot_filename <- paste(
                    save_directory,
                    "img"
                    window,
                    thresh,
                    delta,
                    dist,
                    ".png",
                    sep = "_")
                # save plot image
                png(filename = plot_filename)
                plot(image_data)
                plot(segments, add = TRUE)
                plot(ash_segs, add = TRUE)
                dev.off()

                # name for the shapefile
                shape_filepath <- paste(
                    save_directory,
                    "shp"
                    window,
                    thresh,
                    delta,
                    dist,
                    sep = "_"
                    )
                # write to disk as ESRI shapefile.  
                #See rgdal::ogrDrivers() for complete list of drivers/formats
                rgdal::writeOGR(
                    segments, 
                    shape_filepath,
                    "Segmentation",
                    "ESRI Shapefile"
                )
            }
        }
    }

}