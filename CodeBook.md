
# Codebook
## Introduction
This is the codebook belonging to the task of data tidying
for the programming assignment of week 4 of the coursera course "Getting and cleaning data".

We will explain the data used, the processing steps and the R scripts involved, and the dataframes produced (We only produced dataframe objects, objects of other class only served temporary intermediate purposes).

## Process
As outlined in the [Implementation](README.md#implementation) Part of the [readme](README.md), the [R script](run_analysis.R) performs 9 tasks. We will detail the steps and the data involved in the following.

  1. <a id="I-1"></a> The script simply downloads the zip file containing the data into the current working directory.
  1. <a id="I-2"></a> The script unzips the data, creating a subdirectory called [UCI_HAR_Dataset](UCI_HAR_Dataset).
  1. <a id="I-3"></a> The script analyses the [feature list](UCI_HAR_Dataset/features.txt) given in the data. It therefore loads its content into the dataframe "df_feature_names" using ```read_delim``` from package "readr" and identifies the features that contain only the mean and standard deviation for each measurement. For this task, it uses ```grepl``` with the UCI_HAR_Dlar expression pattern ```.*mean[(][)]|.*std[(][)]``` on all feature names that are found in the column with name "feature_name" in "df_feature_names".
  1. <a id="I-4"></a>The script then reads the feature names that match the regular expression given in [I.3](#I-3) from the datafiles in the [UCI_HAR_Dataset](UCI_HAR_Dataset) subdirectory. These files contain 561 features but only 66 of these are matched by the the regular expression pattern ```.*mean[(][)]|.*std[(][)]```. The script reads these 66 fields from the [training](UCI_HAR_Dataset/train/X_train.txt) and [test files](UCI_HAR_Dataset/test/X_test.txt) in the [UCI_HAR_Dataset](UCI_HAR_Dataset) directory. To perform this task, a custom function called ```read_data_selected_columns``` defined in [an R file with supporting functions](ProgrammingAssignmentFunctions.R) is being used. This function makes use of ```read_fwf``` from the "readr" package to read this fixed-width data. In order to read only selected data, the arguments ```col_positions``` and ```col_types``` for ```read_fwf``` are prepared in the main [R script](run_analysis.R) and passed as arguments to the ```read_data_selected_columns``` function. The custom function also adds fields containing subject identifier and activity identifier that are found in the files "subject_xxx.txt" and "y_xxx.txt" respectively. Here, "xxx" stands for either "train" or "test". The "train" variety of files are found in the [train subdirectory](UCI_HAR_Dataset/train), whereas the "test" variety of files are found in the [test subdirectory](UCI_HAR_Dataset/train). The subject identifier information is added to the features as "subject_id" and "activity_id" columns, respectively. In addition, a "kind" column is added that reads "train" for data read in the [train subdirectory](UCI_HAR_Dataset/train).
  The ```read_data_selected_columns``` custom function returns a dataframe with the following specification:

  |column name | column type | column content|
  | --- | --- | --- |
  |"kind"|chr|"train" or "test"|
  |"activity_id"|int| an integer between 1 and 6 indicating the activity being performed in the corresponding row|
  |"subject_id"|int| an integer between 1 and 30 indicating the subject that was being measured in the corresponding row|
  |feature containing either "std()" or "mean()"|num| the acceleration mean or standard deviation associated with that row and that feature|


  1. <a id="I-5"></a>Merges the datasets into a combined R dataset
  1. <a id="I-6"></a>Changes the activity identifiers to activity labels that are found in a [datafile](UCI_HAR_Dataset/activity_labels.txt) in the unzipped data
  1. <a id="I-7"></a>Renames the selected acceleration measurement names to more appropriate names
  1. <a id="I-8"></a>Creates a [dataframe](df_data_all_tabled_average.Rda) that contains the averages of each measurement for all subjects and activities for the entire dataset (including train and test data)
  1. <a id="I-9"></a>According to tidy data, each table should only contain one category of variables. We therefore split the main [dataframe](df_data_all_activity_labels.Rda) created in step (8.) into two dataframes. The data in each sub-dataframe contains information about the subject identifier and the data kind (train or test):
      1. <a id="I-9-1"></a>An [acceleration dataframe](df_accelerations.Rda) that contains only acceleration measurements
      1. <a id="I-9-1"></a>An [activity dataframe](df_activitykinds.Rda) that contains only observations about the activity that was being performed by the subjects

The observation time is encoded by the row number. Each row (within a subject_id) corresponds to a timeframe defined by the row number. Reordering of rows in only one of the produced dataframes ([acceleration dataframe](df_accelerations.Rda) or  [activity dataframe](df_activitykinds.Rda)) will therefore result in a wrong attribution of activity labels to accelerations. If one wishes to rearrange rows, the same reordering has to be applied to both dataframes.

## Installation and Usage
You can clone this repository, which will automatically download all the data and scripts necessary to perform the calculations. In the cloned Repo, you can then run the main [R script](run_analysis.R). This will again download the data and then perform all the steps detailed in [Implementation](#implementation). In order to focus on sub-parts of the analysis, you can choose to only execute parts of the code given in [R script](run_analysis.R): all of the code blocks are enclosed in conditionals that allow the user to execute only parts of the code. You have to edit the source code in [R script](run_analysis.R) though.

## Remarks
The original task list given by the instructors contains 5 points. The task list says to create an R script that:
  1. <a id="T-1"></a>Merges the training and the test sets to create one data set.
  2. <a id="T-2"></a>Extracts only the measurements on the mean and standard deviation for each measurement.
  3. <a id="T-3"></a>Uses descriptive activity names to name the activities in the data set
  4. <a id="T-4"></a>Appropriately labels the data set with descriptive variable names.
  5. <a id="T-5"></a>From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

We call these points [T.1](#T-1) to [T.5](#T-5). In the [Implementation](README.md#implementation) part we have listed 10 Points. We call these [I.1](#I-1) to [I.9](#I-9).

  * Points [I.1](#I-1) and [I.2](#I-2) were added; they add the functionality of downloading the data directly.
  * Point [I.3](#I-3) and [I.4](#I-4) concern the reading of selected features (mean and std) into dataframes. This corresponds to [T.2](#T-2) Note that these steps also add additional information. This task was not explicitly given in the instructor's list of tasks, but the added information is needed for further analysis (splitting into train and test data, subject information, prediction of activities).
  * Point [I.5](#I-5) corresponds to [T.1](#T-1) We have inversed the order of Task [T.1](#T-1) and [T.2](#T-2) for 2 reasons:
      1. Reading only selected features and then merging is faster and reguires less memory than reading all features, then merging, and then selecting
      2. Some features can not be distinguished from others as they have the same feature name. This makes treatment using the names of columns more complicated (Though not impossible: workarounds exist, e.g. not using the names of columns but using the position of columns). The features we are interested in (mean and std features) are all unique, thus reading these selected features creates a dataframe with well-defined column names.

  * Point [I.6](#I-6) corresponds to [T.3](#T-3)
  * Point [I.7](#I-7) corresponds to [T.4](#T-4)
  * Point [I.8](#I-8) corresponds to [T.5](#T-5)
  * Point [I.9](#I-9) does not correspond to any specific task given by the instructors, but it does follow the principle of tidy data that stipulates that each data should only contain variables of the same category.

In summary, we obtain the following table that links the implementation points [I.1](#I-1) to [I.9](#I-9) to the task points [T.1](#T-1) to [T.5](#T-5):

| Implementation Points | Task Points | Short Description |
| --------------------- | ----------- | --- |
| [I.1](#I-1) and [I.2](#I-2) | #N/A |downloading of the data from the internet   |
| [I.3](#I-3) and [I.4](#I-4) | [T.2](#T-2) | reading of selected features into R dataframes |
| [I.5](#I-5) | [T.1](#T-1) | Merging of datasets |
| [I.6](#I-6) | [T.3](#T-3) | Descriptive activity labels |
| [I.7](#I-7) | [T.4](#T-4) | Appropriate variable names |
| [I.8](#I-8) | [T.5](#T-5) | Creation of summary dataframe |
| [I.9](#I-9) | #N/A | Splitting of main data into two datasets for each category of variable |
