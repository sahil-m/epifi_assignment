tic("data_cleaning_1.R")
rm(list = ls())
source("utils.R")
message("--------------------------")
message("Starting execution...")

odata_mix <- read_delim("data/german.data", delim = " ", col_names = F)

colnames_data_mix <- c("checking_account_status", "duration_in_months", "credit_history", "purpose", "credit_amount", "savings_account_status", "present_employment_since", "installment_as_percent_of_income", "marital_sex_type", "role_in_other_credits", "present_resident_since", "assset_type", "age", "other_installment_plans", "housing_type", "count_existing_credits", "employment_type", "count_dependents", "has_telephone", "is_foreign_worker", "is_credit_worthy")  

colnames(odata_mix) <- colnames_data_mix


odata_num <- read_delim("data/german.data-numeric", delim = " ", col_names = F)

data_num <- odata_num %>% 
  mutate_all(list(~as.numeric(str_trim(., side = "both"))))

# It is worse to class a customer as good when they are bad, than it is to class a customer as bad when they are good. 
# Let 'good' be the positive class, and 'bad' be the negative class i.e. False Positives are more expensive than False Negatives i.e. Precision is very important.

# The numeric files has few additional features, but there is no description of the features so I will just go ahead with the file with both numeric and categorical features


##### categorical -> nominal (binary vs non-binary), ordered
# Binary: has_telephone, is_foreign_worker
# Nominal, non-binary: credit_history, purpose, marital_sex_type, role_in_other_credits, other_installment_plans, housing_type, employment_type, 
# Ordinal, non-binary: checking_account_status, savings_account_status, present_employment_since, assset_type
# marital_sex_type look like that it can be broken down into marotal and sex features. But on further inspection I see it can't be broken because female's married and divorced are mixed, but I can extract sex out of it (male: A91, A93, A94; female: A92, A95)
# Employment_type too seems like it can be broken down, but it can't be and nothing can be extracted from it


# Why this matters?
# In two areas:
# - Visualization
# - Encoding
#   - Binary: 0/1 encoding (1 output feature)
#   - Nominal, non-binary: dummy encoding(n-1 output features for n clases) or one hot encoding (n output features for n classes)
#   - Ordinal, non-binary: all Nominal non-binary options or integer encoding (also called label encoding)
# - There are few algorithms which handle ordered data differently

data_mix <- odata_mix

data_mix$checking_account_status <- factor(data_mix$checking_account_status, levels = c("A14", "A11", "A12", "A13"), ordered = T)

data_mix$savings_account_status <- factor(data_mix$savings_account_status, levels = c("A65", "A61", "A62", "A63", "A64"), ordered = T)

data_mix$present_employment_since <- factor(data_mix$present_employment_since, levels = c("A71", "A72", "A73", "A74", "A75"), ordered = T)

data_mix$assset_type <- factor(data_mix$assset_type, levels = c("A121", "A122", "A123", "A124"), ordered = T)

data_mix$has_telephone <- ifelse(data_mix$has_telephone == "A192", T, F)
data_mix$is_foreign_worker <- ifelse(data_mix$is_foreign_worker == "A201", T, F)
data_mix$is_credit_worthy <- ifelse(data_mix$is_credit_worthy == 1, "Good", "Bad")

count_na(data_mix)


save(data_mix, file = "data_intermediate/data_cleaning_1_output.RData")


message("Saved data")
toc()
message("--------------------------\n\n")
