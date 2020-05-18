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
library(shinycssloaders)


#shapes polygons for leaflet
ma_spdf = geojson_read("data/cb_2018_ma_county_5m.json",  what = "sp")


df_final = read.csv("https://raw.githubusercontent.com/ejfresch/MA_COVID19_data_analysis/master/data/cases_by_county_latest.csv",stringsAsFactors = FALSE, check.names = FALSE)

df_leaflet = ma_spdf
df_leaflet@data = left_join(df_leaflet@data, df_final,by = "NAME")
date_latest_avail_data=colnames(df_final)[ncol(df_final)-1]


df_num_deaths=read.csv("https://raw.githubusercontent.com/ejfresch/MA_COVID19_data_analysis/master/data/num_of_deaths_latest.csv",stringsAsFactors = FALSE)
total_num_deaths = sum(as.numeric(df_num_deaths$Num_deaths))
ma_population = 6892503
perc_entire_population = total_num_deaths/ma_population*100
perc_vs_num_cases = total_num_deaths / (sum(df_final[,(ncol(df_final)-1)])) * 100

df_to_plot_num_deaths=df_num_deaths
df_to_plot_num_deaths$Date=as.Date(df_to_plot_num_deaths$Date)


# DATA FOR THE GROWTH CURVE OF THE CASES
ma = colSums(df_final[,1:(ncol(df_final)-1)])
# doubling every day
n_0 = as.numeric(ma[5])
#lambda=2
#t=0:(nrow(df_final)-1)
#n = n_0 * lambda^t
# doubling every three days
lambda=2
t=0:(ncol(df_final)-6)
n = n_0 * lambda^(t/3)
doubl_3_days = c(rep(0,4),n)
# doubling every four days
lambda=2
t=0:(ncol(df_final)-6)
n = n_0 * lambda^(t/4)
doubl_4_days = c(rep(0,4),n)

df_to_plot=data.frame(
  Date=as.Date(colnames(df_final[1:(ncol(df_final)-1)])),
  Cases=ma, Prev=c(0,ma[1:length(ma)-1]))

df_to_plot$New_cases=df_to_plot$Cases-df_to_plot$Prev



# DATA FOR THE EPI CURVE

cases_by_county = df_final

# sum the data for all the counties / I need to subtract the data of Dukes or Nuntacket because they are
# duplicated in order to display the map correctly
data_all_counties=c(colSums(cases_by_county[,1:(length(cases_by_county)-1)]),
                    "All")
cases_by_county=rbind(cases_by_county,data_all_counties)

names_counties=sort(cases_by_county$NAME)
