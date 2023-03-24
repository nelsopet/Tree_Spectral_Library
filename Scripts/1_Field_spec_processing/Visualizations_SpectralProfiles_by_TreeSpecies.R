require(glue)
#Plot ground spectra by tree species 
Cleaned_Speclib<-read.csv("./Outputs/Cleaned_Tree_SpectralLib.csv")

color <- grDevices::hcl.colors(6, palette = "Spectral", rev = TRUE)

Cleaned_Speclib_tall<-
Cleaned_Speclib %>% 
  #Comment line below if data should be used before rescaling
  #global_min_max_scale(ignore_cols = ignore) %>%  
  group_by(taxon_code) %>% 
  dplyr::select(taxon_code, Latitude, Longitude) %>% 
  unique() %>% 
  #ungroup() %>% 
  #group_by(Functional_group1) %>%
  tally() %>% 
  dplyr::rename(tree_count = n) %>%
  inner_join(Cleaned_Speclib, by="taxon_code") %>% #dim
  group_by(taxon_code) %>% 
  dplyr::mutate(sample_size = n()) %>% 
  dplyr::mutate(taxon_code_wN = glue('{taxon_code} {"(n="} {sample_size} {"scans from "} {tree_count} {"trees"})')) %>%
  #mutate(Functional_group1_wN = Functional_group1) %>% 
  ungroup() %>% #colnames()
  pivot_longer(cols = `X350`:`X2500`,  names_to  = "Wavelength", values_to = "Reflectance") %>%
  mutate(Wavelength = gsub("X","",Wavelength)) %>%
  group_by(taxon_code_wN, Wavelength) %>%  
  dplyr::summarise(Median_Reflectance = median(Reflectance),
                   Max_Reflectance = max(Reflectance),
                   Min_Reflectance = min(Reflectance),
                   Pct_87_5_Reflectance = quantile(Reflectance, probs = 0.875),
                   Pct_12_5_Reflectance = quantile(Reflectance, probs = 0.125),
                   Upper_Reflectance = quantile(Reflectance, probs = 0.95),
                   Lower_Reflectance = quantile(Reflectance, probs = 0.05))%>%
  mutate(Wavelength = as.numeric(Wavelength))  %>%
  as.data.frame() #%>%
  #dplyr::filter(Wavelength>419 & Wavelength<850)

######## Tree species spectral profiles
jpeg("Outputs/Tree_species_spectral_profiles.jpg", height = 9000, width = 6000, res = 350)
ggplot(Cleaned_Speclib_tall, aes(Wavelength, Median_Reflectance), scales = "fixed") +
  
  # labs(title = c("Reflectance by plant functional group and sample \n size with median (black), 75% (dark) and 90% (grey) \n quantiles based on 1302 scans  with vertical bars \n showing Sentinel-2 bandpasses "), y="Reflectance")+
  labs(x = "Wavelength (nm)", y = "Reflectance") +
  theme(
    panel.background = element_rect(fill = "white", colour = "grey50"),
    # legend.key.size = unit(0.5, "cm"),legend.text = element_text(size=25),
    legend.position = "none",
    title = element_text(size = 15),
    strip.text = element_text(size = 15),
    axis.text = element_text(size = 15),
    axis.text.x = element_text(angle = 15)
  ) +
  # Band 1
  # annotate("rect", xmin = 442.7-(21/2), xmax = 442.7+(21/2), ymin = 0, ymax = 1, alpha = .2, color=color[1], fill =color[1])+
  # Band2, fill =
  annotate("rect", xmin = 492.4 - (66 / 2), xmax = 492.4 + (66 / 2), ymin = 0, ymax = 100, alpha = .7, color = color[2], fill = color[2]) +
  # Band3 559.8 36, fill =
  annotate("rect", xmin = 559.8 - (36 / 2), xmax = 559.8 + (36 / 2), ymin = 0, ymax = 100, alpha = .7, color = color[3], fill = color[3]) +
  # Band4 664.6 31, fill =
  annotate("rect", xmin = 664.6 - (31 / 2), xmax = 664.6 + (31 / 2), ymin = 0, ymax = 100, alpha = .7, color = color[4], fill = color[4]) +
  # Band5 704.1 15, fill =
  annotate("rect", xmin = 704.1 - (15 / 2), xmax = 704.1 + (15 / 2), ymin = 0, ymax = 100, alpha = .7, color = color[5], fill = color[5]) +
  # Band6<-740.5 15, fill =
  annotate("rect", xmin = 740.5 - (15 / 2), xmax = 740.5 + (15 / 2), ymin = 0, ymax = 100, alpha = .7, color = color[6], fill = color[6]) +
  # Band7<-782.8 20
  annotate("rect", xmin = 782.8 - (20 / 2), xmax = 782.8 + (20 / 2), ymin = 0, ymax = 100, alpha = .2) +
  # Band8<- 864 21
  annotate("rect", xmin = 864 - (21 / 2), xmax = 864 + (21 / 2), ymin = 0, ymax = 100, alpha = .2) +
  # Band9<-945.1 20
  annotate("rect", xmin = 945.1 - (20 / 2), xmax = 945.1 + (20 / 2), ymin = 0, ymax = 100, alpha = .2) +
  # Band10<-1373.5 31
  annotate("rect", xmin = 1373.5 - (31 / 2), xmax = 1373.5 + (31 / 2), ymin = 0, ymax = 100, alpha = .2) +
  # Band11<-1613.7 91
  annotate("rect", xmin = 1613.7 - (91 / 2), xmax = 1613.7 + (91 / 2), ymin = 0, ymax = 100, alpha = .2) +
  # Band12<-2202.4 175
  annotate("rect", xmin = 2202.4 - (175 / 2), xmax = 2202.4 + (175), ymin = 0, ymax = 100, alpha = .2) +
  geom_line(aes(Wavelength, Median_Reflectance, color = "black"), size = 1.5) +
  scale_color_grey() +
  geom_ribbon(aes(Wavelength, ymin = Pct_12_5_Reflectance, ymax = Pct_87_5_Reflectance), alpha = 0.3) +
  geom_ribbon(aes(Wavelength, ymin = Lower_Reflectance, ymax = Upper_Reflectance), alpha = 0.2) +
  facet_wrap(vars(taxon_code_wN), scales = "fixed", ncol = 4)
# facet_wrap(vars(forcats::fct_relevel(Functional_group2_wN,
#                          levels = c("Lichen  (n= 328)",
#                                     "Moss  (n= 86)",
#                                     "Graminoid  (n= 128)",
#                                     "Forb  (n= 158)",
#                                     "Dwarf Shrub  (n= 130)",
#                                     "Shrub  (n= 326)",
#                                     "Tree  (n= 29)",
#                                     "Non-vegetated surface  (n= 57)"))))
dev.off()

