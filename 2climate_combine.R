library(terra)

# paths
input_dir <- "data/climatic"
output_dir <- "data/climatic_combined"
dir.create(output_dir, showWarnings = FALSE)

nc_files <- list.files(input_dir, pattern = "\\.nc$", full.names = TRUE)

# get variables
file_info <- data.frame(
  path = nc_files,
  name = basename(nc_files),
  stringsAsFactors = FALSE
)

file_info$var <- sub("_(\\d{4})\\.nc$", "", file_info$name)
file_info$year <- as.integer(sub(".*_(\\d{4})\\.nc$", "\\1", file_info$name))

vars <- unique(file_info$var)

for (var in vars) {
  sub_info <- file_info[file_info$var == var, ]
  sub_info <- sub_info[order(sub_info$year), ]
  
  era_ids <- cut(sub_info$year, breaks = seq(min(sub_info$year), max(sub_info$year) + 6, by = 6), right = FALSE)
  sub_info$era <- era_ids
  
  eras <- unique(sub_info$era)
  
  for (era in eras) {
    group_files <- sub_info[sub_info$era == era, "path"]
    years <- sub_info[sub_info$era == era, "year"]
    
    if (length(group_files) == 0) next  
    
    all_layers <- lapply(group_files, rast)
    merged <- do.call(c, all_layers)  
    
    out_name <- sprintf("%s_%d_%d.nc", var, min(years), max(years))
    out_path <- file.path(output_dir, out_name)
    
    writeCDF(merged, filename = out_path, overwrite = TRUE)
    message("Saved: ", out_name)
  }
}



