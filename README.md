
# Tidying Data
## Introduction
This is the programming assignment of week 4 of the coursera course "Getting and cleaning data".

The task is to take some data and prepare it into tidy data specified by the instructors.

The data to be used for the task is accelerometer data from the Samsung Galaxy S smartphone available [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

## Implementation
For this task, we wrote an [R script](run_analysis.R) that performs the following tasks:

  1. Downloads the accelerometer data from the website into the current directory
  1. Unzips the data, creating a subdirectory called [UCI HAR Dataset](UCI HAR Dataset)
  1. Analyses the feature list given in the dataset, and identifies the features that contain only the mean and standard deviation for each measurement
  1. Reads these selected features from the datafiles in the [UCI HAR Dataset](UCI HAR Dataset) subdirectory (both training and test data) into R dataframes
  1. Adds information about subject identifiers, activity identifiers, and data kind ("test" or "train") for each observation in these datasets
  1. Merges the datasets into a combined R dataset
  1. Changes the activity identifiers to activity labels that are found in a [datafile](UCI HAR Dataset/activity_labels.txt) in the unzipped data
  1. Renames the individual, selected acceration measurements to more appropriate titles
  1. Creates a [dataframe](data_all_tabled_average) that contains the averages of each measurement for all subjects and activities for the entire dataset (including train and test data)
  1. According to tidy data, each table should only contain one category of variables. We therefore split the main [dataframe](data_all_activity_labels) created in step (8.) into two dataframes:
      1. An [acceleration dataframe](df_accelerations) that contains only acceleration measurements
      1. An [activity dataframe](df_activitykinds) that contains only observations about the activity that was being performed by the subjects
  <p></p>The data in each sub-dataframe contains information about the subject identifier and the data kind (train or test).

The observation time is encoded by the row number. Each row (within a subject_id) corresponds to a timeframe defined by the row number. Reordering of rows in only one of the produced dataframes ([acceleration dataframe](df_accelerations) or  [activity dataframe](df_activitykinds)) will therefore result in a wrong attribution of activity labels to accelerations. If one wishes to rearrange rows, the same reordering has to be applied to both dataframes.

1. point 1
1. point 2
    1. point 2.1
    1. point 2.2
