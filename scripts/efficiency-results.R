library(data.table)

source("R/helpers.R")

devtools::source_gist("https://gist.github.com/nt-williams/3afb56f503c7f98077722baf9c7eb644")

summarize_sim <- function(df, n) {
  cov <- mean((df$conf.low <= 0) & (df$conf.high >= 0))
  cov_mcse <- sqrt(cov * (1 - cov) / nrow(df))
  bias <- mean(df$estimate)
  bias_mcse <- sqrt(var(df$estimate) / nrow(df))
  data.frame(
    coverage      = cov,
    coverage_mcse = cov_mcse,
    bias          = bias,
    bias_mcse     = bias_mcse,
    bias_scaled   = bias * sqrt(n),
    est_var       = mean(df$std.error^2),
    true_var      = var(df$estimate),
    var_ratio     = mean(df$std.error^2) / var(df$estimate)
  )
}

configs <- data.frame(
  n = c(100, 500, 1000), 
  eps = c(0.01, 0.002, 0.001), 
  delta = rep(0.01, 3)
)

paths <- glue_data(configs, "data/sims/overdatasets_{n}_{eps}_{delta}.zip")

res <- lapply(paths, read_zip_rds)
  
res <- lapply(res, function(x) {
  ada <- lapply(x, \(y) {
    item <- y$adaptive_crossbag$psi
    if (is.null(item)) return(NULL)
    ife::tidy(item)
  }) |> 
    rbindlist(fill = TRUE)

  cf_2 <- 
    lapply(x, \(y) y$crossfit2) |> 
    rbindlist()

  cf_2$conf.low <- cf_2$estimate - qnorm(0.975)*cf_2$std.error
  cf_2$conf.high <- cf_2$estimate + qnorm(0.975)*cf_2$std.error

  cf_10 <- 
    lapply(x, \(y) y$crossfit10) |> 
    rbindlist()

  cf_10$conf.low <- cf_10$estimate - qnorm(0.975)*cf_10$std.error
  cf_10$conf.high <- cf_10$estimate + qnorm(0.975)*cf_10$std.error

  list(adaptive = ada, crossfit_2 = cf_2, crossfit_10 = cf_10)
})

lapply(seq_len(3), function(x) {
  lapply(res[[x]], summarize_sim, n = configs$n[x]) |> 
    rbindlist(idcol = "config")
})
