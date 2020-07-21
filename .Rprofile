library(utils)

ipak <- function(pkg){
  new.pkg <- pkg[!(pkg %in% utils::installed.packages()[, "Package"])]
  if (length(new.pkg))
    install.packages(new.pkg, dependencies = TRUE)
  sapply(pkg, require, character.only = TRUE)
}

packages_always_required <- c("tictoc", "readr", "readxl", "skimr", "Hmisc", "zoo", "plotly", "plyr", "reshape2", "magrittr", "assertthat", "tidyverse", "glue", "stringdist", "ggthemes", "RColorBrewer", "ggmosaic", "gridExtra", "lubridate", "janitor", "assertr", "grid", "ggforce", "knitr", "DT", "GGally", "ggbeeswarm", "markdown")

packages_stats <- c("PropCIs")

packages_hierarchy <- c("treemap", "data.tree", "networkD3")

packages_models_basic <- c("caret", "rpart", "rpart.plot", "Metrics", "h2o", "Boruta", "rsample")
# packages_models_basic <- c("mlr3", "mlr3learners", "glmnet", "mlr3viz)
# packages_models_basic <- c("mlr")

packages_time_series <- c("manipulate", "xts", "timetk", "tidyquant", "dygraphs", "forecast", "stR", "prophet")

packages <- c(packages_always_required, packages_stats, packages_models_basic)

ipak(packages)

options("scipen"=100, "digits"=4) #### Use this to not display no. in exponent format in R

options(readr.show_progress = F)

# options(readr.num_columns = 0)
