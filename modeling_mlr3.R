tic("modeling_mlr3.R")
rm(list = ls())
source("utils.R")
message("--------------------------")
message("Starting execution...")

load("data_intermediate/data_cleaning_1_output.RData")

table(data_mix$is_credit_worthy)


data_after_fs <- data_mix %>% 
  select(duration_in_months, installment_as_percent_of_income, present_resident_since, age, count_existing_credits, count_dependents, is_credit_worthy)

target <- "is_credit_worthy"

data_after_fs[[target]] = factor(data_after_fs[[target]])

##### task
task_germanCredit <- TaskClassif$new(id = "gc", backend = data_after_fs, target = "is_credit_worthy", positive = "Good")

table(task_germanCredit$truth())

# autoplot(task_germanCredit, type = "pairs")

##### evaluation metric
# .3 is for lost interest income opportunity i.e. customer is actually 'good' but we predicted 'bad' and didn't give him loan
# 1 is for lost interest and principal
# -0.4 is for grabbed opportunity
costs = matrix(c(-0.4, 0.2, 1, 0), nrow = 2)
dimnames(costs) = list(response = c("good", "bad"), truth = c("good", "bad"))
print(costs)

# give loan to nobody
(700 * costs[2, 1] + 300 * costs[2, 2]) / 1000

# give loan to everybody
(700 * costs[1, 1] + 300 * costs[1, 2]) / 1000

# This is beacuse 'Bad' is less than 'Good'

cost_measure = msr("classif.costs", costs = costs)
print(cost_measure)

# list(
#   cost_measure,
#   classif.fpr,
#   classif.precision
# )

learner = lrn("classif.log_reg", id = "lr", predict_type = "prob")
learner$feature_types
learner$properties
learner$predict_types
learner$param_set


param_set = paradox::ParamSet$new(
  params = list(paradox::ParamDbl$new("cp", lower = 0.001, upper = 0.1)))
terminator = term("evals", n_evals = 5)
tuner = tnr("grid_search", resolution = 10)

resampling = rsmp("holdout")

at = AutoTuner$new(learner, resampling, measure = measure,
                   param_set, terminator, tuner = tuner)


