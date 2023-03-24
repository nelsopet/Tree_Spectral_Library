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
#Grd_path <- "./Outputs/Ground_Spectra_ME_points_revised.kml"
#Grd_extents<-allKmlLayers(Grd_path)
#Grd_all<-Reduce(raster::union, Grd_extents)
#Grd_all_centroids<-centroids(vect(Grd_all)) 
#writeVector(Grd_all_centroids, "M:/MSGC_DATA/Tree_Spec_Lib/Outputs/Grd_all_centroids.kml") #", filetype = "ESRI Shapefile", overwrite= TRUE)
Grd_all_pts<-readOGR("./Outputs/Ground_Spectra_ME_points_revised.kml") 

#kmlfile <- st_read("M:/MSGC_DATA/Tree_Spec_Lib/Outputs/Extents/All_flights_Maine/All_flights_Maine.kml")

# Plot UAV mission locations
jpeg("./Outputs/MSGC_ground_spectra_locations_Maine.jpg")
loc <- get_tiles(ext(Grd_all_pts))
plotRGB(loc)
points(Grd_all_pts, col="blue", lwd=2)
dev.off()

#plot with leaflet
require(leaflet)
require(mapview)


all_grd_spectra_map<-leaflet(Grd_all_pts) %>%
  addProviderTiles(
    "Esri.WorldImagery",
    group = "Esri.WorldImagery",
    #options = providerTileOptions(minZoom = 1, maxZoom = 50)
  ) %>%
  leaflet::addMarkers(data=Grd_all_pts) #, color = "blue", weight = 3, opacity = 1, fillOpacity = 0)

mapshot(all_grd_spectra_map, file = "./Outputs/MSGC_ground_spectra_locations_Maine.jpg")
