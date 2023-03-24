library(spectrolab)
library(tidyverse)
PEF_dates_spectra<-readRDS("./Outputs/PEF_dates_spectra.rds")
HOW_dates_spectra<-readRDS("./Outputs/HOW_Scans_spectra.rds")
HOW_dates_spectra<-HOW_dates_spectra*100
hb1_spectra<-readRDS("Outputs/HB1_spectra.rds")
hb3_spectra<-readRDS("Outputs/HB3_spectra.rds")

## Combine spectral libraries
TreeSpecLib<-Reduce(spectrolab::combine,list(PEF_dates_spectra,HOW_dates_spectra,hb1_spectra, hb3_spectra))

TreeSpecLib_df<- TreeSpecLib %>% as.data.frame
TreeSpecLib_df$taxon_code<-gsub("alnus","alninc",TreeSpecLib_df$taxon_code)
TreeSpecLib_df$taxon_code<-gsub("betale","betall",TreeSpecLib_df$taxon_code)
TreeSpecLib_df$taxon_code<-gsub("thupli","thuocc",TreeSpecLib_df$taxon_code)

TreeSpecLib_df<-TreeSpecLib_df %>%
  dplyr::filter(duplicated(TreeSpecLib_df[,29:ncol(TreeSpecLib_df)])==FALSE) #%>%
  
#TreeSpecLib_df<-TreeSpecLib_df %>% dplyr::filter(`1000`<0.3) #%>% dim
Target_names<-unique(sort(TreeSpecLib_df$taxon_code))

# Creates an empty list
each_target<-list()

# Function splits the spectral library into spectral objects based on each target (105 Spectral Objects)
for(i in 1:length(Target_names)){
  
  # Subset a functional group
  each_target[[i]]<-subset(TreeSpecLib_df,taxon_code == Target_names[i])
  
  # saves metadata
  metadata<-each_target[[i]][,c(1:34)]%>%as.data.frame()
  
  # Convert to a spectral object
  each_target[[i]] <- as_spectra(each_target[[i]][-1:-34])
  
  # Add metadata
  meta(each_target[[i]])<-data.frame(metadata[,c(1:34)], stringsAsFactors = FALSE)
  
}

# Renames each target in list 
each_target<-each_target%>%setNames(Target_names) 

#plot_interactive(each_target[["abibal"    ]]) #Good but quite variable
#plot_interactive(each_target[["acepen"    ]]) # Good but two group in the Vis
#plot_interactive(each_target[["acerub"    ]]) # 27, 32-38 are very bright
 each_target[["acerub"    ]]<-each_target[["acerub"    ]][-c(3, 21:25, 27, 32:38),]
#plot_interactive(each_target[["acesac"    ]]) #
#plot_interactive(each_target[["alninc"    ]]) #
  each_target[["alninc"    ]]<-each_target[["alninc"    ]][-c(5,7:8),]
#plot_interactive(each_target[["betall"    ]]) #
  each_target[["betall"    ]]<-each_target[["betall"    ]][-c(10),]
#plot_interactive(each_target[["betpap"    ]]) #Good
  each_target[["betpap"    ]]<-each_target[["betpap"    ]][-c(8,18),]
#plot_interactive(each_target[["betpop"    ]]) #Good but a few really bright NIR scans
#plot_interactive(each_target[["faggra"    ]]) #
  each_target[["faggra"    ]]<-each_target[["faggra"    ]][-c(17,18, 35,40,43),]
#plot_interactive(each_target[["fraame"    ]]) # Very nice scans!
#plot_interactive(each_target[["larlar"    ]]) # Nice but quite variable ... seeing a pattern with needle leaf
  each_target[["larlar"    ]]<-each_target[["larlar"    ]][-c(8),]
#plot_interactive(each_target[["picgla"    ]]) #
  each_target[["picgla"    ]]<-each_target[["picgla"    ]][-c(8:9,28,38,41),]
#plot_interactive(each_target[["picrub"    ]]) #Variable but nested features in the IR are nice
  each_target[["picrub"    ]]<-each_target[["picrub"    ]][-c(19,28,36,45,47,49,68,70,71),]
#plot_interactive(each_target[["pinstr"    ]]) # Good
#plot_interactive(each_target[["popbal"    ]]) #
each_target[["popbal"    ]]<-each_target[["popbal"    ]][-c(2,3,50,68,71,91),]
#plot_interactive(each_target[["popgra"    ]]) # Ok but two groups in the vis
#plot_interactive(each_target[["poptre"    ]]) # ok but a little separation in the vis
#plot_interactive(each_target[["prupen"    ]]) #
each_target[["prupen"    ]]<-each_target[["prupen"    ]][-c(8),]
#plot_interactive(each_target[["querub"    ]]) #Nice
#plot_interactive(each_target[["rhutyp"    ]]) #Two groups
each_target[["rhutyp"    ]]<-each_target[["rhutyp"    ]][-c(8,10),]
#plot_interactive(each_target[["thuocc"    ]]) #
each_target[["thuocc"    ]]<-each_target[["thuocc"    ]][-c(26,16),]
#plot_interactive(each_target[["tsucan"]]) #
each_target[["tsucan"    ]]<-each_target[["tsucan"    ]][-c(27,24),]


# Creates a new object with cleaned spectral library
New_targets<-each_target
# Combines all species into one spectral library if satisfied with our results
# The result is a dataframe
Cleaned_TreeSpeclib<-Reduce(spectrolab::combine,New_targets)%>% 
  as.data.frame() #%>% # Converts Spectral Object to a dataframe
  #dplyr::select(-sample_name)

# Creates .rds object
Cleaned_TreeSpeclib_rds<-Reduce(spectrolab::combine,New_targets)

write.csv(Cleaned_TreeSpeclib, "Outputs/Cleaned_Tree_SpectralLib.csv")
saveRDS(Cleaned_TreeSpeclib_rds,"Outputs/Cleaned_Tree_Speclib.rds")
