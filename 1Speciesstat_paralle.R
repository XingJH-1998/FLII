library(terra)
library(dplyr)
library(lubridate)
library(parallel)

# 1. file paths
input_root <- "data/GBIF202504/Aves"
output_year <- "data/processed_gbif/yearcount"
output_month <- "data/processed_gbif/monthcount"
flii <- rast("data/flii_earth_1k/flii_earth_1k.tif")

dir.create(output_year, recursive=TRUE, showWarnings=FALSE)
dir.create(output_month, recursive=TRUE, showWarnings=FALSE)

# 2. get path and ignore unknown species
rda_files <- list.files(
  input_root,
  pattern="\\.rda$",
  full.names=TRUE,
  recursive=TRUE
)
# remove unknown
rda_files <- rda_files[!grepl("unknown", rda_files, ignore.case=TRUE)]

# 3. process function
process_rda <- function(rda_path) {
  # get name
  species_name <- tools::file_path_sans_ext(basename(rda_path))
  
  # load data
  dd <- readRDS(rda_path)
  
  if(!"month" %in% colnames(dd)){
    if("eventDate" %in% colnames(dd)){
      dd$month <- month(ymd(dd$eventDate))
    } else {
      # month信息缺失就跳过
      return(NULL)
    }
  }
  
  # clean and keep only human observation
  dd_clean <- dd %>%
    filter(
      !is.na(decimalLatitude),
      !is.na(decimalLongitude),
      !is.na(year),
      !is.na(species),
      year %in% 2019:2024,
      basisOfRecord == "HUMAN_OBSERVATION",
      decimalLongitude >= xmin(flii), decimalLongitude <= xmax(flii),
      decimalLatitude >= ymin(flii), decimalLatitude <= ymax(flii)
    )
  if(nrow(dd_clean) == 0) return(NULL)
  
  # cell id
  coords <- data.frame(x = dd_clean$decimalLongitude, y = dd_clean$decimalLatitude)
  dd_clean$cell <- cellFromXY(flii, coords)
  
  # calculate by year
  dd_stat <- dd_clean %>%
    group_by(cell, year, species) %>%
    summarise(records = n(), .groups = 'drop')
  cell_xy <- xyFromCell(flii, dd_stat$cell)
  dd_stat$x <- cell_xy[, 1]
  dd_stat$y <- cell_xy[, 2]
  
  # calculate by month
  dd_stat_month <- dd_clean %>%
    group_by(cell, year, month, species) %>%
    summarise(records = n(), .groups = 'drop')
  cell_xy2 <- xyFromCell(flii, dd_stat_month$cell)
  dd_stat_month$x <- cell_xy2[, 1]
  dd_stat_month$y <- cell_xy2[, 2]
  
  # save
  saveRDS(dd_stat, file=file.path(output_year, paste0(species_name, "_yearcount.rds")))
  saveRDS(dd_stat_month, file=file.path(output_month, paste0(species_name, "_monthcount.rds")))
  
  return(species_name)
}

# 4. paralle
ncore <- max(1, detectCores() - 1)
cat("Total files:", length(rda_files), ", using", ncore, "cores\n")
results <- mclapply(rda_files, process_rda, mc.cores=ncore)

cat("Finished processing:\n")
print(unlist(results))



