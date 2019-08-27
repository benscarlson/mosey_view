server <- function(input, output, session){

  trackDat <- reactive({
    
    showEnts <- as.character(get_selected(input$tree,format='classid'))
    
    dat <- df %>%
      filter(
        niche_name %in% showEnts & #input$individual_selector & # 
        #between(as.Date(timestamp), input$Date_range_selector[1], input$Date_range_selector[2])
        between(yday(timestamp),input$doySlider[1],input$doySlider[2])
        )
    
    return(dat)

  })
  
  output$tree <- renderTree({tree})
  
  #output$table <- renderTable(indTable)
  
  output$map <- renderLeaflet({
    
    #These options should make rendering points faster
    #https://community.rstudio.com/t/plotting-thousands-of-points-in-leaflet-a-way-to-improve-the-speed/8196/2
    pto=providerTileOptions(
      updateWhenZooming=FALSE,
      updateWhenIdle=TRUE
    )
    
    mp <- leaflet(data=df, options=leafletOptions(preferCanvas=TRUE)) %>%
      addProviderTiles(
        provider=providers$Esri.WorldImagery,
        options=pto) %>%
      fitBounds(~min(lon), ~min(lat), ~max(lon), ~max(lat)) %>%
      addScaleBar(position='topright',
        options=scaleBarOptions(maxWidth=200,imperial=FALSE)) %>%
      addMeasure(primaryLengthUnit='meters',secondaryLengthUnit='kilometers',
                 primaryAreaUnit='sqmeters',secondaryAreaUnit='sqkilometers',
                 position='topright') %>%
      addLegend('topleft',pal=factpal,values=~niche_name)
    
    return(mp)
  })
  
  # Don't update map when data changes.
  # Approach taken from here: http://rstudio.github.io/leaflet/shiny.html
  observe({
    leafletProxy("map", data = trackDat()) %>%
      clearMarkers() %>%
      addCircleMarkers(lng=~lon, lat=~lat, radius=1.5, color=~factpal(niche_name)) 
  })
  
}

#Esri.WorldImagery