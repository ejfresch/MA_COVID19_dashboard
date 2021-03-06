

server = function(input, output, session) {
  
   
   output$leaflet_chloropleth = renderLeaflet({
      
      target_date = date_latest_avail_data
   
      mybins = c(0,1,10,100,1000,10000,100000)
      mypalette = colorBin( palette="YlOrRd", domain=df_leaflet@data[,target_date], na.color="transparent", bins=mybins)
      
      mytag = paste(
         "County: ", df_leaflet@data$NAME,"<br/>", 
         "Cases: ", df_leaflet@data[,target_date], "<br/>", 
         sep="") %>%
         lapply(htmltools::HTML)
      
      leaflet(df_leaflet) %>% 
         addTiles()  %>% 
         fitBounds(~min(-70), ~min(41.5), ~max(-73.5), ~max(43)) %>%
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
      
      
   })
   

   output$curves = renderPlotly({
      
      
      
      choice = input$choose_type
      
      first_value = df_to_plot[1,]
      last_value = df_to_plot[nrow(df_to_plot),]
      
      if(choice == "Linear"){
         p=ggplot(data=df_to_plot, aes(x=Date, y=Cases, group=1, label = New_cases)) +
            geom_path(size=1, color="#636363",lineend="round", linejoin = "round",)+
            geom_point(data=first_value, aes(x=Date,y=Cases),size=2, color="#525252") +
            geom_point(data=last_value, aes(x=Date,y=Cases),size=2, color="#525252") +
            #geom_point(shape=19, size=2, color="#525252") +
            xlab("Date") + 
            ylab("Number of cases") +
            ylim(c(0,100000)) +
            scale_x_date(date_breaks = "1 week", date_labels = "%b %d")

         
      }else{
         
         p=ggplot(data=df_to_plot, aes(x=Date, y=Cases, group=1, label = New_cases)) +
            geom_path(size=1, color="#636363", lineend="round",linejoin = "round")+
            geom_point(data=first_value, aes(x=Date,y=Cases),size=2, color="#525252") +
            geom_point(data=last_value, aes(x=Date,y=Cases),size=2, color="#525252") +
            #geom_point(shape=19, size=2, color="#525252") +
            xlab("Time") + 
            ylab("Number of cases")+
            ylim(c(0,100000)) +
            scale_y_log10() + 
            scale_x_date(date_breaks = "1 week", date_labels = "%b %d")
         }
      w =ggplotly(p  + 
                     geom_line(aes(x=Date, y = doubl_3_days), color = "red", linetype = "dotted") +
                     geom_line(aes(x=Date, y = doubl_4_days), color = "orange", linetype = "dotted")
                  
      )
      w %>% style(hoverinfo = "skip", traces = c(2,3,4,5))
      
   })
   
   
   
   output$epi_curve = renderPlotly({
      
      selected_county = input$choose_county
      
      
      numbers = cases_by_county[cases_by_county$NAME==selected_county,]
      
      n_cases_selected_county=as.numeric(numbers[1:(length(numbers)-1)])
      vect_for_diff=c(0,n_cases_selected_county[1:(length(n_cases_selected_county)-1)])
      vect_new_cases = n_cases_selected_county - vect_for_diff
      df_new_cases = data.frame(Date=as.Date(colnames(numbers)[1:(length(numbers)-1)]),
                                New_cases=vect_new_cases)
      df_to_plot_epi_curve = df_new_cases
      
      df_to_plot_epi_curve$Date=as.Date(df_to_plot_epi_curve$Date)
      
      
      #first_value = df_to_plot_epi_curve[1,]
      #last_value = df_to_plot_epi_curve[nrow(df_to_plot_epi_curve),]
      
      p = ggplot(df_to_plot_epi_curve,aes(x=Date,y=New_cases))+
         #geom_area( fill="#de2d26", alpha=0.4) +
         #geom_line(color="#de2d26", size=1) +
         geom_point(size=1.5, color="#525252",alpha=0.5) +
         geom_smooth(method="loess",color="#de2d26",formula=y~x,se=FALSE)+
         geom_ribbon(stat = "smooth", method = "loess", alpha = .15,fill="#de2d26",formula=y~x)+
         #geom_point(data=first_value, aes(x=Date,y=New_cases),size=2, color="#de2d26") +
         #geom_point(data=last_value, aes(x=Date,y=New_cases),size=2, color="#de2d26") +
         xlab("Time") + 
         ylab("New cases")+
         scale_x_date(date_breaks = "1 week", date_labels = "%b %d")
      ggplotly(p) %>% style(hoverinfo = "skip", traces = c(2,3))
      
   })
   
   
   output$graph_deaths = renderPlotly({
      
      first_value = df_to_plot_num_deaths[1,]
      last_value = df_to_plot_num_deaths[nrow(df_to_plot_num_deaths),]
      
      p = ggplot(df_to_plot_num_deaths,aes(x=Date,y=Num_deaths))+
         geom_point(size=1.5, color="#525252",alpha=0.5) +
         geom_smooth(method="loess",color="#252525",formula=y~x,se=FALSE)+
         geom_ribbon(stat = "smooth", method = "loess", alpha = .15,fill="#252525",formula=y~x)+
         #geom_area( fill="#252525", alpha=0.4) +
         #geom_line(color="#252525", size=1) +
         #geom_point(data=first_value, aes(x=Date,y=Num_deaths),size=2, color="#252525") +
         #geom_point(data=last_value, aes(x=Date,y=Num_deaths),size=2, color="#252525") +
         #geom_point(size=2, color="#252525") +
         xlab("Time") + 
         ylab("Number of deaths")+
         scale_x_date(date_breaks = "1 week", date_labels = "%b %d")
      ggplotly(p) %>% style(hoverinfo = "skip", traces = c(2,3))
      
   })
   
   
  
   observe({
      
      
     target_date = as.character(input$date)
     
     mybins = c(0,1,10,100,1000,10000,100000)
     mypalette = colorBin( palette="YlOrRd", domain=df_leaflet@data[,target_date], na.color="transparent", bins=mybins)
     
     mytag = paste(
        "County: ", df_leaflet@data$NAME,"<br/>", 
        "Cases: ", df_leaflet@data[,target_date], "<br/>", 
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
   


    
}