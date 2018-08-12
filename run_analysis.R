#Course Project: Getting and Cleaning Data

#Load required libraries
library(reshape2)

#Download Zip Code (check to make sure we haven't already downloaded the file)
zipLocation <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipFileName <- "project_dataset.zip"

if (!file.exists(zipFileName))
{
    download.file(zipLocation, zipFileName, method="curl");
}

#Extract the file (make sure the files haven't already been extracted) 
if (!file.exists("UCI HAR Dataset"))
{
    unzip(zipFileName);
}

#Read Labels from Features and Activities
dtFeatures <- read.table(file.path("UCI HAR Dataset/features.txt"), as.is = TRUE)
dtActivities <- read.table(file.path("UCI HAR Dataset/activity_labels.txt"))

dtFilteredFeatures <- grep("mean|std", dtFeatures[,2])
colnames(dtActivites) <- c("id", "activity")

#Grab all required data
#Read & Merge Train and Test Sets into data tables so we can work with them
dtTrainSubjectData <- read.table(file.path("UCI HAR Dataset/train/subject_train.txt"))
dtTrainXData <- read.table(file.path("UCI HAR Dataset/train/X_train.txt"))
dtTrainYData <- read.table(file.path("UCI HAR Dataset/train/Y_train.txt"))
dtTrainData <- cbind(dtTrainSubjectData, dtTrainYData, dtTrainXData[dtFilteredFeatures])

dtTestSubjectData <- read.table(file.path("UCI HAR Dataset/test/subject_test.txt"))
dtTestXData <- read.table(file.path("UCI HAR Dataset/test/X_test.txt"))
dtTestYData <- read.table(file.path("UCI HAR Dataset/test/Y_test.txt"))
dtTestData <- cbind(dtTestSubjectData, dtTestYData, dtTestXData[dtFilteredFeatures])

dtCombinedData <- rbind(dtTrainData, dtTestData)

#Cleanup the Column Names from the Feature Data
dtCleanedFeatures <- dtFeatures[dtFilteredFeatures,2]
dtCleanedFeatures <- gsub("mean", "Mean", dtCleanedFeatures)
dtCleanedFeatures <- gsub("std", "Standard", dtCleanedFeatures)
dtCleanedFeatures <- gsub("-", "", dtCleanedFeatures)
dtCleanedFeatures <- gsub("[()]", "", dtCleanedFeatures)

colnames(dtCombinedData) <- c("subject", "activity", dtCleanedFeatures)

#Convert the activity data from a numeric value to a human readable value
dtCombinedData$activity <- factor(dtCombinedData$activity, levels = dtActivities[,1], labels = dtActivities[,2])
dtCombinedData$subject <- as.factor(dtCombinedData$subject)

#Group each Subject and Activity & Summarize with mean
dtCombinedData <- melt(dtCombinedData, id = c("subject", "activity"))
dtCombinedData <- dcast(dtCombinedData, subject + activity ~ variable, mean)

#Write out the results to a File called Tidy.txt
write.table(dtCombinedData, "tidy.txt", row.names = FALSE, quote = FALSE)