# install.packages('BiocManager')
# BiocManager::install('impute', version = '3.8')
# install.packages('PMA')

#steps: 
# 1. find the best tuning parameter
# 2. determine best number of CVs
# 3. compute sCCA
# 4. compute p-value on permuted data
# 5. check CV accuracy of this procedure?

library(PMA)

#make some fake data

make_fake_data <- function(N, j_X, k_Y){
  nvars <- j_X + k_Y
  amat <- MASS::mvrnorm(n = N, mu = rep(0, nvars), Sigma = diag(nvars))
  X <- amat[, 1:j_X]
  Z <- amat[, (j_X+1):(j_X+k_Y)]
  return(list(X = X, Z = Z))
}

set.seed(9929) #so that output is the same
somedata <- make_fake_data(300, 40, 19*18/2)
X <- somedata$X # pretend each is a self report item
Z <- somedata$Z # pretend each is a connectivity value

#check out the help file: 
#?PMA::CCA
#?PMA::CCA.permute

#Choose tuning parameter based on the first canonical variates
#Basically what's going on here is this:
#For each pair of tuning parameters (the penalties), the rows of X are shuffled
#(so they no longer correspond to to the rows of Y -- this is makes the null
#hypothesis true). A CCA is computed and the correlation between the canonical
#variates is found, c*_i for each of i permutations. The correlation of the
#canonical variates on the unpermuted data is also found, called c. All c*, and
#c, are transformed using fisherz transformation. Then a Z statistic is computed
#that looks at how extreme the original data correlation is in reference to the
#distribution of c* computed on the shuffled/permuted data. We want tuning
#parameters that maximize the correlation in the real data relative to the null.
#The z statistic is just:
# (Fisher(c) - mean(Fisher(c*))) / sd(Fisher(c*))
#

system.time(acca <- CCA.permute(X, Z, typex = 'standard', typez = 'standard', nperms = 100))
print(acca)
plot(acca)

acca2 <- CCA(X, Z, typex = 'standard', typez = 'standard', 
             penaltyx = acca$bestpenaltyx,
             penaltyz = acca$bestpenaltyz,
             K = 5)

print(acca2)

#Show out-of-sample prediction performance
#Calculate p-value of this procedure