#This is the global file that looks at the movebank database

library(here)

library(DBI)
library(lubridate)
library(leaflet)
library(RSQLite)
library(shiny)
library(shinyTree)
library(tidyverse)
#library(shinyWidgets)

filter <- dplyr::filter
select <- dplyr::select
here <- here::here

source(here('funs/listtree.r'))

#---- Parameters ----#

.wd <- '~/projects/geosp_poc/analysis/test1'
.dbP <- file.path(.wd,'data/database.db')

#debugging.
#studyIds <- 10157679 #LifeTrack White Stork Tunisia

db <- DBI::dbConnect(RSQLite::SQLite(), .dbP)
# stu <- tbl(db,'study')
ind_ <- tbl(db,'individual')
evt_ <- tbl(db, 'event')
study_ <- tbl(db,'study')

tree_ <- ind_ %>%
  inner_join(study_ %>% select(study_id,study_name=name), by='study_id') %>%
  mutate(name=individual_id) %>% #don't have names yet, just use ids
  #filter(study_id %in% studyIds) %>% 
  select(study_name,name,value=individual_id) %>% 
  as_tibble %>%
  listTree
  
#entIds <- unique(df_$individual_id)
entIds <- ind_ %>% 
  filter(study_id %in% studyIds) %>% 
  distinct(individual_id) %>%
  as_tibble %>%
  pluck('individual_id')

# inds <- stu %>% 
#   select(study_id,name) %>%
#   filter(name==.study) %>%
#   inner_join(ind,by='study_id') %>% as_tibble
# 
# indNames <- inds %>% 
#   select(local_identifier) %>% 
#   arrange(local_identifier) %>%
#   pluck('local_identifier')
  
#tree <- as.list(entIds)
#names(tree) <- entIds




# indTable <- niches %>%
#   select(individual_id, niche_name, sex, breeding, eggs, fledglings)

#quick and dirty centroid
# cenx <- mean(summary(df0$lon)[c(1,6)])
# ceny <- mean(summary(df0$lat)[c(1,6)])
# 
# df <- df0 #%>% filter(niche_name=='Magnus-Jun14')

# minDte <- as.Date('2014-06-01','%Y-%m-%d')
# maxDte <- as.Date('2014-06-30','%Y-%m-%d')
#minDte <- as.Date(min(df0$timestamp))
#maxDte <- as.Date(max(df0$timestamp))

#TODO: look at the niches data frame instead
#nicheNames <- sort(unique(df$niche_name))

factpal <- colorFactor(topo.colors(length(entIds)), entIds)
