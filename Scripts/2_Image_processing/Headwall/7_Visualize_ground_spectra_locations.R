#Load packages
require(sf)
library(rgdal)
library(tidyverse)
library(sf)
require(terra)
require(maptiles)
require(stars)

Cleaned_Speclib<-read_csv("./Outputs/Cleaned_Tree_SpectralLib.csv")


##Visualize ground spectral locations
SpecLib_LatLong<-Cleaned_Speclib %>% 
  dplyr::select(Latitude, Longitude) %>% 
  unique() %>% 
  filter(Latitude!="n/a")

# Convert data frame to sf object
SpecLib_LatLong_point <- st_as_sf(x = SpecLib_LatLong, 
                        coords = c("Longitude", "Latitude"),
                        crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0")

st_write(SpecLib_LatLong_point, driver = "KML", "./Outputs/Ground_Spectra_ME_points_revised.kml", append = TRUE)
SpecLib_LatLong_point<-readOGR("./Outputs/Ground_Spectra_ME_points_revised.kml") 
plot(SpecLib_LatLong_point)
