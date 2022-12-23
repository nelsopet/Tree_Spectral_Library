require(Polychrome)
require(glue)
require(vegan)
library(dplyr)
library(tidyr)
library(ggplot2)
library(doBy)

#Bring in spectra--wide format
#Full-canopy spectra
PFT_IMG_SPEC_clean <- read.csv("M:/MSGC_DATA/PEF-Demerit/Spectral_libraries/Clean_PEF_spec_lib.csv")
PFT_IMG_SPEC_clean <- PFT_IMG_SPEC_clean %>% dplyr::select(!c(X, X.1))
PFT_IMG_SPEC_clean$Tree_ID <- paste(PFT_IMG_SPEC_clean$Species, PFT_IMG_SPEC_clean$HT, PFT_IMG_SPEC_clean$DBH, PFT_IMG_SPEC_clean$Site, PFT_IMG_SPEC_clean$Mission_ID, PFT_IMG_SPEC_clean$ScanNum, sep = "_")

#illuminated-canopy spectra
PFT_IMG_SPEC_clean_light <- read.csv("M:/MSGC_DATA/PEF-Demerit/Spectral_libraries/Clean_PEF_spec_lib_light.csv")
PFT_IMG_SPEC_clean_light <- PFT_IMG_SPEC_clean_light %>% select(!c(X, X.1))
PFT_IMG_SPEC_clean_light$Tree_ID <- paste(PFT_IMG_SPEC_clean_light$Species, PFT_IMG_SPEC_clean_light$HT, PFT_IMG_SPEC_clean_light$DBH, sep = "_")

#shaded-canopy spectra
PFT_IMG_SPEC_clean_shadow <- read.csv("M:/MSGC_DATA/PEF-Demerit/Spectral_libraries/Clean_PEF_spec_lib_shadow.csv")
PFT_IMG_SPEC_clean_shadow <- PFT_IMG_SPEC_clean_shadow %>% select(!c(X, X.1))
PFT_IMG_SPEC_clean_shadow$Tree_ID <- paste(PFT_IMG_SPEC_clean_shadow$Species, PFT_IMG_SPEC_clean_shadow$HT, PFT_IMG_SPEC_clean_shadow$DBH, sep = "_")

#count number of each species
species_count <- summaryBy(unique(Tree_ID) ~ Species, data = PFT_IMG_SPEC_clean)

species_count1<- PFT_IMG_SPEC_clean %>% count(Species, Tree_ID)




####Full-canopy spectra####

#change to long format--final product is summarized by species
PFT_IMG_SPEC_clean_tall <- PFT_IMG_SPEC_clean %>% 
  count(Species) %>%
  rename(pixel_count = n) %>%
  inner_join(PFT_IMG_SPEC_clean, PFT_IMG_SPEC_clean_tall, by  = "Species") %>%
  mutate(Species_pixel = paste(Species, " pixels=", pixel_count, sep = "")) %>%
  pivot_longer(cols = `X398`:`X999`,  names_to  = "Wavelength", values_to = "Reflectance") %>%
  mutate(Wavelength = gsub("X","",Wavelength),
         Wavelength = as.numeric(Wavelength)) %>% 
  #summarise spectra by species
  group_by(Species, Wavelength, pixel_count) %>%  
  dplyr::summarise(Median_Reflectance = median(Reflectance),
                   Max_Reflectance = max(Reflectance),
                   Min_Reflectance = min(Reflectance),
                   Pct_87_5_Reflectance = quantile(Reflectance, probs = 0.875),
                   Pct_12_5_Reflectance = quantile(Reflectance, probs = 0.125),
                   Upper_Reflectance = quantile(Reflectance, probs = 0.95),
                   Lower_Reflectance = quantile(Reflectance, probs = 0.05))
  
####Illuminated-canopy spectra####

#change to long format--final product is summarized by species
PFT_IMG_SPEC_clean_tall_light <- PFT_IMG_SPEC_clean_light %>% 
  count(Species) %>%
  rename(pixel_count_light = n) %>%
  inner_join(PFT_IMG_SPEC_clean_light, PFT_IMG_SPEC_clean_tall_light, by  = "Species") %>%
  mutate(Species_pixel_light = paste(Species, " pixels=", pixel_count_light, sep = "")) %>%
  pivot_longer(cols = `X398`:`X999`,  names_to  = "Wavelength", values_to = "Reflectance") %>%
  mutate(Wavelength = gsub("X","",Wavelength),
         Wavelength = as.numeric(Wavelength)) %>% 
  #summarise spectra by species
  group_by(Species, Wavelength, pixel_count_light) %>%  
  dplyr::summarise(Median_Reflectance_light = median(Reflectance),
                   Max_Reflectance_light = max(Reflectance),
                   Min_Reflectance_light = min(Reflectance),
                   Pct_87_5_Reflectance_light = quantile(Reflectance, probs = 0.875),
                   Pct_12_5_Reflectance_light = quantile(Reflectance, probs = 0.125),
                   Upper_Reflectance_light = quantile(Reflectance, probs = 0.95),
                   Lower_Reflectance_light = quantile(Reflectance, probs = 0.05))

####Shaded-canopy spectra####

