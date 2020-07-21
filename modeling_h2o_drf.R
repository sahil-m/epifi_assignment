tic("modeling_h2o_drf.R")
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

##### train drf ####
drf_params_1 <- list(
  ntrees = c(100, 300, 500),
  mtries = c(3, 4, 5, 6),
  max_depth = c(3, 4, 5, 6),
  sample_rate = c(0.5, 0.6, 0.7, 0.8),
  col_sample_rate_per_tree = c(0.7, 0.8, 0.9)
)
search_criteria_1 <- list(strategy = "RandomDiscrete", stopping_metric = "lift_top_group", stopping_tolerance = 0.001, stopping_rounds = 3, max_runtime_secs = 10*60)


# Train and validate a random grid of GBMs
drf_grid <- h2o.grid(
  algorithm = "randomForest",
  x = x,
  y = y,
  grid_id = "drf_grid_12",
  training_frame = train_h2o,
  nfolds = 5,
  hyper_params = drf_params_1,
  search_criteria = search_criteria_1,
  seed = 1
)

h2o.saveGrid("models", "drf_grid_12")

message("Saved model")
toc()
message("--------------------------\n\n")

