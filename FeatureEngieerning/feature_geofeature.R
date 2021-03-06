library(dplyr)
library(data.table)
library(tidyr)

# 根据去过的地理位置的不同，区分出商务人士和一般家庭人员
# Feature1: isbusinessperson
# Feature2: city citynum
# Feature3: citymatch_genderAge
# 获取出经纬度的地理位置信息
# 单独拿出经纬度的信息来进行评估是哪个城市的；
print("load data")
lonlat_match <- readRDS('./input/events_lonlat_city.rds')
events <- readRDS('./input/events.rds')
setkey(lonlat_match, longitude, latitude)
setkey(events, longitude, latitude)
events_addgeocity <- events[lonlat_match]

# transform 
events_addgeocity <- events_addgeocity%>%
  filter(city!="")

# device_id的城市数，常用的城市数，每个城市的次数；
deviceid_city_counts <- events_addgeocity%>%
  count(device_id, city)
# head(deviceid_city_counts, 1000)%>%arrange(device_id)
deviceid_city_times <- deviceid_city_counts%>%count(device_id)

# # top 200<91%>
# cityNum <- events_addgeocity%>%
#   count(city)%>%
#   mutate(pct=n/sum(n))%>%
#   arrange(desc(n))%>%
#   mutate(cumpct=cumsum(pct))%>%head(200)

# city from row to columns
deviceid_city <- deviceid_city_counts%>%
  spread(key = city, value = n, fill = 0)

# device_id的国家数量；
deviceid_country_counts <- events_addgeocity%>%
  distinct(device_id, country)%>%count(device_id, country)

deviceid_country_times <- deviceid_country_counts%>%count(device_id)

# city from row to columns
deviceid_country <- deviceid_country_counts%>%
  spread(key = country, value = n, fill = 0)

# district analysis
deviceid_district_counts <- events_addgeocity%>%
  filter(district!="")%>%
  filter(country=="中国")%>%
  distinct(device_id, district)%>%count(device_id, district)

events_addgeocity%>%count(province)%>%arrange(desc(n))%>%head(100)
# city from row to columns
deviceid_district <- deviceid_district_counts%>%
  spread(key = district, value = n, fill = 0)

# save rds
saveRDS(deviceid_city_times, file = './input/deviceid_city_times.rds')
saveRDS(deviceid_country_times, file = './input/deviceid_country_times.rds')
saveRDS(deviceid_city, file = './input/deviceid_city.rds')
saveRDS(deviceid_country, file = './input/deviceid_country.rds')
saveRDS(deviceid_district, file = './input/deviceid_district.rds')