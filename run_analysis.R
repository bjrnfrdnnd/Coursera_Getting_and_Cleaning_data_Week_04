# do all tasks
source("ProgrammingAssignmentFunctions.R");
require(readr) 
require(dplyr)

## download the data from the internet
if (1){
    URL <- "https://archive.ics.uci.edu/ml/machine-learning-databases/00240/UCI%20HAR%20Dataset.zip"
    zip_FN <- "UCI_HAR_DATASET.zip";
    download.file(url=URL,destfile = zip_FN);
}

## unzip the file contents
if (1){
    unzip(zipfile = zip_FN);
    data_dir <- unzip (zip_FN,list=T)$Name[1];
    data_dir <- substr(data_dir,1,nchar(data_dir)-1);
    data_dir_new <- gsub(" ","_",data_dir);
    file.rename(data_dir, data_dir_new);
    data_dir <- data_dir_new;
    
}

## Read the names of the features
if (1){
    base_FN <- "features.txt";
    FN <- file.path(data_dir, base_FN);
    col_names <- c("index","feature_name");
    delim <- " ";
    df_feature_names <- read_delim(FN,delim=delim,col_names=col_names);
}

## analysis: do we have multiplicity of feature names?
### print the feature names that occur more than once
if (1){
    #### make a table that counts the number of occurences of each feature
    a <- df_feature_names %>% count(feature_name);
    #### subset only those rows that occur more than once
    df_feature_names_occuring_multiple_times <- a %>% filter(n>1);
    cat("column names that occur more than once:\n");
    print(as.data.frame(df_feature_names_occuring_multiple_times));
}

# so we see that many features occur more than once. 
# Do any of these features fall into the class we are interested in?
# Meaning: are any of these features means or standard deviations?
## check if there are multiple occurences of feature names among the selected features
if (1){
    pat <- ".*mean[(][)]|.*std[(][)]";
    src <- tolower(df_feature_names_occuring_multiple_times$feature_name);
    lvec_selected_features <- grepl(pat,src);
    vec_selected_features <- df_feature_names$feature_name[lvec_selected_features];
    if (sum(lvec_selected_features)>0){
        cat ("OK, even amongst our target features we have some that occur multiple times\n");
    } else{
        cat ("no, amongst our target features none occur multiple times\n");
    }
}
# get the information about feature positions for the selected features
# to prepare reading selected columns from the training and test dataset
if (1){
    # get the information about all positions from the training data set
    base_FN <- file.path("train","X_train.txt")
    FN <- file.path(data_dir, base_FN);
    all_col_positions <- fwf_empty(FN);
    
    # calculate the list of selected features
    pat <- ".*mean[(][)]|.*std[(][)]";
    src <- tolower(df_feature_names$feature_name);
    lvec_selected_features <- grepl(pat,src);
    vec_selected_features <- df_feature_names$feature_name[lvec_selected_features];
    
    # change the list all_col_positions to only contain the information concerning
    # the selected features
    selected_col_positions <- lapply(all_col_positions,function(x){x[lvec_selected_features]});
    selected_col_positions$col_names <- vec_selected_features;
    list_selected_col_types <- as.list(rep("d",length(vec_selected_features))); 
    
    # give the list of col_positions the names of the selected features as given by features.txt
    names(list_selected_col_types) <- vec_selected_features;
    
    # prepare the cols_only argument that we use in read_fwf from package readr 
    # that we call in the custom function read_data_selected_columns
    selected_col_types <- do.call(cols_only,list_selected_col_types);
}

# because our selected feature names are unique, we can proceed to extract them
# and do not have to worry that some features will have the same name
# read the test and training data (selected columns)
# these custom functions read selected columns from the training/test data,
# add a column identifying which data kind a given row belongs to (train or test),
# read subject and activity data from the files referred to in the documentation 
# of the dataset and add this data as new columns to the datasets being read.
# as a result, we have a dataset that contains:
#    the selected features
#    a column identifying the subject
#    a column identifying the activity
#    a column identifying the kind of data (train or test)

if (1){
    train_data <- read_data_selected_columns(data_dir=data_dir,
                                         data_kind="train",
                                         col_positions = selected_col_positions, 
                                         col_types = selected_col_types);
    test_data <- read_data_selected_columns(data_dir=data_dir,
                                        data_kind="test",
                                        col_positions = selected_col_positions, 
                                        col_types = selected_col_types);
}


## merge the training and test data in one total data set
if (1){
    df_data_all <- rbind(train_data, test_data);
}

## mutate the df_data_all dataframe to contain a column with descriptive values
if (1){
    # read the table that links activity labels to activity 
    base_FN <- "activity_labels.txt";
    FN <- file.path(data_dir, base_FN);
    col_names <- c("activity_id","activity_label");
    delim <- " ";
    df_activities <- read_delim(FN,delim=delim,col_names=col_names);
    
    # replace the column with the activity_ids with a column containing the activity_labels
    df_data_all_activity_labels <- df_data_all %>% 
        left_join(df_activities) %>%
        select(-activity_id)
}

# generate more appropriate variable names
if (1){
    a <- names(df_data_all_activity_labels);
    a <- gsub("^t(.*)","temporal\\1",a);
    a <- gsub("^f(.*)","frequency\\1",a);
    # the BodyBody string seems to be an error in the feature list
    a <- gsub("BodyBody","Body",a);
    a <- gsub("Acc","Acceleration",a);
    a <- gsub("Gyro","Gyroscope",a);
    a <- gsub("Mag","Magnitude",a);
    a <- gsub("[(][)]","",a);
    a <- gsub("-","_",a);
    
    # separate all descriptive nouns by an underscore
    sapply(c("Acceleration",
             "Gravity",
             "Gyroscope",
             "Jerk",
             "Magnitude",
             "Body"),
           function(x){a <<- gsub(x,paste("_",x,sep=""),a)}
    )
    
    # replace the names of the dataframe with the vector with more appropriate names
    names(df_data_all_activity_labels) <- a;
}

# apply a better ordering of columns
if (1){
    df1 <- df_data_all_activity_labels %>% select(c(kind,subject_id,activity_label));
    df2 <- df_data_all_activity_labels %>% select(-c(kind,subject_id,activity_label));
    df_data_all_activity_labels <- cbind(df1,df2);
}

# create a table with the mean of all variables for each subject and activity
if (1){
    df_data_all_tabled_average <- df_data_all_activity_labels %>% 
    select(-kind) %>% 
    group_by(subject_id, activity_label) %>% 
    summarize_all(.funs=mean);
    a <- names(df_data_all_tabled_average);
    b <- sapply(a[3:length(a)],function(x){paste(x,"average",sep="_")});
    names(df_data_all_tabled_average)[3:length(a)] <- b;
    # order the rows
    df_data_all_tabled_average <- df_data_all_tabled_average %>%
        arrange(subject_id,activity_label);
    df_data_all_tabled_average <- as.data.frame(df_data_all_activity_labels);
}

# split the main dataset again into acceleration observations and activity observations
# in order to have tidy data: each table should only contain observations of one class
# here, one table will have accelerations
# the other, activity labels
if (1){
    df_accelerations <- df_data_all_activity_labels %>% select(-activity_label)
    df_activitykinds <- df_data_all_activity_labels %>% select(kind, subject_id, activity_label)
}

# save the objects to which we wish to refer
if (1){
    save(df_accelerations,file="df_accelerations.Rda");
    save(df_activitykinds,file="df_activitykinds.Rda");
    save(df_data_all_activity_labels,file = "df_data_all_activity_labels.Rda");
    save(df_data_all_tabled_average,file = "df_data_all_tabled_average.Rda")
}
