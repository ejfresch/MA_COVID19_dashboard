

server = function(input, output) {
  
  output$leaflet_chloropleth = renderLeaflet({
    
    df_leaflet = ma_spdf
    
    leaflet(df_leaflet) %>% 
      addTiles()  %>% 
      fitBounds(~min(-70), ~min(41.5), ~max(-73.5), ~max(43))
  })
  
   observe({
     target_date = as.character(input$date)
   
     df_final=read.csv("data/cases_by_county.csv",check.names = FALSE)
     df_leaflet = ma_spdf
     df_leaflet@data = left_join(df_leaflet@data, df_final,by = "NAME")
     
     mybins = c(0,1,10,100,1000,10000,100000)
     mypalette = colorBin( palette="YlOrRd", domain=df_leaflet@data[,target_date], na.color="transparent", bins=mybins)
     
     mytag = paste(
       "County: ", df_leaflet@data$NAME,"<br/>", 
       "Confirmed: ", df_leaflet@data[,target_date], "<br/>", 
       sep="") %>%
       lapply(htmltools::HTML)
     
     leafletProxy("leaflet_chloropleth") %>%
       clearShapes() %>%
       addPolygons(data =df_leaflet, fillColor = ~mypalette(df_leaflet@data[,target_date]),
                   fillOpacity = 0.5,
                   stroke=TRUE,
                   weight=0.8,
                   color="#000000",
                   label = mytag,
                   labelOptions = labelOptions(
                     style = list("font-weight" = "normal", padding = "3px 8px"),
                     textsize = "10px",
                     direction = "auto"
                   ))%>% clearControls() %>%
       addLegend( pal=mypalette, values=df_leaflet@data[,target_date], opacity=0.5, title = "Cases", position = "bottomleft" )
     
    
   
   } )
   

   output$curves = renderPlotly({
      
      df_final=read.csv("data/cases_by_county.csv",check.names = FALSE)
     
     ma = colSums(df_final[,1:(ncol(df_final)-1)])
     # doubling every day
     n_0 = as.numeric(ma[5])
     #lambda=2
     #t=0:(nrow(df_final)-1)
     #n = n_0 * lambda^t
     # doubling every two days
     lambda=2
     t=0:(ncol(df_final)-6)
     n = n_0 * lambda^(t/3)
     doubl_3_days = c(rep(0,4),n)
     # doubling every three days
     lambda=2
     t=0:(ncol(df_final)-6)
     n = n_0 * lambda^(t/4)
     doubl_4_days = c(rep(0,4),n)
     
     df_to_plot=data.frame(
       Date=as.Date(colnames(df_final[1:(ncol(df_final)-1)])),
       Cases=ma)
     
     choice = input$choose_type
     if(choice == "Linear"){
       p=ggplot(data=df_to_plot, aes(x=Date, y=Cases, group=1)) +
         geom_line(size=1, color="#636363")+
         geom_point(shape=19, size=2, color="#525252") +
         xlab("Date") + 
         ylab("Number of cases") +
         scale_x_date(date_breaks = "1 week", date_labels = "%b %d")

     }else{
       
       p=ggplot(data=df_to_plot, aes(x=Date, y=Cases, group=1)) +
         geom_line(size=1, color="#636363")+
         geom_point(shape=19, size=2, color="#525252") +
         xlab("Date") + 
         ylab("Number of cases")+
         scale_y_log10() + 
         scale_x_date(date_breaks = "1 week", date_labels = "%b %d")
         }
     w =ggplotly(p + 
                   geom_line(aes(x=Date, y = doubl_3_days), color = "red", linetype = "dotted") +
                   geom_line(aes(x=Date, y = doubl_4_days), color = "orange", linetype = "dotted")
                 
     )
     w %>% style(hoverinfo = "skip", traces = c(2,3))
     
   })
  
   
   
   output$epi_curve = renderPlotly({
      

      choice = input$choose_county
      
      cases_by_county = read.csv("data/cases_by_county.csv",check.names = FALSE, stringsAsFactors = FALSE)
      
      
      # sum the data for all the counties / I need to subtract the data of Dukes or Nuntacket because they are
      # duplicated in order to display the map correctly
      data_all_counties=c(colSums(cases_by_county[,1:(length(cases_by_county)-1)]) -
                             as.numeric(cases_by_county[cases_by_county$NAME=="Dukes", 1:(length(cases_by_county)-1)]),
                          "All")
      cases_by_county=rbind(cases_by_county,data_all_counties)
            
      selected_county=choice

      numbers = cases_by_county[cases_by_county$NAME==selected_county,]
         
   
      
      n_cases_selected_county=as.numeric(numbers[1:(length(numbers)-1)])
      vect_for_diff=c(0,n_cases_selected_county[1:(length(n_cases_selected_county)-1)])
      vect_new_cases = n_cases_selected_county - vect_for_diff
      df_new_cases = data.frame(Date=as.Date(colnames(numbers)[1:(length(numbers)-1)]),
                                New_cases=vect_new_cases)
      df_to_plot_epi_curve = df_new_cases %>% group_by(Date = cut(Date +6, "week", start.on.monday = FALSE)) %>% 
         summarise(New_cases = sum(New_cases))
      
      df_to_plot_epi_curve$Date=as.Date(df_to_plot_epi_curve$Date)
      
      # remove last point if I do not have the data for the complete week
      if(as.vector(df_to_plot_epi_curve$Date)[nrow(df_to_plot_epi_curve)] < date_latest_avail_data){
         df_to_plot_epi_curve = df_to_plot_epi_curve[1:(nrow(df_to_plot_epi_curve)-1),]
      }
      
      p = ggplot(df_to_plot_epi_curve,aes(x=Date,y=New_cases))+
         geom_area( fill="#69b3a2", alpha=0.4) +
         geom_line(color="#69b3a2", size=1) +
         geom_point(size=2, color="#69b3a2") +
         xlab("Week") + 
         ylab("New cases")+
         scale_x_date(date_breaks = "1 week", date_labels = "%b %d")
      ggplotly(p)
      
   })
   
   
   
    
}