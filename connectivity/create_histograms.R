number_of_processes = 5
width = 16
height = 16
units = 'in'
number_of_subs_per_fig = 16
number_of_rows = 4

rsfc_deriv_dir = "/data/mounts/scs-fs-20/kpsy/genr/users/jflournoy/rsfc_derivatives/power_drysdal/"
pattern = '.*space-MNI152NLin2009cAsym_desc-nuisanced_corrmat.csv'
meanmat = "/data/mounts/scs-fs-20/kpsy/genr/users/jflournoy/rsfc_derivatives/power_drysdal/mean_correlation_matrix.csv"
outdir = file.path(rsfc_deriv_dir, 'histograms') 

if (!dir.exists(outdir)){
	message('Output directory ', outdir, ' does not exist. Creating it...')
	dir.create(outdir)
}

library(ggplot2)
library(data.table)
library(parallel)

#get directory listing of all rs cor mat csv files
file_list <- dir(rsfc_deriv_dir, pattern = pattern, recursive=TRUE, full.names = TRUE) 
#set the names so we can keep track of them for the plots
names(file_list) <- unlist(lapply(file_list, gsub, pattern = '.*(sub-\\d+).*', replacement = '\\1'))

#we need to split this list into groups of size `number_of_subs_per_fig` 
num_unique_groups <- length(file_list) %/% number_of_subs_per_fig + 1
#split it the file list
split_flist <- split(file_list, rep(factor(1:number_of_subs_per_fig), length.out = length(file_list)))

#We also want the mean correlation mat which we can construct in parallel 
split_for_mean_mat_flist <- split(file_list, rep(factor(1:number_of_processes), length.out = length(file_list)))

mean_mat <- fread(file_list[[1]])
vector_length <- dim(mean_mat)[1]

system.time({
#get a template for the mean correlation data table using the first file
mean_mat_results <- mclapply(split_for_mean_mat_flist, function(afilelist){
	r <- rep(0, vector_length)
	NOTNA <- rep(0, vector_length)  #we need to keep track of how many total values we add in each row

	for (fname in afilelist) {
		new_cor_dt <- fread(fname)
		if(any(abs(na.exclude(new_cor_dt$r)) > 1)) stop('Found r > 1')
		r <- rowSums(cbind(r, new_cor_dt$r), na.rm = TRUE)
		NOTNA <- NOTNA + !is.na(new_cor_dt$r)
	}
	return(data.table(r = r, NOTNA = NOTNA))
}, mc.cores = number_of_processes)
})

r_sums <- apply(simplify2array(lapply(mean_mat_results, `[[`, 'r')), 1, sum, na.rm = TRUE) 
not_na_sums <- apply(simplify2array(lapply(mean_mat_results, `[[`, 'NOTNA')), 1, sum) 
mean_mat$r <- r_sums/not_na_sums 

mean_mat <- mean_mat[, c('r', 'row', 'col')]
mean_mat[, z := atanh(r)]

readr::write_csv(mean_mat, path = meanmat)

done <- mclapply(1:length(split_flist), function(flist_id){
	rsfc_dt <- rbindlist(lapply(split_flist[[flist_id]], fread), idcol='sid')[, c('sid', 'r', 'row', 'col')]
	rsfc_dt[, z := atanh(r)]
	rsfc_dt <- merge(rsfc_dt, mean_mat, by = c('row', 'col'), all.x = TRUE, suffixes = c("", "_mean"))
	aplot <- ggplot(rsfc_dt, aes(x = z)) + 
			geom_histogram(alpha = .5, fill = 'blue', bins = 50) +
			geom_histogram(aes(x = z_mean), alpha = .5, fill = 'red', bins = 50) + 
			facet_wrap(~sid, nrow = number_of_rows) +
			theme_minimal()
	ggsave(file.path(outdir, sprintf('hist_%03d.pdf', flist_id)), aplot, width = width, height = height, units = units) 
	
	return(NULL)
}, mc.cores = number_of_processes)

