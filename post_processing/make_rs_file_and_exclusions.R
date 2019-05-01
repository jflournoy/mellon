file_list <- readr::read_csv('rs_MNI_denuisanced_file_list.csv', col_names = 'file')
file_list$sid <- gsub('.*(sub-\\d+).*', '\\1', file_list$file)
file_list$exclude <- 0
readr::write_csv(file_list, 'rs_files_and_exclusions.csv')
