###
### Reformat dart station file:
###
### Lon Lat StationId
###

dartFile <- "/Users/breuera/workspace/gmt/poi/2011_10_05_dart_stations.txt"
dartData <- read.table(dartFile, header=TRUE, skip=10, sep=";", strip.white=TRUE, fill=TRUE)

write.table(file="/Users/breuera/workspace/gmt/poi/2011_10_05_dart_stations_gmt.txt", dartData[c("Longitude","Latitude","Station.ID")], sep=" ", row.names=FALSE, col.names=FALSE)

#pstext - file
#(x, y, size, angle, fontno, justify, text)
size <- list(rep(13, dim(dartData)[1]))
zero <- list(rep(0, dim(dartData)[1]))

pstextData <- c(dartData[c("Longitude","Latitude")], size, zero, zero, zero, dartData["Station.ID"])

write.table(file="/Users/breuera/workspace/gmt/poi/2011_10_05_dart_stations_gmt_pstext.txt", pstextData, sep=" ", row.names=FALSE, col.names=FALSE)
