server <- function(input, output, session){

  trackDat <- reactive({
    
    showEnts <- as.character(get_selected(input$tree,format='classid'))
    # ifelse(length(showEnts)==0,'',showEnts)
    # print(showEnts)
    # print(df_)

    #showEnts <- 10666985 #for debugging
    
    #Function returns NULL if nothing is selected
    if(length(showEnts) == 0) return(NULL)
    
    #One event per day
    sql <- "select *, date(timestamp) as date
      from event
      where individual_id in ({showEnts*})
      group by date
      having min(timestamp)
      order by date" %>% glue_sql(.con=db)

    dbGetQuery(db, sql) %>% return

    # Remove this code. Using parameterized queries instead
    # #TODO: this is doing filter after brining all data into memory, so need to fix this
    # ind_ %>%
    #   filter(individual_id %in% showEnts) %>% #study_id %in% studyIds &
    #   select(study_id,individual_id) %>%
    #   inner_join(evt_, by='individual_id') %>%
    #   as_tibble %>%
    #   filter(between(yday(timestamp),input$doySlider[1],input$doySlider[2])) %>%
    #   group_by(study_id,individual_id) %>% sample_n(500) %>% ungroup %>%
    #   return

  })
  
  output$tree <- renderTree({tree_})
  
  #output$table <- renderTable(indTable)
  
  output$map <- renderLeaflet({
    
    #These options should make rendering points faster
    #https://community.rstudio.com/t/plotting-thousands-of-points-in-leaflet-a-way-to-improve-the-speed/8196/2
    pto=providerTileOptions(
      updateWhenZooming=FALSE,
      updateWhenIdle=TRUE
    )
    
    mp <- leaflet(options=leafletOptions(preferCanvas=TRUE)) %>%
      addProviderTiles(
        provider=providers$Esri.WorldImagery,
        options=pto) %>%
      #fitBounds(~min(lon), ~min(lat), ~max(lon), ~max(lat)) %>%
      addScaleBar(position='topright',
        options=scaleBarOptions(maxWidth=200,imperial=FALSE)) %>%
      addMeasure(primaryLengthUnit='meters',secondaryLengthUnit='kilometers',
                 primaryAreaUnit='sqmeters',secondaryAreaUnit='sqkilometers',
                 position='topright') #%>%
      #addLegend('topleft',pal=factpal,values=~niche_name)
    
    return(mp)
  })
  
  # Don't update map when data changes.
  # Approach taken from here: http://rstudio.github.io/leaflet/shiny.html
  
  observe({
    dat <- trackDat()
    
    if(is.null(dat)) {
      leafletProxy("map") %>% clearMarkers
    } else {
      leafletProxy("map", data = dat) %>%
        clearMarkers() %>%
        addCircleMarkers(lng=~lon, lat=~lat, radius=1.5, layerId = ~event_id, 
          popup=~timestamp) #, color=~factpal(individual_id)
    }
  })
  
  #Example of how to observe an event
  # observeEvent(input$map_marker_click, { 
  #   p <- input$map_marker_click  # typo was on this line
  #   print(p)
  # })
  
}

#Esri.WorldImagery