#change to long format--final product is summarized by species
PFT_IMG_SPEC_clean_tall_shadow <- PFT_IMG_SPEC_clean_shadow %>% 
  count(Species) %>%
  rename(pixel_count_shadow = n) %>%
  inner_join(PFT_IMG_SPEC_clean_shadow, PFT_IMG_SPEC_clean_tall_shadow, by  = "Species") %>%
  mutate(Species_pixel_shadow = paste(Species, " pixels=", pixel_count_shadow, sep = "")) %>%
  pivot_longer(cols = `X398`:`X999`,  names_to  = "Wavelength", values_to = "Reflectance") %>%
  mutate(Wavelength = gsub("X","",Wavelength),
         Wavelength = as.numeric(Wavelength)) %>% 
  #summarise spectra by species
  group_by(Species, Wavelength, pixel_count_shadow) %>%  
  dplyr::summarise(Median_Reflectance_shadow = median(Reflectance),
                   Max_Reflectance_shadow = max(Reflectance),
                   Min_Reflectance_shadow = min(Reflectance),
                   Pct_87_5_Reflectance_shadow = quantile(Reflectance, probs = 0.875),
                   Pct_12_5_Reflectance_shadow = quantile(Reflectance, probs = 0.125),
                   Upper_Reflectance_shadow = quantile(Reflectance, probs = 0.95),
                   Lower_Reflectance_shadow = quantile(Reflectance, probs = 0.05))

#Merge all canopy spectra types (full, shaded, illuminated)
ALL_PFT_IMG_SPEC_clean_tall_1 <- inner_join(PFT_IMG_SPEC_clean_tall, PFT_IMG_SPEC_clean_tall_light, by = c("Species", "Wavelength"))
ALL_PFT_IMG_SPEC_clean_tall <- inner_join(ALL_PFT_IMG_SPEC_clean_tall_1, PFT_IMG_SPEC_clean_tall_shadow, by = c("Species", "Wavelength"))

all_viz <- ALL_PFT_IMG_SPEC_clean_tall %>% 
  mutate(species_count = case_when(
    Species == "BF" ~ 3,
    Species == "EH" ~ 13,
    Species == "HH" ~ 1,
    Species == "RM" ~ 6,
    Species == "RS" ~ 18,
    Species == "SM" ~ 3,
    Species == "WA" ~ 1,
    Species == "WP" ~ 1,
    Species == "YB" ~ 1
  )) %>%
  mutate(species_name = case_when(
    Species == "BF" ~ "Balsam fir",
    Species == "EH" ~ "Eastern hemlock",
    Species == "HH" ~ "American hophornbean",
    Species == "RM" ~ "Red maple",
    Species == "RS" ~ "Red spruce",
    Species == "SM" ~ "Sugar maple",
    Species == "WA" ~ "White ash",
    Species == "WP" ~ "Eastern white pine",
    Species == "YB" ~ "Yellow birch"
  )) %>%
  mutate(Tree_ID_header = glue('{species_name} {"(n="}{species_count}{", pixels="}{pixel_count}{")"}')) 

write.csv(all_viz, "M:/MSGC_DATA/PEF-Demerit/Spectral_libraries/Clean_PEF_spec_lib_tall_full_light_shadow.csv")



####VISUALIZATION####

#visualize all components of canopy (full, illuminated, shaded) together
ALL_PFT_IMG_SPEC_clean_tall <- read.csv("M:/MSGC_DATA/PEF-Demerit/Spectral_libraries/Clean_PEF_spec_lib_tall_full_light_shadow.csv")

jpeg("M:/Tree_Spectral_Library/Outputs/Spectral_profiles/PEF_all.jpg", height = 10000, width = 9000, res = 350)
ggplot(ALL_PFT_IMG_SPEC_clean_tall, scales = "fixed")+
  labs(title = c(
  "Reflectance by species with median (purple), 75% (dark) and 90% (grey) quantiles of full canopies. 
   Median reflectance of fully-illuminated canopies (orange) and fully-shaded canopies (blue) are also shown"), y="Reflectance")+
  theme(panel.background = element_rect(fill = "white", colour = "grey50"), 
        #legend.key.size = unit(0.5, "cm"),legend.text = element_text(size=25),
        legend.position = "none",
        title = element_text(size=25),
        strip.text = element_text(size = 25),
        axis.text = element_text(size = 20),
        axis.text.x = element_text(angle = 90)) +
  geom_line(aes(Wavelength, Median_Reflectance), color = "#CC79A7",size = 2)+  
  geom_ribbon(aes(Wavelength, ymin = Pct_12_5_Reflectance, ymax = Pct_87_5_Reflectance), alpha = 0.3) +
  geom_ribbon(aes(Wavelength, ymin = Lower_Reflectance, ymax = Upper_Reflectance), alpha = 0.2) +
  geom_line(aes(Wavelength, Median_Reflectance_light), color = "#D55E00", size = 2) +
  geom_line(aes(Wavelength, Median_Reflectance_shadow), color = "#0072B2", size = 2) +
  facet_wrap(vars(Tree_ID_header), scales = "fixed", ncol = 3) 
dev.off()

####END of VISUALIZATION####
