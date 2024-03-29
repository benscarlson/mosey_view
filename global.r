#This is the global file that looks at a mosey_db database

suppressWarnings(
  suppressPackageStartupMessages({
    library(assertthat)
    library(conflicted)
    library(DBI)
    library(fasttime)
    library(glue)
    library(here)
    library(lubridate)
    library(leaflet)
    library(leafpop)
    library(RSQLite)
    library(sf)
    library(shiny)
    library(shinyTree)
    library(tidyverse)
}))

conflict_prefer('filter','dplyr',quiet=TRUE)
conflict_prefer('select','dplyr',quiet=TRUE)

source(here::here('src/funs/listtree.r'))

#---- Functions ----#
#as_timestamp <- function(x) as.POSIXct(x, format='%Y-%m-%dT%H:%M:%S', tz='UTC')

myLabelFormat = function(...,dates=FALSE){ 
  if(dates){ 
    function(type = "numeric", cuts){ 
      as.Date(cuts, origin="1970-01-01")
    } 
  }else{
    labelFormat(...)
  }
}

#---- Parameters ----#

.dbPF <- '~/projects/ms2/analysis/main/data/mosey.db'

invisible(assert_that(file.exists(.dbPF)))
db <- DBI::dbConnect(RSQLite::SQLite(), .dbPF)
invisible(assert_that(length(dbListTables(db))>0))

ind_ <- tbl(db,'individual')
evt_ <- tbl(db, 'event')
study_ <- tbl(db,'study')
#evtstat_ <- tbl(db,'event_indiv_stats')

#Really annoying, but shinyTree doesn't return node values, only the names
# So, the 'value' field below isn't actually used
# Instead, need to do a reverse lookup based on name using treeDat_
treeDat_ <- ind_ %>%
  #filter(study_id %in% .debugStudyIds) %>%
  inner_join(study_ %>% select(study_id,study_name), by='study_id') %>% 
  as_tibble %>%
  mutate(
    study_name=glue('{study_name}'),
    name=glue('{local_identifier} (id:{individual_id})')) %>%
  select(study_name,name,individual_id) %>%
  arrange(study_name,individual_id)

tree_ <- treeDat_ %>% 
  select(study_name,name,value=individual_id) %>%
  listTree

