#Provided a directory, collects all filenames and full file contents into a single csv file.
#Each cell in the second column is the un-parsed contents of the file specified in the first column

library(data.table)
library(dplyr)
library(readr)

DIRNAME="/home/jflournoy/code/mellon/post_processing/isRunning_motion_correction"
PATTERN=".*"

message("Searching for error files in ", DIRNAME, "...")
file_list <- dir(DIRNAME, pattern = PATTERN, full.names = TRUE)
file_contents <- lapply(file_list, function(filename) { df <- tibble(file = filename, content = list(read_file(filename))) })
file_df <- bind_rows(file_contents)

file_df$errortype <- case_when( grepl('does not exist', file_df$content) ~ 'file missing' , grepl('3dDespike failed', file_df$content) ~ '3dDespike')
file_df$sid <- gsub('.*(sub-\\d+).*', '\\1', file_df$file)

message("Found ", dim(file_df)[1], " files.")
message("Error types are: ")
message(table(file_df$errortype))
message("Writing out to ", getwd(), "/sids_with_nuisance_correction_errors.csv")
write.csv(select(file_df, sid, errortype, file), 'sids_with_nuisance_correction_errors.csv', row.names = FALSE)
