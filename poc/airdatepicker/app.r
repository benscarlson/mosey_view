library(shiny)
library(shinyWidgets)

ui <- fluidPage(
  airDatepickerInput(
    inputId = "tsRange",
    label = "Select date/time range:",
    placeholder = "Pick a date range",
    range=TRUE,
    autoClose=TRUE,
    #multiple = 2, 
    timepicker=TRUE,
    clearButton = TRUE
  ),
  verbatimTextOutput("res")
)

server <- function(input, output, session) {
  output$res <- renderPrint(input$tsRange)
}

shinyApp(ui, server)