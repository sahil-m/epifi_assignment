tic("split_data.R")
rm(list = ls())
source("utils.R")
message("--------------------------")
message("Starting execution...")

load("data_intermediate/data_preped.RData")

set.seed(123)
data_split <- initial_split(data_preped, prop = .8, strata = is_credit_worthy)

data_train <- training(data_split)
data_test  <- testing(data_split)

dim(data_train)
prop.table(table(data_train$is_credit_worthy))
dim(data_test)
prop.table(table(data_test$is_credit_worthy))


save(data_split, data_train, data_test, file = "data_intermediate/splitted_data.RData")


message("Saved data")
toc()
message("--------------------------\n\n")