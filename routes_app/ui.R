library(shinydashboard)
library(leaflet)
library(plotly)

l1 <- read.csv("routeinfo.csv")
routeid <- l1$number
names(routeid) <- l1$name


header <- dashboardHeader(title = "Train routes")

body <- dashboardBody(fluidRow(column(
  width = 9,
  box(
    width = 12,
    solidHeader = TRUE,
    tags$style(type = "text/css", "#trainmap {height: calc(100vh - 80px) !important;}"),
    leafletOutput("trainmap")
  )
),
column(
  width = 3,
  box(
    width = 12,
    status = "warning",
    selectInput(
      "route",
      label = "select routes:",
      choices = routeid,
      selected = routeid[1],
      multiple = FALSE
    ),
    sliderInput(
      "timeRange",
      label = "Time range(Hour):",
      min = 0,
      max = 24,
      value = c(0, 24)
    ),
    p(
      class = "text-muted",
      br(),
      "Tips:",
      br(),
      "Points mean the train on this route will pass the station during the time range selected.",
      br(),
      "Blue lines mean the route."
    )
  ),
  box(
    width = 12,
    status = "warning",
    tabsetPanel(
      type = "tabs",
      tabPanel("passing times",
               br(),
               plotlyOutput("plotly1")),
      tabPanel("passing routes",
               br(),
               plotlyOutput("plotly2"))
    )
    
  )
)))

dashboardPage(header,
              dashboardSidebar(disable = TRUE),
              body)
