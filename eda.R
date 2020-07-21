tic("eda.R")
rm(list = ls())
source("utils.R")
message("--------------------------")
message("Starting execution...")

load("data_intermediate/data_cleaning_1_output.RData")

# Would a person with critical credit history, be more credit worthy? --------
plot_list = plot_target_cat_feature_cat(data_mix, "credit_history", "is_credit_worthy", "Good", "Bad")

ggplotly(
  plot_list[[1]]
)

# Credit worthiness for a group of observations can be measured by good/bad proportion. Higher the proportion, higher the credit worthiness

# Assuming 'critical' roughly means more existing credits i.e. it increase from A30 to A35, critical has positive association with credit worthiness
# Also, the no. of customers under each credit_history category affects the uncertainity of the credit worthiness of that category. This can be seen via this plot

ggplotly(
  plot_list[[2]]
  , tooltip = "text"
)

# Are young people more creditworthy? -----------------------------------------
plot_list <- plot_target_cat_feature_cont(data_mix, "age", "is_credit_worthy")

ggplotly(
  plot_list[[1]]
)

plot_list[[2]]


message("EDA done")
toc()
message("--------------------------\n\n")


# The distributions are quite overlapping. But there are more young in "Bad" compared to "Good", and that is also visible in the difference in means. So, young people seems less credit worthy.

# But let's break the age into groups to see finer details

quantile(data_mix$age, seq(0,1,.1))
# 18-24, 25-29, 30-34, 35-39, 40-49, 50-64, 65+

data_mix$age_groups <- cut(data_mix$age, breaks = c(18, 24, 29, 34, 39, 49, 64, Inf), ordered_result = T)
sum(is.na(data_mix$age_groups))

plot_list = plot_target_cat_feature_cat(data_mix, "age_groups", "is_credit_worthy", "Good", "Bad")

ggplotly(
  plot_list[[1]]
)

# "Bad" is quite low for the (34, 39] age group


# Would a person with more credit accounts, be more credit worthy? --------
# I am assuming more credit accounts is same as "Number of existing credits at this bank" i.e. 'count_existing_credits' 
plot_list <- plot_target_cat_feature_cat(data_mix, "count_existing_credits", "is_credit_worthy", "Good", "Bad")

ggplotly(
  plot_list[[1]]
)

ggplotly(
  plot_list[[2]]
  , tooltip = "text"
)

# Data is too unreliable to say anything


# credit amount -----------------------------------------------------------
plot_list <- plot_target_cat_feature_cont(data_mix, "credit_amount", "is_credit_worthy")

ggplotly(
  plot_list[[1]]
)

plot_list[[2]]

