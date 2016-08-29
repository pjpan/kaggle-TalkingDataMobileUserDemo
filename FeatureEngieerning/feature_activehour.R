library(dplyr)
library(tidyr)
library(lubridate)
events <- readRDS('./input/events.rds')
events <- events%>%mutate(timestamp = ymd_hms(timestamp)
                          ,day = day(timestamp)
                          ,weekofday = weekdays(timestamp)
                          ,hour = hour(timestamp)
                          )

events_device_hour_detail <- events%>%
  count(device_id,hour)%>%summarise_each(funs = sum(n), device_id)


