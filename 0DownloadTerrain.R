#Download Elevation Slope Terrain Ruggedness Index from Amatulli et al.
library(data.table)
library(tidyr)

data <- read.table("/Users/tangerine/Downloads/GMTED_list-of-links-to-files.tab", 
                   header = TRUE,    
                   sep = "\t",       
                   stringsAsFactors = FALSE)  

data2 <- data %>%
  separate(`File.name`, into = c("Source", "Type", "Rest"), sep = "\\|") %>%
  mutate(across(c(Source, Type, Rest), trimws)) %>%
  separate(Rest, into = c("Name", "LengthRes", "Type2"), sep = "_", remove = TRUE) %>%
  extract(LengthRes, into = c("Length", "Res"), regex = "([0-9]+[A-Z]+)([a-zA-Z]+)$") %>%
  filter(Type %in% c("elevation","slope","tri")) %>%
  filter(Length == "1KM")
urls <- data2$URL.file
dest_files <- file.path("data", basename(urls))
options(timeout = 3600)
for(i in 14:18) {
  download.file(urls[i], destfile = dest_files[i], mode = "wb")
  Sys.sleep(60)
}

aet <- rast("/Users/tangerine/Downloads/TerraClimate_aet_2024.nc")

