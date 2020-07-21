tic("data_prep_before_split.R")
rm(list = ls())
source("utils.R")
message("--------------------------")
message("Starting execution...")

load("data_intermediate/data_after_fs.RData")

data_preped <- data_after_fs %>% 
  mutate_if(is.ordered, factor, ordered = F) %>% 
  mutate_if(is.character, factor, ordered = F) %>% 
  mutate(is_credit_worthy = factor(is_credit_worthy, levels = c("Good", 'Bad')))

assert_that(sum(sapply(data_preped, function(x) sum(is.na(x)))) == 0)

save(data_preped, file = "data_intermediate/data_preped.RData")


message("Saved data")
toc()
message("--------------------------\n\n")
