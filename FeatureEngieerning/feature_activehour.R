library(dplyr)
library(tidyr)
library(lubridate)
events <- readRDS('./input/events.rds')
events <- events%>%mutate(timestamp = ymd_hms(timestamp)
                          ,day = day(timestamp)
                          ,weekofday = weekdays(timestamp)
                          ,hour = hour(timestamp)
                          )

# group by device_id,hour
events_device_hour_detail <- events%>%
  count(device_id,hour)
setkey(events_device_hour_detail, device_id, hour)  # set the key to join

# look at hour distribution,looks like balance
events_device_hour_detail%>%
  count(hour)%>%
  mutate(pct= n/sum(n))%>%
  arrange(desc(pct))%>%
  View()

# group by device_id
events_device_summary <- events%>%
  count(device_id)
setkey(events_device_summary, device_id)   # set key to join

#join hourdata and pct
device_hour_pct_detail <- events_device_hour_detail[events_device_summary]%>%
  mutate(pct=n/i.n)%>%
  select(device_id,hour,pct)%>%
  mutate(hour = paste0("hour-", hour))

# convert row to columns
device_hour_pct <- spread(device_hour_pct_detail, key = hour, value = pct, fill = 0)

# device_hour_pct%>%head(10)

# write rds
saveRDS(device_hour_pct, file = './input/device_hour_pct.rds')
saveRDS(events_device_summary, file = './input/device_logintimes.rds')
