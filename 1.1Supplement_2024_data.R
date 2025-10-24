library(terra)
library(dplyr)
library(parallel)

flii <- rast("data/flii_earth_1k/flii_earth_1k.tif")

input_new <- "data/GBIF_2024"
output_year <- "data/processed_gbif/yearcount"
output_month <- "data/processed_gbif/monthcount"

rda_files_new <- list.files(
  input_new,
  pattern="\\.rda$",
  full.names=TRUE
)

update_species <- function(rda_path){
  species_name <- tools::file_path_sans_ext(basename(rda_path))
  dd <- readRDS(rda_path)
  
  dd_clean <- dd %>%
    filter(
      !is.na(decimalLatitude),
      !is.na(decimalLongitude),
      !is.na(year),
      !is.na(species),
      year %in% 2024:2025,
      decimalLongitude >= xmin(flii), decimalLongitude <= xmax(flii),
      decimalLatitude >= ymin(flii), decimalLatitude <= ymax(flii)
    )
  
  if(nrow(dd_clean) == 0){
    cat("No data for 2024-2025, skip:", species_name, "\n")
    return(NULL)
  }
  
  # cell id
  coords <- data.frame(x = dd_clean$decimalLongitude, y = dd_clean$decimalLatitude)
  dd_clean$cell <- cellFromXY(flii, coords)
  
  # year stat
  dd_stat_year <- dd_clean %>%
    group_by(cell, year, species) %>%
    summarise(records = n(), .groups = 'drop')
  cell_xy <- xyFromCell(flii, dd_stat_year$cell)
  dd_stat_year$x <- cell_xy[,1]
  dd_stat_year$y <- cell_xy[,2]
  
  # month stat
  dd_stat_month <- dd_clean %>%
    group_by(cell, year, month, species) %>%
    summarise(records = n(), .groups = 'drop')
  cell_xy2 <- xyFromCell(flii, dd_stat_month$cell)
  dd_stat_month$x <- cell_xy2[,1]
  dd_stat_month$y <- cell_xy2[,2]
  
  # Update
  species_name_no_underline <- gsub("_", " ", species_name)
  file_year <- file.path(output_year, paste0(species_name_no_underline, "_yearcount.rds"))
  file_month <- file.path(output_month, paste0(species_name_no_underline, "_monthcount.rds"))
  
  if(file.exists(file_year)){
    processed_gbif_year <- readRDS(file_year)
    processed_gbif_year <- processed_gbif_year %>% filter(!year %in% 2024:2025)
    processed_gbif_year <- bind_rows(processed_gbif_year, dd_stat_year)
  } else {
    processed_gbif_year <- dd_stat_year
  }
  
  if(file.exists(file_month)){
    processed_gbif_month <- readRDS(file_month)
    processed_gbif_month <- processed_gbif_month %>% filter(!year %in% 2024:2025)
    processed_gbif_month <- bind_rows(processed_gbif_month, dd_stat_month)
  } else {
    processed_gbif_month <- dd_stat_month
  }
  
  saveRDS(processed_gbif_year, file_year)
  saveRDS(processed_gbif_month, file_month)
  
  cat("Updated:", species_name, "\n")
  return(species_name)
}

ncore <- max(1, detectCores() - 5)

results <- mclapply(rda_files_new, update_species, mc.cores=ncore)

cat("Updated species number:", length(unlist(results)), "\n")



