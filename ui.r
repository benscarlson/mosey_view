ui <- fluidPage(
  
  titlePanel('Movement Track Viewer'),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,

      # Add a Slider Input to select doy
      sliderInput("doySlider", "Select Day of Year",
                  min = 0, max = 365, value = c(0,365)),
      # Add a Slider Input to select date range
      # sliderInput("Date_range_selector", "Select Date Range",
      #             min = minDte, max = maxDte, value = c(minDte,maxDte)),
      
      #checkboxGroupInput("individual_selector", "Show individual:", nicheNames, nicheNames)
      # prettyCheckboxGroup(inputId="individual_selector", label="Show individual:",
      #   choiceNames=entNames, choiceValues=entNames, selected=entNames, outline=TRUE)
      # column(3,
      #   tableOutput('table')
      # )
      
      shinyTree('tree',checkbox=TRUE)
    ),
    
    mainPanel(
      leafletOutput("map",height = 900),
      width = 9
    )
  )
  

)



