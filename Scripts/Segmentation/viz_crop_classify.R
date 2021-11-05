require(leaflet)
require(leafem)

summary(segments)
summary(cropped_image_RGB)
pairs(cropped_image_RGB)

segments_proj<-st_transform(segments, crs = target_crs)
writeOGR(segments_proj, dsn = "Outputs/hookset_9105_segments_proj.shp", driver = "ESRI Shapefile" , layer = "CA_m2")
cropped_image_RGB_proj<- projectRaster(cropped_image_RGB, crs=target_crs)

#
raster::plotRGB(cropped_image_RGB, r=1, g=2, b=3)
plot(cropped_image_RGB,)

leaflet(cropped_image_RGB_proj) %>%
 #leaflet::addTiles("https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
 #                  options = providerTileOptions(minZoom = 3, maxZoom = 100)) %>%
  leafem::addRasterRGB(cropped_image_RGB_proj, r=1, g=2, b=3)%>%
  #addTiles() %>%
  #addPolygons(data = segments_proj)
  leaflet::addPolygons(segments_proj, lat = segments_proj$Y, lng = segments_proj$X)
  
  leaflet::addLegend("bottomleft", colors = genera_colors$Color, labels = genera_colors$FNC_grp1) %>% #, opacity = 0) %>%
  addOpacitySlider(layerId = "layer")
saveWidget(maprint, file="Output/Prediction/Genera/TwelveMile2_Genera_map.html")
mapshot(maprint, file="Output/Prediction/Genera/TwelveMile2_Genera_map.jpeg")
