## gaglm packages
Automatic selection of explanatory variable of multiple regression analysis by genetic algorithm.

### Description
It is generally difficult to select explanatory variables in multiple regression analysis. This package automatically selects explanatory variables of multiple regression analysis with genetic algorithm and it will be useful for creating your statistical model.

### Installation
You can install from R console.

If `devtools` is not installed on your PC, install `devtools` with Internet connection.

    install.packages("devtools")

Install from GitHub using `devtools`.
    
    library(devtools)
    install_github("ToshihiroIguchi/gaglm")

Load the `qatsp` package and attach it.

    library(qatsp)

Installation may fail if running under proxy environment.
In that case, you may be able to install using the `httr` package.

