## Combine spectral libraries
SpecLib<-spectrolab::combine(PEF_dates_spectra,HOW_dates_spectra) %>% as.data.frame
SpecLib_df<-SpecLib %>% 
  as.data.frame() 

SpecLib_df<-SpecLib_df %>%
  filter(duplicated(SpecLib_df[,32:ncol(SpecLib_df)])==FALSE) #%>%
  #filter(taxon_code=="abibal") %>%
  #dim()

SpecLib_unique<-as.spectra(SpecLib_df[-1:-31])
meta(SpecLib_unique) = SpecLib_df[c(1:31)] %>% as.data.frame()


Cleaned_Speclib<-Reduce(spectrolab::combine,New_targets)%>% 
  as.data.frame() #%>% colnames() # Converts Spectral Object to a dataframe
#dplyr::select(-sample_name)

# Creates .rds object
Cleaned_Speclib_rds<-Reduce(spectrolab::combine,New_targets)

colnames(SpecLib_df)
Target_names<-unique(sort(SpecLib_df$taxon_code))

# Creates an empty list
each_target<-list()

# Function splits the spectral library into spectral objects based on each target (105 Spectral Objects)
for(i in 1:length(Target_names)){
  
  # Subset a functional group
  each_target[[i]]<-subset(SpecLib_df,taxon_code == Target_names[i])
  
  # saves metadata
  metadata<-each_target[[i]][,c(1:31)]%>%as.data.frame()
  
  # Convert to a spectral object
  each_target[[i]] <- as.spectra(each_target[[i]][-1:-31])
  
  # Add metadata
  meta(each_target[[i]])<-data.frame(metadata[,c(1:31)], stringsAsFactors = FALSE)
  
}

# Renames each target in list 
each_target<-each_target%>%setNames(Target_names) 

#[1] "abibal" "acepen" "acerub" "alninc" "betall" "betpap" "betpop"
#[8] "faggra" "fraame" "larlar" "picrub" "pinstr" "popgra" "prupen"
#[15] "querub" "rhutyp" "tsucan"
plot_interactive(each_target[["abibal"    ]]) #
each_target[["abibal"    ]]<-each_target[["abibal"    ]][-c(19, 22, 41, 46, 27, 28),]

plot_interactive(each_target[["acepen"    ]]) # Good
plot_interactive(each_target[["acerub"    ]]) # 
each_target[["acerub"    ]]<-each_target[["acerub"    ]][-c(3,21, 22, 25, 27),]
each_target[["acerub"    ]]<-each_target[["acerub"    ]][-c(21, 20),]

plot_interactive(each_target[["alninc"    ]]) # Good mostly
each_target[["alninc"    ]]<-each_target[["alninc"    ]][-c(7:10),]

plot_interactive(each_target[["betall"    ]]) # 
each_target[["betall"    ]]<-each_target[["betall"    ]][-c(10),]

plot_interactive(each_target[["betpap"    ]]) # Good mostly
plot_interactive(each_target[["betpop"    ]]) # Good mostly
each_target[["betpop"    ]]<-each_target[["betpop"    ]][-c(1:4),]

plot_interactive(each_target[["faggra"    ]]) # Good mostly
each_target[["faggra"    ]]<-each_target[["faggra"    ]][-c(17, 18),]

plot_interactive(each_target[["fraame"    ]]) # Good mostly
plot_interactive(each_target[["larlar"    ]]) # Good mostly
each_target[["larlar"    ]]<-each_target[["larlar"    ]][-c(8),]

plot_interactive(each_target[["picrub"    ]]) # Good mostly
each_target[["picrub"    ]]<-each_target[["picrub"    ]][-c(13),]

plot_interactive(each_target[["pinstr"    ]]) # Good mostly
plot_interactive(each_target[["popgra"    ]]) # Good mostly
each_target[["popgra"    ]]<-each_target[["popgra"    ]][-c(4:5),]

plot_interactive(each_target[["prupen"    ]]) # Good mostly
each_target[["prupen"    ]]<-each_target[["prupen"    ]][-c(8),]

plot_interactive(each_target[["querub"    ]]) # Good mostly
plot_interactive(each_target[["rhutyp"    ]]) # Good mostly
each_target[["rhutyp"    ]]<-each_target[["rhutyp"    ]][-c(8,10, 21, 24, 31, 32),]
each_target[["rhutyp"    ]]<-each_target[["rhutyp"    ]][-c(25),]

plot_interactive(each_target[["tsucan"    ]]) # Good mostly
each_target[["tsucan"    ]]<-each_target[["tsucan"    ]][-c(24, 27, 29, 30),]

# Creates a new object with cleaned spectral library
New_targets<-each_target
# Combines all species into one spectral library if satisfied with our results
# The result is a dataframe
Cleaned_Speclib<-Reduce(spectrolab::combine,New_targets)%>% 
  as.data.frame() #%>% # Converts Spectral Object to a dataframe
  #dplyr::select(-sample_name)

# Creates .rds object
Cleaned_Speclib_rds<-Reduce(spectrolab::combine,New_targets)

write.csv(Cleaned_Speclib, "Outputs/Cleaned_Tree_SpectralLib.csv")
saveRDS(Cleaned_Speclib_rds,"Outputs/Cleaned_Tree_Speclib.rds")
