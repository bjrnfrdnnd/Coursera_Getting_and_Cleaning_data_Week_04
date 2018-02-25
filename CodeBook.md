
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

  1. <a id="I-5"></a> The script merges the "train" and "test" dataframes produced by ```read_data_selected_columns``` into a combined R dataframe called "df_data_all" using ```rbind```.

  1. <a id="I-6"></a> The script changes the activity identifiers to activity labels that are found in a [datafile](UCI_HAR_Dataset/activity_labels.txt) in the unzipped data. To perform this taks, the [datafile](UCI_HAR_Dataset/activity_labels.txt) is read using ```read_delim``` into a dataframe called "df_activities". The two resulting columns are named "activity_id" and "activity_label" respectively. The main dataframe "df_data_all" is joined to this dataframe ("df_activities") using ```left_join``` on the only common field name ("activity_id"). The resulting dataframe now has one additional column "activity_label" as compared to the main dataframe "df_data_all". We subsequently drop the "activity_id" column, such that the resulting combined dataframe has the same number of columns as before, but now the column "activity_id" is replaced by a column called "activity_label". The result is written to a [dataframe](df_data_all_activity_labels.Rda) called "df_data_all_activity_labels".

  1. <a id="I-7"></a>The script renames the selected acceleration measurement names to more appropriate names. To do this, the script simply parses the names of the columns with several calls to ```gsub``` exchanging shorthand notation like "Acc" for "Acceleration", adding underscores to separate components, and eliminating "()" from the names. It also seems that there is an error in some column names: The [file with the feature names](UCI_HAR_Dataset/features.txt) lists several features containing the string "BodyBody". We believe this is an error and the substring should read "Body". Therefore, in addition to the other calls to ```gsub```, we also replace "BodyBody" with "Body".

  1. <a id="I-8"></a>The script creates a [summary dataframe](df_data_all_tabled_average.Rda) called "df_data_all_tabled_average" that contains the averages of each measurement for all subjects and activities for the entire dataset (no separation between "train" and "test" data - all data from the combined dataframe is being taken into account). To create this aggregation, a combination of ```group_by``` and ```summarize_all``` is being used.

  1. <a id="I-9"></a> The script splits the [main dataframe](df_data_all_activity_labels.Rda) into two distinct dataframes: one containing only acceleration measurements, one containing only activity observations. This split is done following the concept of tidy data, where each table should only contain one category of variables (here: one table with acceleration variables, one table with activity observations). In addition to the information about acceleration resp. activity, each of the two produced dataframes contains information about the subject identifier and the data kind (train or test) to be able to easily subset the data. The two produced dataframes are:
      1. <a id="I-9-1"></a>An [acceleration dataframe](df_accelerations.Rda) that contains only acceleration measurements
      1. <a id="I-9-2"></a>An [activity dataframe](df_activitykinds.Rda) that contains only observations about the activity that was being performed by the subjects

To summarize, the ```read_data_selected_columns``` custom function returns a dataframe with the following specification (step [I.4](I-4)):

|column name | column type | column content|
| --- | --- | --- |
|"kind"|chr|"train" or "test"|
|"subject_id"|int| an integer between 1 and 30 indicating the subject that was being measured in the corresponding row|
|"activity_id"|int| an integer between 1 and 6 indicating the activity being performed in the corresponding row|
|feature containing either "std()" or "mean()"|num| the acceleration mean or acceleration standard deviation associated with that row and that feature|

The [main R script](run_analysis.R) merges the two dataframes produced by ```read_data_selected_columns```, exchanges the "activity_id" column for a "activity_label" column containing descriptive activity labels, renames the feature names according to [I.7](#I-7) and writes the result to the [combined dataframe](df_data_all_activity_labels.Rda) called "df_data_all_activity_labels". This [combined dataframe](df_data_all_activity_labels.Rda) has the following structure (step [I.7](I-7)):

|column name | column type | column content|
| --- | --- | --- |
|"kind"|chr|"train" or "test"|
|"subject_id"|int| an integer between 1 and 30 indicating the subject that was being measured in the corresponding row|
|"activity_label"|chr| a label that is one of the 6 possible activity types given in the [activity label datafile](UCI_HAR_Dataset/activity_labels.txt): WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, or LAYING |
|feature containing either "std()" or "mean()"|num| the acceleration mean or acceleration standard deviation associated with that row and that feature|

The [summary dataframe](df_data_all_tabled_average.Rda) containing the averages for each subject and each activity type has the following structure (step [I.8](I-8)):

|column name | column type | column content|
| --- | --- | --- |
|"subject_id"|int| an integer between 1 and 30 indicating the subject that was being measured in the corresponding row|
|"activity_label"|chr| a label that is one of the 6 possible activity types given in the [activity label datafile](UCI_HAR_Dataset/activity_labels.txt): WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, or LAYING |
|feature containing either "std()" or "mean()"|num| the average of the acceleration mean or acceleration standard deviation for this subject and this activity|

The [acceleration dataframe](df_accelerations.Rda) has the following structure ((step [I.9.1](I-9-1))):
|column name | column type | column content|
| --- | --- | --- |
|"kind"|chr|"train" or "test"|
|"subject_id"|int| an integer between 1 and 30 indicating the subject that was being measured in the corresponding row|
|feature containing either "std()" or "mean()"|num| the acceleration mean or acceleration standard deviation associated with that row and that feature|

The [activity dataframe](df_activity.Rda) has the following structure ((step [I.9.2](I-9-2))):
|column name | column type | column content|
| --- | --- | --- |
|"kind"|chr|"train" or "test"|
|"subject_id"|int| an integer between 1 and 30 indicating the subject that was being measured in the corresponding row|
|"activity_label"|chr| a label that is one of the 6 possible activity types given in the [activity label datafile](UCI_HAR_Dataset/activity_labels.txt): WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, or LAYING |
