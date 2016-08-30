library(xgboost)
library(dplyr)
library(data.table)

# app_events;
cat("load data")

# train models
(group_name <- na.omit(unique(y)))
idx_train <- which(!is.na(y))
idx_test <- which(is.na(y))
train_data <- x[idx_train,]
test_data <- x[idx_test,]
train_label <- match(y[idx_train],group_name)-1
test_label <- match(y[idx_test],group_name)-1
dtrain <- xgb.DMatrix(train_data,label=train_label,missing=NA)
dtest <- xgb.DMatrix(test_data,label=test_label,missing=NA)

#  train xgbmodel
param <- list("objective" = "multi:softprob",
              "num_class" = length(group_name),
              # "eval_metric" = "merror",
              "eval_metric" = "mlogloss", 
              "eta" = 0.05,
              "max_depth" = 5,
              "subsample" = 0.5,
              "colsample_bytree" = 0.7,
              # "lambda" = 1.0,
              "alpha" = 1.0,
              # "min_child_weight" = 6,
              # "gamma" = 10,
              "nthread" = 24)

watchlist <- list(train=dtrain)
xgb_cv <- xgb.cv(params=param,
                 data=dtrain,
                 nrounds=3000,
                 maximize = F,
#                  watchlist=watchlist,
                 nfold=5,
                 early.stop.round=15,
                 verbose=1)

nround <- which.min(bst.cv$test.mlogloss.mean)
set.seed(114)
xgb_model <- xgb.train(params=param,
                     data=dtrain,
                     nrounds=nround,
                     watchlist=watchlist,
                     verbose=1)
# predict
pred <- predict(xgb_model, dtest)
pred_detail <- t(matrix(pred,nrow=length(group_name)))
submit <- cbind(id=id[idx_test],as.data.frame(pred_detail))
colnames(submit) <- c("device_id",group_name)
write.csv(res_submit,file="submit_v0_0_0.csv",row.names=F,quote=F)








