
#combine train & test data
gender_age_train <- readRDS(file = './input/gender_age_train.rds')
gender_age_test <- readRDS(file = './input/gender_age_test.rds')
gender_age_test$gender <- NA
gender_age_test$age <- NA
gender_age_test$group <- NA
gender_age_test$type <- "test"
gender_age_train$type <- "train"
gender_age_all <- as.data.table(bind_rows(gender_age_train, gender_age_test))
setkey(gender_age_all, device_id)
rm(gender_age_train, gender_age_test)
gc()

# load geo feature
deviceid_city_times <- readRDS(file = './input/deviceid_city_times.rds')  # 中间过程；
setkey(deviceid_city_times, device_id)
deviceid_country_times <- readRDS(file = './input/deviceid_country_times.rds')
setkey(deviceid_country_times, device_id)
deviceid_city <- readRDS(file = './input/deviceid_city.rds')
setkey(deviceid_city, device_id)
deviceid_country <- readRDS(file = './input/deviceid_country.rds')
setkey(deviceid_country, device_id)
deviceid_district <- readRDS(file = './input/deviceid_district.rds')
setkey(deviceid_district, device_id)
# load appaction features;
deviceid_hour_pct <- readRDS(file = './input/device_hour_pct.rds')
setkey(deviceid_hour_pct, device_id)
deviceid_logintimes <- readRDS(file = './input/device_logintimes.rds')
setkey(deviceid_logintimes, device_id)
deviceid_weekday_pct <- readRDS(file = './input/deviceid_weekday_pct.rds')
setkey(deviceid_weekday_pct, device_id)
deviceid_weekday_totalactions <- readRDS(file = './input/deviceid_weekday_totalactions.rds')
setkey(deviceid_weekday_totalactions, device_id)
deviceid_appid_totalcounts <- readRDS(file = './input/deviceid_appid_totalcounts.rds')
setkey(deviceid_appid_totalcounts, device_id)
deviceid_appid_active_pct <- readRDS(file = './input/deviceid_appid_active_pct.rds')
setkey(deviceid_appid_active_pct, device_id)
deviceid_appid_summary <- readRDS(file = './input/deviceid_appid_summary.rds')
setkey(deviceid_appid_summary, device_id)
deviceid_brandmodels_onehot <- readRDS(file = './input/device_brandmodels_onehot.rds')
setkey(deviceid_brandmodels_onehot, device_id)
deviceid_brands_onehot <- readRDS(file = './input/device_brands_onehot.rds')
setkey(deviceid_brands_onehot, device_id)
# combine raw device to other features
# total sampe 186716

# join geo features
names(deviceid_city_times) <- c("device_id","citytimes")
gender_age_all_ <- dplyr::left_join(gender_age_all, deviceid_city_times, by = c("device_id"="device_id")) # add citynums
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_city, by = c("device_id"="device_id")) # add citydetails
names(deviceid_country_times) <- c("device_id","countrytimes")
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_country_times, by = c("device_id"="device_id")) # add countrynums
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_country, by = c("device_id"="device_id")) # add countrydetails
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_district, by = c("device_id"="device_id")) # add districts

# join time features
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_hour_pct, by = c("device_id"="device_id")) # add districts
names(deviceid_logintimes) <- c("device_id","logintimes")
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_logintimes, by = c("device_id"="device_id")) # add districts
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_weekday_pct, by = c("device_id"="device_id")) # add districts
names(deviceid_weekday_totalactions) <- c("device_id","totalactions")
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_weekday_totalactions, by = c("device_id"="device_id")) # add districts


# join appid action features
names(deviceid_appid_totalcounts) <- c("device_id","totalappconts")
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_appid_totalcounts, by = c("device_id"="device_id")) # add districts
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_appid_active_pct, by = c("device_id"="device_id")) # add districts
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_appid_summary, by = c("device_id"="device_id")) # add districts
# join phone features
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_brandmodels_onehot, by = c("device_id"="device_id")) # add districts
gender_age_all_ <- dplyr::left_join(gender_age_all_, deviceid_brands_onehot, by = c("device_id"="device_id")) # add districts

# save files
# (186716, 3543)
saveRDS(gender_age_all_, file = './input/gender_age_allfeatures.rds')
names(gender_age_all_)






