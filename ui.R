


ui = fluidPage(
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "myTheme.css")
  ),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href="https://fonts.googleapis.com/css?family=Roboto&display=swap")
  ),
  
  fluidRow(
    column(10,offset=1, align="left",
    # title
    titlePanel("COVID-19 outbreak in Massachusetts"),
    br(),
    h2("Epidemic curve of the number of cases"),
    HTML('<p>The following graph shows the number of new COVID-19 cases reported in each county (or All counties) as a function of time. This is a weekly epidemiological curve, to try to avoid some of the fluctuations in the data. To extrapolate some trends you should look at multiple observations. You can learn more by reading the Wikipedia page on the <a href="https://en.wikipedia.org/wiki/Epidemic_curve">epidemic curve</a>.</p>'),
    plotlyOutput("epi_curve"),
    br(),
    )),
  
    fluidRow(
    column(10,offset = 1, align="center",
           selectInput("choose_county","County",choices = names_counties),
           br(),
    )),

  fluidRow(
    column(10, offset = 1, align="left",
           HTML('Data source: <a href="https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Massachusetts">2020_coronavirus_pandemic_in_Massachusetts</a> Wikipedia page.
       Original data: <a href="https://www.mass.gov/orgs/department-of-public-health">Massachusetts Department of Public Health</a>.'),    br(),
    br(),
    HTML("<b>NOTE</b>: if you do not know to which county your city/town belongs to, you can use the map below to find out."),
    br(),
    br(),
    br(),
    )),
    
  fluidRow(
    column(10, offset = 1, align="left",   
    h2("Spatiotemporal evolution of the outbreak"),
    HTML("<p>The following map shows the break down of the Massachusetts COVID-19 cases by counties.
                                 It is possible to use the slider to have a look at the situation on a specific date. Finally, by clicking on the play button it is possible to have a look at the spatiotemporal evolution of the epidemics. 
                                 </p>"),
    leafletOutput("leaflet_chloropleth"),
    br()
    )),

  fluidRow(
    column(10, offset = 1, align="center",
           sliderInput("date",
                       "Dates:",
                       min = as.Date(colnames(df_final)[1],"%Y-%m-%d"),
                       max = as.Date(colnames(df_final)[ncol(df_final)-1],"%Y-%m-%d"),
                       value = as.Date(colnames(df_final)[ncol(df_final)-1],"%Y-%m-%d"),
                       width="60%", 
                       animate = animationOptions(interval = 1000, loop = FALSE, playButton = NULL,
                                                  pauseButton = NULL)
                       ),
           br()
    )),
  
  
  fluidRow(
    column(10, offset=1, align="left",
    HTML('Data source: <a href="https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Massachusetts">2020_coronavirus_pandemic_in_Massachusetts</a> Wikipedia page.
       Original data: <a href="https://www.mass.gov/orgs/department-of-public-health">Massachusetts Department of Public Health</a>.'),
    br(),
    HTML('<br /><b>NOTE:</b> the data for the Dukes and Nantucket counties are combined in the reports of the MA Department of Public Health. Here we display the combined number of cases (Dukes + Nantucket) in both counties.'),
    br(),
    br(),
    br(),
 
    )),
  
  
  fluidRow(
    column(10,offset=1, align="left",
           h2("Growth curve of the number of cases"),
           HTML("<p>The following graph shows the number of total 
       cases of COVID-19 in Massachusetts as a function of
       time (dark grey curve). The red and organge curves show 
       the theoretical growth curves if the doubling time 
       of the cases was three or four days, respectively.</p>"),
           plotlyOutput("curves"),
           br(),
    )),
  
  fluidRow(
    column(10,offset = 1, align="center",
           selectInput("choose_type","Scale",choices = c("Linear","Logarithmic")),
           br(),
    )),
  
  fluidRow(
    column(10, offset = 1, align="left",
           HTML('Data source: <a href="https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Massachusetts">2020_coronavirus_pandemic_in_Massachusetts</a> Wikipedia page.
       Original data: <a href="https://www.mass.gov/orgs/department-of-public-health">Massachusetts Department of Public Health</a>.'),
           br(),
           br(),
           HTML("<b>NOTE</b>: the red and orange curves were calculated using the number of cases reported on Mar 9 (n = 43). This is a bit arbitrary, but please just consider them as references to follow the curve as it flattens."),
           br(),
           br(),
           br(),
    )),
  
  
  fluidRow(
    column(10,offset=1, align="left",
           h2("Updates and feedback"),
           HTML('<p>The graphs are automatically updated using the data available on the <a href="https://en.wikipedia.org/wiki/2020_coronavirus_pandemic_in_Massachusetts">2020_coronavirus_pandemic_in_Massachusetts</a> Wikipedia page. If you find any mistake, or you think this app can be improved, plase send an e-mail to <img src="email.png"/></p>'),
           br(),
    )),
  
  
  
  fluidRow(
    column(10, offset=1, align="left",
         
           br(),
           HTML('Author: Luca Freschi; Licence: <a href="https://creativecommons.org/licenses/by/4.0/deed.ast">CC-BY-4.0</a>; Last update: 2020-04-07'),
           br(),
           br()
          
           
    ))
  
  
  
)
  