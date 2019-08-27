library(DBI)
library(dbplyr)
library(dplyr)
library(lubridate)
library(shiny)
library(shinyTree)
library(shinyWidgets)
library(leaflet)
library(readr)
library(RSQLite)

con <- DBI::dbConnect(RSQLite::SQLite(), "~/projects/whitestork/src/db/db.sqlite")

#.pd <- '~/projects/whitestork/results/stpp_models/loburg_jun14'
.pd <- '~/projects/whitestork/results/stpp_models/huj_eobs'

df0 <- read_csv(file.path(.pd,'data','obs.csv'),col_types=cols()) #%>% filter(obs)

breed0 <- tbl(con, 'stork_breeding_data_raw')  %>% #has breeding data
  mutate(breeding = eggs != 0)

#for now, use the niches file to build niches
niches <- read_csv(file.path(.pd,'niches.csv')) %>%
  left_join(as_tibble(breed0),by=c('individual_id','year'))

#shinyTree
# tree <- list(
#   'Loburg'= list(
#     'loburg-2013' = list(
#       'Agatha-2013'='',
#       'Albert-2013'=''
#     )
#   ),
#   'Dromling' = list(
#     'dromling-2013' = list(
#       '4X774-2013'=''
#     )
#   )
# )

# dat <- data.frame(
#   col1=rep(c('a','b'),each=4),
#   col2=rep(c('p','q'),each=2),
#   col3=c('x','y'),
#   stringsAsFactors = FALSE) #note col2 & col3 recycle

#only works for three levels. could make this more general by making it recursive.
#splits by each consequtive column to make nested lists of lists
listTree <- function(dat) {
  lstTree <- lapply(split(dat,dat[[1]]),function(dat) { #note the 'x' here is a dataframe
    dat <- dat[-1]
    lapply(split(dat,dat[[1]]),function(dat) {
      dat <- dat[-1]
      return(sapply(dat[[1]],simplify=FALSE,USE.NAMES=TRUE,function(x){''}))
    })
  })
  
  return(lstTree)
}

tree <- niches %>% 
  select(population,niche_set,niche_name) %>% 
  arrange(population,niche_set,niche_name) %>%
  listTree

indTable <- niches %>%
  select(individual_id, niche_name, sex, breeding, eggs, fledglings)

#quick and dirty centroid
cenx <- mean(summary(df0$lon)[c(1,6)])
ceny <- mean(summary(df0$lat)[c(1,6)])

df <- df0 #%>% filter(niche_name=='Magnus-Jun14')

# minDte <- as.Date('2014-06-01','%Y-%m-%d')
# maxDte <- as.Date('2014-06-30','%Y-%m-%d')
#minDte <- as.Date(min(df0$timestamp))
#maxDte <- as.Date(max(df0$timestamp))

#TODO: look at the niches data frame instead
nicheNames <- sort(unique(df$niche_name))

factpal <- colorFactor(topo.colors(length(nicheNames)), nicheNames)
