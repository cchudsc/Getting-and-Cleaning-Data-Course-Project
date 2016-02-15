library(dplyr)

renameColumns <- function (columns) {
    columnNames <- gsub("^t","time_",columns)
    columnNames <- gsub("^f","frequency_",columnNames)
    columnNames <- gsub("Acc","_accelerometer_",columnNames)
    columnNames <- gsub("Gyro","_gyroscope_",columnNames)
    columnNames <- gsub("Jerk","_jerk_",columnNames)
    columnNames <- gsub("Mag","_magnitude_",columnNames)
    columnNames <- gsub("BodyBody","_body_",columnNames)
    columnNames <- gsub("-mean\\(\\)","_mean_",columnNames)
    columnNames <- gsub("-std\\(\\)","_std_",columnNames)
    columnNames <- tolower(gsub("_$","",gsub("-","",(gsub("_+","_",columnNames)))))
    columnNames
}

readDataSet <- function (measureName, activityLabels, dataSetName, dataFile, activityDataFile, subjectFile) {
    data = read.table(dataFile,header=FALSE)
    data = select(data,grep("-mean\\(\\)|-std\\(\\)",measureName))
    names(data) <- renameColumns(grep("-mean\\(\\)|-std\\(\\)",measureName,value=TRUE))
    activity = read.table(activityDataFile,header=FALSE, col.names=c("activity_id"))
    activity$id <- 1:nrow(activity)
    activity = merge(activity, activityLabels, by.x="activity_id",by.y="activity_id", all=TRUE)
    activity = activity[order(activity$id),]
    subject = read.table(subjectFile,header=FALSE, col.names=c("subject"))
    data = cbind(subject, "dataset" = dataSetName, "activity_name" = activity$activity_name,data)
    data
    
}

featureFile = "UCI HAR Dataset\\features.txt"
activityLabelFile = "UCI HAR Dataset\\activity_labels.txt"
trainingDataFile = "UCI HAR Dataset\\train\\X_train.txt"
trainingActivityFile = "UCI HAR Dataset\\train\\y_train.txt"
trainingSubjectFile = "UCI HAR Dataset\\train\\subject_train.txt"
testingDataFile = "UCI HAR Dataset\\test\\X_test.txt"
testingActivityFile = "UCI HAR Dataset\\test\\y_test.txt"
testingSubjectFile = "UCI HAR Dataset\\test\\subject_test.txt"

#Download and unzip files
if (!all(file.exists(c(featureFile,activityLabelFile,
                       trainingDataFile,trainingActivityFile,trainingSubjectFile,
                     testingDataFile,testingActivityFile, testingSubjectFile)))) {
    unlink("UCI HAR Dataset", recursive=TRUE)
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","getdata_projectfiles_UCI HAR Dataset.zip")
    unzip("getdata_projectfiles_UCI HAR Dataset.zip")
}

#Read features and activity
labels = read.table(featureFile, col.names=c("label_id","measure_name"))
activityLabels = read.table(activityLabelFile, col.names=c("activity_id","activity_name"))

#Read and create training data
trainingData = readDataSet(labels$measure_name, activityLabels, "training",
                           trainingDataFile, trainingActivityFile, 
                           trainingSubjectFile)

#Read and create testing data
testingData = readDataSet(labels$measure_name, activityLabels, "testing",
                          testingDataFile, testingActivityFile, 
                          testingSubjectFile)


#combine testing and training dataset
allData = rbind(trainingData, testingData)

meanBySubjectActivity = aggregate(allData[,4:69],list(allData$subject,allData$activity_name), mean)
meanBySubjectActivity = rename(meanBySubjectActivity,subject=Group.1,activity_name=Group.2)
meanBySubjectActivity = arrange(meanBySubjectActivity,subject,activity_name)
