require(vegan)
require(pca3d)
require(tidyverse)
Cleaned_Speclib<-read_csv("./Outputs/Cleaned_Tree_SpectralLib.csv")

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

TreeSpec_env<-Cleaned_Speclib %>% inner_join(Sp_Info, by = "taxon_code")
#PCA of trees by spectra
TreeSpec_PCA<-prcomp(Cleaned_Speclib_onlyspectra_vnir)

#How many axes needed
TreeSpec_PCA %>% summary()
TreeSpec_PCA %>% screeplot()

#summary()

#ordiarrows(TreeSpec_PCA, groups = TreeSpec_env$taxon_code )
#pca3d(TreeSpec_PCA, group = TreeSpec_env$taxon_code)  
#envfit(NPS_veg_trees_PCA, NPS_veg_trees_flat_all_Cycles_env$Tree_density)
#ordisurf(NPS_veg_trees_PCA, NPS_veg_trees_flat_all_Cycles_env$Tree_density)
#ordisurf(NPS_veg_trees_PCA, NPS_veg_trees_flat_all_Cycles_env$Tree_density) %>% summary()

#Cluster plots based on their woody veg
#QUESTION: Should we use scale() to center the data
TreeSpec_clust<-hclust(dist(sqrt(as.matrix(Cleaned_Speclib_onlyspectra_vnir))))
TreeSpec_clust_dend<-as.dendrogram(TreeSpec_clust)
#plot(TreeSpec_clust, group = TreeSpec_env$taxon_code)

Genus_num<-c(1:length(unique(Sp_Info$Genus)))

pdf("./Outputs/PCA_VNIR_Genus_biplot_ellipsoids.pdf", height = 6, width = 10)
p1<-ordiplot(TreeSpec_PCA, type="none")
ordiellipse(p1, groups=TreeSpec_env$Genus, label=TRUE, col=Genus_num)
dev.off()

pdf("./Outputs/PCA_VNIR_Genus_biplot_points.pdf", height = 6, width = 10)
p1<-ordiplot(TreeSpec_PCA, type="none")
points(p1, "sites", pch=Genus_num, col=Genus_num)#, bg="yellow")
ordiellipse(p1, groups=TreeSpec_env$Genus, label=FALSE,col=Genus_num)
legend("topright", col=Genus_num, legend = Sp_Info$Genus,
       pch=Genus_num, cex=1)
dev.off()


