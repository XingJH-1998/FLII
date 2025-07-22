library(terra)
library(parallel)

flii <- rast("data/flii_earth_1k/flii_earth_1k.tif")
cell.id <- readRDS("data/cell_id.rda")

soil_folders <- list.dirs("data/soil", full.names = TRUE, recursive = FALSE)
#soil_folders <- soil_folders[-5]

# paths
soil_files <- unlist(lapply(soil_folders, function(folder) {
  list.files(folder, pattern = "\\.tif$", full.names = TRUE)
}))


categories <- c("bdod", "clay", "phh2o", "silt")


process_soil_files_by_category <- function(cat) {
  cat_files <- soil_files[grepl(cat, basename(soil_files), ignore.case = TRUE)]
  if (length(cat_files) == 0) {
    warning(paste("No files found for category:", cat))
    return(NULL)
  }
  
  message("Processing category: ", cat)
  
  n_cores <- max(1, detectCores() - 1)
  soil_values_list <- mclapply(cat_files, function(file) {
    r <- rast(file)
    aligned <- project(r, flii, method = "bilinear")
    values(aligned)
  }, mc.cores = n_cores)
  
  soil_matrix <- do.call(cbind, soil_values_list)
  colnames(soil_matrix) <- basename(cat_files)
  soil_matrix <- as.data.frame(soil_matrix)
  soil_matrix$cell_id <- 1:ncell(flii)
  soil_matrix_clean <- soil_matrix[soil_matrix$cell_id %in% cell.id,]
  
  saveRDS(soil_matrix, file = paste0("data/soil_", cat, ".rda"))
  saveRDS(soil_matrix_clean, file = paste0("data/soil_", cat, "_clean.rda"))
  message("Saved category: ", cat)
}

lapply(categories, process_soil_files_by_category)


twi <- rast("data/soil/6b0c4358-2bf3-4924-aa8f-793d468b92be/ga2.nc")
aligned <- resample(twi, flii, method = "bilinear")
saveRDS(aligned, "data/soil/soil_twi_resampled.rda")
value <- as.data.frame(aligned, cells=TRUE, na.rm=TRUE)
value.clean <- value[value$cell %in% cell.id.flii,]
saveRDS(value.clean, "data/soil/soil_twi.rda")

bedrockdepth <- rast("data/soil/BDTICM_M_250m_ll.tif")
aligned <- resample(bedrockdepth, flii, method = "bilinear")
saveRDS(aligned, "data/soil/soil_bedrockdepth_resampled.rda")
value <- as.data.frame(aligned, cells=TRUE, na.rm=TRUE)
value.clean <- value[value$cell %in% cell.id.flii,]
saveRDS(value.clean, "data/soil/soil_bedrockdepth.rda")
