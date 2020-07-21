tic("modeling_mlr.R")
rm(list = ls())
source("utils.R")
message("--------------------------")
message("Starting execution...")

load("data_intermediate/data_cleaning_1_output.RData")


data_after_fs <- data_mix %>% 
  select(duration_in_months, installment_as_percent_of_income, present_resident_since, age, count_existing_credits, count_dependents, is_credit_worthy)

target <- "is_credit_worthy"


##### task
task_germanCredit <- makeClassifTask(id = "task_gc", data = data_after_fs, target = target, positive = "Good")

##### costs
costs = matrix(c(-0.4, 0.2, 1, 0), nrow = 2)
dimnames(costs) = list(response = c("good", "bad"), truth = c("good", "bad"))
print(costs)

credit.costs = makeCostMeasure(id = "credit.costs", name = "Credit costs", costs = costs, best = -1, worst = 1)

# ##### learning without tuning
# listLearners("classif", properties = "weights")[c("class", "package")]
# listLearners("classif", properties = "class.weights")[c("class", "package")] # can directly pass class weights
# 
# th = costs[2,1]/(costs[2,1] + costs[1,2])
# w = (1 - th)/th
# lrn = makeLearner("classif.glmnet", predict.type = "prob", predict.threshold = th, trace = FALSE)
# lrn = makeWeightedClassesWrapper(lrn, wcw.weight = w)
# 
# rin = makeResampleInstance("CV", iters = 3, task = task_germanCredit)
# 
# r = resample(lrn, task_germanCredit, rin, measures = list(credit.costs, mmce), show.info = FALSE)
# 
# performance(r$pred, measures = list(credit.costs, mmce))
# performance(setThreshold(r$pred, 0.5), measures = list(credit.costs, mmce))
# d = generateThreshVsPerfData(r, measures = list(credit.costs, mmce))
# plotThreshVsPerf(d, mark.th = th)


##### learning with tuning
lrn = makeLearner("classif.glmnet", predict.type = "prob", trace = FALSE)
lrn = makeWeightedClassesWrapper(lrn)

rin = makeResampleInstance("CV", iters = 3, task = task_germanCredit)

ps = makeParamSet(makeDiscreteParam("wcw.weight", seq(4, 12, 0.5)))
ctrl = makeTuneControlGrid()
tune.res = tuneParams(lrn, 
                      task_germanCredit, 
                      resampling = rin, 
                      par.set = ps,
                      control = ctrl, 
                      measures = list(credit.costs, mmce), 
                      show.info = FALSE)

lrn = makeLearner("classif.multinom", predict.type = "prob", trace = FALSE)
lrn = makeWeightedClassesWrapper(lrn, wcw.weight = tune.res$wcw.weight)

r = resample(lrn, task_germanCredit, rin, measures = list(credit.costs, mmce), show.info = FALSE)

d = generateThreshVsPerfData(r, measures = list(credit.costs, mmce))
plotThreshVsPerf(d, mark.th = th)
tune.res = tuneThreshold(pred = r$pred, measure = credit.costs)

performance(r$pred, measures = list(credit.costs, mmce))
performance(setThreshold(r$pred, 0.5), measures = list(credit.costs, mmce)) # set to optimum threshold


