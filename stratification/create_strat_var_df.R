library(data.table)


dti <- haven::read_sav('~/data/general_data/dataFile_JohnFlournoy_26apr2019.sav')
names(dti) <- (tolower(names(dti)))

dti <- dti[dti$mri_consent %in% 1 & dti$exclude_incidental %in% 0, ]

mri_cleared_idc <- dti[, c('idc', 'mri_consent', 'exclude_incidental')]
mri_cleared_idc$sid <- paste0('sub-', mri_cleared_idc$idc) 
write.csv(mri_cleared_idc, '/home/jflournoy/code/mellon/post_processing/mri_cleared.csv') 

dti$ethninf_3g <- NA

dti$ethninf_3g[dti$ethninfv2==1] = 0
dti$ethninf_3g[dti$ethninfv2==2] = 1
dti$ethninf_3g[dti$ethninfv2==3] = 2
dti$ethninf_3g[dti$ethninfv2==4] = 2
dti$ethninf_3g[dti$ethninfv2==5] = 2
dti$ethninf_3g[dti$ethninfv2==6] = 2
dti$ethninf_3g[dti$ethninfv2==7] = 2
dti$ethninf_3g[dti$ethninfv2==200] = 2
dti$ethninf_3g[dti$ethninfv2==300] = 1
dti$ethninf_3g[dti$ethninfv2==400] = 2
dti$ethninf_3g[dti$ethninfv2==500] = 1
dti$ethninf_3g[dti$ethninfv2==600] = 2
dti$ethninf_3g[dti$ethninfv2==700] = 1
dti$ethninf_3g[dti$ethninfv2==800] = 1
dti$ethninf_3g[is.na(dti$ethninfv2)] = 3
dti$ethninf_3gLab <- factor(dti$ethninf_3g, levels=c(0,1,2,3), labels=c('Dutch', 'Other Western', 'Non-Western','Missing'))

# > table(dti$ethninf_3gLab)
# 
#         Dutch Other Western  Non-Western
#          2320           348          1193

dti$educm_2g = dplyr::case_when(
	dti$educm %in% 0:3 ~ 0,
	dti$educm %in% 4:5 ~ 1,
	is.na(dti$educm) ~ 2)
dti$educm_2gLab <- factor(dti$educm_2g, levels = c(0, 1, 2), labels = c('less than higher, phase 1', 'higher, phase 1 or 2', 'Missing')) 


#> table(dti$educm_2gLab, dti$ethninf_3gLab, useNA='ifany')
#
#            Dutch Other Western Non-Westernr <NA>
#  lt_higher   849           111          783    0
#  higher     1391           212          263    1
#  <NA>         80            25          147   79


#Income at age 5 has the most complete data
dti$inc_4g = dplyr::case_when(
	dti$income5 %in% 1:5 ~ 0,
	dti$income5 %in% 6:7 ~ 1,
	dti$income5 %in% 8:9 ~ 2,
	dti$income5 %in% 10:11 ~ 3,
	is.na(dti$income5) ~ 4)

dti$inc_4gLab <- factor(dti$inc_4g, levels = c(0, 1, 2, 3, 4), labels = c('less than 2400', '2401-3200', '3201-4800', 'greater than 4801', 'Missing'))

dti$child_iq <- dti$f0300178

dti$child_iq_3g <- dplyr::case_when(
	dti$child_iq <= 96 ~ 0,
	dti$child_iq <= 109 ~ 1,
	dti$child_iq > 109 ~ 2,
	is.na(dti$child_iq) ~ 3)

dti$child_iq_3gLab <- factor(dti$child_iq_3g, levels = c(0, 1, 2, 3), labels = c('iq <= 96', '96 < iq <= 109', '109 < iq', 'Missing'))

readr::write_csv(dplyr::select(dti, ethninf_3g, ethninf_3gLab, educm_2g, educm_2gLab, inc_4g, inc_4gLab, gender, child_iq_3g, child_iq_3gLab), 'stratification_data.csv')
