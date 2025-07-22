#Cell id of FLII to remove nan value
library(terra)
flii <- rast("data/flii_earth_1k/flii_earth_1k.tif")
flii.df <- as.data.frame(flii, cells=TRUE, na.rm=TRUE)
cell.id.flii <- flii.df$cell
saveRDS(cell.id.flii, "data/cell_id.rda")