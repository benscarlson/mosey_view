library(DBI)
library(dbplyr)
library(dplyr)
library(lubridate)
library(purrr)
library(shiny)
library(shinyTree)
library(shinyWidgets)
library(leaflet)
library(readr)

.datPF <- '~/projects/oilbirds/analysis/oilbirds/data/obs.csv'

df0 <- read_csv(.datPF,col_types=cols())

entNames <- sort(unique(df$niche_name))

entLst <- as.list(entNames)
names(entLst) <- entNames
tree <- list(oilbirds=entLst)

#quick and dirty centroid
cenx <- mean(summary(df0$lon)[c(1,6)])
ceny <- mean(summary(df0$lat)[c(1,6)])

df <- df0

factpal <- colorFactor(topo.colors(length(entNames)), entNames)
