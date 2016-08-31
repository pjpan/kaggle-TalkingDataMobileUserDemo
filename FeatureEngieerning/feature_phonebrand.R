library(data.table)
library(dplyr)
library(tidyr)

device_phone_brand <- readRDS('./input/phone_brand_device.rds')
device_phonebrand <- device_phone_brand[,list(N=.N, 
                                         devicemodels = paste0(device_model,collapse = ";"), 
                                         devicebrands= paste0(phone_brand,collapse = ";"),
                                         modelbrands = paste(phone_brand, device_model,collapse = ";", sep = ":")), keyby='device_id']

# delete the same device mtach >=2 brand;
device_phonebrand <- device_phonebrand%>%filter(N==1)
# phone brand distribution 98.9%
devicebrands_selected <- device_phonebrand%>%
  count(devicebrands)%>%
  arrange(desc(n))%>%
  mutate(pct=n/sum(n))%>%
  mutate(cumpct = cumsum(pct))%>%head(35)
# 只选取前35名的品牌名称；
device_phonebrand <- device_phonebrand%>%
  mutate(devicebrands = ifelse(devicebrands%in% devicebrands_selected$devicebrands, devicebrands, '其他'))
# device_phonebrand%>%count(devicebrands)
# device_phonebrand%>%head(100)%>%View()

# row to columns
names(device_phonebrand)
device_brands_onehot <- device_phonebrand%>%
  select(device_id, N, devicebrands)%>%
  spread(key = devicebrands, value = N, fill= 0)

# devices model to recatogory
devicemodels_selected <- device_phonebrand%>%
  count(devicemodels)%>%
  arrange(desc(n))%>%
  mutate(pct=n/sum(n))%>%
  mutate(cumpct = cumsum(pct))%>%head(300)
# 只选取前300名的手机；
device_phonebrand <- device_phonebrand%>%
  mutate(devicemodels = ifelse(devicemodels%in% devicemodels_selected$devicemodels, devicemodels, '其他'))
device_phonebrand%>%count(devicemodels)

# row to columns
names(device_phonebrand)
device_brandmodels_onehot <- device_phonebrand%>%
  select(device_id, N, devicemodels)%>%
  spread(key = devicemodels, value = N, fill= 0)

device_brandmodels_onehot%>%head(10)%>%DT::datatable()  # View data
# write rds file

saveRDS(device_brandmodels_onehot, file = './input/device_brandmodels_onehot.rds')
saveRDS(device_brands_onehot, file = './input/device_brands_onehot.rds')
