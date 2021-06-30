##This code is used for renaming the image name with image label in very text file using the mapped.csv
## The output text files will be used as input in the WSDDN_test_TIGER.m script
main_dir=c('D:/WSDDN New/textfiles/')
getwd()
setwd(main_dir)
list_files <- list.files(main_dir)

for(n in 1:length(list_files)) {
  a <- paste(n, ".txt", sep="")
  matlab_text <- read.table(a, 
                            quote="\"", comment.char="")
  
  mapped_updated <- read.csv("D:/WSDDN New/mapped.csv",
                             header = T)
  for(n in 1:length(mapped_updated$file_names)){
    mapped_updated$file_names[n]=strsplit(mapped_updated$file_names,"[/]")[[n]][2]
  }
  library(dplyr)
  names(matlab_text)[1]="file_names"   
  matlab_text$file_names<-paste(matlab_text$file_names,".jpg",sep = "")
  final_file<-left_join(matlab_text,mapped_updated,by="file_names")
  final_file<-data.frame(final_file$as.character.final_name.,final_file$V2)
  final_file$as.character.final_name. <- str_replace(final_file$final_file.as.character.final_name. , ".jpg", "")
  final_file$final_file.as.character.final_name. <- as.character(final_file$as.character.final_name.)
  #final_file<- data.frame(final_file$final_file.as.character.final_name.,final_file$V2)
  final_file <- subset(final_file, select = -c(as.character.final_name.) )
  print(final_file)
  dest <- paste('D:/WSDDN New/Renamed_Textfiles/', a, sep="")
  write.table(final_file,dest,sep="\t",row.names=FALSE, col.names = FALSE, quote = FALSE)
}

