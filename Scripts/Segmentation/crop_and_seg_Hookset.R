source("Scripts/Segmentation/crop_and_classify.R")



## Messy data loading
# get relevant CRS
# comment of solving this problem
epsg_code <- 26983
target_wkt <- sf::st_crs(epsg_code)[[2]]
target_crs <- sp::CRS(target_wkt)



#crop data cube
hook_path = "F:/TreeSpecLib_BigFiles/Hooksett"
hook_path_valid = "F:/TreeSpecLib_BigFiles/Hooksett/Validation"
list.files(hook_path)




# should pre-load dataset as input_data object
input_file_path <- paste(hook_path,"raw_9105_rd_rf_or", sep="/")
image_data <- brick(input_file_path)
image_data_proj<-raster::projectRaster(
  image_data_proj,
  crs = target_crs,
  method = "bilinear")

image_data_812nm_proj<-raster::projectRaster(
  image_data_812nm,
  crs = target_crs,
  method = "bilinear")

image_data_RGB<-image_data[[c("X701.284.nm","X551.29.nm","X425.369.nm")]]

hookset_9150_pred<-raster("C:/Users/Nelson Lab/Downloads/hook_9105_shadmasked.envi_PredLayer.tif")
hookset_9150_pred_proj<-projectRaster(hookset_9150_pred, crs=target_crs)
shapefile_path <- paste(hook_path_valid,"hook_9105_crowndelins.shp", sep="/")
human_tree_shapes <- rgdal::readOGR(dsn = shapefile_path) #,  #layer = "15366_crown_delins",)
transformed_trees <- sp::spTransform(human_tree_shapes, target_crs)

cropped_shape <- raster::crop(transformed_trees,extent(image_data_812nm))
cropped_image_allbands<-raster::crop(image_data,extent(human_tree_shapes))
cropped_image_RGB<-raster::crop(image_data_RGB, extent(human_tree_shapes))
cropped_image<-raster::crop(image_data_812nm,extent(human_tree_shapes))
mask_pred<-raster::mask(hookset_9150_pred_proj,segments)
writeRaster(mask_pred, "Outputs/2_Imagery/Headwall/Segments/Hookset/hookset_9105_pred_mask.tiff" )

plot(mask_pred)
plot(cropped_image)
crs(cropped_image)

gc()
cropped_image_proj<-projectRaster(cropped_image, crs =target_crs)

#### Run the Pipeline ####

# define parameters based on grid search
dist <- 40
window <- 41
thresh_base <- 0.6
delta_t <- 0.15

# Perform segmentation
segments <- itcSegment::itcIMG(
    imagery = cropped_image_proj,
    epsg = 26983,
    TRESHSeed = thresh_base,
    TRESHCrown = (thresh_base + delta_t),
    searchWinSize = window,
    DIST = dist
)
Sys.time()
segments <- itcSegment::itcIMG(
  imagery = image_data_812nm_proj,
  epsg = 26983,
  TRESHSeed = thresh_base,
  TRESHCrown = (thresh_base + delta_t),
  searchWinSize = window,
  DIST = dist
)
Sys.time()

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


hookset_spectra <- extract_spectra(hookset_9150_pred_proj, segments_proj)

plot(hookset_spectra)
print(dim(spectra))
plot(spectra[8, 3:280])
