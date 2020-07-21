tic("modeling_h2o_glm.R")
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

#### train #####
model_glm_base <-
  h2o.glm(
    family = "binomial",
    x = x,
    y = y,
    training_frame = train_h2o,
    lambda = 0,
    compute_p_values = T
  )

# h2o.varimp_plot(model_glm_base)
# perf <- h2o.performance(model_glm_base, newdata = train_h2o)
# plot(perf, type = "roc")

h2o::h2o.saveModel(model_glm_base, "models")


message("Saved model")
toc()
message("--------------------------\n\n")



