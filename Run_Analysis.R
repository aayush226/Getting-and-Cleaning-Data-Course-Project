#load the package dplyr assuming you have it already
library(dplyr)
filename <- "Courseproject.zip"
#Checks if a file called Courseproject.zip exists in the current working directory
if (!file.exists(filename)){
  url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(url, filename, method="curl")
}  
#extracts contents of the zip file
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}
#setting working directory as UCI HAR Dataset
setwd(file.path(getwd(),"UCI HAR Dataset"))
#reading the data
features <- read.table("features.txt", col.names = c("no","functions"))
activities <- read.table("activity_labels.txt", col.names = c("id", "activity"))
subject_test <- read.table("test/subject_test.txt", col.names = "subject")
x_test <- read.table("test/X_test.txt", col.names = features$functions)
y_test <- read.table("test/y_test.txt", col.names = "id")
subject_train <- read.table("train/subject_train.txt", col.names = "subject")
x_train <- read.table("train/X_train.txt", col.names = features$functions)
y_train <- read.table("train/y_train.txt", col.names = "id")

#merge test + train sets
x<- rbind(x_train, x_test)
y <- rbind(y_train, y_test)
subject <- rbind(subject_train, subject_test)
merged_data <- cbind(subject, y, x)
#tidy data and select mean and std entries only
tidydata <- merged_data %>% select(subject, id , contains("mean"), contains("std"))
tidydata$id <- activities[tidydata$id, 2]
#give descriptive names
names(tidydata)[2] = "Activity"
names(tidydata)<-gsub("-mean()", "Mean", names(tidydata), ignore.case = TRUE)
names(tidydata)<-gsub("-std()", "Std", names(tidydata), ignore.case = TRUE)
names(tidydata)<-gsub("-freq()", "Frequency", names(tidydata), ignore.case = TRUE)
names(tidydata)<-gsub("Acc", "Accelerometer", names(tidydata))
names(tidydata)<-gsub("Gyro", "Gyroscope", names(tidydata))
#create a second data set
secondtidydata <- tidydata %>%
  group_by(subject, Activity) %>%
  summarise_all(funs(mean))
write.table(secondtidydata, "secondtidydata.txt", row.name=FALSE)