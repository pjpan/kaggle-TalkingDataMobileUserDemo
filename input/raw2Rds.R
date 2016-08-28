library(data.table)
library(bit64)

# app_events;
cat("load data")
app_events <- fread('./input/app_events.csv', integer64 = "character")  # the same event_id has muti app_id
events <- fread('./input/events.csv', integer64 = "character") # event_id is unique

app_labels <- fread('./input/app_labels.csv', integer64 = "character")  # each app_id has it's unique label
label_categories <- fread('./input/label_categories.csv', integer64 = "character") # ecah label has its unique category
gender_age_train <- fread('./input/gender_age_train.csv', integer64 = "character")
gender_age_test <- fread('./input/gender_age_test.csv', integer64 = "character")
phone_brand_device <- fread('./input/phone_brand_device_model.csv', integer64 = "character")

# wrie data to rds
saveRDS(app_events, './input/app_events.rds')
saveRDS(events, './input/events.rds')
saveRDS(app_labels, './input/app_labels.rds')
saveRDS(label_categories, './input/label_categories.rds')
saveRDS(gender_age_train, './input/gender_age_train.rds')
saveRDS(gender_age_test, './input/gender_age_test.rds')
saveRDS(phone_brand_device, './input/phone_brand_device.rds')
