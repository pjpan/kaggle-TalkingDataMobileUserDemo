#  访问地址
# http://api.map.baidu.com/geocoder/v2/?ak=h5nCTXjRSYCgnhntfOYxuTDRGLLGwB95&location=31,121&output=json&pois=1
#####自动运行-begin#####
#载入需要的包
library(rjson)
library(jsonlite)
library(RCurl)
library(dplyr)
library(DT)

#建立地址转换网址
AK <- "h5nCTXjRSYCgnhntfOYxuTDRGLLGwB95"

# for(i in 12171:nrow(events_lonlat))
for(i in 1:12171)
{ 

    if(i%%6000 ==0) { Sys.sleep(5) }  # 请求太频繁了，需要中断几秒钟；
  
    cat('第N个记录:', i,"\n")
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
}

