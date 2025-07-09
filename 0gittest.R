library(terra)


flii <- rast("/Users/tangerine/Downloads/flii_earth_1k/flii_earth_1k.tif")

# Complie 2 datasets
# 1 species records per pixel
# 2 env variables per pixel

# How many data quality information to keep?
dd <- readRDS('/Volumes/Extreme SSD/GBIF202504/Aves/Anseriformes/Anatidae/Anas/Anas acuta/Anas acuta.rda')
aves <- readRDS('/Volumes/Extreme SSD/GBIF202504/Aves.rda')
colnames(dd)
table(dd$taxonRank)
table(dd$occurrenceStatus)
summary(dd$coordinateUncertaintyInMeters)
summary(dd$coordinatePrecision)
table(dd$basisOfRecord)
summary(dd$elevation)

# Time unit of env data: Year/Month/Average?

ts_elv <- rast("/Users/tangerine/Downloads/elevation_1KMmn_GMTEDmn.tif")
plot(ts_elv)
ts_elv2 <- rast("/Users/tangerine/Downloads/elevation_1KMmn_SRTM.tif")
plot(ts_elv2)


