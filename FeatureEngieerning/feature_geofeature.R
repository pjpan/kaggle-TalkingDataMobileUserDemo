library(dplyr)
library(data.table)
library(tidyr)

print("load data")
lonlat_match <- fread('./input/events_lonlat_city.csv')
setkey(lonlat_match, longitude, latitude)
setkey(events, longitude, latitude)
events_addgeocity <- events[lonlat_match]

# device_id的城市数，常用的城市数，每个城市的次数；
deviceid_city_counts <- events_addgeocity%>%
  count(device_id, city)
head(deviceid_city_counts, 1000)%>%arrange(device_id)

# top 200<91%>
cityNum <- deviceid_city_counts%>%
  count(city)%>%
  mutate(pct=n/sum(n))%>%
  arrange(desc(n))%>%
  mutate(cumpct=cumsum(pct))%>%head(200)

# device_id的国家数量；
deviceid_country_counts <- events_addgeocity%>%
  distinct(device_id, country)%>%count(device_id, country)
head(deviceid_country_counts, 1000)%>%arrange(device_id)

# save rds
saveRDS(deviceid_city_counts, file = './input/deviceid_city_nums.rds')
saveRDS(deviceid_country_counts, file = './input/deviceid_country_nums.rds')
# 地理位置的相似性；




