library(dplyr)

#source("M:\\lecospec\\lecospec\\Functions\\spectral_operations.R")
##^^this needs to be run manually PJB 11/1/22##

source("M:\\lecospec\\lecospec\\Functions\\raster_operations.R")
source("M:\\lecospec\\lecospec\\Functions\\dataframe_operations.R")
source("M:\\lecospec\\lecospec\\Functions\\model_support.R")
source("M:\\lecospec\\lecospec\\Functions\\utilities.R")
source("M:\\lecospec\\lecospec\\Functions\\validation.R")
source("M:\\lecospec\\lecospec\\Functions\\visualization.R")
source("M:\\lecospec\\lecospec\\Functions\\pfts.R")
source("M:\\lecospec\\lecospec\\Functions\\type_conversion.R")
source("M:\\lecospec\\lecospec\\Functions\\training_utilities.R")

ground_spec<-read.csv("M:/Tree_Spectral_Library/Outputs/Cleaned_Tree_SpectralLib.csv")
img_spec<-read.csv("M:/MSGC_DATA/PEF-Demerit/Spectral_libraries/Clean_PEF_spec_lib.csv")


##Bind both ground and image spectra summaries (quantiles) together
PFT_SPEC_GROUND_IMAGE <- bind_rows(img_spec, ground_spec)


#Plot median refl for one PFT from two different sources

######## Functional group 1 spectral profiles
jpeg("M:/Tree_Spectral_Library/Outputs/Spectral_profiles/abibal.jpg", height = 10000, width = 10000, res = 350)
ggplot((PFT_SPEC_GROUND_IMAGE %>% dplyr::filter(taxon_code == "abibal") ), aes(Wavelength, Median_Reflectance), scales = "fixed")+
  geom_ribbon(aes(Wavelength, ymin = Pct_12_5_Reflectance, ymax = Pct_87_5_Reflectance, alpha = 0.3))+
  geom_ribbon(aes(Wavelength, ymin = Lower_Reflectance, ymax = Upper_Reflectance, alpha = 0.2))+
  labs(title = c("Reflectance by plant functional group and sample size with median (red), 75% (dark) and 90% (grey) quantiles based on 1242 scans"), y="Reflectance")+
  theme(panel.background = element_rect(fill = "white", colour = "grey50"), 
        #legend.key.size = unit(0.5, "cm"),legend.text = element_text(size=25),
        legend.position = "none",
        title = element_text(size=25),
        strip.text = element_text(size = 25),
        axis.text = element_text(size = 20),
        axis.text.x = element_text(angle = 90)) 
  #geom_line(aes(Wavelength, Median_Reflectance,color = "red"),size = 2)+
  #geom_line(aes(Wavelength, Median_Reflectance,color = Source),size = 2)+
  
  #facet_wrap(vars(sample_name), scales = "fixed", ncol = 4) 
#facet_wrap(vars(Functional_group1), scales = "fixed", ncol = 3) 

dev.off()

#PFT_IMG_SPEC_clean_merge$UID<-c(PFT_IMG_SPEC_clean_merge$UID)

Cleaned_Speclib_merge %>%
  dplyr::select(-UID,-Source, -Functional_group1, `X425`:`X998`) %>%
  as.matrix() %>%
  hist()


PFT_IMG_SPEC_clean_merge %>%
  dplyr::select(-UID,-Source, -Functional_group1, `X425`:`X998`) %>%
  as.matrix() %>%
  hist()

PFT_SPEC<-bind_rows(Cleaned_Speclib_merge, PFT_IMG_SPEC_clean_merge) 

PFT_SPEC %>% 
  dplyr::mutate(Area= case_when(Area == "EightMile" ~ "Eight Mile",
                                Area == "Murphy"  ~ "Murphy Dome",
                                Area == "Big Trail" ~ "Fairbanks Area Big Trail Lake",
                                Area == "12mile" ~ "Twelve Mile",
                                Area == "Chatanika" ~ "Caribou Poker", 
                                TRUE ~ Area)) %>%
  group_by(Area,Functional_group1, Source) %>% 
  tally() %>% 
  pivot_wider(names_from = Functional_group1, values_from = n) %>% 
  arrange(Area, Source) %>%
  write.csv("./Output/TableScansPFTSiteAllSpectra.csv")


