rsfc_deriv_dir = "/data/mounts/scs-fs-20/kpsy/genr/users/jflournoy/rsfc_derivatives/power_drysdale"
pattern = '.*space-MNI152NLin2009cAsym_desc-nuisanced_corrmat.csv'
meanmat = "/data/mounts/scs-fs-20/kpsy/genr/users/jflournoy/rsfc_derivatives/power_drysdale/mean_correlation_matrix.csv"
outdir = rsfc_deriv_dir

library(ggplot2)
library(data.table)
library(parallel)

file_list <- dir(rsfc_deriv_dir, pattern = pattern, recursive=TRUE, full.names = TRUE) 

names(file_list) <- unlist(lapply(file_list, gsub, pattern = '.*(sub-\\d+).*', replacement = '\\1'))

split_flist <- split(file_list, rep(factor(1:2), length.out = length(file_list)))

mean_mat <- fread(meanmat)[, c('r', 'row', 'col')]

mean_mat[, z := atanh(r)]

done <- mclapply(1:length(split_flist), function(flist_id){
	rsfc_dt <- rbindlist(lapply(split_flist[[flist_id]], fread), idcol='sid')[, c('sid', 'r', 'row', 'col')]
	rsfc_dt[, z := atanh(r)]
	rsfc_dt <- merge(rsfc_dt, mean_mat, by = c('row', 'col'), all.x = TRUE, suffixes = c("", "_mean"))
	aplot <- ggplot(rsfc_dt, aes(x = z)) + 
			geom_histogram(alpha = .5, fill = 'blue', bins = 50) +
			geom_histogram(aes(x = z_mean), alpha = .5, fill = 'red', bins = 50) + 
			facet_wrap(~sid, ncol = 4) +
			theme_minimal()
	ggsave(file.path(outdir, sprintf('hist_%03d.pdf', flist_id)), aplot, width = 16, height = 16, units = 'in') 
	
	return(NULL)
}, mc.cores = 5)

