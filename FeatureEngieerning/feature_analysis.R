# 查看一下各地的上网情况；
events_piece <- filter(events, device_id == '-17299534936664237')
ggmap(get_googlemap(center = 'china', zoom=4, maptype='terrain'),extent='device')+
  geom_point(data= events_piece,aes(x= longitude, y= latitude),colour = 'blue',alpha=0.7)

# 查看所有设备的路径图
ggmap(get_googlemap(center = 'china', zoom=4, maptype='terrain'),extent='device')+
  geom_point(data= events,aes(x= longitude, y= latitude),colour = 'blue',alpha=0.7)+
  ggtitle("所有用户的行动路径图")

# 查看不同deviceID对应的brand和models
phone_brand_device_ <- phone_brand_device%>%distinct()

# 查看不同地区的分布情况；
ggmap(get_googlemap(center = 'china', zoom=4,maptype='terrain'),extent='device')+
  geom_point(data=data, aes(x=lon,y=lan), colour = 'red', alpha=0.7)