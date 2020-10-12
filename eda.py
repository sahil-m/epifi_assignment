# To add a new cell, type '# %%'
# To add a new markdown cell, type '# %% [markdown]'
# %%
import pandas as pd
from dataprep.eda import plot


# %%
odata_mix = pd.read_csv("data/german.data", delimiter=" ", header=None)


# %%
colnames_data_mix = ["checking_account_status", "duration_in_months", "credit_history", "purpose", "credit_amount", "savings_account_status", "present_employment_since", "installment_as_percent_of_income", "marital_sex_type", "role_in_other_credits", "present_resident_since", "assset_type", "age", "other_installment_plans", "housing_type", "count_existing_credits", "employment_type", "count_dependents", "has_telephone", "is_foreign_worker", "is_credit_worthy"]

odata_mix.columns = colnames_data_mix


# %%
odata_mix.head()


# %%
odata_mix.describe()


# %%
plot(odata_mix)


# %%



