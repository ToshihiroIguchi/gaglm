#gaglm.R


#遺伝的アルゴリズムでglmを最適化。
gaglm <- function(formula, family = "gaussian", data, offset =NULL, method = "AIC",
                  cook = 0.5,
                  popSize = 100, iters = 100,
                  mutationChance= NULL , zeroToOneRatio=10){

  #methodはAIC,BICとしたい。

  #説明変数を指定。カテゴリカル変数はダミー変数に変換される。
  x <- model.matrix(formula,data=data)

  #目的変数を指定。
  #修正の余地があると思う。
  y <- model.frame(formula,data=data)[,1]

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

  #エラーが発生したときに返す値。
  #切片だけの情報量基準の値を返す。
  result.intercept <- glm(formula = formula2, family = family, offset = offset, data = data2[,c(1,2)])
  errorAIC <- AIC(result.intercept)
  errorBIC <- BIC(result.intercept)

  #指定した説明変数の重回帰分析の結果を返す関数
  glm_res <- function(x){
    #説明変数がない場合、エラーとして扱う。
    if(max(x) == 0){return(result.intercept)}

    #目的変数は必ず入れるので最初はTRUE
    ev_use <- c(TRUE, as.logical(x))

    result <- glm(formula = formula2, family = family, offset = offset, data = data2[,ev_use])

    #係数がNAを含む場合、エラーとして扱う。
    if(anyNA(coef(result))){result <- result.intercept}

    #Cookの距離が閾値を超える場合、エラーとして扱う。
    cook_d <- max(abs(cooks.distance(result)))
    if(is.nan(cook_d) || cook_d >= cook){result <- result.intercept}

    return(result)
  }

  #最小化対象の関数
  glm_res_ic <- switch(method,
         "AIC" = {function(x){tryCatch(AIC(glm_res(x)), error=errorAIC)}},
         "BIC" = {function(x){tryCatch(BIC(glm_res(x)), error=errorBIC)}},
         stop("Please specify method correctly."))

  #遺伝的アルゴリズムで最適化
  if(is.null(mutationChance)){mutationChance <- 1/(ev_num + 1)}
  result_ga <- rbga.bin(size = ev_num, evalFunc = glm_res_ic,
                        mutationChance = mutationChance,
                        zeroToOneRatio = zeroToOneRatio,
                        popSize = popSize, iters = iters)

  #最適値が見つからない場合。
  if(method == "AIC"){if(min(result_ga$best) == errorAIC){stop("A model better than the model with only intercepts was not found.")}}
  if(method == "BIC"){if(min(result_ga$best) == errorBIC){stop("A model better than the model with only intercepts was not found.")}}

  #最適モデル
  best_num <- which.min(result_ga$best)
  bestmodel <- glm_res(result_ga$population[best_num, ])

  #結果を返す
  ret <- list(bestmodel = bestmodel, ga = result_ga, method = method)
  class(ret) <- "gaglm"
  return(ret)
}

#結果を返す
summary.gaglm <- function(result){
  summary(result$bestmodel)
}

#結果のプロット
plot.gaglm <- function(result){
  par(mfrow=c(2,2))

  #遺伝的アルゴリズムの推移
  plot(result$ga$best, type = "l",
       xlab = "generation", ylab = result$method)

  #回帰診断
  plot(result$bestmodel, which = c(1,2,4))
  par(mfrow=c(1,1))
}

#係数を返す
coef.gaglm <- function(result){
  coef(result$bestmodel)
}

