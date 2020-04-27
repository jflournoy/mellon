number_of_processes = 7
width = 16
height = 16
units = 'in'
number_of_subs_per_fig = 16
number_of_rows = 4

rsfc_deriv_dir = "~/Desktop/DT_Alln131_rsfc_corrmat//"
pattern = '.*_corrmat.csv'
meanmat = file.path(rsfc_deriv_dir, 'mean_corr_mat.csv')
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
names(file_list) <- unlist(lapply(file_list, gsub, pattern = '.*/(\\d{4})_.*', replacement = '\\1'))

#we need to split this list into groups of size `number_of_subs_per_fig` 
num_unique_groups <- length(file_list) %/% number_of_subs_per_fig + 1
#split it the file list
split_flist <- split(file_list, rep(factor(1:num_unique_groups), length.out = length(file_list)))

# ####
# #Create files to help with QA
# qa_flist_df <- data.frame(pdf = rep(factor(1:num_unique_groups), length.out = length(file_list)), 
#                           sid = gsub('.*sub-(\\d+).*', '\\1', file_list))
# qa_flist_df <- qa_flist_df[order(qa_flist_df$pdf), ]
# qa_flist_10 <- qa_flist_df[qa_flist_df$pdf %in% 1:10, ]
# 
# split_qa_list <- cbind(11:(num_unique_groups), rep(1:2, each = (num_unique_groups-10)/2))
# qa_flist_half_1 <- qa_flist_df[qa_flist_df$pdf %in% split_qa_list[split_qa_list[,2] == 1,1], ]
# qa_flist_half_2 <- qa_flist_df[qa_flist_df$pdf %in% split_qa_list[split_qa_list[,2] == 2,1], ]

# write.csv(qa_flist_half_1, file = file.path('/data/mounts/scs-fs-20/kpsy/genr/users/jflournoy/rsfc_qa/', 'histogram_qa_jannel.csv'), row.names = F)
# write.csv(qa_flist_half_2, file = file.path('/data/mounts/scs-fs-20/kpsy/genr/users/jflournoy/rsfc_qa/', 'histogram_qa_patricia.csv'), row.names = F)
# ####

#We also want the mean correlation mat which we can construct in parallel 
split_for_mean_mat_flist <- split(file_list, rep(factor(1:number_of_processes), length.out = length(file_list)))

mean_mat <- fread(file_list[[1]])
vector_length <- dim(mean_mat)[1]

breaks <- seq(-1, 1, length.out = 51) 

system.time({
  #get a template for the mean correlation data table using the first file
  bin_mat_results <- data.table::rbindlist(mclapply(split_for_mean_mat_flist, function(afilelist){
   data.table::rbindlist(lapply(afilelist, function(fname){
      new_cor_dt <- fread(fname)
      if(any(abs(na.exclude(new_cor_dt$r)) > 1)) stop('Found r > 1')
      return(new_cor_dt[, bin := findInterval(r, breaks)][, .N, by = bin])
    }))
  }, mc.cores = number_of_processes))[, list('count' = sum(N)), by = bin][, count_prop := count/sum(count)]
})

ggplot(bin_mat_results, aes(x = bin, y = count_prop)) + 
  geom_col() + 
  scale_x_continuous(breaks = seq(1, 51, 5), labels = sprintf("%.2f", breaks[seq(1, 51, 5)]))

system.time({
#get a template for the mean correlation data table using the first file
mean_mat_results <- mclapply(split_for_mean_mat_flist, function(afilelist){
	z <- rep(0, vector_length)
	NOTNA <- rep(0, vector_length)  #we need to keep track of how many total values we add in each row

	for (fname in afilelist) {
		new_cor_dt <- fread(fname)
		new_cor_dt[, z := atanh(r)]
		if(any(abs(na.exclude(new_cor_dt$r)) > 1)) stop('Found r > 1')
		z <- rowSums(cbind(z, new_cor_dt$z), na.rm = TRUE)
		NOTNA <- NOTNA + !is.na(new_cor_dt$z)
	}
	return(data.table(z = z, NOTNA = NOTNA))
}, mc.cores = number_of_processes)
})

z_sums <- apply(simplify2array(lapply(mean_mat_results, `[[`, 'z')), 1, sum, na.rm = TRUE) 
not_na_sums <- apply(simplify2array(lapply(mean_mat_results, `[[`, 'NOTNA')), 1, sum) 
mean_mat$z <- z_sums/not_na_sums 

mean_mat <- mean_mat[, c('z', 'row', 'col')]
mean_mat[, r := tanh(z)]

library(ggplot2)
library(patchwork)
reorder_cormat <- function(cormat){
  # Use correlation between variables as distance
  dd <- as.dist((1-cormat)/2)
  hc <- hclust(dd)
  cormat <-cormat[hc$order, hc$order]
}

acormat <- diag(max(c(mean_mat$col, mean_mat$row)))
acormat[upper.tri(acormat)] <- mean_mat$r[order(mean_mat$col, mean_mat$row)]
acormat[lower.tri(acormat)] <- mean_mat$r[order(mean_mat$row, mean_mat$col)]

acormat_reo <- reorder_cormat(acormat)
acormat_reo[lower.tri(acormat_reo)] <- NA
diag(acormat_reo) <- NA
acormat_reo_dt <- data.table::melt(data.table(acormat_reo)[, row := 1:.N], 
                                   id.vars = 'row', 
                                   measure.vars = 1:dim(acormat_reo)[1],
                                   variable.name = 'col', 
                                   na.rm = T)[, col := as.numeric(gsub('V', '', col))]

unordered_p <- ggplot(data = mean_mat, aes(row, col, fill = r))+
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-.5, .5), space = "Lab", 
                       name="Correlation") +
  theme_minimal()+ 
  coord_fixed() + 
  labs(title = 'Unordered')
ordered_p <- ggplot(data = acormat_reo_dt, aes(row, col, fill = value))+
  geom_tile(color = "white") +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-.5, .5), space = "Lab", 
                         name="Correlation") +
  theme_minimal()+ 
  coord_fixed() + 
  labs(title = 'Ordered via hclust')

unordered_p + ordered_p

readr::write_csv(mean_mat, path = meanmat)

done <- mclapply(1:length(split_flist), function(flist_id){
	rsfc_dt <- rbindlist(lapply(split_flist[[flist_id]], fread), idcol='sid')[, c('sid', 'r', 'row', 'col')]
	rsfc_dt[, z := atanh(r)]
	rsfc_bin_dt <- rsfc_dt[, bin := findInterval(r, breaks)][, list('count' = .N), by = c('bin', 'sid')]
	rsfc_bin_dt[, count_prop := count/sum(count), by = sid]
	aplot <- ggplot(rsfc_bin_dt, aes(x = bin, y = count_prop)) + 
	  geom_col(data = bin_mat_results, alpha = .5, aes(fill = 'Group')) + 
	  geom_col(alpha = .5, aes(fill = 'ID')) +
	  facet_wrap(~sid, nrow = number_of_rows) +
	  scale_fill_manual(values = c('Group' = '#BB6A23', 'ID' = '#2A5078'), name = "") +
	  scale_x_continuous(breaks = seq(1, 51, 5), labels = sprintf("%.2f", breaks[seq(1, 51, 5)])) +
	  theme_minimal()
	ggsave(file.path(outdir, sprintf('hist_%03d.pdf', flist_id)), aplot, width = width, height = height, units = units) 
	
	return(NULL)
}, mc.cores = number_of_processes)

