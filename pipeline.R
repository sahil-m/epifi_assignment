tic("ALL")
source("data_cleaning_1.R")
source("eda.R")
source("feature_selection.R")
source("data_prep_before_split.R")
source("split_data.R")
source("costs.R")

source("modeling_h2o_glm.R")
source("modeling_h2o_gbm.R")
source("modeling_h2o_drf.R")

render("final.Rmd", "all")

toc()