library(terra)
library(parallel)
#terrain

flii <- rast("data/flii_earth_1k/flii_earth_1k.tif")

# paths
terrain_files <- list.files("data/terrain", pattern = "\\.tif$", full.names = TRUE)

n_cores <- max(1, detectCores() - 1)

process_raster <- function(file) {
  r <- rast(file)
  aligned <- project(r, flii, method = "bilinear")  
  values(aligned)
}

terrain_values <- mclapply(terrain_files, process_raster, mc.cores = n_cores)

terrain_matrix <- do.call(cbind, terrain_values)
colnames(terrain_matrix) <- basename(terrain_files)

terrain_df <- as.data.frame(terrain_matrix)
cell.id <- readRDS("data/cell_id.rda")
terrain_df_clean <- terrain_df[terrain_df$cell %in% cell.id,]
saveRDS(terrain_df, "data/terrain_combine.rda")
saveRDS(terrain_df_clean, "data/terrain_combine_clean.rda")


