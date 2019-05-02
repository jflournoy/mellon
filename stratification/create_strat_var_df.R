library(data.table)


dti <- haven::read_sav('~/data/general_data/dataFile_JohnFlournoy_26apr2019.sav')
names(dti) <- (tolower(names(dti)))

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
dti$ethninf_3gLab <- factor(dti$ethninf_3g, levels=c(0,1,2), labels=c('Dutch', 'Other Western', 'Non-Westernr'))

# > table(dti$ethninf_3gLab)
# 
#         Dutch Other Western  Non-Westernr
#          4948           865          3409


