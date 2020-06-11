library(jsonlite)
library(data.table)
library(lubridate)
###########
# https://github.com/ucdavis-sta141b-sq-2020/sta141b-project
# https://gallery.shinyapps.io/nyc-metro-vis/?_ga=2.263211788.1401660902.1591610915-935468152.1588398581
# http://api.bart.gov/docs/overview/examples.aspx

# # specific route
# a <- fromJSON("http://api.bart.gov/api/sched.aspx?cmd=routesched&route=12&key=MW9S-E7SL-26DU-VV8V&json=y")
# 
# # stations info
# b <- fromJSON("http://api.bart.gov/api/stn.aspx?cmd=stns&key=MW9S-E7SL-26DU-VV8V&json=y")
# # c <- fromJSON("http://api.bart.gov/api/stn.aspx?cmd=stninfo&orig=ssan&key=MW9S-E7SL-26DU-VV8V&json=y")
# 
# # routes list
# l <- fromJSON("http://api.bart.gov/api/route.aspx?cmd=routes&key=MW9S-E7SL-26DU-VV8V&json=y")

#########

l <- fromJSON("http://api.bart.gov/api/route.aspx?cmd=routes&key=MW9S-E7SL-26DU-VV8V&json=y")
l1 <- l$root$routes$route
l1_ns <- l1$number
l_all <- list()
for (i in l1_ns) {
  print(i)
  url1 <- sprintf("http://api.bart.gov/api/sched.aspx?cmd=routesched&route=%s&key=MW9S-E7SL-26DU-VV8V&json=y", i)
  dat <- fromJSON(url1)
  
  ###
  spe_routes <- dat$root$route$train$stop
  ll <- list()
  for (j in seq(length(spe_routes))) {
    print(j)
    x <- spe_routes[[j]]
    x[, "index"] <- j
    x[, "station_id"] <- seq(nrow(x))
    ll <- c(ll, list(x))
  }
  y <- rbindlist(ll)
  y[, "number"] <- i
  l_all <- c(l_all, list(y))
}
alldat <- rbindlist(l_all)

### merge route info
alldat1 <- merge(alldat, l1, by = "number")
setnames(alldat1, old = "name", new = "routename")

### merge station info
b <- fromJSON("http://api.bart.gov/api/stn.aspx?cmd=stns&key=MW9S-E7SL-26DU-VV8V&json=y")
stationinfo <- b$root$stations$station
alldat2 <- merge(alldat1, stationinfo, by.x = "@station", by.y = "abbr")
alldat2[, gtfs_latitude := as.numeric(gtfs_latitude)]
alldat2[, gtfs_longitude := as.numeric(gtfs_longitude)]

setnames(alldat2, old = "@origTime", new = "reachtime")
alldat2[, reachtime := hour(parse_date_time(reachtime, '%I:%M %p'))]
###
fwrite(alldat2, "allinfo.csv")
fwrite(l1, "routeinfo.csv")

temp1 <- alldat2[, .N, by =.(number, index)]
setorder(temp1, number, -N)
temp2 <- temp1[, .SD[1], by = .(number)]
temp3 <- merge(alldat2, temp2, by = c("number", "index"))
fwrite(temp3, "single_route.csv")

