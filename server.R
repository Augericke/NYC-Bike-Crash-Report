##################################
# NYC-Bike-Crash-Report - Server #
##################################

server <- function(input, output) {
  
  #Reactive df for cause/time reports
  bike_react <- reactive({
    
    if(!(input$target_zone %in% zipcode$zip)){
      
      set_zoom <<- 13
      set_lat <<-  40.7128
      set_lon <<- -73.9560
      
      return(bike_collisions)
      
    } else {
      
      target_zip <- filter(zipcode, zip == input$target_zone)
      set_lat <<- target_zip$latitude[1]
      set_lon  <<- target_zip$longitude[1]
      set_zoom <<- 15
      
      bike_collisions <- filter(bike_collisions, zip_code == input$target_zone)
      
      return(bike_collisions)
      
    }
    
  })
  
  # Place map markers
  output$map <- renderLeaflet({
    
    local_bike <- filter(bike_react(), !is.na(latitude))
    
    bike_icon <- awesomeIcons( icon = 'fas fa-bicycle',
                               iconColor = '#FFFFFF',
                               library = 'fa',
                               markerColor = ifelse(local_bike$number_of_cyclist_killed > 0 , 'lightred','lightblue'))
    
    leaflet(data = local_bike) %>%
      setView(lat = set_lat, lng = set_lon, zoom = set_zoom) %>%
      addTiles(urlTemplate = paste("https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=", Sys.getenv("thunder_key"), sep = ""))%>%
      addAwesomeMarkers(
        lng = ~as.numeric(longitude), lat = ~as.numeric(latitude),
        label = ~contributing_factor_vehicle_1,
        popup = ~paste('<center>', local_bike$date, '</center>',
                       '<p>', local_bike$on_street_name, '</p>',
                       '<p>', local_bike$contributing_factor_vehicle_1, '</p>',
                       '<p> Cyclist Injured: ', local_bike$number_of_cyclist_injured,
                       '    |   Cyclist Killed: ', local_bike$number_of_cyclist_killed, '</p>'),
        icon = bike_icon,
        clusterOptions = markerClusterOptions()
      )
  })
  
  # Street Level Report - Incident Tally
  output$street_report <- renderHighchart({
    
    local_bike <- bike_react()
    street_hc <- summarize(group_by(local_bike, on_street_name), 
                           injured = sum(number_of_cyclist_injured),
                           killed = sum(number_of_cyclist_killed),
                           incidents = sum(number_of_cyclist_injured) + sum(number_of_cyclist_killed))
    
    street_hc <- street_hc[order(-street_hc$incidents),]
    
    highchart() %>% 
      hc_xAxis(categories = head(street_hc$on_street_name, n = 10), title = list(text = "Top 10 Streets")) %>% 
      hc_yAxis(title = list(text = ""), allowDecimals = FALSE) %>% 
      hc_chart(type = "column", inverted = TRUE) %>%
      hc_plotOptions(column = list(stacking = "normal")) %>%
      hc_series(list(name = "Injured", data = head(street_hc$injured, n = 10)),
                list(name = "Killed", data = head(street_hc$killed, n = 10), color = "#ff5050")) %>%
      hc_exporting(enabled = TRUE) # enable export
  })
  
  # Cause Treemap 
  output$cause_report <- renderHighchart({
    
    local_bike <- filter(bike_react(),!(contributing_factor_vehicle_1 %in% "Unspecified"))
    
    hctreemap2( local_bike,
                group_vars = c("contributing_factor_vehicle_1"),
                size_var = "number_of_cyclist_injured",
                color_var = "number_of_cyclist_injured") %>% 
      hc_colorAxis(minColor = brewer.pal(3, "Blues")[1],
                   maxColor = brewer.pal(9, "Blues")[9]) %>% 
      hc_tooltip(pointFormat = "<b>{point.name}</b>:<br>
                 Incidents: {point.value:,.0f}") %>% 
      hc_exporting(enabled = TRUE) 
    
  })
  
  # Time Report
  observe({
    
    output$time_hc <- renderHighchart({
      
      #Dynamic grouping via time selection
      local_bike <- bike_react()
      
      crash_hc <- summarize(group_by_(local_bike, input$time_report),  
                            injured = sum(as.numeric(number_of_cyclist_injured)),
                            killed =  sum(as.numeric(number_of_cyclist_killed)),
                            incidents = sum(as.numeric(number_of_cyclist_injured)) + sum(as.numeric(number_of_cyclist_killed)))
      
      highchart() %>% 
        hc_chart(type = "line") %>% 
        hc_xAxis(categories = crash_hc[[input$time_report]]) %>% 
        hc_yAxis(title = list(text = "Number of Incidents")) %>% 
        hc_plotOptions(line = list(
          dataLabels = list(enabled = TRUE),
          enableMouseTracking = TRUE)) %>% 
        hc_exporting(enabled = TRUE) %>%
        hc_series(
          list(
            name = "Injured",
            data = crash_hc$injured
          ),
          list(
            name = "Killed",
            data = crash_hc$killed,
            color = "#ff5050"
          )
        )
    })
  })
  
  # Location / Time Disclaimer 
  output$location_time <- renderText({ 
    
    if(!(input$target_zone %in% zipcode$zip)){
      paste("The above graphs are currently showing all cyclists accidents in NYC from",
            min(bike_collisions$date), "to", max(bike_collisions$date))
    } else {
      paste("The above graphs are currently showing all cyclists accidents in the ", input$target_zone, "area from",
            min(bike_collisions$date), "to", max(bike_collisions$date))
    }
  })
  
}