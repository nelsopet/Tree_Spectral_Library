#Visualizations
#Read in data
#Cleaned_Speclib<-read_csv("./Outputs/D_002_SpecLib_Derivs.csv")
Cleaned_Speclib<-read_csv("./Outputs/Cleaned_Tree_SpectralLib.csv")

################# Lichen yellow

Cleaned_Speclib_onlyspectra<-Cleaned_Speclib[,-1:-32]
Cleaned_Speclib_onlyspectra<-Cleaned_Speclib_onlyspectra %>% replace(is.na(.),0)
dist(Cleaned_Speclib_onlyspectra) %>% hist()

Cleaned_Speclib_onlyspectra_names<-colnames(Cleaned_Speclib_onlyspectra) #%>% as.numeric() %>% as.data.frame() %>% filter(.<1000)
Cleaned_Speclib_meta<-Cleaned_Speclib[,1:32]
unique(Cleaned_Speclib_meta$taxon_code) %>% as.matrix()
Cleaned_Speclib_onlyspectra_vnir<-Cleaned_Speclib_onlyspectra[52:502]
Genus<-c("Abies"
,"Acer"
,"Acer"
,"Alnus"
,"Betula"
,"Betula"
,"Betula"
,"Fagus"
,"Fraxinus"
, "Larix"
, "Picea"
, "Pinus"
, "Populus"
, "Prunus"
, "Quercus"
, "Rhus"
, "Tsuga")

Guild<-c("Conifer"
,"Deciduous"
,"Deciduous"
,"Deciduous"
,"Deciduous"
,"Deciduous"
,"Deciduous"
,"Deciduous"
,"Deciduous"
, "Conifer"
, "Conifer"
, "Conifer"
, "Deciduous"
, "Deciduous"
, "Deciduous"
, "Deciduous"
, "Conifer")

Sp_Info<-cbind(Guild,Genus, unique(Cleaned_Speclib_meta$taxon_code)) %>% as.data.frame() %>% rename(taxon_code = V3)

fnc_grp1_colors = createPalette(length(unique(Cleaned_Speclib_meta$taxon_code)),  c("#ff0000", "#00ff00", "#0000ff")) %>%
  as.data.frame() %>%
  dplyr::rename(Color = ".") %>%
  mutate(Tree_Species = unique(Cleaned_Speclib_meta$taxon_code)) %>%
  mutate(ColorNum = seq(1:length(unique(Cleaned_Speclib_meta$taxon_code))));

fnc_grp2_colors = createPalette(length(unique(Sp_Info$Guild)),  c("#ff0000")) %>%
  as.data.frame() %>%
  dplyr::rename(Color_Guild = ".") %>%
  mutate(Guild = unique(Sp_Info$Guild)) %>%
  mutate(ColorNum = seq(1:length(unique(Sp_Info$Guild))));

fnc_grp3_colors = createPalette(length(unique(Sp_Info$Genus)),   c("#ff0000", "#00ff00", "#0000ff"))  %>%
  as.data.frame() %>%
  dplyr::rename(Color_Genus = ".") %>%
  mutate(Genus = unique(Sp_Info$Genus)) %>%
  mutate(ColorNum = seq(1:length(unique(Sp_Info$Genus))));


fnc_grp1_color_list<-Cleaned_Speclib_meta %>% 
  dplyr::select(taxon_code) %>%
  inner_join(fnc_grp1_colors, by=c("taxon_code"="Tree_Species"), keep=FALSE) %>%
  inner_join(Sp_Info, by="taxon_code", keep=FALSE) %>%
  inner_join(fnc_grp2_colors, by="Guild") %>%
  inner_join(fnc_grp3_colors, by="Genus")

  
pdf("./Outputs/Tree_Spectral_VNIR_Heatmap.pdf", height = 12, width = 20)
heatmap.2(as.matrix(Cleaned_Speclib_onlyspectra_vnir), dendrogram="row", trace="none", Colv = FALSE, RowSideColors = fnc_grp1_color_list$Color)
legend(x="topright", legend=unique(fnc_grp1_color_list$taxon_code), fill=unique(fnc_grp1_color_list$Color))
dev.off()

pdf("./Outputs/Tree_Spectral_Conifer_Hardwood_VNIR_Heatmap.pdf", height = 12, width = 20)
heatmap.2(as.matrix(Cleaned_Speclib_onlyspectra_vnir), dendrogram="row", trace="none", Colv = FALSE, RowSideColors = fnc_grp1_color_list$Color_Guild)
legend(x="topright", legend=unique(fnc_grp1_color_list$Guild), fill=unique(fnc_grp1_color_list$Color_Guild))
dev.off()

pdf("./Outputs/Tree_Spectral_Genus_VNIR_Heatmap.pdf", height = 12, width = 20)
heatmap.2(as.matrix(Cleaned_Speclib_onlyspectra_vnir), dendrogram="row", trace="none", Colv = FALSE, RowSideColors = fnc_grp1_color_list$Color_Genus)
legend(x="topright", legend=unique(fnc_grp1_color_list$Genus), fill=unique(fnc_grp1_color_list$Color_Genus))
dev.off()
