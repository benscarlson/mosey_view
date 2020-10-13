server <- function(input, output, session){

  output$startDoy <- renderText('Jan-1')
  output$endDoy <- renderText('Dec-31')
  
  trackDat <- reactive({
    
    doy <- input$doySlider
    year <- input$yearSlider
    
    #get month, day for doy, ignoring leap-years
    x <- as.Date(doy,origin = "2019-01-01")
    
    start <- make_date(year[1],month(x[1]),day(x[1]))
    end <- make_date(year[2],month(x[2]),day(x[2]))
    
    snames <- as.character(get_selected(input$tree,format='names'))
    
    #---- Returns here if nothing selected ----#
    #Function returns NULL if nothing is selected
    if(length(snames) == 0) return(NULL)
    
    output$queryDesc <- renderText(glue('Requesting points between {start} and {end}'))
    
    showEnts <- treeDat_ %>% filter(name %in% snames) %>% pull('individual_id')
    
    if(input$oneperday) {
      #One event per individual per day
      sql <- "select *, 
        date(timestamp) as date
      from event
      where individual_id in ({showEnts*})
      and date between {start} and {end}
      group by individual_id, date
      having min(timestamp)
      order by date" %>% glue_sql(.con=db)
    } else {
      #All events in the given time frame
      sql <- "select *, 
        date(timestamp) as date
      from event
      where individual_id in ({showEnts*})
      and date between {start} and {end}
      order by timestamp" %>% glue_sql(.con=db)
    }

    message(sql)
    
    results <- dbGetQuery(db, sql) %>% 
      mutate(date=as.Date(date), 
             timestamp=as_timestamp(timestamp)) %>% #dbGetQuery returns dates & times as strings
      arrange(individual_id,timestamp)
    
    #---- Update results info pane ---#
    if(nrow(results) != 0) {

      selStdIds <- ind_ %>% filter(individual_id %in% showEnts) %>%
        as_tibble %>% pull('study_id') %>% unique
  
      output$selectedStudyId <- renderText(glue('Study IDs: {paste(selStdIds,collapse=",")}'))
      output$dateRange <- renderText(glue('Date range: {min(results$date)} to {max(results$date)}'))
      output$nPoints <- renderText(glue('Num Points: {nrow(results)}'))
    } else {
      output$selectedStudyId <- renderText('No results')
      output$dateRange <- NULL
      output$nPoints <- NULL
    }
    
    return(results)
  })
  
  output$tree <- renderTree({tree_})
  
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
      addScaleBar(position='topright',
        options=scaleBarOptions(maxWidth=200,imperial=FALSE)) %>%
      addMeasure(primaryLengthUnit='meters',secondaryLengthUnit='kilometers',
                 primaryAreaUnit='sqmeters',secondaryAreaUnit='sqkilometers',
                 position='topright')
    
    return(mp)
  })
  
  # Don't update map when data changes.
  # Approach taken from here: http://rstudio.github.io/leaflet/shiny.html
  
  observe({
    dat <- trackDat()
    
    if(is.null(dat) || nrow(dat)==0) {
      leafletProxy("map") %>% clearMarkers %>% clearShapes %>% removeControl('legend')
    } else {
      
      #Need to create sf object so that lines can be displayed seperately
      # turning point geom into lines: https://github.com/r-spatial/sf/issues/321
      lines <- dat %>% 
        st_as_sf(coords=c('lon','lat')) %>% 
        st_set_crs(4326) %>%
        group_by(individual_id) %>% 
        summarize(do_union=FALSE,.groups='drop') %>%
        st_cast('LINESTRING') 
      
      
      #TODO: might want to be able to toggle between coloring by date and coloring by timestamp
      #Have to use julian day and labFormat in order to get legend to work
      # See here: https://stackoverflow.com/questions/34234576/r-leaflet-use-date-or-character-legend-labels-with-colornumeric-palette
      
      pal <- colorNumeric(
        palette = "plasma",
        domain = dat$julian)
      
      dat %>%
        mutate(julian=as.numeric(date)) %>%
      leafletProxy("map", data = .) %>%
        clearMarkers %>%
        clearShapes %>% #clears all polylines
        removeControl('legend') %>%
        addPolylines(data=lines,weight=2) %>%
        addCircleMarkers(lng=~lon, lat=~lat, radius=2, layerId = ~event_id,
          popup=~timestamp, color=~pal(date),opacity=0.8) %>% #%>% #, color=~factpal(individual_id)
        addLegend('topleft',pal=pal,values=~julian,layerId='legend',title='Timestamp',
                  labFormat = myLabelFormat(dates=TRUE))
        #fitBounds(min(dat$lon), min(dat$lat), max(dat$lon), max(dat$lat))

    }
  })
  
  message('Server complete')
}
