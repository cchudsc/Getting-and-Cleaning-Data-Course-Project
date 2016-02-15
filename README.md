# Getting-and-Cleaning-Data-Course-Project

##Usage of the analysis file:
1. Put the file under your working directory
2. In R, run command:
  * source("run_analysis.R")
3. Tidy dataset for all mean and std measures (in step 4) are named as "allData"
4. Tidy dataset for average measures group by subject and activity are named as "meanBySubjectActivity"

##How the run_analysis.R script works
* The script would define all required file name as variables
```
featureFile = "UCI HAR Dataset\\features.txt"
activityLabelFile = "UCI HAR Dataset\\activity_labels.txt"
trainingDataFile = "UCI HAR Dataset\\train\\X_train.txt"
trainingActivityFile = "UCI HAR Dataset\\train\\y_train.txt"
trainingSubjectFile = "UCI HAR Dataset\\train\\subject_train.txt"
testingDataFile = "UCI HAR Dataset\\test\\X_test.txt"
testingActivityFile = "UCI HAR Dataset\\test\\y_test.txt"
testingSubjectFile = "UCI HAR Dataset\\test\\subject_test.txt"
```    
* When the scripts starts, it will check for required files under folder "UCI HAR Dataset, if any of required file is missing, it would download the dataset from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" and extract the file downloaded in working directory
```
#Download and unzip files
if (!all(file.exists(c(featureFile,activityLabelFile,
                       trainingDataFile,trainingActivityFile,trainingSubjectFile,
                     testingDataFile,testingActivityFile, testingSubjectFile)))) {
    unlink("UCI HAR Dataset", recursive=TRUE)
    download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip","getdata_projectfiles_UCI HAR Dataset.zip")
    unzip("getdata_projectfiles_UCI HAR Dataset.zip")
}
```
* After the file is downloaded, the script would start reading features.txt for all column names and activity_labels.txt for mapping of activity to names
```
#Read features and activity
labels = read.table(featureFile, col.names=c("label_id","measure_name"))
activityLabels = read.table(activityLabelFile, col.names=c("activity_id","activity_name"))
```
* The script will then call the readDataSet(...) function defined to read training dataset and create a tidy training dataset. 
```
#Read and create training data
trainingData = readDataSet(labels$measure_name, activityLabels, "training",
                           trainingDataFile, trainingActivityFile, 
                           trainingSubjectFile)
```
* The `readDataSet <- function (measureName, activityLabels, dataSetName, dataFile, activityDataFile, subjectFile)` function would perform the followings,
  * Read measures from the data file (X_train.txt for training dataset or X_test.txt for testing dataset)
```
data = read.table(dataFile,header=FALSE)
```
  * Select only the mean and std measures from the measures dataset
```
data = select(data,grep("-mean\\(\\)|-std\\(\\)",measureName))
```
  * Rename the dataset columns to descriptive names
```
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
...
names(data) <- renameColumns(grep("-mean\\(\\)|-std\\(\\)",measureName,value=TRUE))
```
  * Read activity data from activity file (y_train.txt for training dataset or y_test.txt for testing dataset) and add an id column to record the line number of the record
```
activity = read.table(activityDataFile,header=FALSE, col.names=c("activity_id"))
activity$id <- 1:nrow(activity)
```
  * Merge activity data with activity_labels.txt loaded in step 2 to map activity name to the activity dataset. After activity name merged, the order of the data is changed. So the script need to arrange activity data in ascending order of the id added in order to resume original record ordering
```
activity = merge(activity, activityLabels, by.x="activity_id",by.y="activity_id", all=TRUE)
activity = activity[order(activity$id),]
```
  * Read subject data from subject file (subject_train.txt for training dataset or subject_test.txt for testing dataset)
```
subject = read.table(subjectFile,header=FALSE, col.names=c("subject"))
```
  * Use the cbind function to combine subuject data, activity data and the measures dataset and return the combined dataset
```
data = cbind(subject, "dataset" = dataSetName, "activity_name" = activity$activity_name,data)
data
```
4. After training dataset is properly formatted and merged with subject and activity data, the script would then call the readDataSet(...) function for the testing dataset
5. When both training dataset and testing dataset are ready, use the rbind() function to combine both training dataset and testing dataset and generate the result dataset named as "allData"
6. After "allData" dataset is created, the dataset is grouped by subject and activity_name, all measures data are aggregated by the mean function.
  * meanBySubjectActivity = aggregate(allData[,4:69],list(allData$subject,allData$activity_name), mean)
7. meanBySubjectActivity dataset is renamed to replace the Group.1 and Group.2 column name to "subject" and "activity_name" respectively
8. The final data is then sort by subject and activity_name
9. Final data is extracted with the write.table() function

