library(sf)
library(DBI)
library(RSQLite)

as_timestamp <- function(x) as.POSIXct(x, format='%Y-%m-%dT%H:%M:%S', tz='UTC')

#showEnts <- c(142216521,142216678)
#start <- '2014-02-06'; end <- '2014-08-10'

showEnts <- c(3053704, 3053706)
start <- '2010-01-02'; end <- '2010-09-19'

# showEnts <- c(3053704)
# start <- '2010-01-02'; end <- '2010-09-19'

.dbP <- '~/projects/movebankdb/analysis/movebankdb/data/movebank.db'
db <- DBI::dbConnect(RSQLite::SQLite(), .dbP)

sql <- "select event_id,individual_id,timestamp,lon,lat, 
          date(timestamp) as date
      from event
      where individual_id in ({showEnts*})
      and date between {start} and {end}
      group by individual_id, date
      having min(timestamp)
      order by date" %>% glue_sql(.con=db)

results <- dbGetQuery(db, sql) %>%
  as_tibble %>% 
  mutate(date=as.Date(date), 
         timestamp=as_timestamp(timestamp)) %>%
  arrange(individual_id,timestamp)

x1 <- results %>% 
  st_as_sf(coords=c('lon','lat')) %>% 
  st_set_crs(4326) %>%
  group_by(individual_id) %>% 
  summarize(do_union=FALSE,.groups='drop') %>% 
  st_cast('LINESTRING')

g1 <- x1[1,] %>% st_geometry; g1[[1]] #individual_id: 3053704

x2 <- results %>% 
  filter(individual_id==3053704) %>%
  st_as_sf(coords=c('lon','lat')) %>% 
  st_set_crs(4326) %>%
  group_by(individual_id) %>% 
  summarize(do_union=FALSE,.groups='drop') %>% 
  st_cast('LINESTRING')

g2 <- x2[1,] %>% st_geometry; g2[[1]] #individual_id: 3053704

g1[[1]] == g2[[1]]
