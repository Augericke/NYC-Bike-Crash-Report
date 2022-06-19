# NYC-Bike-Crash-Report

The NYC Bike Crash Report was created with the primary goal of making public data more accessible to local cyclists. The report can be used to better inform a rider’s commute, provide an overview of cycling in the city, or allow for a detailed look at the risks present in one’s own neighborhood.  [Check it out!](https://agericke.shinyapps.io/NYC-Bike-Crash-Report-v2/)

## Getting Started 

### APIs
#### Socrata Open Data 
https://dev.socrata.com/foundry/data.cityofnewyork.us/qiz3-axqb

#### Thunder Forest / OpenStreetMap
https://www.thunderforest.com/docs/apikeys/

#### RevGeo - Google (Optional)
https://developers.google.com/maps/documentation/geocoding/get-api-key

### Setting Up Enviromental Variables in R 
All API tokens were stored locally within a .Renviron file. Publishing this application, requires that this file be kept within the same directory as the ui and server.  
```
file.edit("~/.Renviron")
```

### Running Locally 
The application can be run locally via the below console command.
```
runApp("currentDir")
```
For more information on setting up and running shiny apps check out this [page](https://shiny.rstudio.com/articles/app-formats.html). 
## Acknowledgment
Special thanks to OpenStreetMap for their OpenCycleMap - which was used within this app to mark bike routes, Citi Bike stations, and local pubs (with free wifi)! The key for their map can be found [here](https://www.opencyclemap.org/docs/).
