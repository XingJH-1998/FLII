library(terra)
library(dplyr)
library(ggplot2)

dd <- readRDS('/Volumes/Extreme SSD/GBIF202504/Aves/Anseriformes/Anatidae/Anas/Anas acuta/Anas acuta.rda')
flii <- rast("/Users/tangerine/Downloads/flii_earth_1k/flii_earth_1k.tif")


dd_clean <- dd %>%
  filter(
    !is.na(decimalLatitude),
    !is.na(decimalLongitude),
    !is.na(year),
    !is.na(species)
  ) %>%
  filter(year %in% 2019:2024) %>%
  filter(basisOfRecord == "HUMAN_OBSERVATION")


# 3. 保证点在栅格范围内
dd_clean <- dd_clean %>%
  filter(
    decimalLongitude >= xmin(flii), decimalLongitude <= xmax(flii),
    decimalLatitude >= ymin(flii), decimalLatitude <= ymax(flii)
  )

# 4. 提取每个点的cell编号（格子编号）
coords <- data.frame(x = dd_clean$decimalLongitude, y = dd_clean$decimalLatitude)
dd_clean$cell <- cellFromXY(flii, coords)

# 5. 按cell、year、species统计每格每年每物种的记录数
dd_stat <- dd_clean %>%
  group_by(cell, year, species) %>%
  summarise(records = n(), .groups = 'drop')

# 6. 可选：加上cell的中心坐标，便于可视化和空间分析
cell_xy <- xyFromCell(flii, dd_stat$cell)
dd_stat$x <- cell_xy[, 1]
dd_stat$y <- cell_xy[, 2]

# 结果：每行表示某个格子、某年、某物种，共记录了几次
head(dd_stat)

ggplot(dd_stat)+
  geom_point(aes(x=x, y=y, color=factor(year)))





