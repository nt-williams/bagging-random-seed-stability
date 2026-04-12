library(data.table)

source("R/helpers.R")

devtools::source_gist("https://gist.github.com/nt-williams/3afb56f503c7f98077722baf9c7eb644")

res <- read_zip_rds("data/sims/crossbag/aipw_dataset_0.01_0.01.zip")
res <- rbindlist(res)

mean((res$conf.low <= 0) & (res$conf.high >= 0))
