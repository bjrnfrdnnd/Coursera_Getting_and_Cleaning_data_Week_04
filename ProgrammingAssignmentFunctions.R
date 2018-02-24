require(dplyr);
read_data_selected_columns <- function(data_dir, data_kind, col_positions, col_types){
    # helper function to read selected columns from datafiles in a subdirectory
    # reads three kinds of data corresponding to data_kind: feature data, subject data, activity data 
    # Args:
    #   data_dir: the directory where the data are located
    #   data_kind: the kind of data to read: one of "train" or "test"
    #   col_positions: a list as returned from fwf_empty(), but only with the selected columns
    #   col_types: a list with the corresponding types of columns which is passed to read_fwf
    #
    # Returns:
    #   a dataframe containing
    #    * the selected columns from X_{train|test}.txt
    #    * the corresponding subject identifiers found in subject_{train|test}.txt
    #    * the corresponding activity identifiers found in y_{train|test}.txt
    # The data are in
    #   feature data: X_train.txt resp. X_test.txt
    #   subject data: subject_train.txt resp. subject_test.txt
    #   activity data: y_train.txt resp. y_test.txt
    
    # read feature data
    base_FN <- file.path(data_kind,paste("X_",data_kind,".txt",sep=""));
    FN <- file.path(data_dir, base_FN);
    feature_data <- read_fwf(file=FN,
                col_positions = col_positions,
                col_types=col_types)
    
    feature_data <- feature_data %>% mutate(kind=data_kind);
    
    # read subject data
    base_FN <- file.path(data_kind, paste("subject_",data_kind,".txt",sep=""));
    FN <- file.path(data_dir, base_FN);
    subject_data <- read_delim(FN,delim=" ",col_names = "subject_id");
    
    # read activity data
    base_FN <- file.path(data_kind, paste("y_",data_kind,".txt",sep=""));
    FN <- file.path(data_dir, base_FN);
    activity_data <- read_delim(FN,delim=" ",col_names = "activity_id");
    
    data <- cbind(feature_data, subject_data, activity_data);
}

read_data_all_columns <- function(data_dir, 
                                          data_kind, 
                                          vec_features){
    # helper function to read data from a subdirectory
    # reads three kinds of data corresponding to data_kind: feature data, subject data, activity data 
    # Args:
    #   data_dir: the directory where the data are located
    #   data_kind: the kind of data to read: one of "train" or "test"
    #   vec_features: a character vector with the names of all the columns of the feature file X_train.txt resp. X_test.txt
    #
    # Returns:
    #   a dataframe containing all the columns from X_....text, subject_....txt, and y_....txt
    # The data are in
    #   feature data: X_train.txt resp. X_test.txt
    #   subject data: subject_train.txt resp. subject_test.txt
    #   activity data: y_train.txt resp. y_test.txt)
    
    # read feature data
    base_FN <- file.path(data_kind,paste("X_",data_kind,".txt",sep=""));
    FN <- file.path(data_dir, base_FN);
    col_positions <- fwf_empty(FN);
    col_positions$col_names <- vec_features;
    
    feature_data <- read_fwf(file=FN,
                             col_positions = col_positions);
    names(feature_data) <- vec_features;

    # cannot use mutate because column names are not unique
    vec_data_kind <- rep(data_kind,dim(feature_data)[1]);
    feature_data <- cbind(feature_data,data.frame(kind=vec_data_kind));
    
    
    # read subject data
    base_FN <- file.path(data_kind, paste("subject_",data_kind,".txt",sep=""));
    FN <- file.path(data_dir, base_FN);
    subject_data <- read_delim(FN,delim=" ",col_names = "subject_id");
    
    # read activity data
    base_FN <- file.path(data_kind, paste("y_",data_kind,".txt",sep=""));
    FN <- file.path(data_dir, base_FN);
    activity_data <- read_delim(FN,delim=" ",col_names = "activity_id");
    
    # combine the three data sets
    data <- cbind(feature_data, subject_data, activity_data);
}

