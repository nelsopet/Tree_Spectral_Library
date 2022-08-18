####COMBINE EXTENTS KML WITH TREE STEM MAPS####
library(plyr)
library(dplyr)
library(sf)
library(rgdal)


#File paths
#Need one for extents and one for trees
extents_path <- "M:/MSGC_DATA/Tree_Spec_Lib/Outputs/Extents/PEF-Demerit/"
#"M:/MSGC_DATA/Tree_Spec_Lib/Outputs/Extents/Howland/"
#"M:/MSGC_DATA/Tree_Spec_Lib/Outputs/Extents/PEF-Demerit/"

trees_path <- "M:/MSGC_DATA/Shapefiles for all areas (Elias)/PEF/"
#"M:/MSGC_DATA/Shapefiles for all areas (Elias)/Howland/"
#"M:/MSGC_DATA/Shapefiles for all areas (Elias)/PEF/"

#read in combined kml for given directory
flight_extents <- st_read(paste(extents_path, "/", "PEF_all.kml", sep = ""))


#bring in all point data for tree stem maps
#These must be hand-checked to ensure the data is appropriate!
treelist1 <- list.files(trees_path, recursive = T, pattern = ".shp")
treelist <- subset(treelist1, grepl(".shp.", treelist1)==FALSE)
treelist <- treelist[c(1,2,3,6,7,8,9)] 

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
#100038_PEF_SM_4_110m_2019_06_18_15_16_13_ortho_raw_3965_rd_rf_or (191 total trees)
#100044_PEF_SM_11b_110m_2019_06_15_15_26_52_Orthos_raw_16967_rd_rf_or (188 total trees)
#100047_PEF_SM_12a_110m_2019_06_16_15_25_41_Orthos_raw_15568_rd_rf_or (45 total trees)

#subset individual images
image_100038_3965 <- subset(trees_in_sub, Name == "100038_PEF_SM_4_110m_2019_06_18_15_16_13_ortho_raw_3965_rd_rf_or")

#write to file
st_write(image_100038_3965, paste0(extents_path, "points_100038_3965.shp"), driver = "ESRI Shapefile")



##EXTRAS##

#read in lidar-derived canopy delineation layer and transform CRS
canopies <- st_read("M:\\MSGC_DATA\\Tree_Spec_Lib\\Outputs\\Extents\\PEF-Demerit\\canopies_PEF_100038_3965.shp")
canopies <- st_transform(canopies, crs = st_crs(flight_extents))

#write to file
st_write(canopies, paste0(extents_path, "canopies_PEF_100038_3965_WGS84.shp"), driver = "ESRI Shapefile")

