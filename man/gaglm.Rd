\name{gaglm}
\alias{gaglm}
\title{Automatic selection of explanatory variable of multiple regression analysis by genetic algorithm}
\usage{
gaglm(formula, family = "gaussian", data, offset =NULL, method = "AIC", cook = 0.5,
popSize = 100, iters = 100, mutationChance = NULL, zeroToOneRatio=10)
}

\arguments{
\item{formula}{
an object of class "formula" (or one that can be coerced to that class): a symbolic description of the model to be fitted.
}
\item{family}{
a description of the error distribution and link function to be used in the model. For gaglm this can be a character string naming a family function, a family function or the result of a call to a family function.
}
\item{data}{
an optional data frame, list or environment (or object coercible by as.data.frame to a data frame) containing the variables in the model.
}
\item{offset}{
this can be used to specify an a priori known component to be included in the linear predictor during fitting. This should be NULL or a numeric vector of length equal to the number of cases. One or more offset terms can be included in the formula instead or as well, and if more than one is specified their sum is used.
}
\item{method}{
method is optimization target. You can select AIC or BIC.
}
\item{cook}{
It is the upper limit of cook distance. If the model exceeds the upper limit value, it returns the value of the model with only the intercept.
}
\item{popSize}{
the population size.
}
\item{iters}{
the number of iterations.
}
\item{mutationChance}{
the chance that a gene in the chromosome mutates. By default 1/(size+1). It affects the convergence rate and the probing of search space: a low chance results in quicker convergence, while a high chance increases the span of the search space.
}
\item{zeroToOneRatio}{
the change for a zero for mutations and initialization. This option is used to control the number of set genes in the chromosome.
}

}


\description{

It is generally difficult to select explanatory variables in multiple regression analysis.
This package automatically selects explanatory variables of multiple regression analysis with genetic algorithm and it will be useful for creating your statistical model.

If the coefficient can not be calculated during optimization with the genetic algorithm, if the cook distance exceeds the threshold, if an error occurs, return the value of the model with only the intercept.
}

\examples{

set.seed(108)
result <- gaglm(Petal.Length~., data = iris)
plot(result)
summary(result)

}
