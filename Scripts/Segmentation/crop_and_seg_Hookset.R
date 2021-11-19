source("Scripts/Segmentation/crop_and_classify.R")
require(raster)
require(terra)
require(tidyverse)
require(leaflet)
require(leafem)
require(rgdal)
## Messy data loading
# get relevant CRS
# comment of solving this problem
epsg_code <- 26983
target_wkt <- sf::st_crs(epsg_code)[[2]]
target_crs <- sp::CRS(target_wkt)


##NHTI 0 data cube
nhti_path = "D:/Chan_Thesis_Missions/Ash_07262019/100145_ash_nhti_2019_07_28_18_03_33"
nhti_input_file_path <- paste(nhti_path, "raw_0_rd_rf_or", sep="/")
nhti_image_data <- brick(nhti_input_file_path)
nhti_image_data_RGB<-nhti_image_data[[c("X701.284.nm","X551.29.nm","X425.369.nm")]]
nhti_image_data_812nm<-nhti_image_data$X812.39.nm

nhti_image_data_812nm_proj<--raster::projectRaster(
  nhti_image_data_812nm,
  crs = target_crs,
  method = "bilinear")

nhti_image_data_RGB_proj<--raster::projectRaster(
  nhti_image_data_RGB,
  crs = target_crs,
  method = "bilinear")

leaflet(nhti_image_data_RGB_proj) %>%
  leaflet::addTiles("https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
                    options = providerTileOptions(minZoom = 3, maxZoom = 100)) %>%
  leafem::addRasterRGB(nhti_image_data_RGB_proj, r=3, g=2, b=1 ) #%>%


#Read in predicted layers and validation and project them 
#hookset_9150_pred<-raster("C:/Users/Nelson Lab/Downloads/hook_9105_shadmasked.envi_PredLayer.tif")
#hookset_9150_pred_proj<-projectRaster(hookset_9150_pred, crs=target_crs)
nhti_shapefile_path <-"D:/Forests/OriginalData/nhti_0_crop.shp"
nhti_human_tree_shapes <- rgdal::readOGR(dsn = nhti_shapefile_path) #,  #layer = "15366_crown_delins",)
nhti_transformed_trees <- sp::spTransform(nhti_human_tree_shapes, target_crs)

#Crop validation by 
nhti_cropped_shape <- raster::crop(nhti_transformed_trees,extent(nhti_image_data_812nm_proj))
#nhti_cropped_image_allbands<-raster::crop(nhti_image_data,extent(nhti_human_tree_shapes))
nhti_cropped_image_RGB<-raster::crop(nhti_image_data_RGB, extent(nhti_human_tree_shapes))
nhti_cropped_image_data_812nm<-raster::crop(nhti_image_data_812nm,extent(nhti_human_tree_shapes))
#nhti_mask_pred<-raster::mask(nhtiset_9150_pred_proj,segments)
#writeRaster(mask_pred, "Outputs/2_Imagery/Headwall/Segments/nhtiset/nhtiset_9105_pred_mask.tiff" )
nhti_cropped_image_812nm_proj<-projectRaster(nhti_cropped_image_data_812nm, crs =target_crs)


    # define parameters based on grid search
    dist <- 40
    window <- 41
    thresh_base <- 0.6
    delta_t <- 0.15
    
        # Perform segmentation
        gc()
        Sys.time()
        nhti_segments <- itcSegment::itcIMG(
          imagery = nhti_cropped_image_812nm_proj,
          epsg = 26983,
          TRESHSeed = thresh_base,
          TRESHCrown = (thresh_base + delta_t),
          searchWinSize = window,
          DIST = dist
        )
        Sys.time()
    
        writeOGR(nhti_segments, dsn = "Outputs/nhti_0_segments.shp", layer = "segment", driver="ESRI Shapefile")
       
        
 ##NHTI 2489 data cube
  nhti_2489_path = "D:/Chan_Thesis_Missions/Ash_07262019/100145_ash_nhti_2019_07_28_18_03_33"
  nhti_2489_input_file_path <- paste(nhti_2489_path, "raw_2489_rd_rf_or", sep="/")
  nhti_2489_image_data <- brick(nhti_2489_input_file_path)
  nhti_2489_image_data_RGB<-nhti_2489_image_data[[c("X701.284.nm","X551.29.nm","X425.369.nm")]]
  nhti_2489_image_data_812nm<-nhti_2489_image_data$X812.39.nm
  
  nhti_2489_image_data_812nm_proj<--raster::projectRaster(
    nhti_2489_image_data_812nm,
    crs = target_crs,
    method = "bilinear")
  
  nhti_2489_image_data_RGB_proj<--raster::projectRaster(
    nhti_2489_image_data_RGB,
    crs = target_crs,
    method = "bilinear")
  
  leaflet(nhti_2489_image_data_RGB_proj) %>%
    leaflet::addTiles("https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
                      options = providerTileOptions(minZoom = 3, maxZoom = 100)) %>%
    leafem::addRasterRGB(nhti_2489_image_data_RGB_proj, r=3, g=2, b=1 ) #%>%
  
  #Read in predicted layers and validation and project them 
  #hookset_9150_pred<-raster("C:/Users/Nelson Lab/Downloads/hook_9105_shadmasked.envi_PredLayer.tif")
  #hookset_9150_pred_proj<-projectRaster(hookset_9150_pred, crs=target_crs)
  nhti_2489_shapefile_path <-"D:/Forests/OriginalData/nhti_2489_crop_PRN.shp"
  nhti_2489_human_tree_shapes <- rgdal::readOGR(dsn = nhti_2489_shapefile_path) #,  #layer = "15366_crown_delins",)
  nhti_2489_transformed_trees <- sp::spTransform(nhti_2489_human_tree_shapes, target_crs)
  
  #Crop validation by 
  nhti_2489_cropped_shape <- raster::crop(nhti_2489_transformed_trees,extent(nhti_2489_image_data_812nm_proj))
  #nhti_2489_cropped_image_allbands<-raster::crop(nhti_2489_image_data,extent(nhti_2489_human_tree_shapes))
  nhti_2489_cropped_image_RGB<-raster::crop(nhti_2489_image_data_RGB, extent(nhti_2489_human_tree_shapes))
  nhti_2489_cropped_image_data_812nm<-raster::crop(nhti_2489_image_data_812nm,extent(nhti_2489_human_tree_shapes))
  #nhti_2489_mask_pred<-raster::mask(nhtiset_9150_pred_proj,segments)
  #writeRaster(mask_pred, "Outputs/2_Imagery/Headwall/Segments/nhtiset/nhtiset_9105_pred_mask.tiff" )
  nhti_2489_cropped_image_812nm_proj<-projectRaster(nhti_2489_cropped_image_data_812nm, crs =target_crs)
  
  # define parameters based on grid search
  dist <- 40
  window <- 41
  thresh_base <- 0.6
  delta_t <- 0.15
  
  # Perform segmentation
  gc()
  Sys.time()
  nhti_2489_segments <- itcSegment::itcIMG(
    imagery = nhti_2489_cropped_image_812nm_proj,
    epsg = 26983,
    TRESHSeed = thresh_base,
    TRESHCrown = (thresh_base + delta_t),
    searchWinSize = window,
    DIST = dist
  )
  Sys.time()
  
  writeOGR(nhti_2489_segments, dsn = "Outputs/nhti_2489_segments.shp", layer = "segment", driver="ESRI Shapefile")
  
 
  
  #Hookset
