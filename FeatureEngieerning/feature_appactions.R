library(data.table)
library(dplyr)
library(tidyr)

# events中的event_id是唯一的；
# app_events中的一个event_id会对应多个app_id
# combine applabel and label categories

# join applables and label categories
app_labels <- readRDS('./input/app_labels.rds')  # each app_id has it's unique label
label_categories <- readRDS('./input/label_categories.rds') # ecah label has its unique category
setkey(app_labels, label_id)
setkey(label_categories, label_id)
app_categories <- as.data.table(left_join(app_labels, label_categories, copy = F))%>%
  select(app_id, category)
rm(app_labels, label_categories)
# save rds
saveRDS(app_categories, file = './input/app_categories.rds')

# load events
events <- readRDS(file ='./input/events.rds')
events <- events%>%mutate(timestamp = ymd_hms(timestamp)
                          ,day = day(timestamp)  # no meaning
                          ,weekofday = weekdays(timestamp) # 周几
                          ,hour = hour(timestamp))   # 活动时刻；

# join appevents with appcategory
app_events <- readRDS(file ='./input/app_events.rds')
setkey(app_events, app_id)
app_events_addappcategory <- left_join(app_events, app_categories, by = c("app_id"="app_id"))
app_events_addappcategory%>%head(10)

# join with appevents with events  set the unique event_id
appid_category <- app_events_addappcategory[is_active==1, list(applist=paste0(category, collapse = ";"), appactions = .N), by = event_id]
appid_category%>%head(20)%>%View()
setkey(appid_category, event_id)

# join events with appid_category,use the applist and appactions;
setkey(events, event_id)
events_appid_category <- events[appid_category]

# 查看device的一周内的活动轨迹；
deviceid_weekday_cnt <- events_appid_category[, list(num = .N), by = list(device_id, weekofday)]
deviceid_weekday_total <- events_appid_category[, list(total = .N), by = list(device_id)]
deviceid_weekday_pct<- left_join(deviceid_weekday_cnt, deviceid_weekday_total, by = c("device_id"="device_id"))%>%
  mutate(pct = num/total)
# transform row to columns
deviceid_weekday_pct <- deviceid_weekday_pct%>%
  select(device_id, weekofday, pct)%>%
  spread(key = weekofday, value = pct, fill = 0)

# save rds, events with appcategorys'
saveRDS(events_appid_category, file = './input/events_appid_category.rds')
saveRDS(deviceid_weekday_pct, file = './input/deviceid_weekday_pct.rds')
saveRDS(deviceid_weekday_total, file = './input/deviceid_weekday_totalactions.rds')


