library(data.table)
#this is set up for the MNI space data at the moment.
#The misc_issues data might change per data source.

desc = "MNI_space_processed"

#boldrefcheck <- fread('bold_ref_movie_checked.csv')
#histcheck <- fread('histogram_qa.csv')
few_vols <- setkey(fread('sids_with_too_few_volumes.csv'), sid)
misc_issues <- setkey(fread('miscellaneous_issues_list.csv', header=TRUE), sid)
mri_cleared <- setkey(fread('mri_cleared.csv'), sid)[,-c('V1', 'idc')]
has_data <- fread('rs_bold_preproc_file_list.txt', col.names='file')

#get unique ids of participants who have either MNI or T1w data from fmriprep
has_data <- unique(has_data[,c('sid', 'has_data', 'file') := .(gsub('.*(sub-\\d+).*', '\\1', file), 1, NULL)])

#use only those who have consent and no exclusions from incidental findings
has_data_cleared <- mri_cleared[has_data, on = 'sid']

#remove those with too little data
has_data_cleared_goodvols <- has_data_cleared[!few_vols, on = 'sid']

#ADD QA ASSESSMENT HERE

#Finally, remove those with unresovled misc_issues
# -- to do, consider filtering on !misc_issues$resolved
subs_to_include <- has_data_cleared_goodvols[!misc_issues, on = 'sid']

readr::write_csv(subs_to_include, paste0('inclusions_desc-', desc, '.csv'))
