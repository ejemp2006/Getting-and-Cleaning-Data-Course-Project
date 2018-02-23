###Download the data
setwd("~/Desktop/Data_Science_Specialist/Getting and Cleaning Data")
filesPath <- "Desktop/Data_Science_Specialist/UCI HAR Dataset"
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="curl")
unzip(zipfile="./data/Dataset.zip",exdir="./data")

###Load packages
library(dplyr)
library(data.table)
library(tidyr)

###Read files and create a table
filesPath <- "~/Desktop/Data_Science_Specialist/Getting and Cleaning Data/UCI HAR Dataset"
dataSubjectTrain <- tbl_df(read.table(file.path(filesPath, "train", "subject_train.txt")))
dataSubjectTest <- tbl_df(read.table(file.path(filesPath, "test", "subject_test.txt")))
dataActivityTrain <- tbl_df(read.table(file.path(filesPath, "train", "Y_train.txt")))
dataActivityTest <- tbl_df(read.table(file.path(filesPath, "test", "Y_test.txt")))

###Merge the training and test sets to create one data set
alldataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
setnames(alldataSubject, "V1", "subject")
alldataActivity <- rbind(dataActivityTrain, dataActivityTest)
setnames(alldataActivity, "V1", "activityNum")
dataTable <- rbind(dataTrain, dataTest)
dataFeatures <- tbl_df(read.table(file.path(filesPath, "features.txt")))
setnames(dataFeatures, names(dataFeatures), c("featureNum", "featureName"))
colnames(dataTable) <- dataFeatures$featureName
activityLabels <- tbl_df(read.table(file.path(filesPath, "activity_labels.txt")))
setnames(activityLabels, names(activityLabels), c("activityNum", "activityName"))
alldataSubjAct <- cbind(alldataSubject, alldataActivity)
dataTable <- cbind(alldataSubjAct, dataTable)

###Get only measurements for mean and sd
dataFeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)", dataFeatures$featureName,value=TRUE)
dataFeaturesMeanStd <- union(c("subject", "activityNum"), dataFeaturesMeanStd)
dataTable <- subset(dataTable,select=dataFeaturesMeanStd)

###Uses descriptive activity names to name the activities in the data set
dataTable <- merge(activityLabels, dataTable, by="activityNum", all.x=TRUE)
dataTable$activityName <- as.character(dataTable$activityName)
dataTable$activityName <- as.character(dataTable$activityName)
dataAggr <- aggregate(. ~ subject - activityName, data = dataTable, mean)
dataTable <- tbl_df(arrange(dataAggr, subject, activityName))

##Appropriately label the data set
head(str(dataTable), 2)
names(dataTable) <- gsub("std()", "SD", names(dataTable))
names(dataTable)<-gsub("mean()", "MEAN", names(dataTable))
names(dataTable)<-gsub("^t", "time", names(dataTable))
names(dataTable)<-gsub("^f", "frequency", names(dataTable))
names(dataTable)<-gsub("Acc", "Accelerometer", names(dataTable))
names(dataTable)<-gsub("Gyro", "Gyroscope", names(dataTable))
names(dataTable)<-gsub("Mag", "Magnitude", names(dataTable))
names(dataTable)<-gsub("BodyBody", "Body", names(dataTable))

head(str(dataTable),6)

###Make the tidydata txt file
write.table(dataTable, "TidyData.txt", row.name=FALSE)