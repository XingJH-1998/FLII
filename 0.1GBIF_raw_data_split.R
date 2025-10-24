library(data.table)
library(parallel)


gbif <- fread("data/0049093-251009101135966.csv", nrows = 500000, select = c("species", "decimalLatitude", "decimalLongitude", "year", "month"))

gbif_sub <- gbif[gbif$species!="",]
# 按物种拆分
sp_list <- split(gbif_sub, gbif_sub$species)

# 创建输出文件夹
dir.create("GBIF_2024", showWarnings = FALSE)

# 并行保存
mclapply(names(sp_list), function(sp) {
  sp_data <- sp_list[[sp]]
  file_name <- paste0("GBIF_2024/", gsub("[^A-Za-z0-9]", "_", sp), ".rda")
  saveRDS(sp_data, file_name)
}, mc.cores = detectCores() - 10)   # 用到的核数




