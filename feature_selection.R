tic("feature_selection.R")
rm(list = ls())
source("utils.R")
message("--------------------------")
message("Starting execution...")

load("data_intermediate/data_cleaning_1_output.RData")

data_mix$is_credit_worthy <- factor(data_mix$is_credit_worthy, levels = c("Good", "Bad"))


##### Boruta
set.seed(0)
boruta_train_obj <- Boruta(is_credit_worthy~., data = data_mix, doTrace = 2)
print(boruta_train_obj)
save(boruta_train_obj, file='models/boruta_train_obj.RData')

plot(boruta_train_obj, xlab = "", xaxt = "n")
lz<-lapply(1:ncol(boruta_train_obj$ImpHistory),function(i)
  boruta_train_obj$ImpHistory[is.finite(boruta_train_obj$ImpHistory[,i]),i])
names(lz) <- colnames(boruta_train_obj$ImpHistory)
Labels <- sort(sapply(lz,median))
axis(side = 1,las=2,labels = names(Labels),
     at = 1:ncol(boruta_train_obj$ImpHistory), cex.axis = 0.7)

boruta_predict_obj <- TentativeRoughFix(boruta_train_obj)

feat_sel_final <- getSelectedAttributes(boruta_predict_obj, withTentative = F)

boruta_results <- attStats(boruta_predict_obj)

data_after_fs <- select(data_mix, c(all_of(feat_sel_final), 'is_credit_worthy'))

save(data_after_fs, file = "data_intermediate/data_after_fs.RData")

message("Saved data")
toc()
message("--------------------------\n\n")