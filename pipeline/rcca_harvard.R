rcc = function (X, Y, ncomp = 2, method = "ridge", lambda1 = 0, lambda2 = 0) 
{
  arg.call = match.call()
  user.arg = names(arg.call)[-1]
  err = tryCatch(mget(names(formals()), sys.frame(sys.nframe())), 
                 error = function(e) e)
  if ("simpleError" %in% class(err)) 
    stop(err[[1]], ".", call. = FALSE)
  data.names = c(deparse(substitute(X)), deparse(substitute(Y)))
  choices = c("ridge", "shrinkage")
  method = choices[pmatch(method, choices)]
  if (is.na(method)) 
    stop("'method' should be one of 'ridge' or 'shrinkage'.", 
         call. = FALSE)
  if (is.data.frame(X)) 
    X = as.matrix(X)
  if (!is.matrix(X) || is.character(X)) 
    stop("'X' must be a numeric matrix.", call. = FALSE)
  if (any(apply(X, 1, is.infinite))) 
    stop("infinite values in 'X'.", call. = FALSE)
  if (method == "shrinkage") {
    if (any(is.na(X))) 
      stop("missing values in 'X' matrix. NAs not are allowed if method = 'shrinkage'.", 
           call. = FALSE)
  }
  if (is.data.frame(Y)) 
    Y = as.matrix(Y)
  if (!is.matrix(Y) || is.character(Y)) 
    stop("'Y' must be a numeric matrix.", call. = FALSE)
  if (any(apply(Y, 1, is.infinite))) 
    stop("infinite values in 'Y'.", call. = FALSE)
  if (method == "shrinkage") 
    if (any(is.na(Y))) 
      stop("missing values in 'Y' matrix. NAs not are allowed if method = 'shrinkage'.", 
           call. = FALSE)
  if ((n = nrow(X)) != nrow(Y)) 
    stop("unequal number of rows in 'X' and 'Y'.", call. = FALSE)
  p = ncol(X)
  q = ncol(Y)
  X.names = colnames(X)
  if (is.null(X.names)) 
    X.names = paste("X", 1:ncol(X), sep = "")
  Y.names = colnames(Y)
  if (is.null(Y.names)) 
    Y.names = paste("Y", 1:ncol(Y), sep = "")
  ind.names = dimnames(X)[[1]]
  if (is.null(ind.names)) 
    ind.names = dimnames(Y)[[1]]
  if (is.null(ind.names)) 
    ind.names = 1:n
  if (is.null(ncomp) || ncomp < 1 || !is.finite(ncomp)) 
    stop("invalid value for 'ncomp'.", call. = FALSE)
  ncomp = round(ncomp)
  if (ncomp > min(p, q)) 
    stop("'comp' must be smaller or equal than ", min(p, 
                                                      q), ".", call. = FALSE)
  if (!is.finite(lambda1) || is.null(lambda1)) 
    stop("invalid value for 'lambda1'.", call. = FALSE)
  if (lambda1 < 0) 
    stop("'lambda1' must be a non-negative value.", call. = FALSE)
  if (!is.finite(lambda2) || is.null(lambda2)) 
    stop("invalid value for 'lambda2'.", call. = FALSE)
  if (lambda2 < 0) 
    stop("'lambda2' must be a non-negative value.", call. = FALSE)
  if (method == "ridge") {
    Cxx = var(X, na.rm = TRUE, use = "pairwise") + diag(lambda1, 
                                                        ncol(X))
    Cyy = var(Y, na.rm = TRUE, use = "pairwise") + diag(lambda2, 
                                                        ncol(Y))
    Cxy = cov(X, Y, use = "pairwise")
  }
  else {
    Cxx = cov.shrink(X, verbose = FALSE)
    Cyy = cov.shrink(Y, verbose = FALSE)
    lambda.x = attr(Cxx, "lambda")
    lambda.y = attr(Cyy, "lambda")
    sc.x = sqrt(var.shrink(X, verbose = FALSE))
    sc.y = sqrt(var.shrink(Y, verbose = FALSE))
    w = rep(1/n, n)
    xs = wt.scale(X, w, center = TRUE, scale = TRUE)
    ys = wt.scale(Y, w, center = TRUE, scale = TRUE)
    h1 = n/(n - 1)
    Cxy = h1 * crossprod(sweep(sweep(xs, 1, sqrt((1 - lambda.x) * 
                                                   w), "*"), 2, sc.x, "*"), sweep(sweep(ys, 1, sqrt((1 - 
                                                                                                       lambda.y) * w), "*"), 2, sc.y, "*"))
  }
  Cxx.fac = chol(Cxx)
  Cyy.fac = chol(Cyy)
  Cxx.fac.inv = solve(Cxx.fac)
  Cyy.fac.inv = solve(Cyy.fac)
  mat = t(Cxx.fac.inv) %*% Cxy %*% Cyy.fac.inv
  if (p >= q) {
    result = svd(mat, nu = ncomp, nv = ncomp)
    cor = result$d
    xcoef = Cxx.fac.inv %*% result$u
    ycoef = Cyy.fac.inv %*% result$v
  }
  else {
    result = svd(t(mat), nu = ncomp, nv = ncomp)
    cor = result$d
    xcoef = Cxx.fac.inv %*% result$v
    ycoef = Cyy.fac.inv %*% result$u
  }
  names(cor) = 1:length(cor)
  X.aux = scale(X, center = TRUE, scale = FALSE)
  Y.aux = scale(Y, center = TRUE, scale = FALSE)
  X.aux[is.na(X.aux)] = 0
  Y.aux[is.na(Y.aux)] = 0
  U = X.aux %*% xcoef
  V = Y.aux %*% ycoef
  cl = match.call()
  cl[[1]] = as.name("rcc")
  if (method == "ridge") {
    lambda = c(lambda1 = lambda1, lambda2 = lambda2)
  }
  else {
    lambda = c(lambda1 = lambda.x, lambda2 = lambda.y)
  }
  result = list(call = cl, X = X, Y = Y, ncomp = ncomp, method = method, 
                cor = cor, loadings = list(X = xcoef, Y = ycoef), variates = list(X = U, 
                                                                                  Y = V), names = list(sample = ind.names, colnames = list(X = colnames(X), 
                                                                                                                                           Y = colnames(Y)), blocks = c("X", "Y"), data = data.names), 
                lambda = lambda)
  explX = explained_variance(result$X, result$variates$X, ncomp)
  explY = explained_variance(result$Y, result$variates$Y, ncomp)
  result$explained_variance = list(X = explX, Y = explY)
  class(result) = "rcc"
  return(invisible(result))
}

