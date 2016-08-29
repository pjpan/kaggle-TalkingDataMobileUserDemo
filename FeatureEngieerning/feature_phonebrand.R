library(data.table)
library(dplyr)

device_phone_brand <- readRDS('./input/phone_brand_device.rds')

device_phone_brand%>%count(device_id,)

app_events <- readRDS('./input/app_events.rds')
app_labels <- readRDS('./input/app_labels.rds')
labels_categories <- readRDS('./input/label_categories.rds')

events%>%head(10)
app_events%>%head(10)

app_events%>%head(100)%>%View()
app_events%>%count(is_installed)
