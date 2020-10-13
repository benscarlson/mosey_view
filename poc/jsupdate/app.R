library(shiny)
ui <- fluidPage(
  tags$script(src='script.js'),
  sliderInput("doySlider", "Day of year",
              min = 1, max = 365, value = c(1,365)),
  htmlOutput('startDoy'),
  htmlOutput('endDoy')
)
server <- function(input, output, session) {
  output$startDoy <- renderText('init start')
  output$endDoy <- renderText('init end')
}
shinyApp(ui, server)
