tic("modeling_h2o_gbm.R")
rm(list = ls())
source("utils.R")
message("--------------------------")
message("Starting execution...")

h2o.init()

load("data_intermediate/splitted_data.RData")
load("data_intermediate/costs.RData")


#### h2o data prep ####
train_h2o <- as.h2o(data_train)
test_h2o  <- as.h2o(data_test)

y <- "is_credit_worthy"
x <- setdiff(names(train_h2o), y)

##### train gbm ####
# GBM hyperparameters (bigger grid than above)
# gbm_params_1 <- list(learn_rate = seq(0.01, 0.1, 0.01),
#                      max_depth = seq(2, 10, 1),
#                      sample_rate = seq(0.5, 1.0, 0.1),
#                      col_sample_rate = seq(0.1, 1.0, 0.1))
# search_criteria_1 <- list(strategy = "RandomDiscrete", stopping_metric = "lift_top_group", stopping_tolerance = 0.001, stopping_rounds = 3, max_runtime_secs = 10*60)

gbm_params_2 <- list(class_sampling_factors =  list(c(1, 0.6), c(1, 0.8), c(1, 1.5), c(1,2), c(1,2.5), c(1,3)))
search_criteria_2 <- list(strategy = "Cartesian")

# Train and validate a random grid of GBMs
gbm_grid <- h2o.grid(
  algorithm = "gbm",
  x = x,
  y = y,
  grid_id = "gbm_grid_11",
  training_frame = train_h2o,
  nfolds = 5,
  balance_classes = T,
  hyper_params = gbm_params_2,
  search_criteria = search_criteria_2,
  seed = 1
)

gbm_gridperf_2_byPrecision <- h2o.getGrid(grid_id = "gbm_grid_11",
                                          sort_by = "precision",
                                          decreasing = TRUE)

gbm_gridperf_2_byAUC <- h2o.getGrid(grid_id = "gbm_grid_11",
                                    sort_by = "auc",
                                    decreasing = TRUE)

# Grab the top GBM model, chosen by validation AUC
model_gbm_best <- h2o.getModel(gbm_gridperf_2_byAUC@model_ids[[1]])


# h2o.saveGrid("models", "gbm_grid_11")
h2o.saveModel(model_gbm_best, "models")

message("Saved Model")
toc()
message("--------------------------\n\n")