predict_rcc = function(rcc_fit, X_train, Y_train, X_test, Y_test, ncomp){
  scale_x =  scale(as.matrix(X_train))
  scale_y =  scale(as.matrix(Y_train))
  cor_train = cor_test = c()
  X_train_CV = scale(as.matrix(X_train)) %*% as.matrix(rcc_fit$loadings$X)
  Y_train_CV = scale(as.matrix(Y_train)) %*% as.matrix(rcc_fit$loadings$Y)
  X_test_CV = scale(as.matrix(X_test),center=attr(scale_x,'scaled:center'),scale=attr(scale_x,'scaled:scale')) %*% as.matrix(rcc_fit$loadings$X)
  Y_test_CV = scale(as.matrix(Y_test),center=attr(scale_y,'scaled:center'),scale=attr(scale_y,'scaled:scale')) %*% as.matrix(rcc_fit$loadings$Y)
  for(i in 1:ncomp){
    cor_train[i] = cor(X_train_CV[,i],Y_train_CV[,i])
    cor_test[i] = cor(X_test_CV[,i],Y_test_CV[,i])
  }
  list(X_train_CV=X_train_CV,Y_train_CV=Y_train_CV,cor_train=cor_train,
       X_test_CV=X_test_CV,Y_test_CV=Y_test_CV,cor_test=cor_test)  
}

cor_select = function(X,Y,cor_method="spearman",num_features=100){
  corrmat <- cor(X,Y,method=cor_method)
  abscorrmat <- abs(corrmat)
  fc_scores <- colSums(abscorrmat,na.rm=TRUE)
  best_fc <- sort(fc_scores,decreasing=TRUE,index.return=TRUE)
  out = best_fc$ix[1:num_features]
  out
}

rcc_validate = function(X_train,Y_train,X_test,Y_test,num_comp=1,lamb1=0.0,lamb2=0.0) {
  rcc_train <- rcc(X_train,Y_train,ncomp=num_comp,lambda1=lamb1,lambda2=lamb2,method="ridge")
  predict_fit = predict_rcc(rcc_train, X_train, Y_train, X_test, Y_test, num_comp)  
  list(X_coefs=rcc_train$loadings$X, Y_coefs=rcc_train$loadings$Y,
       X_train_CV=predict_fit$X_train_CV,Y_train_CV=predict_fit$Y_train_CV,
       X_test_CV=predict_fit$X_test_CV,Y_test_CV=predict_fit$Y_test_CV,
       cor_train=predict_fit$cor_train, cor_test=predict_fit$cor_test)
}

explained_variance = function (data, variates, ncomp) 
{
  check = Check.entry.single(data, ncomp)
  data = check$X
  ncomp = check$ncomp
  if (anyNA(data)) {
    warning("NA values put to zero, results will differ from PCA methods used with NIPALS")
    isna = is.na(data)
    data[isna] = 0
  }
  nor2x <- sum((data)^2)
  exp.varX = NULL
  for (h in 1:ncomp) {
    a <- t(variates[, h, drop = FALSE]) %*% data
    ta = t(a)
    exp_var_new <- a %*% ta/crossprod(variates[, h], variates[, 
                                                              h])/nor2x
    exp.varX = append(exp.varX, exp_var_new)
  }
  names(exp.varX) = paste("comp", 1:ncomp)
  exp.varX
}

Check.entry.single = function(X,  ncomp, q)
{
  
  #-- validation des arguments --#
  if (length(dim(X)) != 2)
    stop(paste0("'X[[", q, "]]' must be a numeric matrix."))
  
  if(! any(class(X) %in% "matrix"))
    X = as.matrix(X)
  
  if (!is.numeric(X))
    stop(paste0("'X[[", q, "]]'  must be a numeric matrix."))
  
  N = nrow(X)
  P = ncol(X)
  
  if (is.null(ncomp) || !is.numeric(ncomp) || ncomp <= 0)
    stop(paste0("invalid number of variates 'ncomp' for matrix 'X[[", q, "]]'."))
  
  ncomp = round(ncomp)
  
  # add colnames and rownames if missing
  X.names = dimnames(X)[[2]]
  if (is.null(X.names))
  {
    X.names = paste("X", 1:P, sep = "")
    dimnames(X)[[2]] = X.names
  }
  
  ind.names = dimnames(X)[[1]]
  if (is.null(ind.names))
  {
    ind.names = 1:N
    rownames(X)  = ind.names
  }
  
  if (length(unique(rownames(X))) != nrow(X))
    stop("samples should have a unique identifier/rowname")
  if (length(unique(X.names)) != P)
    stop("Unique indentifier is needed for the columns of X")
  
  return(list(X=X, ncomp=ncomp, X.names=X.names, ind.names=ind.names))
}

