- Manually removed spaces from numeric data file to make it easy to read 
- Use the file with both numeric and categorical features
- Modeling Strategies for cost sensitive learning
  - Change cost function
    - Change the function itself
      - the main function
      - penalty component
    - Change function parameters
      - More weight to observations with positive class, which will result in more penalty for FP
        - oversample positive class
          - synthetic sample generation (like SMOTE)
          - give more weight
        - undersample sample negative class
  - Optimize thresholds that are used for converting output probabilities into class labels - valid only for models which output probabilities
  - Ensembling

I will explore 

- Models
  - Logistic
  - SVM
  - Boosted trees
  - Random Forest

- Evaluation Strategies for Cost sensitive classification
  - Favour Precision over Recall
  - Give weights to different buckets in confusion matrix, and use that to construct a custom evaluation metric


- Evaluation
- Modeling
- Thresholding

- Feature Selection
- Create a single task
- Create learners by setting their class weight parameter
  - Predict probabilities whenever possible
- Evaluation
  - Create cost sensitive evaluation metric
  - Cross validation
- Train
  - Hyperparameter tuning for class weight parameter
- Threshold tuning


listLearners("classif", properties = "class.weights")[c("class", "package")]
lrn = makeLearner("classif.multinom", trace = FALSE)
lrn = makeWeightedClassesWrapper(lrn, wcw.weight = w)
lrn

classif.task = makeClassifTask(id = "BreastCancer", data = df, target = "Class", positive = "malignant")
costsens.task = makeCostSensTask(data = df, cost = cost)

In case of class-dependent costs it is sufficient to generate an ordinary ClassifTask (Task()). A CostSensTask (Task()) is only needed if the costs are example-dependent



- give more weight to positive class
  - tune the weight
- optimize threshold for defined cost function



- checking_account_status is "A14" i.e. no checking account
- duration_in_months is less than 12 month i.e. a year
- credit_amount is less than 2k
- credit_history is "A34" i.e. critical account/other existing credits
- Purpose is A43 i.e. radio/television
