library(geojsonio)
library(ggplot2)
library(leaflet)
library(plotly)
library(RColorBrewer)
library(dplyr)
library(broom)
library(mapproj)
library(reshape2)
library(digest)
library(lubridate)

source("get_data_from_wikipedia.R",local=TRUE)

#shapes polygons for leaflet
ma_spdf = geojson_read("data/cb_2018_ma_county_5m.json",  what = "sp")


# Download the data from Wikipedia
library(rvest)    
url = "https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Massachusetts"
r_data_wiki = url %>% 
  read_html() 

if (file.exists("data/collection.Rdata")){
  load("data/collection.Rdata")
}
  
current_data_hash = digest(r_data_wiki %>% html_text(), "md5")
if(exists("stored_data_hash")){
  if(current_data_hash != stored_data_hash){
    get_data_from_wiki(r_data_wiki)
  }
  
}else{
  get_data_from_wiki(r_data_wiki)
}

