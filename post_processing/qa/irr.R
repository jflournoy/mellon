library(irr)
library(data.table)

r1 <- read.csv('/home/jflournoy/code/mellon/post_processing/qa/histogram_qa_jcf.csv')
r2 <- read.csv('/home/jflournoy/code/mellon/post_processing/qa/histogram_qa_test1.csv')
r3 <- read.csv('/home/jflournoy/code/mellon/post_processing/qa/histogram_qa_test2.csv')

ratings_l <- rbindlist(list(r1 = r1, r2 = r2, r3 = r3), idcol = 'rater')[,.(rater, sid, score)]
ratings <- dcast(ratings_l, sid~rater)

irr::kappam.fleiss(ratings[,.(r1, r2, r3)], detail = T)
