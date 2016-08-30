
#combine train & test data
gender_age_train <- readRDS(file = './input/gender_age_train.rds')
gender_age_test <- readRDS(file = './input/gender_age_test.rds')
gender_age_test$gender <- NA
gender_age_test$age <- NA
gender_age_test$group <- NA
gender_age_test$type <- "test"
gender_age_train$type <- "train"
gender_age_all <- bind_rows(gender_age_train, gender_age_test)
rm(gender_age_train, gender_age_test)
gc()

# load feature
deviceid_city_nums <- readRDS(file = './input/deviceid_city_nums.rds')
deviceid_country_nums <- readRDS(file = './input/deviceid_country_nums.rds')
deviceid_city <- readRDS(file = './input/deviceid_city.rds')
deviceid_country <- readRDS(file = './input/deviceid_country.rds')
deviceid_district <- readRDS(file = './input/deviceid_district.rds')
deviceid_hour_pct <- readRDS(file = './input/device_hour_pct.rds')
deviceid_logintimes <- readRDS(file = './input/device_logintimes.rds')
deviceid_weekday_pct <- readRDS(file = './input/deviceid_weekday_pct.rds')
deviceid_weekday_totalactions <- readRDS(file = './input/deviceid_weekday_totalactions.rds')
deviceid_appid_totalcounts <- readRDS(file = './input/deviceid_appid_totalcounts.rds')
deviceid_appid_active_pct <- readRDS(file = './input/deviceid_appid_active_pct.rds')
deviceid_appid_summary <- readRDS(file = './input/deviceid_appid_summary.rds')
deviceid_brandmodels_onehot <- readRDS(file = './input/device_brandmodels_onehot.rds')
deviceid_brands_onehot <- readRDS(file = './input/device_brands_onehot.rds')

# combine raw device to other features








