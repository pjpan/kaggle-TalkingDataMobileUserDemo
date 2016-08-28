#  访问地址: 方法1：百度API接口
# http://api.map.baidu.com/geocoder/v2/?ak=h5nCTXjRSYCgnhntfOYxuTDRGLLGwB95&location=31,121&output=json&pois=1
#####begin#####
#载入需要的包
library(rjson)
library(jsonlite)
library(RCurl)
library(dplyr)
library(DT)

# 去重复的经纬度；
events_lonlat <- events%>%
  filter(longitude>5, latitude >5)%>%
  select(longitude, latitude)%>%
  distinct()

# baidu API的AK，设置IP地址白名单为： *
AK <- "h5nCTXjRSYCgnhntfOYxuTDRGLLGwB95"

# for(i in 12171:nrow(events_lonlat))
for(i in 1:nrow(events_lonlat))
{ 

    if(i%%6000 ==0) { Sys.sleep(25) }  # 请求太频繁了，需要中断几秒钟；
  
    cat('第', i, '个记录:',"\n")
    # 设置URL地址
    url <- paste0("http://api.map.baidu.com/geocoder/v2/?ak=",AK,"&location=",events_lonlat$latitude[i],",",events_lonlat$longitude[i],"104&output=json&pois=1")
    url_string <- URLencode(url)
    # 捕获连接对象
    connect <- url(url_string)
    # 处理json对象
    geo_json <- tryCatch(fromJSON(paste(readLines(connect,warn = F), collapse = "")))
    if(!is.na(geo_json)) {
      events_lonlat[i,"country"] <- geo_json$result$addressComponent$country
      events_lonlat[i,"province"] <- geo_json$result$addressComponent$province
      events_lonlat[i,"city"] <- geo_json$result$addressComponent$city
      events_lonlat[i,"district"] <- geo_json$result$addressComponent$district    
    }
}

# 存取数据,存成.rds文件更节省存储空间；
# write.csv(events_lonlat, file = './input/events_lonlat_city.csv', row.names = F)
saveRDS(events_lonlat, file = './input/events_lonlat.rds')

#####--- end---- #######

#######  being  #########
# 方法2： 利用google接口，不过有个限制，2500/天；
# 采用 google的接口来进行查看；
for(i in 1:2500) { 
  cat('第几个记录', i)
  events_lonlat$address[i] <- revgeocode(c(events_lonlat$longitude[i], events_lonlat$latitude[i]), output = "address")  
}

