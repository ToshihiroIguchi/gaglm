#gaglm.R


#遺伝的アルゴリズムでglmを最適化。
gaglm.cv <- function(formula, family = "gaussian", data, offset =NULL,
                     nfolds = 5,
                     cook = 0.5,
                     popSize = 100, iters = 100,
                     mutationChance= NULL , zeroToOneRatio=10){

  ##family = "gaussian", "poisson"
  #if(family != "gaussian" && family != "poisson"){
  #  stop("For family variable only gaussian or poisson can be specified.")
  #}

  #現段階では正規分布のみ
  #family = "gaussian"
  if(family != "gaussian"){
    stop("For family variable only gaussian can be specified.")
  }


  #説明変数を指定。カテゴリカル変数はダミー変数に変換される。
  x <- model.matrix(formula,data=data)

  #目的変数を指定。
  #修正の余地があると思う。
  y <- model.frame(formula,data=data)[,1]

  if(!is.numeric(y) && !is.integer(y)){
    stop("You can only specify numeric or integer objective variables.")
  }

  #解析用データフレーム
  yname <- as.character(formula[2])

  #説明変数に括弧等の特殊文字があるとエラーを起こすので置換。
  #以下は特殊文字の置換の参考。
  #https://stackoverflow.com/questions/9449466/remove-parenthesis-from-string
  sc <- c("(", ")", "^", "+", "-", "*", "/", ":")
  for(i in 1:length(sc)){
    yname <- gsub(sc[i], ".", yname, fixed = TRUE)
  }


  data2 <- data.frame(y, x)
  names(data2)[1] <- yname
  names(data2)[2] <- "Intercept"

  #解析用フォーミュラ
  formula2 <- as.formula(paste0(yname, "~.+0"))

  #説明変数の個数
  ev_num <- length(data2[1,]) - 1

  #idを付与する。
  idvec <- function(x, nfolds){
    #エラーチェック
    if(nfolds <= 1 || nfolds%%1 != 0){stop("nfolds must be an integer greater than or equal to 2.")}
    if(x < nfolds){stop("nfolds is too big.")}
    #id付与。
    ret <- rep(c(1: nfolds), times = floor(x/nfolds))
    remainder <- x%%nfolds
    if(remainder > 0){ret <- c(ret, c(1: remainder))}
    ret <- sample(ret)
    return(ret)
  }
  idvec <- idvec(x = length(data[,1]), nfolds = nfolds)

  #指定した説明変数のCV
  glm_cv <- function(x){
    #目的変数は必ず入れるので最初はTRUE
    ev_use <- c(TRUE, as.logical(x))

    #通常のglm
    result <- glm(formula = formula2, family = family, offset = offset, data = data2[, ev_use])

    #cross varidation
    cv.pre <- data.frame()
    for(i in 1:nfolds){
      cv.res <- glm(formula = formula2, family = family, offset = offset,
                    data = data2[which(idvec != i), ev_use])
      cv.pre0 <- data.frame(Mes = data2[which(idvec == i), 1],
                            Pre = predict(cv.res, data2[which(idvec == i), ev_use]))
      cv.pre <- rbind(cv.pre, cv.pre0)
    }

    #RMSE
    rmse <- sqrt(mean((cv.pre[, 1] - cv.pre[, 2])^2))

    #戻り値
    ret <- list(result = result, cv = cv.pre, rmse = rmse)
    return(ret)
  }

  #エラーが発生したときに返す値
  result_intercept <- glm_cv(c(1, rep(0, times = ev_num - 1)))
  errorCV <- result_intercept$rmse

  glm_res <- function(x){
    #説明変数がない場合、エラーとして扱う。
    if(max(x) == 0){return(result_intercept)}

    #本体
    result <- glm_cv(x)

    #係数がNAを含む場合、エラーとして扱う。
    if(anyNA(coef(result$result))){return(result_intercept)}

    #Cookの距離が閾値を超える場合、エラーとして扱う。
    cook_d <- max(abs(cooks.distance(result$result)))
    if(is.nan(cook_d) || cook_d >= cook){return(result_intercept)}

    return(result)
  }


  #最小化対象の関数
  glm_rmse <- function(x){
    tryCatch(glm_res(x)$rmse, error = errorCV)
  }

  #遺伝的アルゴリズムで最適化
  if(is.null(mutationChance)){mutationChance <- 1/(ev_num + 1)}
  result_ga <- rbga.bin(size = ev_num, evalFunc = glm_rmse,
                        mutationChance = mutationChance,
                        zeroToOneRatio = zeroToOneRatio,
                        popSize = popSize, iters = iters)

  #最適値が見つからない場合。
  if(min(result_ga$best) == errorCV){stop("A model better than the model with only intercepts was not found.")}

  #最適モデル
  best_num <- which.min(result_ga$best)
  bestmodel <- glm_res(result_ga$population[best_num, ])

  #結果を返す
  ret <- list(bestmodel = bestmodel, ga = result_ga)
  class(ret) <- "gaglm.cv"
  return(ret)
}



#結果を返す
summary.gaglm.cv <- function(result){
  summary(result$bestmodel$result)
}


#結果のプロット
plot.gaglm.cv <- function(result){
  par(mfrow=c(2,3))

  #遺伝的アルゴリズムの推移
  plot(result$ga$best, type = "l",
       xlab = "Generation", ylab = "RMSE")

  #Cross Varidationの結果
  plot(result$bestmodel$cv, xlab = "Measure", ylab = "Predict")
  abline(a=0, b=1, lty = 3)

  #回帰診断
  plot(result$bestmodel$result, which = c(1,2,3,4))
  par(mfrow=c(1,1))
}



#係数を返す
coef.gaglm.cv <- function(result){
  coef(result$bestmodel$result)
}