PFT_SPEC_global_rescale<-PFT_SPEC %>%
  global_min_max_scale(ignore_cols = c("UID","Source","Functional_group1","Area"))



PFT_SPEC_TALL<-PFT_SPEC_global_rescale %>% dplyr::select(UID,Source, Functional_group1, everything()) %>%
  pivot_longer(cols = `X420`:`X998`,  names_to  = "Wavelength", values_to = "Reflectance") #%>%
#dplyr::filter(is.na(Reflectance))
#dplyr::filter(Reflectance==0)



#Remove columns not usable in PCA
tst_mat<-PFT_SPEC_global_rescale%>% 
  dplyr::select(-UID,-Source, -Functional_group1, `X425`:`X998`) %>%
  as.matrix()

hist(tst_mat)
#Replace any NAs or Zeros with very small value
tst_mat[tst_mat==0]<-0.00000001
tst_mat[is.na(tst_mat)]<-0.00000001
tst_na<-tst_mat[is.nan(tst_mat)==TRUE]

#Build PCA with and without sqrt transform
#tst_pca<-princomp(tst_mat) #, center=FALSE, scale=FALSE)
tst_pca_pr<-prcomp(log10(tst_mat)) #, center=FALSE, scale=FALSE)

summary(tst_pca)

#How many values in 
seq(1:length(unique(PFT_SPEC$Functional_group1)))
cols<-palette.colors(n=9)
screeplot(tst_pca_pr)
plot(scores(tst_pca_pr)[,1:2], col=cols, pch=c(1:2))
title(main="PCA reflectance global minmax rescale \n after merging image and ground spectra libraries")

#legend(x = -6, y =10, legend=unique(PFT_SPEC$Functional_group1), lty=1, col=c(1:9), cex=0.5)
#legend(x = -6, y =3, legend=unique(PFT_SPEC$Source), pch=c(1:2), cex=0.5)
legend(x = 4, y =0, legend=unique(PFT_SPEC$Functional_group1), lty=1, col=c(1:9), cex=0.5)
legend(x = 2, y =-5, legend=unique(PFT_SPEC$Source), pch=c(1:2), cex=0.5)


#Cluster plots based on their woody veg
#QUESTION: Should we use scale() to center the data
tst_mat_clust<-hclust(dist(tst_mat))
tst_mat_clust_dend<-as.dendrogram(tst_mat_clust)
plot(tst_mat_clust, group = as.factor(PFT_SPEC$Source))

jpeg("./Output/PCA_ALL_SPECTRA_boxplot_PC2.jpeg", width = 1200, height =400)
boxplot(scores(tst_pca_pr)[,2]~PFT_SPEC_global_rescale$Functional_group1)
title(main="PCA axis 2 of reflectance global minmax rescale after \n merging image and ground spectra libraries")
dev.off()

fnc_grp1_colors = createPalette(length(unique(PFT_SPEC$Functional_group1)),  c("#ff0000", "#00ff00", "#0000ff")) %>%
  as.data.frame() %>%
  dplyr::rename(Color = ".") %>%
  mutate(Functional_group1 = unique(PFT_SPEC$Functional_group1)) %>%
  mutate(ColorNum = seq(1:length(unique(PFT_SPEC$Functional_group1))));

fnc_grp1_color_list<-PFT_SPEC %>% dplyr::select(Functional_group1) %>% inner_join(fnc_grp1_colors, by="Functional_group1", keep=FALSE)

jpeg("./Output/HEATMAP_ALL_SPECTRA_boxplot.jpeg", width = 6000, height =4000)

heatmap(log10(tst_mat), 
        dendrogram="row", 
        trace="none", 
        Colv = FALSE,
        RowSideColors = fnc_grp1_color_list$Color)

legend(x='bottomright', legend=unique(fnc_grp1_color_list$Functional_group1), fill=unique(fnc_grp1_color_list$Color), cex=2)
dev.off()



##############Vegetation Indices

##Read in vegetation indices of image spectra
Cleaned_Speclib_derivs<-read.csv("./Data/D_002_SpecLib_Derivs.csv")

