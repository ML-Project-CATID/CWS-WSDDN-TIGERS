##@author: Chandan Pandey
##code to create a name mapping between files (for example, Bhadra_BMR0dot8_20060407_181600_2.jpg to 000001.jpg)
##The output will be a csv file containing the above mentioned mapping
##The output csv will be used in Create-text-files.R script for renaming the image names to the mapped label in the respective text files

#setting the working directory
main_dir=c("D:/WSDDN New/Tiger")
traget<-"D:/WSDDN New/output/"#change as per you need
setwd(main_dir)
#listing all the subfoldered inside this folder
folder_sub<-list.dirs(recursive = T)[-1]
rename_file<-NA
file_names<-list.files(recursive = T)
new_name<-paste("00000",1:length(file_names),sep = "")
#final_name<-substr(new_name,nchar(new_name)-1,nchar(new_name))
final_name <- paste(new_name, ".jpg", sep="")
for(n in 1:length(final_name)){
  file.rename(from = file_names[n],to = paste(traget,final_name[n],sep = ""))
}
map<-data.frame(file_names,as.character(final_name))
map

write.csv(map,"D:/WSDDN New/mapped.csv")
