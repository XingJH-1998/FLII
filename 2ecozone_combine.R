library(terra)

# 1. 读取数据
fl_raster <- rast("data/flii_earth_1k/flii_earth_1k.tif")
ecoregion <- vect("data/Ecoregions2017/Ecoregions2017.shp") # 用terra读入，自动转换CRS
cell.id <- readRDS("data/cell_id.rda")


# 3. 栅格化shapefile，使之与fl_raster对齐
eco_raster <- rasterize(ecoregion, fl_raster, field="BIOME_NAME", touches=TRUE)
eco_realm <- rasterize(ecoregion, fl_raster, field="REALM", touches=TRUE)
eco_nnh   <- rasterize(ecoregion, fl_raster, field="NNH_NAME", touches=TRUE)

biome_num <- as.data.frame(eco_raster,cells=TRUE, na.rm=TRUE)
biome_num.clean <- biome_num[biome_num$cell %in% cell.id,]
realm_num <- as.data.frame(eco_realm,cells=TRUE, na.rm=TRUE)
realm_num.clean <- realm_num[realm_num$cell %in% cell.id,]
nnh_num <- as.data.frame(eco_nnh,cells=TRUE, na.rm=TRUE)
nnh_num.clean <- nnh_num[nnh_num$cell %in% cell.id,]

library(dplyr)
df.ecozone <- realm_num.clean %>%
  left_join(nnh_num.clean, by = "cell") %>%
  left_join(biome_num.clean, by = "cell")
saveRDS(df.ecozone,"data/ecozone_combine.rda")
head(df.ecozone)
