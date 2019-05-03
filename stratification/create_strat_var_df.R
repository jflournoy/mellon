library(data.table)


rsfcml <- haven::read_sav('~/data/general_data/dataFile_JohnFlournoy_26apr2019.sav')
names(rsfcml) <- (tolower(names(rsfcml)))

rsfcml <- rsfcml[rsfcml$mri_consent %in% 1 & rsfcml$exclude_incidental %in% 0, ]

mri_cleared_idc <- rsfcml[, c('idc', 'mri_consent', 'exclude_incidental')]
mri_cleared_idc$sid <- paste0('sub-', mri_cleared_idc$idc) 
write.csv(mri_cleared_idc, '/home/jflournoy/code/mellon/post_processing/mri_cleared.csv') 

rsfcml$ethninf_3g <- NA

rsfcml$ethninf_3g[rsfcml$ethninfv2==1] = 0
rsfcml$ethninf_3g[rsfcml$ethninfv2==2] = 1
rsfcml$ethninf_3g[rsfcml$ethninfv2==3] = 2
rsfcml$ethninf_3g[rsfcml$ethninfv2==4] = 2
rsfcml$ethninf_3g[rsfcml$ethninfv2==5] = 2
rsfcml$ethninf_3g[rsfcml$ethninfv2==6] = 2
rsfcml$ethninf_3g[rsfcml$ethninfv2==7] = 2
rsfcml$ethninf_3g[rsfcml$ethninfv2==200] = 2
rsfcml$ethninf_3g[rsfcml$ethninfv2==300] = 1
rsfcml$ethninf_3g[rsfcml$ethninfv2==400] = 2
rsfcml$ethninf_3g[rsfcml$ethninfv2==500] = 1
rsfcml$ethninf_3g[rsfcml$ethninfv2==600] = 2
rsfcml$ethninf_3g[rsfcml$ethninfv2==700] = 1
rsfcml$ethninf_3g[rsfcml$ethninfv2==800] = 1
rsfcml$ethninf_3g[is.na(rsfcml$ethninfv2)] = 3
rsfcml$ethninf_3gLab <- factor(rsfcml$ethninf_3g, levels=c(0,1,2,3), labels=c('Dutch', 'Other Western', 'Non-Western','Missing'))

# > table(rsfcml$ethninf_3gLab)
# 
#         Dutch Other Western  Non-Western
#          2320           348          1193

rsfcml$educm_2g = dplyr::case_when(
	rsfcml$educm %in% 0:3 ~ 0,
	rsfcml$educm %in% 4:5 ~ 1,
	is.na(rsfcml$educm) ~ 2)
rsfcml$educm_2gLab <- factor(rsfcml$educm_2g, levels = c(0, 1, 2), labels = c('less than higher, phase 1', 'higher, phase 1 or 2', 'Missing')) 


#> table(rsfcml$educm_2gLab, rsfcml$ethninf_3gLab, useNA='ifany')
#
#            Dutch Other Western Non-Westernr <NA>
#  lt_higher   849           111          783    0
#  higher     1391           212          263    1
#  <NA>         80            25          147   79


#Income at age 5 has the most complete data
rsfcml$inc_4g = dplyr::case_when(
	rsfcml$income5 %in% 1:5 ~ 0,
	rsfcml$income5 %in% 6:7 ~ 1,
	rsfcml$income5 %in% 8:9 ~ 2,
	rsfcml$income5 %in% 10:11 ~ 3,
	is.na(rsfcml$income5) ~ 4)

rsfcml$inc_4gLab <- factor(rsfcml$inc_4g, levels = c(0, 1, 2, 3, 4), labels = c('less than 2400', '2401-3200', '3201-4800', 'greater than 4801', 'Missing'))

rsfcml$child_iq <- rsfcml$f0300178

rsfcml$child_iq_3g <- dplyr::case_when(
	rsfcml$child_iq <= 96 ~ 0,
	rsfcml$child_iq <= 109 ~ 1,
	rsfcml$child_iq > 109 ~ 2,
	is.na(rsfcml$child_iq) ~ 3)

rsfcml$child_iq_3gLab <- factor(rsfcml$child_iq_3g, levels = c(0, 1, 2, 3), labels = c('iq <= 96', '96 < iq <= 109', '109 < iq', 'Missing'))

rsfcml$genderLab <- factor(rsfcml$gender, levels = attr(rsfcml$gender, 'labels'), labels = names(attr(rsfcml$gender, 'labels')))

#condsidered age as well, but most kids came in just before or just after age 10
#this histogram is really nice for this.

rsfcml_to_write <- dplyr::select(rsfcml, idc,mri_consent, exclude_incidental, gender, genderLab, ethninf_3g, ethninf_3gLab, educm_2g, educm_2gLab, inc_4g, inc_4gLab, gender, child_iq_3g, child_iq_3gLab)
rsfcml_to_write$sid <- paste0('sub-', rsfcml_to_write$idc)
readr::write_csv(rsfcml_to_write, '~/data/general_data/stratification_data.csv')

#Create a file that takes into account resting-state exclusions:

rs_inclusion <- fread('../post_processing/inclusions_desc-MNI_space_processed.csv')

rsfcml_to_write_rs_incl <- as.data.table(rsfcml_to_write)[rs_inclusion, on = 'sid']
readr::write_csv(rsfcml_to_write_rs_incl, '~/data/general_data/stratification_data_rs_incl.csv')

