# combine spectral libraries
TreeSpecLib <- spectrolab::combine(PEF_dates_spectra, HOW_dates_spectra)
TreeSpecLib_df <- TreeSpecLib %>% 
  as.data.frame() 

TreeSpecLib_df <- TreeSpecLib_df %>%
  dplyr::filter(duplicated(TreeSpecLib_df[ ,32:ncol(TreeSpecLib_df)]) == FALSE) #%>%
  #filter(taxon_code=="abibal") %>%
  #dim()

TreeSpecLib_unique <- as_spectra(TreeSpecLib_df[-1:-31])
meta(TreeSpecLib_unique) = TreeSpecLib_df[c(1:31)] %>% as.data.frame()


#Cleaned_Speclib<-Reduce(spectrolab::combine,New_targets)%>% 
#  as.data.frame() #%>% colnames() # converts Spectral Object to a dataframe
#dplyr::select(-sample_name)

# creates .rds object
#Cleaned_Speclib_rds<-Reduce(spectrolab::combine,New_targets)

colnames(TreeSpecLib_df)
Target_names <- unique(sort(TreeSpecLib_df$taxon_code))

# creates an empty list
each_target <- list()

# function splits the spectral library into spectral objects based on each target (105 Spectral Objects)
for(i in 1:length(Target_names)){
  
  # subset a functional group
  each_target[[i]] <- subset(TreeSpecLib_df, taxon_code == Target_names[i])
  
  # saves metadata
  metadata <- each_target[[i]][,c(1:31)] %>% 
    as.data.frame()
  
  # convert to a spectral object
  each_target[[i]] <- as_spectra(each_target[[i]][-1:-31])
  
  # add metadata
  meta(each_target[[i]]) <- data.frame(metadata[ ,c(1:31)], stringsAsFactors = FALSE)
  
}

# Renames each target in list 
each_target <- each_target %>%
  setNames(Target_names) 

#[1] "abibal" "acepen" "acerub" "alninc" "betall" "betpap" "betpop"
#[8] "faggra" "fraame" "larlar" "picrub" "pinstr" "popgra" "prupen"
#[15] "querub" "rhutyp" "tsucan"
#plot_interactive(each_target[["abibal"    ]]) #
each_target[["abibal"]] <- each_target[["abibal"]][-c(11, 12, 48), ]

#plot_interactive(each_target[["acepen"    ]]) # Good
#plot_interactive(each_target[["acerub"    ]]) # 
each_target[["acerub"]] <- each_target[["acerub"]][-c(3,21, 22, 25, 27), ]
each_target[["acerub"]] <- each_target[["acerub"]][-c(15:19), ]
each_target[["acerub"]] <- each_target[["acerub"]][-c(19), ]


#plot_interactive(each_target[["alninc"    ]]) # Good mostly
#each_target[["alninc"    ]]<-each_target[["alninc"    ]][-c(7:10),]

#plot_interactive(each_target[["betall"    ]]) # 
each_target[["betall"]] <- each_target[["betall"]][-c(10), ]

#plot_interactive(each_target[["betpap"    ]]) # Good mostly
#plot_interactive(each_target[["betpop"    ]]) # Good mostly
#each_target[["betpop"    ]]<-each_target[["betpop"    ]][-c(1:4),]

#plot_interactive(each_target[["faggra"    ]]) # Good mostly
each_target[["faggra"]] <- each_target[["faggra"]][-c(17, 18), ]

#plot_interactive(each_target[["fraame"    ]]) # Good mostly

#Where did the Larix scans go?
#plot_interactive(each_target[["larlar"    ]]) # Good mostly
#each_target[["larlar"    ]]<-each_target[["larlar"    ]][-c(8),]

#plot_interactive(each_target[["picrub"    ]]) # Good mostly
each_target[["picrub"]] <- each_target[["picrub"]][-c(27,33), ]

#plot_interactive(each_target[["pinstr"    ]]) # Good mostly
#plot_interactive(each_target[["popgra"    ]]) # Good mostly
#each_target[["popgra"    ]]<-each_target[["popgra"    ]][-c(4:5),]

#Where did pruns go?
#plot_interactive(each_target[["prupen"    ]]) # Good mostly
#each_target[["prupen"    ]]<-each_target[["prupen"    ]][-c(8),]

#plot_interactive(each_target[["querub"    ]]) # Good mostly
#plot_interactive(each_target[["rhutyp"    ]]) # Good mostly
each_target[["rhutyp"]] <- each_target[["rhutyp"]][-c(10, 13, 20, 21), ]
#each_target[["rhutyp"    ]]<-each_target[["rhutyp"    ]][-c(25),]


#plot_interactive(each_target[["thuocc"    ]]) # Good mostly

#plot_interactive(each_target[["tsucan"    ]]) # Good mostly
each_target[["tsucan"]] <- each_target[["tsucan"]][-c(37,38), ]
each_target[["tsucan"]] <- each_target[["tsucan"]][-c(20), ]
each_target[["tsucan"]] <- each_target[["tsucan"]][-c(17), ]

# creates a new object with cleaned spectral library
New_targets <- each_target

# combines all species into one spectral library if satisfied with our results
# the result is a dataframe
Cleaned_TreeSpeclib <- Reduce(spectrolab::combine, New_targets) %>% 
  as.data.frame() #%>% # Converts Spectral Object to a dataframe
  #dplyr::select(-sample_name)

# Creates .rds object
Cleaned_TreeSpeclib_rds <- Reduce(spectrolab::combine, New_targets)

write.csv(Cleaned_TreeSpeclib, "Outputs/Cleaned_Tree_SpectralLib.csv")
saveRDS(Cleaned_TreeSpeclib_rds, "Outputs/Cleaned_Tree_Speclib.rds")
