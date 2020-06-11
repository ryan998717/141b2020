library(shinydashboard)
library(leaflet)
library(data.table)
library(plotly)

allinfo <- fread("allinfo.csv")
singleroute <- fread("single_route.csv")
plotly_dat <-
  allinfo[, .(pv = .N, uv = uniqueN(number)), by = .(name)]

function(input, output, session) {
  output$trainmap <- renderLeaflet({
    # browser()
    
    # parse_date_time(paste0(input$timeRange, ":00"), '%I:%M')
    
    needdat <-
      unique(allinfo[between(reachtime, input$timeRange[1], input$timeRange[2]) &
                       number == input$route][order(station_id), .(name, gtfs_latitude, gtfs_longitude)])
    needdat1 <-
      singleroute[number == input$route][order(station_id)]
    
    map <- leaflet(needdat) %>%
      addTiles() %>% 
      addMarkers(
        ~ gtfs_longitude,
        ~ gtfs_latitude,
        popup = needdat$name
      ) %>%
      addPolylines(needdat1$gtfs_longitude,
                   needdat1$gtfs_latitude)
    map
  })
  
  output$plotly1 <- renderPlotly({
    pd <- head(plotly_dat[order(-pv)], 5)
    plot_ly(
      x = pd$pv,
      y = pd$name,
      type = 'bar',
      orientation = 'h'
    ) %>% layout(
      xaxis = list(title = "passing times"),
      showlegend = FALSE,
      title = 'passing times Top5 stations'
    )
  })
  
  output$plotly2 <- renderPlotly({
    pd <- head(plotly_dat[order(-uv)], 5)
    plot_ly(
      x = pd$uv,
      y = pd$name,
      type = 'bar',
      orientation = 'h'
    ) %>% layout(
      xaxis = list(title = "passing routes"),
      showlegend = FALSE,
      title = 'passing routes Top5 stations'
    )
  })
}
