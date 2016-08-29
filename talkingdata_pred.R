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
app_events <- fread('./input/app_events.csv', integer64 = "character", nrows = 100000)  # the same event_id has muti app_id
events <- fread('./input/events.csv', integer64 = "character") # event_id is unique

app_labels <- fread('./input/app_labels.csv', integer64 = "character", nrows = 100000)  # each app_id has it's unique label
label_categories <- fread('./input/label_categories.csv', integer64 = "character") # ecah label has its unique category
gender_age_train <- fread('./input/gender_age_train.csv', integer64 = "character")
gender_age_test <- fread('./input/gender_age_test.csv', integer64 = "character", nrows = 100000)
phone_brand_device <- fread('./input/phone_brand_device_model.csv', integer64 = "character", nrows = 100000)

setkey(app_labels, label_id)
setkey(label_categories, label_id)
# combine applabel and label categories
app_labels_detail <- as.data.table(left_join(app_labels, label_categories, copy = F))
rm(app_labels, label_categories)
gc()
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
# sample
events%>%
  group_by(device_id)%>%
  count()%>%
  arrange(desc(n))%>%
  head(10)

# 查看一下各地的上网情况；
events_piece <- filter(events, device_id == '-17299534936664237')
ggmap(get_googlemap(center = 'china', zoom=4, maptype='terrain'),extent='device')+
  geom_point(data= events_piece,aes(x= longitude, y= latitude),colour = 'blue',alpha=0.7)

# 查看所有设备的路径图
ggmap(get_googlemap(center = 'china', zoom=4, maptype='terrain'),extent='device')+
  geom_point(data= events,aes(x= longitude, y= latitude),colour = 'blue',alpha=0.7)+
  ggtitle("所有用户的行动路径图")

# 查看不同deviceID对应的brand和models
phone_brand_device_ <- phone_brand_device%>%distinct()
devicephone <- phone_brand_device_[,list(N=.N, 
                                         devicemodels = paste0(device_model,collapse = ";"), 
                                         devicebrands= paste0(phone_brand,collapse = ";")), keyby='device_id']

# 查看不同地区的分布情况；
ggmap(get_googlemap(center = 'china', zoom=4,maptype='terrain'),extent='device')+
  geom_point(data=data, aes(x=lon,y=lan), colour = 'red', alpha=0.7)

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










