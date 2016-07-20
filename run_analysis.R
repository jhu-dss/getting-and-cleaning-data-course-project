# run_analysis.R

library(plyr)
library(reshape2)

# Merges the training and the test sets to create one data set.
DataSet <- NULL
for(cc in c("test", "train")) {
	p1 <- paste(sep = "", "./dataset/", cc, "/subject_", cc, ".txt")
	p2 <- paste(sep = "", "./dataset/", cc, "/y_", cc, ".txt")
	p3 <- paste(sep = "", "./dataset/", cc, "/X_", cc, ".txt")	
	DataSet <- rbind(DataSet, cbind(read.table(p1), read.table(p2), read.table(p3)))
}
Features <- read.table("./dataset/features.txt", col.names = c("id", "name"), stringsAsFactors = FALSE)
Headings <- unlist(Features$name)
names(DataSet) <- c("Subject", "Activity", Headings)

# extracts only the measurements on the mean and standard deviation for each measurement
SubDataSet <- DataSet[c(1, 2, grep("mean|std", names(DataSet), ignore.case = TRUE))]

# Uses descriptive activity names to name the activities in the data set.
ActivityNames <- read.table("./dataset/activity_labels.txt", col.names = c("id", "name"), stringsAsFactors = FALSE)
SubDataSet$Activity <- ActivityNames$name[SubDataSet$Activity]

# Appropriately labels the data set with descriptive variable names.
names(SubDataSet) <- gsub("^f", "Frequency", names(SubDataSet))
names(SubDataSet) <- gsub("mean", "Mean", names(SubDataSet))
names(SubDataSet) <- gsub("std", "StdDev", names(SubDataSet))
names(SubDataSet) <- gsub("^t", "Time", names(SubDataSet))
names(SubDataSet) <- gsub("[[:punct:]]", "", names(SubDataSet))

write.table(SubDataSet, file="first-tidy-data-set.txt",row.names = FALSE)


# creates a 2nd, independent tidy data set with the average of each variable for each activity and each subject
SecondDataSet <- ddply(melt(SubDataSet, id.vars=c("Subject", "Activity")), .(Subject, Activity), summarise, MeanSamples=mean(value))

write.table(SecondDataSet, file="second-tidy-data-set.txt",row.names = FALSE)
