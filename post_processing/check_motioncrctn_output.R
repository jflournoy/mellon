
#!/data/mounts/scs-fs-20/kpsy/software/tools/R/3.4.3/bin/Rscript
#
# Usage:
# Rscript scriptname.R Directory Search_pattern
#
# Example:
#
# Rscript check_motioncrctn_output.R ~/data/GenR_motion ".*space-MNI152NLin2009cAsym_desc-outlierstat.csv"

TR=1.76
MIN_MINUTES=4.5
min_trs=MIN_MINUTES*60/TR

args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 2 | length(args) > 2){
	stop(paste0("Must include two, and only two arguments:
1. the name of the directory, 
2. and the search pattern.
Args are: ",
paste(args, collapse = "\n")))
}
search_dir <- args[1]
search_pattern <- args[2]

message("Searching ", search_dir, " for ", search_pattern)

library(data.table)

if (!dir.exists(search_dir)){
	stop(paste0(search_dir, " does not exist."))
}

files <- dir(search_dir, 
             pattern = search_pattern, 
             recursive = T, full.names = T)

if (length(files) == 0){
	stop("No files found. Check your search pattern?")
} else {
	message("Found ", length(files), " files.\nAgglomerating them...")
}

df_list <- lapply(files, fread)
names(df_list) <- gsub('.*(sub-\\d+.*)_space.*', '\\1', files)
df <- rbindlist(df_list, idcol = 'file')

df[,V1 := NULL]
df <- df[variable == 'total']
df[,variable := NULL]
df[,total := outliers + clean_trs]
df[,sid := gsub('(sub-\\d+).*', '\\1', file)]

#Count number of subjects with <200 volumes, and with < min_trs volumes
summary_of_df <- df[, .(total = .N, 
                        `<200` = sum(total < 200), 
                        `<4.5 min` = sum(clean_trs < min_trs))]

sids_with_short_runs <- df[total < 200, .(sid, total)]
sids_with_much_bad_data <- df[clean_trs < min_trs, .(sid, clean_trs)]

all_bad_sids <- merge(sids_with_short_runs, sids_with_much_bad_data, by = "sid", all =T)

write.csv(all_bad_sids, file = "all_bad_sids.csv", row.names = T)

message(
"Found ", summary_of_df$total, " motion correction summary files.
Of these, ", summary_of_df$`<200`, " had fewer than 200 volumes to begin with.
After motion exclusions, ", summary_of_df$`<4.5 min`, " have fewer than 4.5 minutes (", ceiling(min_trs) ," TRs) of good data.
You can find a full accounting of these participants in 'all_bad_sids.csv'."
)

