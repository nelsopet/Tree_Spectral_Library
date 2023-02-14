#Script to calculate file size by file name for imagery for MSGC data submission
require(tidyverse)

#Set a path
msgc_path<-"M:/MSGC_DATA//Deboullie/Imagery"

#List all the directories in the path
list_paths<-list.dirs(msgc_path)

#Only keep paths with flights
list_path2<-list_paths[grep("_flight", list_paths)]

#Only keep paths with orthorectified images that have been previously processed
list_path3<-list_path2[grep("Orthos", list_path2)]

#Try one path
list_path3_files<-list.files(list_path3[1])

#List all the files and their sizes for that path
list_file_metadata<-lapply(1:length(list_path3_files), function(x) {
    name = paste(list_path3[1],list_path3_files[x], sep="/")
    size = file.size(paste(list_path3[1],list_path3_files[x], sep="/"))
    meta<-c(name,size)
    return(meta)})

t(as.data.frame(list_file_metadata)) %>% head()
