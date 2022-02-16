server <- function(input, output, session){

  #TODO: make this a start, end timestamp picker, instead of the sliders
  output$startDoy <- renderText('Jan-1')
  output$endDoy <- renderText('Dec-31')
  
  trackDat <- reactive({
    print('inside trackDat')
    #doy <- c(152, 181) # Jun, non leap-year
    #year <- c(2014,2014) 
    doy <- input$doySlider
    year <- input$yearSlider
    
    #get month, day for doy, ignoring leap-years
    x <- as.Date(doy,origin = "2019-01-01") #does not use the year component
    
    start <- make_date(year[1],month(x[1]),day(x[1]))
    end <- make_date(year[2],month(x[2]),day(x[2]))
    
    snames <- as.character(get_selected(input$tree,format='names'))
    
    #---- Returns here if nothing selected ----#
    #Function returns NULL if nothing is selected
    if(length(snames) == 0) return(NULL)
    
    output$queryDesc <- renderText(glue('Requesting points between {start} and {end}'))
    
    #showEnts <- c(83559577)
    showEnts <- treeDat_ %>% filter(name %in% snames) %>% pull('individual_id')
    
    #TODO: remote duplicate parts of these two queries
    if(input$oneperday) {
      #One event per individual per day
      sql <- "select event_id,individual_id,timestamp,lon,lat,
        date(timestamp) as date, outlier
      from event
      where individual_id in ({showEnts*})
      and date between {start} and {end}
      group by individual_id, date
      having min(timestamp)
      order by date" %>% glue_sql(.con=db)
    } else {
      #All events in the given time frame
      sql <- "select event_id,individual_id,timestamp,lon,lat, 
        date(timestamp) as date, outlier
      from event
      where individual_id in ({showEnts*})
      and date between {start} and {end}
      order by individual_id,timestamp" %>% glue_sql(.con=db)
    }

    message(sql)
    
    results <- dbGetQuery(db, sql) %>% 
      as_tibble %>%
      mutate(date=as.Date(date), 
             timestamp=fastPOSIXct(timestamp, tz='UTC'),
             individual_id=factor(individual_id),
             outlier=as.logical(outlier)) %>%
      arrange(individual_id,timestamp)
    
    
    message(glue('Query returned {nrow(results)} rows'))
    
    # #Include outliers. Do in R to avoid join to full event table
    # #TODO: use individual_id from results to select outliers
    # outl <- 'select * from outlier
    #     where individual_id in ({unique(results$individual_id)*})' %>%
    #   glue_sql(.con=db) %>%
    #   dbGetQuery(db, .) %>% as_tibble %>%
    #   select(-individual_id) %>%
    #   mutate(outlier=TRUE)
    # 
    # results <- results %>%
    #   left_join(outl,by='event_id') %>%
    #   mutate(outlier=ifelse(is.na(outlier),FALSE,outlier))
    
    #Does not seem like the cleanest design, but it makes sense that the update goes here, since this
    # is all based on trackDat data. 
    #---- Update results info pane ---#
    if(nrow(results) != 0) {
      
      selStdIds <- ind_ %>% filter(individual_id %in% showEnts) %>%
        as_tibble %>% pull('study_id') %>% unique
  
      selNames <- ind_ %>% filter(individual_id %in% showEnts) %>% 
        as_tibble %>% pull('local_identifier')
      
      output$selectedStudyId <- renderText(glue('Study IDs: {paste(selStdIds,collapse=",")}'))
      output$individualName <- renderText(glue('Individual Name: {paste(selNames,collapse=",")}'))
      output$individualId <- renderText(glue('Individual Id: {paste(showEnts,collapse=",")}'))
      output$dateRange <- renderText(glue('Date range: {min(results$date)} to {max(results$date)}'))
      output$nPoints <- renderText(glue('Num Points: {nrow(results)}'))
    } else {
      output$selectedStudyId <- renderText('No results')
      output$dateRange <- NULL
      output$nPoints <- NULL
    }
    
    return(results)
  })
  
  # treeR <- reactive({
  #   if(input$filtertree) {
  #     return(NULL)
  #   } else {
  #     return(tree_)
  #   }
  # })
  # 
  # output$tree <- renderTree({treeR()})
  
  #---- Filter tree based on selected dates. Tree control not maintaining state
  #----
  
  # treeR <- reactive({
  #   print('here')
  #   doy <- input$doySlider
  #   year <- input$yearSlider
  # 
  #   #get month, day for doy, ignoring leap-years
  #   x <- as.Date(doy,origin = "2019-01-01")
  # 
  #   start <- make_date(year[1],month(x[1]),day(x[1]))
  #   end <- make_date(year[2],month(x[2]),day(x[2]))
  # 
  #   if(input$filtertree) {
  #     #Filter out case 1 and case 2, where there is no overlap between
  #     # the requested range and the min/max dates for the individual
  #     #<case 1> <range> <case 2>
  # 
  #     treeDat_ %>%
  #       inner_join(
  #         evtstat_ %>% as_tibble %>%
  #           filter(!((ts_min < start & ts_max < start) |
  #                      (ts_min > end & ts_min > end))) %>%
  #           select(individual_id),
  #         by='individual_id') %>%
  #       select(study_name,name,value=individual_id) %>%
  #       listTree %>%
  #       return
  #   } else {
  #     treeDat_ %>%
  #       select(study_name,name,value=individual_id) %>%
  #       listTree %>%
  #       return
  #   }
  # })
  # 
  # output$tree <- renderTree({treeR()})
  
  #---- Set up tree
  
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
    print('inside first observe')
    dat <- trackDat()
    
    .colorfield <- input$colorfield #'outlier' 
    
    if(is.null(dat) || nrow(dat)==0) {
      leafletProxy("map") %>% clearMarkers %>% clearShapes %>% removeControl('legend')
    } else {
      
      #Need to create sf object so that lines can be displayed seperately
      # turning point geom into lines: https://github.com/r-spatial/sf/issues/321
      #TODO: maybe store this inside of reactive container so I don't need to recalculate?
      lines <- dat %>% 
        st_as_sf(coords=c('lon','lat')) %>% 
        st_set_crs(4326) %>%
        group_by(individual_id) %>% 
        summarize(do_union=FALSE,.groups='drop') %>%
        st_cast('LINESTRING') 
      
      #Have to use julian day and labFormat in order to get legend to work for timestamps
      # See here: https://stackoverflow.com/questions/34234576/r-leaflet-use-date-or-character-legend-labels-with-colornumeric-palette
      
      #TODO: Could have a ui element that lets you pick asc and desc?
      dat <- dat %>% arrange(!!as.name(.colorfield))
      
      colorcol <- dat %>% pull(.colorfield)
      
      #labelFormat function is still confusing. If I don't do anything special, assign with no parameters
      # to format by dates, use my custom myLabelFormat function
      #TODO: it seems like as.Date might be slow.
      if(is.factor(colorcol)) {
        pal <- colorFactor(palette = 'plasma', domain = colorcol)
        labformat <- labelFormat()
      } else if(is.logical(colorcol)) {
        colorcol <- factor(colorcol)
        pal <- colorFactor(palette= 'plasma', domain=colorcol)
        labformat <- labelFormat()
      } else if(is.POSIXct(colorcol)) {
        dates <- as.Date(colorcol)
        colorcol <- as.numeric(dates) #Julian date
        pal <- colorNumeric(palette='plasma', domain=colorcol)
        labformat <- myLabelFormat(dates=TRUE) #dates,
      }
      
      colors <- pal(colorcol)

      #TODO: I might not need this line anymore
      ldat <- dat #%>%
        #mutate(
          #julian=as.numeric(date),
          #individual_id=factor(individual_id))
        #arrange(desc(outlier)) %>%
      
      leafletProxy("map", data = ldat) %>%
        clearMarkers %>%
        clearShapes %>% #clears all polylines
        removeControl('legend') %>%
        addPolylines(data=lines,weight=2) %>%
        addCircleMarkers(lng=~lon, lat=~lat, radius=2, layerId = ~event_id,
          popup=popupTable(ldat), color=colors, opacity=0.8) %>% #popup=~timestamp #~pal(individual_id), color=~pal(date)
        addLegend('topleft',pal=pal,values=colorcol,layerId='legend',title=.colorfield,labFormat=labformat) 
        #values=~julian, labFormat = myLabelFormat(dates=TRUE)
        # addPolylines(data=lines,weight=2,color=~pal(individual_id)) %>%
        # addCircleMarkers(lng=~lon, lat=~lat, radius=2, layerId = ~event_id,
        #   popup=~timestamp, color=~pal(individual_id),opacity=0.8) %>% #%>% #, color=~factpal(individual_id)
        # addLegend('topleft',pal=pal,values=~individual_id,layerId='legend',title='Individual')
        # #fitBounds(min(dat$lon), min(dat$lat), max(dat$lon), max(dat$lat))

    }
  })
  
  #TODO: need a (reactive?) function that will set up color field
  # Need to set up color palette, legend, sort dataset
  # Idea: Have an overall mapData() function that is called by the observers. 
  #  within this function, call other reactive functions that set up the data. 
  #  trackDat() gets the data from the database
  #  colorfield() sets up things so different fields can be colored
  
  #TODO: START HERE!!! 
  # make this update the colors & legend in the 
  # observe({
  #   print('inside second observe')
  #   print(input$colorfield)
  #   dat <- trackDat()
  # })
  
  message('Server complete')
}
