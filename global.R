##################################
# NYC-Bike-Crash-Report - Global #
##################################

# Load required packages
packages_required <- c("RSocrata", "shiny", "shinythemes", "zipcode",
                       "leaflet","highcharter", "dplyr", "lubridate",
                       "ggplot2", 'revgeo', "treemap","RColorBrewer")
lapply(packages_required, require, character.only = TRUE)


# NYPD Motor Vehicle Collisions - Limited to collisions where a cyclist was injured or killed in the past 365 days
# https://dev.socrata.com/foundry/data.cityofnewyork.us/qiz3-axqb
bike_collisions <- read.socrata(  
  paste("https://data.cityofnewyork.us/resource/qiz3-axqb.json?$where=date between '", Sys.Date()-366 ,"T0:00:01' and '", 
        Sys.Date()-1, "T23:59:59' AND (number_of_cyclist_injured>0 OR number_of_cyclist_killed>0)", sep = ""),
  app_token = Sys.getenv("socrata_nyc_token")
)


############
# Clean Up #
############ 


# Get time of day (hour, day, month)
bike_collisions$Hour <- as.integer(gsub(":.*","", bike_collisions$time))
bike_collisions$Day <- wday(bike_collisions$date, label = T)
bike_collisions$Month <- month(bike_collisions$date, label = T)

# Replace missing on street with cross street
missing_street <- is.na(bike_collisions$on_street_name)
bike_collisions$on_street_name[missing_street] <- bike_collisions$cross_street_name[missing_street]

# Write street in title format 
bike_collisions$on_street_name <- tolower(bike_collisions$on_street_name) %>% tools::toTitleCase()

# Adjust Str for injured/killed tally 
cyclist_tally <- c('number_of_cyclist_injured','number_of_cyclist_killed')
bike_collisions[,cyclist_tally] <- lapply(bike_collisions[, cyclist_tally], as.integer)

# Reverse geocode missing zipcodes (This section has been left out due to API limitations but feel free to set up your own connection!) 
# https://developers.google.com/maps/documentation/geocoding/get-api-key
# missing_zip <- bike_collisions %>% 
#   filter(is.na(zip_code)) %>%
#   group_by(latitude,longitude) %>% 
#   summarize() 
#       
# missing_zip$zip_code <- revgeo(missing_zip$longitude,
#                                missing_zip$latitude,
#                                provider = 'google',
#                                API = Sys.getenv("google_maps_key"),
#                                output = 'hash', item = 'zip')
#
# bike_collisions <- merge(bike_collisions, missing_zip, by = c('longitude','latitude'), all = TRUE)

# Get Lat/Lng via zipcode (used for map adjustment on user input)
data('zipcode')
zipcode <- zipcode %>% 
  filter(state == 'NY')

