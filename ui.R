


ui = fluidPage(
  titlePanel(NULL, windowTitle = "COVID-19 outbreak in Massachusetts"),

  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href="https://fonts.googleapis.com/css?family=Roboto&display=swap")
  ),
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href="https://fonts.googleapis.com/css2?family=Lato:wght@300;400&display=swap")
  ),
  
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "myTheme.css")
  ),

  fluidRow(
    column(10,offset=1, align="left",
    # title
    h1(id="main_title","COVID-19 outbreak in Massachusetts"),
    br(),
    h2("Epidemic curve"),
    HTML(paste(
      '<p>The following graph shows the number of new COVID-19 cases reported in each county (or All counties) as a function of time. The dots represent the raw data. The trend line is a loess fit. The red area describes the confidence interval for the loess fit.',
      "</p>",
      sep="")),
    plotlyOutput("epi_curve") %>% withSpinner(color="#bfbfbf"),
    br(),
    )),
  
    fluidRow(
    column(10,offset = 1, align="center",
           selectInput("choose_county","County",choices = names_counties),
           br(),
    )),

  fluidRow(
    column(10, offset = 1, align="left",
           HTML('Data: <a href="https://www.mass.gov/orgs/department-of-public-health">Massachusetts Department of Public Health</a>.'),    br(),
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
    leafletOutput("leaflet_chloropleth") %>% withSpinner(color="#bfbfbf"),
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
    HTML('Data: <a href="https://www.mass.gov/orgs/department-of-public-health">Massachusetts Department of Public Health</a>.'),
    br(),
    br(),
    br(),
 
    )),
  
  
  fluidRow(
    column(10,offset=1, align="left",
           h2("Growth curve of the number of cases"),
           HTML("<p>The following graph shows the number of total 
       cases of COVID-19 in Massachusetts as a function of
       time (dark grey curve). The red and orange curves show 
       the theoretical growth curves if the doubling time 
       of the cases was three or four days, respectively.</p>"),
           plotlyOutput("curves") %>% withSpinner(color="#bfbfbf"),
           br(),
    )),
  
  fluidRow(
    column(10,offset = 1, align="center",
           selectInput("choose_type","Scale",choices = c("Linear","Logarithmic")),
           br(),
    )),
  
  fluidRow(
    column(10, offset = 1, align="left",
           HTML('Data: <a href="https://www.mass.gov/orgs/department-of-public-health">Massachusetts Department of Public Health</a>.'),
           br(),
           br(),
           HTML("<b>NOTE</b>: the red and orange curves were calculated using the number of cases reported on Mar 9 (n = 43). This is a bit arbitrary, so please consider them as references to follow the grey curve as it flattens."),
           br(),
           br(),
           br(),
    )),
  
  
 
  
  
  
  
  fluidRow(
    column(10,offset=1, align="left",
           # title
           h2("Death toll"),
           HTML(paste("<p>",
                      total_num_deaths, 
                      " deaths attributed to COVID-19 were reported in Massachusetts. This number corresponds to ",
                      format(round(perc_vs_num_cases, 1), nsmall = 1),
                      "% of the total number of reported cases and roughly to ",
                      format(round(perc_entire_population, 3), nsmall = 3),
                      '% of the entire Massachusetts population (Massachusetts population estimates 2019: 6,892,503; source: <a href="https://www.census.gov/quickfacts/MA">census.gov</a>). ',
                      "</p><p>",
                      "The following graph shows the number of deaths as a function of time (daily number of deaths). The dots represent the raw data. The trend line is a loess fit. The dark gray area describes the confidence interval for the loess fit.",
                      sep="")),
           br(),
           plotlyOutput("graph_deaths") %>% withSpinner(color="#bfbfbf"),
           br(),
    )),

  
  fluidRow(
    column(10, offset = 1, align="left",
           HTML('Data: <a href="https://www.mass.gov/orgs/department-of-public-health">Massachusetts Department of Public Health</a>.'),    br(),
           br(),
           br(),
    )),
  
  fluidRow(
    column(10,offset=1, align="left",
           h2("Updates and feedback"),
           HTML('<p>The graphs are updated daily. If you find any mistake or you think this app can be improved, plase send an e-mail to <img src="email.png"/></p>'),

    )),
  
  fluidRow(
    column(10,offset=1, align="left",
           h2("An open-source project"),
           HTML('<p>The source code of this app is available at: <a href="https://github.com/ejfresch/MA_COVID19_dashboard">
    https://github.com/ejfresch/MA_COVID19_dashboard</a>.</p>'),
           br(),
    )),  
  
  
  fluidRow(
    column(10, offset=1, align="left",
         
           br(),
           HTML(paste('Author: Luca Freschi; Licence: <a href="https://creativecommons.org/licenses/by/4.0/deed.ast">CC-BY-4.0</a> (contents); Last update: ',
                date_latest_avail_data,sep="")),
           br(),
           br()
          
           
    ))
  
  
  
)
  