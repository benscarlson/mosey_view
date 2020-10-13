ui <- fluidPage(
  tags$script(src="script.js"),
    
  titlePanel('Movement Track Viewer'),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,

      # Add a Slider Input to select doy
      # UI ignores leap-years
      # 1-365 is more intuitive so use this in UI
      # Also sqlite (%j parameter), and JS are 1-indexed (1-365, non-leap year), 
      #   but R is 0-indexed (0-364, non-leap-year)
      splitLayout(
        htmlOutput('startDoy'),
        htmlOutput('endDoy')
      ),
      sliderInput("doySlider", "Day of year",
                  min = 1, max = 365, value = c(1,365)),
      sliderInput('yearSlider','Year',
                  min = 2008, max = 2020, step=1, sep='', value=c(2008,2020)),
      textOutput('queryDesc'),
      checkboxInput("oneperday", "Show one location per day", TRUE),
      
      wellPanel(
        p('Results info:'),
        textOutput('selectedStudyId'),
        textOutput('dateRange'),
        textOutput('nPoints'),
      ),
      wellPanel(
        style = "height:500px; overflow-y:scroll; overflow-x:scroll",
        shinyTree('tree',checkbox=TRUE)
      )
    ),
    
    mainPanel(
      leafletOutput("map",height = 900),
      width = 9
    )
  )
)



