
# Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. 
# A Public Domain Dataset for Human Activity Recognition Using Smartphones. 
# 21th European Symposium on Artificial Neural Networks, Computational Intelligence 
# and Machine Learning, ESANN 2013. Bruges, Belgium 24-26 April 2013.


## Reading data 

if (!file.exists("data.zip")){
        url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"       
        download.file(url, "data.zip")
}

activity <- read.table(unz("data.zip",  filename = "UCI HAR Dataset/activity_labels.txt"),
                              col.names=c("activity_id","activity_name"))
feat <- read.table(unz("data.zip", 
                         filename = "UCI HAR Dataset/features.txt")) # features
trainX <- read.table(unz("data.zip", 
                         filename = "UCI HAR Dataset/train/X_train.txt")) # trainData
trainY <- read.table(unz("data.zip", 
                         filename = "UCI HAR Dataset/train/y_train.txt")) # trainLabel
SubTrain <- read.table(unz("data.zip", 
                         filename = "UCI HAR Dataset/train/subject_train.txt")) # trainSubject
testX <- read.table(unz("data.zip", 
                        filename = "UCI HAR Dataset/test/X_test.txt")) # testData
testY <- read.table(unz("data.zip", 
                        filename = "UCI HAR Dataset/test/y_test.txt")) # testLabel
SubTest <- read.table(unz("data.zip", 
                         filename = "UCI HAR Dataset/test/subject_test.txt")) # testSubject


## 1. Merges the training and the test sets to create one data set.

joinData <- rbind(trainX, testX)
joinLabel <- rbind(trainY, testY)
joinSubject <- rbind(SubTrain, SubTest)


## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 

meanStdIndices <- grep("mean\\(\\)|std\\(\\)", feat[, 2])
joinData <- joinData[, meanStdIndices]
names(joinData) <- gsub("\\(\\)", "", feat[meanStdIndices, 2]) # remove "()"
names(joinData) <- gsub("mean", "Mean", names(joinData)) # capitalize M
names(joinData) <- gsub("std", "Std", names(joinData)) # capitalize S
names(joinData) <- gsub("-", "", names(joinData)) # remove "-" in column names 


## 3. Uses descriptive activity names to name the activities in the data set

activity[, 2] <- tolower(gsub("_", "", activity[, 2]))
substr(activity[2, 2], 8, 8) <- toupper(substr(activity[2, 2], 8, 8))
substr(activity[3, 2], 8, 8) <- toupper(substr(activity[3, 2], 8, 8))
activityLabel <- activity[joinLabel[, 1], 2]
joinLabel[, 1] <- activityLabel
names(joinLabel) <- "activity"


## 4. Appropriately labels the data set with descriptive activity names.

names(joinSubject) <- "subject"
cleanedData <- cbind(joinSubject, joinLabel, joinData)
write.table(cleanedData, "tidyData.txt")


## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

subjectLen <- length(table(joinSubject))
activityLen <- dim(activity)[1]
columnLen <- dim(cleanedData)[2]
result <- matrix(NA, nrow=subjectLen*activityLen, ncol=columnLen) 
result <- as.data.frame(result)
colnames(result) <- colnames(cleanedData)
row <- 1
for(i in 1:subjectLen) {
        for(j in 1:activityLen) {
                result[row, 1] <- sort(unique(joinSubject)[, 1])[i]
                result[row, 2] <- activity[j, 2]
                bool1 <- i == cleanedData$subject
                bool2 <- activity[j, 2] == cleanedData$activity
                result[row, 3:columnLen] <- colMeans(cleanedData[bool1&bool2, 3:columnLen])
                row <- row + 1
        }
}
head(result)
write.table(result, "meansData.txt")