Cleaned_Speclib_Derivs_merge <-
  Cleaned_Speclib_derivs %>%
  dplyr::select(ScanID, Functional_group1, Boochs:Vogelmann4) %>% #colnames()
  #global_min_max_scale(ignore_cols = merge_ignore1) %>% #colnames() #dplyr::select(X398:X998) %>% as.matrix() %>% hist()
  dplyr::rename(UID=ScanID) %>%
  mutate(Source = "Ground") %>%
  #mutate(UID=c(Source, ScanID,Functional_group1))
  #dplyr::select(UID,Source, Functional_group1, X398:X998) %>%
  as.data.frame()

VI_DF<read.csv("./Data/D_002_Image_SpecLib_Derivs.csv")

hist(Cleaned_Speclib_Derivs_merge %>% 
       dplyr::select(-UID,-Source, -Functional_group1) %>% 
       columnwise_min_max_scale() %>% #str()
       as.matrix())

ground_PFT_derivs_mat<-Cleaned_Speclib_Derivs_merge %>% 
  dplyr::select(-UID,-Source, -Functional_group1) %>% 
  columnwise_min_max_scale() %>% # #str()
  as.matrix() 

hist(ground_PFT_derivs_mat)

rownames(ground_PFT_derivs_mat)<-Cleaned_Speclib_Derivs_merge$UID

heatmap.2(columnwise_min_max_scale(ground_PFT_derivs_mat) %>% as.matrix(), 
          dendrogram="row", 
          trace="none", 
          Colv = FALSE,
          RowSideColors = fnc_grp1_color_list$Color)
legend(x='topright', legend=unique(fnc_grp1_color_list$Functional_group1), fill=unique(fnc_grp1_color_list$Color), cex=0.7)

hist(as.matrix(VI_DF %>% 
                 dplyr::select(-1:-5)) %>% columnwise_min_max_scale() %>% as.matrix())




##Cast vegetation index VI to matrix and plot using heatmap and PCA
image_PFT_derivs_mat<-as.matrix(VI_DF %>% 
                                  dplyr::select(-1:-5) %>%
                                  columnwise_min_max_scale()) 

hist(image_PFT_derivs_mat)

rownames(image_PFT_derivs_mat)<-VI_DF_rescale$UID

heatmap.2(columnwise_min_max_scale(image_PFT_derivs_mat) %>% as.matrix(), 
          dendrogram="row", 
          trace="none", 
          Colv = FALSE,
          RowSideColors = fnc_grp1_color_list$Color)
legend(x='topright', legend=unique(fnc_grp1_color_list$Functional_group1), fill=unique(fnc_grp1_color_list$Color), cex=0.7)

dim(ground_PFT_derivs_mat)
dim(image_PFT_derivs_mat)

range(ground_PFT_derivs_mat, na.rm=TRUE)
range(image_PFT_derivs_mat, na.rm=TRUE)

hist(dist(ground_PFT_derivs_mat))
hist(dist(image_PFT_derivs_mat))

PFT_derivs_mat<-rbind(ground_PFT_derivs_mat, image_PFT_derivs_mat)

hist(dist(PFT_derivs_mat))
dim(PFT_derivs_mat)

all_deriv_grp<-c(VI_DF_rescale$Functional_group1,Cleaned_Speclib_Derivs_merge$Functional_group1) %>% as.data.frame()
colnames(all_deriv_grp)<-"Functional_group1"

all_derivs_grp1_colors = createPalette(length(unique(all_deriv_grp$Functional_group1)),  c("#ff0000", "#00ff00", "#0000ff")) %>%
  as.data.frame() %>%
  dplyr::rename(Color = ".") %>%
  mutate(Functional_group1 = unique(all_deriv_grp$Functional_group1)) %>%
  mutate(ColorNum = seq(1:length(unique(all_deriv_grp$Functional_group1))));

all_derivs_grp1_color_list<-all_deriv_grp %>% dplyr::select(Functional_group1) %>% inner_join(all_derivs_grp1_colors, by="Functional_group1", keep=FALSE)


#PFT_derivs_mat_rescale<-PFT_derivs_mat %>% 
#  columnwise_min_max_scale() %>% 
#  as.matrix()

