library(xgboost)
library(dplyr)
library(data.table)
library(Matrix)

gender_age_total <- readRDS(file = './input/gender_age_allfeatures.rds')
gender_age_train <- gender_age_total[type == "train", ]
gender_age_test <- gender_age_total[type == "test", ]

# recode the group class
gender_age_train$group <- car::recode(gender_age_train$group,"'F24-26'=0; 'M29-31'=1; 'M22-'=2; 'F33-42'=3; 'M32-38'=4; 'M39+'=5; 'F43+'=6; 'F27-28'=7; 'F23-'=8; 'M23-26'=9; 'M27-28'=10; 'F29-32'=11")

groupname <- c('F24-26', 'M29-31', 'M22-', 'F33-42', 'M32-38', 'M39+', 'F43+', 'F27-28', 'F23-', 'M23-26', 'M27-28', 'F29-32')

# split training and CV set 
train <- rbinom(nrow(gender_age_train), 1, 0.8)==1
# gender_age_train_cv1 <- gender_age_train[train,-5, with = F]
gender_age_train_cv1 <- gender_age_train[train,]%>%select(-c(type, device_id, gender, age))  # delete deviceid,gender,age 
gender_age_train_cv2 <- gender_age_train[!train,]%>%select(-c(type, device_id, gender, age)) # delete deviceid,gender,age

# check wheather has same distributions
# gender_age_train_cv1%>%count(group)%>%mutate(pct=n/sum(n))
# gender_age_train_cv2%>%count(group)%>%mutate(pct=n/sum(n))

# change columns names,fix utf8 error
gender_age_train_names <- names(gender_age_train_cv1)
names(gender_age_train_cv1)[2:ncol(gender_age_train_cv1)] <- paste0("X_",2:ncol(gender_age_train_cv1))
names(gender_age_train_cv2)[2:ncol(gender_age_train_cv2)] <- paste0("X_",2:ncol(gender_age_train_cv2))

# train models
group_class <- na.omit(unique(gender_age_train$group))

#  train xgbmodel
param <- list("objective" = "multi:softprob",
              "num_class" = 12,
              # "eval_metric" = "merror",
              "eval_metric" = "mlogloss", 
              "eta" = 0.05,
              "max_depth" = 5,
              "subsample" = 0.6,
              "colsample_bytree" = 0.7,
              # "lambda" = 1.0,
              "alpha" = 1.0,
              # "min_child_weight" = 6,
              # "gamma" = 10,
              "nthread" = 32)

# change data to xgb.dmatrix
dtrain <- xgb.DMatrix(as.matrix(gender_age_train_cv1%>%select(-group)), label = gender_age_train_cv1$group, missing = NA)
dtest <- xgb.DMatrix(as.matrix(gender_age_train_cv2%>%select(-group)), label = gender_age_train_cv2$group, missing = NA)

set.seed(831)
watchlist = list(train = dtrain, eval = dtest)
xgb_cv <- xgb.cv(params = param,
                 data = dtrain,
                 nrounds = 1000,
                 maximize = F,
                 watchlist = watchlist,
                 nfold = 5,
                 early.stop.round = 15,
                 verbose = 1)

bst_cv_round <- which.min(xgb_cv$test.mlogloss.mean)

xgb_model <- xgb.train(params = param,
                     data = dtrain,
                     nrounds = bst_cv_round,
                     watchlist = watchlist,
                     verbose = 1)
xgb.importance(model = xgb_model)

# predict
pred <- predict(xgb_model, dtest)
pred_detail <- t(matrix(pred, nrow=length(groupname)))
colnames(pred_detail) <- groupname

test <- as.data.table(cbind(gender_age_train[!train,]%>%select(group), pred_detail))
test$group <- car::recode(test$group,"0='F24-26'; 1='M29-31'; 2='M22-'; 3='F33-42'; 4='M32-38'; 5='M39+'; 6='F43+'; 7='F27-28'; 8='F23-'; 9='M23-26'; 10='M27-28'; 11='F29-32'")

# submit <- cbind(id=id[idx_test],as.data.frame(pred_detail))
# colnames(submit) <- c("device_id",groupname)
# write.csv(res_submit,file="submit_v0_0_0.csv",row.names=F,quote=F)







