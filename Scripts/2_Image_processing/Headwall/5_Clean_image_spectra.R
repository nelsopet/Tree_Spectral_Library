#Clean image spectra to prep for merge with ground spectra

library(dplyr)

img_spec<-read.csv("M:/MSGC_DATA/PEF-Demerit/Spectral_libraries/PEF_spec_lib.csv")

#remove duplicate columns
clean_img_spec <- img_spec %>% select(!c(
  Species.1,
  HT.1,
  DBH.1,
  Cnpy_Type.1,
  Site.1,
  Mission_ID.1,
  ScanNum.1,
  File.1,
  Species.2,
  HT.2,
  DBH.2,
  Cnpy_Type.2,
  Site.2,
  Mission_ID.2,
  ScanNum.2,
  File.2,
  Species.3,
  HT.3,
  DBH.3,
  Cnpy_Type.3,
  Site.3,
  Mission_ID.3,
  ScanNum.3,
  File.3
))

#clean scan number column
clean_img_spec$ScanNum <- tools::file_path_sans_ext(clean_img_spec$ScanNum)

#create new taxon column to match ground spectra from PEF and Howland
clean_img_spec <- clean_img_spec %>% mutate(taxon_code = 
                                              case_when(Species == "BF" ~ "abibal",
                                                        Species == "EH" ~ "tsucan",
                                                        Species == "HH" ~ "ostvir",
                                                        Species == "RM" ~ "acerub",
                                                        Species == "SM" ~ "acesac",
                                                        Species == "WA" ~ "fraame",
                                                        Species == "WP" ~ "pinstr",
                                                        Species == "YB" ~ "betall"))


#Write to file
write.csv(clean_img_spec, "M:/MSGC_DATA/PEF-Demerit/Spectral_libraries/Clean_PEF_spec_lib.csv")
