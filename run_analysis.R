library(reshape2)

downloadfile <- "getdata_dataset.zip"

## Download / unzip the dataset:
if (!file.exists(downloadfile)){
  URLpath <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(URLpath, downloadfile, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(downloadfile) 
}

# Load activity labels + features
activityLabelslist <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabelslist[,2] <- as.character(activityLabelslist[,2])
featureslist <- read.table("UCI HAR Dataset/features.txt")
featureslist[,2] <- as.character(featureslist[,2])

# Extract only the data on mean and standard deviation
featureslistWanted <- grep(".*mean.*|.*std.*", featureslist[,2])
featureslistWanted.names <- features[featureslistWanted,2]
featureslistWanted.names = gsub('-mean', 'Mean', featureslistWanted.names)
featureslistWanted.names = gsub('-std', 'Std', featureslistWanted.names)
featureslistWanted.names <- gsub('[-()]', '', featureslistWanted.names)


# Load the datasets
traindata <- read.table("UCI HAR Dataset/train/X_train.txt")[featureslistWanted]
traindataActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
traindataSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
traindata <- cbind(traindataSubjects, traindataActivities, traindata)

testlist <- read.table("UCI HAR Dataset/test/X_test.txt")[featureslistWanted]
testlistActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testlistSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
testlist <- cbind(testlistSubjects, testlistActivities, testlist)

# merge datasets and add labels
completeData <- rbind(traindata, testlist)
colnames(completeData) <- c("subject", "activity", featureslistWanted.names)

# turn activities & subjects into factors
completeData$activity <- factor(completeData$activity, levels = activityLabelslist[,1], labels = activityLabelslist[,2])
completeData$subject <- as.factor(completeData$subject)

completeData.melted <- melt(completeData, id = c("subject", "activity"))
completeData.mean <- dcast(completeData.melted, subject + activity ~ variable, mean)

write.table(completeData.mean, "averagedata_tidy.txt", row.names = FALSE, quote = FALSE)