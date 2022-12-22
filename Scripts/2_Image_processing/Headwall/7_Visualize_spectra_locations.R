#Load packages
require(sf)
library(rgdal)
library(tidyverse)
library(sf)
require(terra)
require(maptiles)
require(stars)


#Custom function to get each KML
allKmlLayers <- function(kmlfile){
  lyr <- ogrListLayers(kmlfile)
  mykml <- list()
  for (i in 1:length(lyr)) {
    mykml[i] <- readOGR(kmlfile,lyr[i])
  }
  names(mykml) <- lyr
  return(mykml)
}

#get centroids of KMLs (UAS flight paths)
UAS_path <- "M:/MSGC_DATA/Tree_Spec_Lib/Outputs/Extents/All_flights_Maine/All_flights_Maine.kml"
UAS_extents<-allKmlLayers(UAS_path)
UAS_all<-Reduce(raster::union, UAS_extents)
UAS_all_centroids<-centroids(vect(UAS_all)) 
writeVector(UAS_all_centroids, "M:/MSGC_DATA/Tree_Spec_Lib/Outputs/UAS_all_centroids.kml") #", filetype = "ESRI Shapefile", overwrite= TRUE)
UAS_all_centroids<-readOGR("M:/MSGC_DATA/Tree_Spec_Lib/Outputs/UAS_all_centroids.kml") 

kmlfile <- st_read("M:/MSGC_DATA/Tree_Spec_Lib/Outputs/Extents/All_flights_Maine/All_flights_Maine.kml")

# Plot UAV mission locations
jpeg("M:/Tree_Spectral_Library/Outputs/Spectra_locations/MSGC_flight_locations_Maine.jpg")
loc <- get_tiles(ext(kmlfile))
plotRGB(loc)
points(UAS_all_centroids, col="blue", lwd=2)
dev.off()

#plot with leaflet
require(leaflet)
require(mapview)

all_flights<-readOGR("M:/MSGC_DATA/Tree_Spec_Lib/Outputs/Extents/All_flights_Maine/PEF_all.kml")

all_flights_map<-leaflet(all_flights) %>%
  addProviderTiles(
    "Esri.WorldImagery",
    group = "Esri.WorldImagery",
    #options = providerTileOptions(minZoom = 1, maxZoom = 50)
  ) %>%
  leaflet::addPolygons(data=all_flights, color = "red", weight = 3, opacity = 1, fillOpacity = 0)

mapshot(all_flights_map, file = "M:/Tree_Spectral_Library/Outputs/Spectra_locations/MSGC_flight_locations_PEF_esrisat.jpg")
