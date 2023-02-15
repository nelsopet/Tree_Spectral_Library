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
    path = paste(list_path3[1])
    file_name = paste(list_path3_files[x])    
    size = file.size(paste(list_path3[1],list_path3_files[x], sep="/"))
    meta<-c(path, file_name,size)
    names(meta)<-c("path", "file_name", "size")
    return(meta)})

t(as.data.frame(list_file_metadata)) %>% ()

dirs<-"M:/MSGC_DATA/"

#List all the directories in the path
list_dir_paths<-list.dirs(dirs)

#Only keep paths with flights
list_dir_paths_orthos<-list_dir_paths[grep("Orthos", list_dir_paths)]

#Now do it for several paths
list_dirs_metadata<-lapply(1:length(list_dir_paths_orthos), function(x) {
      path = paste(list_dir_paths_orthos[[x]])
      list_path_files<-list.files(path)

      lapply(1:length(list_path_files), function(x) {
        path = path
        file_name = paste(list_path_files[x])    
        size = file.size(paste(path,list_path_files[x], sep="/"))
        meta<-c(path, file_name,size)
        names(meta)<-c("path", "file_name", "size")
        return(meta)})
  
})
list_dirs_metadata<-t(as.data.frame(list_dirs_metadata)) #%>% dim
rownames(list_dirs_metadata)<-NULL
write.csv(list_dirs_metadata, "./Outputs/MSGC_Data_Summary.csv")
