####COMBINE EXTENTS KML WITH TREE STEM MAPS####
library(plyr)
library(dplyr)
library(sf)
library(rgdal)


#File paths
#Need one for extents and one for trees
extents_path <- "M:/MSGC_DATA/Tree_Spec_Lib/Outputs/Extents/Howland/"
#"M:/MSGC_DATA/Tree_Spec_Lib/Outputs/Extents/Howland/"
#"M:/MSGC_DATA/Tree_Spec_Lib/Outputs/Extents/PEF-Demerit/"

trees_path <- "M:/MSGC_DATA/Shapefiles for all areas (Elias)/Howland/"
#"M:/MSGC_DATA/Shapefiles for all areas (Elias)/Howland/"
#"M:/MSGC_DATA/Shapefiles for all areas (Elias)/PEF/"

#read in combined kml for given directory
flight_extents <- st_read(paste(extents_path, "/", "Howland_all.kml", sep = ""))


#bring in all point data for tree stem maps
#WHOLE DIRECTORY
#These must be hand-checked to ensure the data is appropriate!
treelist1 <- list.files(trees_path, recursive = T, pattern = ".shp")
treelist <- subset(treelist1, grepl(".shp.", treelist1)==FALSE)
treelist <- treelist[c(1,2,3,6,7,8,9)] 

#SINGLE FILE
treelist <- st_read("M:\\MSGC_DATA\\Shapefiles for all areas (Elias)\\Howland\\Shawn\\Howland_Shawn_Tree_Locs2.shp")
treelist <- st_transform(treelist, crs = st_crs(flight_extents))
pts_in <- st_join(treelist, flight_extents, join = st_within)
trees_in_sub <- pts_in[!is.na(pts_in$Name),]



#read in stem maps, transform CRS to match flight extents, and compile into df
trees_in <- data.frame()
for(i in treelist) {
  treefile1 <- st_read(paste0(trees_path, i))
  treefile <- st_transform(treefile1, crs = st_crs(flight_extents))
  pts_in <- st_join(treefile, flight_extents, join = st_within)
  trees_in <- rbind.fill(pts_in, trees_in)
}

#subset df to remove NAs
trees_in_sub <- trees_in[!is.na(trees_in$Name),]

#Identify images that contain trees, and counts by species
tree_counts <- trees_in_sub %>% count(Name)
tree_countsbyspecies <- trees_in_sub %>% count(Name, SP)

#favorite images (based on image quality and occurrence of P. rubens)
#HOWLAND
#100003_Howland_plot_1a_110m_2019_07_01_16_48_13_Orthos_raw_16552_rd_rf_or (yes)

#PEF
#maybe 100032_24245


#bad images
#HOWLAND
#100003_Howland_plot_1a_110m_2019_07_01_16_48_13_Orthos_raw_11583_rd_rf_or (streaky image)
#100003_Howland_plot_1a_110m_2019_07_01_16_48_13_Orthos_raw_13583_rd_rf_or (streaky)

#PEF
#All of 100032 is bad
#100035 is bad
#100044_PEF_SM_11b_110m_2019_06_15_15_26_52_Orthos_raw_16967_rd_rf_or (no trees in center of image)
#100306_PEF_SM_1d_flight_2020_06_28_15_12_04_Orthos_raw_16684_rd_rf_or (lots of trees but poor illumination)

#subset individual images
image_100038_9492 <- subset(trees_in_sub, Name == "100038_PEF_SM_4_110m_2019_06_18_15_16_13_ortho_raw_9492_rd_rf_or")

#write to file
st_write(image_100038_9492, paste0(extents_path, "points_100038_9492.shp"), driver = "ESRI Shapefile")



##EXTRAS##

#read in lidar-derived canopy delineation layer and transform CRS
canopies <- st_read("M:\\MSGC_DATA\\Tree_Spec_Lib\\Outputs\\Extents\\PEF-Demerit\\canopies_PEF_100038_3965.shp")
canopies <- st_transform(canopies, crs = st_crs(flight_extents))

#write to file
st_write(canopies, paste0(extents_path, "canopies_PEF_100038_3965_WGS84.shp"), driver = "ESRI Shapefile")

