#This is the global file that looks at the movebank database

library(here)

library(DBI)
library(glue)
library(lubridate)
library(leaflet)
library(RSQLite)
library(shiny)
library(shinyTree)
library(tidyverse)

filter <- dplyr::filter
select <- dplyr::select
here <- here::here

source(here('funs/listtree.r'))

#---- Functions ----#
as_timestamp <- function(x) as.POSIXct(x, format='%Y-%m-%dT%H:%M:%S', tz='UTC')

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

.dbP <- '~/projects/movebankdb/analysis/movebankdb/data/movebank.db'

db <- DBI::dbConnect(RSQLite::SQLite(), .dbP)
ind_ <- tbl(db,'individual')
evt_ <- tbl(db, 'event')
study_ <- tbl(db,'study')

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
  select(study_name,name,individual_id)

tree_ <- treeDat_ %>% 
  select(study_name,name,value=individual_id) %>%
  listTree

