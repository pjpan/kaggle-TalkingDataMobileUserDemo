library(xgboost)
library(mxnet)
library(dplyr)
library(data.table)

# app_events;
cat("load data")
app_events <- fread('./input/app_events.csv', integer64 = "character")  # the same event_id has muti app_id
events <- fread('./input/events.csv', integer64 = "character") # event_id is unique

app_labels <- fread('./input/app_labels.csv', integer64 = "character")  # each app_id has it's unique label
label_categories <- fread('./input/label_categories.csv', integer64 = "character") # ecah label has its unique category
gender_age_train <- fread('./input/gender_age_train.csv', integer64 = "character")
gender_age_test <- fread('./input/gender_age_test.csv', integer64 = "character")
phone_brand_device <- fread('./input/phone_brand_device_model.csv', integer64 = "character")

setkey(app_labels, label_id)
setkey(label_categories, label_id)
# combine applabel and label categories
app_labels_detail <- left_join(app_labels, label_categories, copy = F)
rm(app_labels, label_categories, product_descriptions)
gc()
# app_label_detail the same app_id has tow label_id
head(app_labels_detail, 1000)

# 
library(ggplot2)
library(ggthemes)
library(lubridate)
ggplot()+geom_bar(aes(phone_brand_device$phone_brand))+theme_economist()
# feature engineering
cat("feature engineering")
device_logintime <- events[, .N, by = device_id]  # device login times 
appid_category_group <- app_labels_detail[, .(action = paste0(category, collapse = ";")), by = app_id]

# change timestamp to year,month,day,weekofday,hour
events <- events%>%mutate(timestamp = ymd_hms(timestamp)
                          ,year = year(timestamp)
                          ,month = month(timestamp)
                          ,day = day(timestamp)
                          ,weekofday = weekdays(timestamp)
                          ,hour = hour(timestamp))

events%>%ggplot()+geom_bar(aes(hour))
events%>%group_by(hour)%>%summarise(n=.N)

deviceid <- c('1805595054953645708')
filter(events, device_id == deviceid)
filter(gender_age_train, device_id == deviceid)
filter(device_logintime, device_id == deviceid)
filter(app_events, event_id == 3246084)




