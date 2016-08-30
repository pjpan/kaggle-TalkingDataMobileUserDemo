library(xgboost)
library(dplyr)
library(data.table)
library(plotly)
library(ggplot2)
library(ggthemes)
library(lubridate)
library(ggmap)

# app_events;
cat("load data")

# app_label_detail the same app_id has tow label_id
head(app_labels_detail, 1000)

#combine train & test data
gender_age_test$gender <- NA
gender_age_test$age <- NA
gender_age_test$group <- NA
gender_age_test$type <- "test"
gender_age_train$type <- "train"
gender_age_all <- bind_rows(gender_age_train, gender_age_test)
rm(gender_age_train, gender_age_test)
gc()
# 
ggplot()+geom_bar(aes(phone_brand_device$phone_brand))+theme_economist()
# feature engineering
cat("feature engineering")
device_logintime <- events[, .N, by = device_id]  # device login times 
appid_category_group <- app_labels_detail[, .(action = paste0(category, collapse = ";")), by = app_id]

appid_category_cnt <- app_labels_detail[, .N, by = list(app_id,category)]
appid_category_cnt%>%head(10)

# change timestamp to year,month,day,weekofday,hour
# just 7days data,so the importance feature would be hour:
events <- events%>%mutate(timestamp = ymd_hms(timestamp)
                          ,day = day(timestamp)
                          ,weekofday = weekdays(timestamp)
                          ,hour = hour(timestamp))

# 根据去过的地理位置的不同，区分出商务人士和一般家庭人员
# Feature1: isbusinessperson
# Feature2: city citynum
# Feature3: citymatch_genderAge
# 获取出经纬度的地理位置信息
# 单独拿出经纬度的信息来进行评估是哪个城市的；

# events_lonlat <- events_lonlat%>%
#   mutate(address = revgeocode(c(longitude, latitude), output = "address"))
allcategory <- app_labels_detail%>%
  group_by(category)%>%
  count(category)%>%
  mutate(pct=n/sum(n))%>%
  arrange(desc(pct))

pred <- predict(fit_xgb,dtest)
pred_detail <- t(matrix(pred,nrow=length(group_name)))
res_submit <- cbind(id=id[idx_test],as.data.frame(pred_detail))
colnames(res_submit) <- c("device_id",group_name)
write.csv(res_submit,file="submit_v0_7_1.csv",row.names=F,quote=F)








