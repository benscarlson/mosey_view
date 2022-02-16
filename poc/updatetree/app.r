library(shiny)
library(shinyTree)
library(dplyr)

dat <- tibble(
  grp=rep(c("1-3a","1-3b","4-6"),each=3),
  leaf=c(1:3,1:3,4:6),
  val=c(1:3,1:3,4:6),
)

#' Recursively walks down the columns of a dataframe making nested groups
listTree <- function(dat) {
  if(ncol(dat) > 2) {
    x <- dat %>% nest(data=-1)
    lst <- as.list(x[[2]])
    names(lst) <- x[[1]]
    lst %>% map(listTree)
  } else if(ncol(dat)==2) {
    lst<-as.list(dat[[2]])
    names(lst)<-dat[[1]]
    return(lst)
  } else if(ncol<2) {
    stop('ERROR')
  }
}

ui <- fluidPage(
  p('Filter nodes < selected value'),
  sliderInput("num", "Value",
              min = 1, max = 6, value = 1),
  shinyTree("tree",checkbox=TRUE)
)
server <- function(input, output, session) {
  

  datr <- reactive({
    dat %>% filter(val >= input$num)
  })
  
  output$tree <- renderTree({listTree(datr())})
  
}

shinyApp(ui, server)



