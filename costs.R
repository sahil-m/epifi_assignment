tic("costs.R")
rm(list = ls())
source("utils.R")
message("--------------------------")
message("Starting execution...")

load("data_intermediate/splitted_data.RData")

##### benchmarking ####
# costs
costs = matrix(c(-0.4, 0.2, 1, 0), nrow = 2)
dimnames(costs) = list(Prediction = c("Good", "Bad"), Reference = c("Good", "Bad"))
print(costs)

save(costs, file = "data_intermediate/costs.RData")


message("Saved data")
toc()
message("--------------------------\n\n")