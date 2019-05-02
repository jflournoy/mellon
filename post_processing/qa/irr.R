library(irr)
library(data.table)

r1 <- read.csv('/home/jflournoy/code/mellon/post_processing/qa/histogram_qa_jcf.csv')
r2 <- read.csv('/home/jflournoy/code/mellon/post_processing/qa/ReliabilityCheck_patricia.csv')[, -1]
r3 <- read.csv('/home/jflournoy/code/mellon/post_processing/qa/reliability_qa_jk.csv')[, -1]

ratings_l <- rbindlist(list(r1 = r1, r2 = r2, r3 = r3), idcol = 'rater', fill = TRUE)[,.(rater, sid, score)]
ratings_bin_l <- ratings_l
ratings_bin_l$score <- dplyr::case_when(ratings_bin_l$score %in% 0 ~ 0,
                                        ratings_bin_l$score %in% 1:2 ~ 1,
                                        TRUE ~ NA_real_)
ratings <- dcast(ratings_l, sid~rater)
ratings_bin <- dcast(ratings_bin_l, sid~rater)

irr::kappam.fleiss(ratings[,.(r1, r2, r3)], detail = T)
irr::kappam.fleiss(ratings_bin[,.(r1, r2, r3)], detail = T)

ratings_ <- merge(ratings, r1[, c('sid', 'pdf')])

ratings_disagree <- ratings_[ratings_$r1 != ratings_$r2, ]
ratings_disagree[order(ratings_disagree$pdf), ]

ratings_disagree <- ratings_[ratings_$r1 != ratings_$r3, ]
ratings_disagree[order(ratings_disagree$pdf), ]
