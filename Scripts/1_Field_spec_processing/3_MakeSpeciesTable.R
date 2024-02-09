source("./Functions/lecospectR.R")

#Read in clean speclib
SpLib<-read.csv("./Outputs/Cleaned_Tree_SpectralLib.csv", header=TRUE) %>% as.data.frame()
head(SpLib)
TreeNames<-unique(SpLib$taxon_code) %>% as.data.frame()
colnames(TreeNames)<-"taxon_code"
write.csv(TreeNames, "Data/SpeciesTable.csv")



#Make 6 letter code look Raster Attribute Table
SixLetCodeRAT<-cbind(seq(1:22),unique(SpLib$taxon_code)) %>% as.data.frame()
write.csv(SixLetCodeRAT,"assets/SixLetCodeRATRAT.csv")
    
