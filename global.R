library(geojsonio)
library(ggplot2)
library(leaflet)
library(plotly)
library(RColorBrewer)
library(dplyr)
library(broom)
library(mapproj)
library(reshape2)

#shapes polygons for leaflet
ma_spdf = geojson_read("data/cb_2018_ma_county_5m.json",  what = "sp")


# Download the data from Wikipedia
library(rvest)    
url = "https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Massachusetts"
raw_data_wiki = url %>% 
  read_html() 

raw_data= raw_data_wiki %>% 
  html_node(xpath = '/html/body/div[3]/div[3]/div[4]/div/table[4]') %>%
  html_table(fill = TRUE)


# Formatthe data
library(lubridate)
data_cleaned = raw_data[2:(nrow(raw_data)-2),1:(ncol(raw_data)-2)]
colnames(data_cleaned) =raw_data[1,1:(ncol(raw_data)-2)] 

data_final = t(data_cleaned[,2:ncol(data_cleaned)])
colnames(data_final) = data_cleaned$Date

# Fixing problems Dukes/Nantucket
idx_dukes_nantucket = which(rownames(data_final)=="Dukes and Nantucket")
## I save the data
row = data_final[idx_dukes_nantucket,]
## I change the name "Dukes and Nantucket" -> "Dukes"
rownames(data_final)[idx_dukes_nantucket] = "Dukes"
## I create the row for Nantucket
data_final = rbind(data_final, row)
rownames(data_final)[nrow(data_final)] = "Nantucket"

# I change the names of the columns
list_of_dates = as.Date(paste(colnames(data_final),"2020",sep=" "),"%B %d %Y")
colnames(data_final)=format(list_of_dates, format="%Y-%m-%d")

mat = data_final
# I fill the empty cells and convert all cells to numeric
for(r in 1:nrow(mat)){
  current_vect = mat[r, ]
  prev = 0
  vect_results=c()
  for(element in current_vect){
    if(is.na(element)){
      vect_results=c(vect_results,prev)
    }else if(element==""){
      vect_results=c(vect_results,prev)
    }else{
      vect_results=c(vect_results,as.numeric(element))
      prev = as.numeric(element)
    }
  }
  mat[r,] = vect_results
}
m = sapply(mat, FUN=as.numeric)
mat_final=matrix(m, ncol=ncol(data_final),nrow=nrow(data_final))

# I convert the matrix to data frame
df_final = as.data.frame(mat_final)
rownames(df_final) = rownames(data_final)
colnames(df_final) = colnames(data_final)

# I add a column with the names
df_final$NAME = rownames(df_final)
df_final=df_final[,5:ncol(df_final)]
names_counties = sort(c("All",df_final$NAME))
write.csv(df_final,file="data/cases_by_county.csv",quote=FALSE,row.names=FALSE)

date_latest_avail_data=colnames(df_final)[ncol(df_final)-1]


raw_data_table_deaths = raw_data_wiki %>% 
  html_node(xpath = '/html/body/div[3]/div[3]/div[4]/div/table[3]') %>%
  html_table(fill = TRUE)
# location column of the deaths
column_deaths = ncol(raw_data_table_deaths) - 2
df_num_deaths = data.frame(Date=as.Date(paste(raw_data_table_deaths[7:(nrow(raw_data_table_deaths)-2),1],"2020",sep=" "), format = "%B %d %Y"),
                                        Num_deaths = raw_data_table_deaths[7:(nrow(raw_data_table_deaths)-2),column_deaths],stringsAsFactors = FALSE)

df_num_deaths = df_num_deaths %>% mutate(Num_deaths = ifelse(Num_deaths %in% "", 0, as.numeric(Num_deaths)))
df_num_deaths[df_num_deaths$Date=="2020-03-20","Num_deaths"]=1
total_num_deaths = sum(as.numeric(df_num_deaths$Num_deaths))
ma_population = 6892503
perc_entire_population = total_num_deaths/ma_population*100
perc_vs_num_cases = total_num_deaths / (sum(df_final[df_final$NAME!="Nantucket",(ncol(df_final)-1)])) * 100

df_to_plot_num_deaths = df_num_deaths %>% group_by(Date = cut(Date +6, "week", start.on.monday = FALSE)) %>% 
  summarise(Num_deaths = sum(Num_deaths))

df_to_plot_num_deaths$Date=as.Date(df_to_plot_num_deaths$Date)

# remove last point if I do not have the data for the complete week
if(as.vector(df_to_plot_num_deaths$Date)[nrow(df_to_plot_num_deaths)] < date_latest_avail_data){
  df_to_plot_num_deaths = df_to_plot_num_deaths[1:(nrow(df_to_plot_num_deaths)-1),]
}