PFT_derivs_mat[PFT_derivs_mat<=0.000001]<-0.00000001
PFT_derivs_mat[is.nan(PFT_derivs_mat)]<-0.00000001
PFT_derivs_mat[is.na(PFT_derivs_mat)]<-0.00000001

PFT_derivs_mat_rescale<-PFT_derivs_mat

hist(dist(PFT_derivs_mat_rescale))


dim(PFT_derivs_mat)
heatmap.2(PFT_derivs_mat_rescale, 
          dendrogram="row", 
          trace="none", 
          Colv = FALSE,
          RowSideColors = all_fnc_grp1_color_list$Color)
legend(x='topright', legend=unique(all_fnc_grp1_color_list$Functional_group1), fill=unique(all_fnc_grp1_color_list$Color), cex=0.7)

dev.off()

derivs_pca_pr<-prcomp(PFT_derivs_mat_rescale) #, center=FALSE, scale=FALSE)

cols<-palette.colors(n=8)
screeplot(derivs_pca_pr)
plot(scores(derivs_pca_pr)[,2:3], col=all_derivs_grp1_color_list$Color)#, pch=c(1:2))
title(main = "PCA of min max rescaled vegetations indices from ground and image")


jpeg("./Output/PCA_Veg_Indices_boxplot_PC`.jpeg", width = 1200, height =400)
boxplot(scores(derivs_pca_pr)[,]~c(VI_DF_rescale$Functional_group1,Cleaned_Speclib_Derivs_merge$Functional_group1))
dev.off()


PFT_df<-bind_rows(Cleaned_Speclib_merge,PFT_IMG_SPEC_clean_merge)

all_fnc_grp1_colors = createPalette(length(unique(PFT_df$Functional_group1)),  c("#ff0000", "#00ff00", "#0000ff")) %>%
  as.data.frame() %>%
  dplyr::rename(Color = ".") %>%
  mutate(Functional_group1 = unique(PFT_df$Functional_group1)) %>%
  mutate(ColorNum = seq(1:length(unique(PFT_df$Functional_group1))));

all_fnc_grp1_color_list<-PFT_df %>% dplyr::select(Functional_group1) %>% inner_join(all_fnc_grp1_colors, by="Functional_group1", keep=FALSE)


area_colors = createPalette(length(unique(PFT_df$Area)), "#ff0000") %>%
  as.data.frame() %>%
  dplyr::rename(Color = ".") %>%
  mutate(Area = unique(PFT_df$Area)) %>%
  mutate(ColorNum = seq(1:length(unique(PFT_df$Area))));

area_color_list<-PFT_df %>% dplyr::select(Area) %>% inner_join(area_colors, by="Area", keep=FALSE)

source_colors = createPalette(length(unique(PFT_df$Source)), "#ff0000") %>%
  as.data.frame() %>%
  dplyr::rename(Color = ".") %>%
  mutate(Source = unique(PFT_df$Source)) %>%
  mutate(ColorNum = seq(1:length(unique(PFT_df$Source))));

source_color_list<-PFT_df %>% dplyr::select(Source) %>% inner_join(source_colors, by="Source", keep=FALSE)

ground_mat<-Cleaned_Speclib_merge %>% 
  dplyr::select(-UID,-Source, -Functional_group1, -Area) %>% 
  #columnwise_min_max_scale() %>% #str()
  as.matrix() 
rownames(ground_mat)<-Cleaned_Speclib_merge$UID

image_mat<-as.matrix(PFT_IMG_SPEC_clean_merge %>% 
                       dplyr::select(-1:-4))

rownames(image_mat)<-PFT_IMG_SPEC_clean_merge$UID

PFT_mat<-rbind(ground_mat, image_mat)

PFT_mat[PFT_mat<=0.000001]<-0.00000001

heatmap.2(PFT_mat, 
          dendrogram="row", 
          trace="none", 
          Colv = FALSE,
          RowSideColors = all_fnc_grp1_color_list$Color)

dev.off()

spectra_pca_pr<-prcomp(PFT_mat) #, center=FALSE, scale=FALSE)

cols<-palette.colors(n=8)
screeplot(spectra_pca_pr)
plot(scores(spectra_pca_pr)[,1:2], col=source_color_list$Color)#, pch=c(1:2))
title(main = "PCA of spectra from images")


