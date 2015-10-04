#
# Getting and Cleaning data course project source code.
#
# file: run_analysis.R
# date: 10/4/2015
#

library(reshape2)

filename <- "getdata_dataset.zip"
folder <- "UCI HAR Dataset"

## Download and unzip the dataset
if (!file.exists(filename)) {
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, filename, method="curl")
}
if (!file.exists(folder)) { 
    unzip(filename) 
}


# Load activity labels and features
activityLabels <- read.table(paste(folder, "activity_labels.txt", sep='/'))
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table(paste(folder, "features.txt", sep='/'))
features[,2] <- as.character(features[,2])


# Extract only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)


# Load the datasets
train <- read.table(paste(folder, "train/X_train.txt", sep='/'))[featuresWanted]
trainActivities <- read.table(paste(folder, "train/Y_train.txt", sep='/'))
trainSubjects <- read.table(paste(folder, "train/subject_train.txt", sep='/'))
train <- cbind(trainSubjects, trainActivities, train)


test <- read.table(paste(folder, "test/X_test.txt", sep='/'))[featuresWanted]
testActivities <- read.table(paste(folder, "test/Y_test.txt", sep='/'))
testSubjects <- read.table(paste(folder, "test/subject_test.txt", sep='/'))
test <- cbind(testSubjects, testActivities, test)


# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.names)


# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)
