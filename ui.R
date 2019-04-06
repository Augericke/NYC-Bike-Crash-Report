##############################
# NYC-Bike-Crash-Report - UI #
##############################

ui <- function(request) {
  
  fluidPage(
    
    theme = shinytheme("flatly"),
    
    leafletOutput("map", height = "400px"),
    absolutePanel(top = 20, left = 70, style = "opacity: 0.95; z-index: 1000;",
                  textInput("target_zone", "" , placeholder = "Enter Zip Code")),
    
    sidebarLayout(
      
      sidebarPanel(
        
        h2(strong("NYC Bike Crash Report")),
        
        h5("The NYC Bike Crash Report was created with the primary goal of making public data more accessible to local cyclists. 
           The report can be used to better inform a rider’s commute, provided an overview of cycling in the city, 
           or allow for a detailed look at the risks present in one’s own neighborhood. "),
        
        h5(" All data was pulled directly from NYC's Socratic Open Data API and is updated monthly to show the
           most recent accidents from the past year. Location data was assigned to the closest intersection of an 
           accident and not the site of the crash itself. Therefore, these markers are not indicative of where 
           an incident occurred but are rather the closest approximation. "),
        
        h5(paste("Special thanks to OpenStreetMap for their OpenCycleMap - which was used within this app to mark bike routes, 
                 Citi Bike stations, and local pubs (with free wifi)! The key for their map can be found"), a("here.", href = "https://www.opencyclemap.org/docs/"))
        
        ),
      
      mainPanel(
        
        tabsetPanel( type = "tabs",
                     tabPanel("Street", highchartOutput("street_report")),
                     tabPanel("Cause", highchartOutput("cause_report")),
                     tabPanel("Time",
                              highchartOutput("time_hc"),
                              tags$div(align = 'center', radioButtons(inputId  = 'time_report',label = NULL,
                                                                      choices  = c("Month","Day","Hour"), inline  = TRUE)))
        ), 
        
        tags$div( align = "center", em(h6(textOutput("location_time"))))
        
      )
    )
  )
}


