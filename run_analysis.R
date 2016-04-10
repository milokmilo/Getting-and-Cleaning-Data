
# Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. A Public Domain Dataset for Human Activity Recognition Using Smartphones. 21th European Symposium on Artificial Neural Networks, Computational Intelligence and Machine Learning, ESANN 2013. Bruges, Belgium 24-26 April 2013.

# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.
# From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


if (!file.exists("data.zip")){
        url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"       
        download.file(url, "data.zip")
}

activity <- read.table(unz("data.zip",  filename = "UCI HAR Dataset/activity_labels.txt"),
                              col.names=c("activity_id","activity_name"))
feat <- read.table(unz("data.zip", 
                         filename = "UCI HAR Dataset/features.txt")) # features
feat_names <-  feat[,2]
trainX <- read.table(unz("data.zip", 
                         filename = "UCI HAR Dataset/train/X_train.txt")) # traindata
colnames(trainX) <- feat_names
trainY <- read.table(unz("data.zip", 
                         filename = "UCI HAR Dataset/train/y_train.txt")) # train_activity_id
colnames(trainY) <- "activity_id"
SubTrain <- read.table(unz("data.zip", 
                         filename = "UCI HAR Dataset/train/subject_train.txt")) # train_subject_id
colnames(SubTrain) <- "subject_id"
testX <- read.table(unz("data.zip", 
                        filename = "UCI HAR Dataset/test/X_test.txt")) # testdata
colnames(testX) <- feat_names
testY <- read.table(unz("data.zip", 
                        filename = "UCI HAR Dataset/test/y_test.txt")) # test_activity_id
colnames(testY) <- "activity_id"
SubTest <- read.table(unz("data.zip", 
                         filename = "UCI HAR Dataset/test/subject_test.txt")) # test_subject_id
colnames(SubTest) <- "subject_id"

test_data <- cbind(SubTest , testY , testX)

train_data <- cbind(SubTrain , trainY , trainX)

all_data <- rbind(train_data,test_data)

mean_col_idx <- grep("mean",names(all_data),ignore.case=TRUE)
mean_col_names <- names(all_data)[mean_col_idx]
std_col_idx <- grep("std",names(all_data),ignore.case=TRUE)
std_col_names <- names(all_data)[std_col_idx]
meanstddata <-all_data[,c("subject_id","activity_id",mean_col_names,std_col_names)]

descrnames <- merge(activity, meanstddata,
                    by.x="activity_id",
                    by.y="activity_id",
                    all=TRUE)

library(reshape2)
data_melt <- melt(descrnames,id=c("activity_id","activity_name","subject_id"))

mean_data <- dcast(data_melt,activity_id + activity_name + subject_id ~ variable,mean)

write.table(mean_data,"tidyData.txt")