#crop data cube
hook_path = "F:/TreeSpecLib_BigFiles/Hooksett"
hook_path_valid = "F:/TreeSpecLib_BigFiles/Hooksett/Validation"

hook_input_file_path <- paste(hook_path,"raw_9105_rd_rf_or", sep="/")
hook_image_data <- brick(hook_input_file_path)
hook_image_data_RGB<-hook_image_data[[c("X701.284.nm","X551.29.nm","X425.369.nm")]]
hook_image_data_812nm<-hook_image_data$X812.39.nm

hook_image_data_812nm_proj<--raster::projectRaster(
    hook_image_data_812nm,
    crs = target_crs,
    method = "bilinear")
  
hook_image_data_RGB_proj<--raster::projectRaster(
  hook_image_data_RGB,
  crs = target_crs,
  method = "bilinear")

leaflet(hook_image_data_RGB_proj) %>%
  leaflet::addTiles("https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
                    options = providerTileOptions(minZoom = 3, maxZoom = 100)) %>%
  leafem::addRasterRGB(hook_image_data_RGB_proj, r=1, g=2, b=3 ) #%>%
  #addOpacitySlider(layerId = "layer")



#Read in predicted layers and validation and project them 
hookset_9150_pred<-raster("C:/Users/Nelson Lab/Downloads/hook_9105_shadmasked.envi_PredLayer.tif")
hookset_9150_pred_proj<-projectRaster(hookset_9150_pred, crs=target_crs)
shapefile_path <- paste(hook_path_valid,"hook_9105_crowndelins.shp", sep="/")
hook_human_tree_shapes <- rgdal::readOGR(dsn = shapefile_path) #,  #layer = "15366_crown_delins",)
hook_transformed_trees <- sp::spTransform(human_tree_shapes, target_crs)

#Crop validation by 
hook_cropped_shape <- raster::crop(hook_transformed_trees,extent(hook_image_data_812nm_proj))
#hook_cropped_image_allbands<-raster::crop(hook_image_data,extent(hook_human_tree_shapes))
hook_cropped_image_RGB<-raster::crop(hook_image_data_RGB, extent(hook_human_tree_shapes))
hook_cropped_image_data_812nm<-raster::crop(hook_image_data_812nm,extent(hook_human_tree_shapes))
#hook_mask_pred<-raster::mask(hookset_9150_pred_proj,segments)
#writeRaster(mask_pred, "Outputs/2_Imagery/Headwall/Segments/Hookset/hookset_9105_pred_mask.tiff" )

#plot(mask_pred)
plot(hook_cropped_image_data_812nm)
crs(cropped_image)

gc()
hook_cropped_image_812nm_proj<-projectRaster(hook_cropped_image_data_812nm, crs =target_crs)

#### Run the Pipeline ####

# define parameters based on grid search
dist <- 40
window <- 41
thresh_base <- 0.6
delta_t <- 0.15

# Perform segmentation
  Sys.time()
hook_segments <- itcSegment::itcIMG(
  imagery = hook_cropped_image_812nm_proj,
  epsg = 26983,
  TRESHSeed = thresh_base,
  TRESHCrown = (thresh_base + delta_t),
  searchWinSize = window,
  DIST = dist
)
Sys.time()

# filter the segmentation
filtered_segments <- filter_segmentation(segments, cropped_shape)





######Not sure if we need this below
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
