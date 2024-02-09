require(devtools)
install.packages("RStoolbox")
require(RStoolbox) #need to install from github using devtools
require(tidyverse)

Cleaned_TreeSpeclib<-read.csv("Outputs/Cleaned_Tree_SpectralLib.csv")
Cleaned_TreeSpeclib_tall<-Cleaned_TreeSpeclib %>% 
group_by(sample_name, taxon_code) %>%
dplyr::select(`X350`:`X2500`) %>%
pivot_longer(cols = `X350`:`X2500`,  names_to  = "Wavelength", values_to = "Reflectance") %>%
  mutate(Wavelength = gsub("X","",Wavelength)) %>%
  pivot_wider(names_from = c(taxon_code,sample_name), values_from = Reflectance)

writeSLI(Cleaned_TreeSpeclib_tall,"Outputs/Cleaned_Tree_Speclib2.sli", wavl.units = "Nanometers")

Cleaned_TreeSpeclib_tall_median_by_taxon<-Cleaned_TreeSpeclib %>% 
group_by(taxon_code) %>%
dplyr::select(`X350`:`X2500`) %>% #dim
pivot_longer(cols = `X350`:`X2500`,  names_to  = "Wavelength", values_to = "Reflectance") %>% #dim
mutate(Wavelength = gsub("X","",Wavelength)) %>%
group_by(taxon_code,Wavelength) %>%  
dplyr::summarise(Reflectance = median(Reflectance))%>%
mutate(Wavelength = as.numeric(Wavelength)) %>%
as.data.frame() %>% 
pivot_wider(names_from = taxon_code, values_from = Reflectance) %>%
mutate(Wavelength = as.numeric(Wavelength)) %>%
dplyr::arrange(Wavelength)


#df<-Cleaned_TreeSpeclib %>% 
#group_by(taxon_code) %>%
#dplyr::select(`X350`:`X2500`) %>% #dim
#pivot_longer(cols = `X350`:`X2500`,  names_to  = "Wavelength", values_to = "Reflectance") %>% #dim
#mutate(Wavelength = gsub("X","",Wavelength)) %>%
#group_by(taxon_code,Wavelength) %>%  
#dplyr::summarise(Reflectance = median(Reflectance))%>%
#mutate(Wavelength = as.numeric(Wavelength)) %>%
#as.data.frame()

#windows();
#ggplot(df, aes(Wavelength, Reflectance), scales = "fixed") +
#  
#  # labs(title = c("Reflectance by plant functional group and sample \n size with median (black), 75% (dark) and 90% (grey) \n quantiles based on 1302 scans  with vertical bars \n showing Sentinel-2 bandpasses "), y="Reflectance")+
#  labs(x = "Wavelength (nm)", y = "Reflectance") +
#  theme(
#    panel.background = element_rect(fill = "white", colour = "grey50"),
#    # legend.key.size = unit(0.5, "cm"),legend.text = element_text(size=25),
#    legend.position = "none",
#    title = element_text(size = 15),
#    strip.text = element_text(size = 15),
#    axis.text = element_text(size = 15),
#    axis.text.x = element_text(angle = 15)
#  ) +
#  geom_line(aes(Wavelength, Reflectance, color = taxon_code), size = 1.5) 
#dev.off()

RStoolbox::writeSLI(Cleaned_TreeSpeclib_tall_median_by_taxon,"Outputs/Cleaned_TreeSpeclib_tall_median_by_taxon.sli", wavl.units = "Nanometers")

