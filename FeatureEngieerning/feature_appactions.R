library(data.table)
library(dplyr)
library(tidyr)
library(lubridate)

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

# data clean
app_categories <- app_categories%>%
  filter(category!='Industry tag', category != 'unknown', category!='Custom label')%>%
  filter(category != 'Property Industry new', category != 'Property Industry 1.0', category != 'Property Industry 2.0')%>%
  filter(category != 'Cozy 1')%>%
  distinct()

# the same app_id has many category

# cut the game to game 
# appid time means this action copare to how many actions;
app_categories <- app_categories[, list(category_collect = paste0(category, collapse = ";")), by = "app_id"]
app_categories%>%head(100)%>%View()
app_categories%>%count(category_collect)%>%
  arrange(desc(n))%>%
  View()

# save rds
saveRDS(app_categories, file = './input/app_categories.rds')
# write.csv(app_categories$category_collect, file = './input/app_categories.txt', row.names = F)
  
# load events
events <- readRDS(file ='./input/events.rds')
events <- events%>%mutate(timestamp = ymd_hms(timestamp)
                          ,day = day(timestamp)  # no meaning
                          ,weekofday = weekdays(timestamp) # 周几
                          ,hour = hour(timestamp))   # 活动时刻；

# join appevents with appcategory, app_events
app_events <- readRDS(file ='./input/app_events.rds')
setkey(app_events, app_id)
app_events_addappcategory <- left_join(app_events, app_categories, by = c("app_id"="app_id"))
# app_events_addappcategory%>%head(1000)%>%View()

# events with appevents,match deviceid to appacations
# match events to deviceid
app_events_add_deviceid <- left_join(app_events_addappcategory, events%>%select(event_id, device_id)%>%distinct(), by = c("event_id"="event_id"))

# feature engineer ,to recategory
app_events_add_deviceid <- app_events_add_deviceid%>%
  mutate(recategory = ifelse(grepl("game-Puzzle;Relatives 1;Tencent;game",category_collect)>0, 'Tencent-game-Puzzle', category_collect)
         ,recategory = ifelse(grepl("80s Japanese comic",category_collect)>0, 'Game-80s', category_collect)
         ,recategory = ifelse(grepl("90s Japanese comic",category_collect)>0, 'Game-90s', category_collect)
         ,recategory = ifelse(grepl("online malls",category_collect)>0, 'Onlinemalls', category_collect)
         )

# app_events_add_deviceid%>%
#   count(recategory)%>%
#   arrange(desc(n))%>%
#   # filter(recategory=='Tencent-game-Puzzle')%>%
#   View()

# split data into device appcategory pair
tmp <- strsplit(app_events_add_deviceid$category_collect,";")
deviceid_apps <- data.table(device_id=rep(app_events_add_deviceid$device_id,
                                        times=sapply(tmp,length)),
                          appcategory=unlist(tmp))%>%count(device_id, appcategory)
# select top 200 appids
deviceid_apps_top200 <- deviceid_apps%>%
  count(appcategory)%>%
  mutate(pct=n/sum(n))%>%
  arrange(desc(pct))%>%
  mutate(cumsum = cumsum(n/sum(n)))%>%
  head(200)

# bigger then 200-> 'other'
deviceid_apps_detail <- deviceid_apps%>%
  mutate(appcategory = ifelse(appcategory%in%deviceid_apps_top200$appcategory, appcategory, 'other'))
# deviceid_apps_detail%>%head(10)

# deviceid appcategory summary
deviceid_appid_summary <- deviceid_apps_detail%>%
  group_by(device_id, appcategory)%>%
  summarise(total = sum(n))%>%
  spread(key = appcategory, value = total, fill = 0)

# deviceid_appid_summary%>%
#   head(100)%>%View()

# isactive appid actions
device_appid_category_cnt <- app_events_add_deviceid%>%
  filter(is_active==1)%>%
  count(device_id,category_collect)%>%
  arrange(desc(n))  # appevents sum by deviceid

deviceid_appid_category_total <- app_events_add_deviceid%>%
  count(device_id, is_active)%>%
  mutate(total = sum(n))%>%
  mutate(pct = n/total
         ,is_active = paste0("isactive:", is_active))   # appevents sum by deviceid

# change isactive row to columns
deviceid_appid_active_pct <- deviceid_appid_category_total%>%
  select(device_id,is_active,pct)%>%
  spread(key = is_active, value = pct, fill =0)
deviceid_appid_active_pct%>%head(10)%>%View()

# deviceid total appids
# change isactive row to columns
deviceid_appid_totalcounts <- app_events_add_deviceid%>%
  count(device_id)
deviceid_appid_totalcounts%>%head(100)%>%View()

# 查看device的一周内的活动轨迹；
deviceid_weekday_cnt <- events[, list(num = .N), by = list(device_id, weekofday)]
deviceid_weekday_total <- events[, list(total = .N), by = list(device_id)]
deviceid_weekday_pct<- left_join(deviceid_weekday_cnt, deviceid_weekday_total, by = c("device_id"="device_id"))%>%
  mutate(pct = num/total)

# transform row to columns
deviceid_weekday_pct <- deviceid_weekday_pct%>%
  select(device_id, weekofday, pct)%>%
  spread(key = weekofday, value = pct, fill = 0)

# save rds, events with appcategorys'
saveRDS(app_events_add_deviceid, file = './input/app_events_add_deviceid.rds')
saveRDS(deviceid_weekday_pct, file = './input/deviceid_weekday_pct.rds')
saveRDS(deviceid_weekday_total, file = './input/deviceid_weekday_totalactions.rds')
saveRDS(deviceid_appid_totalcounts, file = './input/deviceid_appid_totalcounts.rds')
saveRDS(deviceid_appid_active_pct, file = './input/deviceid_appid_active_pct.rds')
saveRDS(deviceid_appid_summary, file = './input/deviceid_appid_summary.rds')
