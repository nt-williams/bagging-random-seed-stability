library(data.table)
library(purrr)

source("R/helpers.R")

devtools::source_gist("https://gist.github.com/nt-williams/3afb56f503c7f98077722baf9c7eb644")

# Empirical stability
res_01_01 <- read_zip_rds("data/sims/crossbag/adaptive_aipw_0.01_0.01.zip")

res_2 <- read_zip_rds("data/sims/crossfit/aipw_2.zip")
res_2 <- rbindlist(res_2)

res_10 <- read_zip_rds("data/sims/crossfit/aipw_10.zip")
res_10 <- rbindlist(res_10)

res_99 <- read_zip_rds("data/sims/crossfit/aipw_99.zip")
res_99 <- rbindlist(res_99)

res_2_80 <- read_zip_rds("data/sims/crossfit/aipw_2_80.zip")
res_2_80 <- rbindlist(res_2_80)

res_10_80 <- read_zip_rds("data/sims/crossfit/aipw_10_80.zip")
res_10_80 <- rbindlist(res_10_80)

res_99_80 <- read_zip_rds("data/sims/crossfit/aipw_99_80.zip")
res_99_80 <- rbindlist(res_99_80)

pointval <- function(x) {
  rbindlist(lapply(x, \(x) tryCatch(ife::tidy(x$psi), error = \(e) NULL)))$estimate
}

epsilon <- seq(0.0001, 0.7, length.out = 1e5)

average_bags <- function(x) {
  median(list_c(map(x, "V")))
}

average_bags(res_01_01)

png("plots/adaptive-crossbag-aipw.png", width = 3, height = 2.5, units = "in", res = 600)
par(mar = c(3, 3, 0.5, 0.5), mgp = c(2, 0.6, 0), cex.axis = 0.8, cex.lab = 0.9)
plot(epsilon, delta(pointval(res_01_01), epsilon), type = "l", 
     xlab = expression(paste("Tolerance ", epsilon)), 
     ylab = expression(paste("Probability ", delta)), 
     ylim = c(0, 0.5), xlim = c(0, 0.2))
lines(epsilon, delta(res_2$estimate, epsilon), col = "blue", lty = "dashed")
lines(epsilon, delta(res_10$estimate, epsilon), col = "red", lty = "dashed")
lines(epsilon, delta(res_99$estimate, epsilon), col = "darkgreen", lty = "dashed")
lines(epsilon, delta(res_2_80$estimate, epsilon), col = "blue", lty = "dotted")
lines(epsilon, delta(res_10_80$estimate, epsilon), col = "red", lty = "dotted")
lines(epsilon, delta(res_99_80$estimate, epsilon), col = "darkgreen", lty = "dotted")
dev.off()

delta(pointval(res_01_01), 0.01) / 0.01
delta(res_2$estimate, 0.01) / 0.01
delta(res_10$estimate, 0.01) / 0.01
delta(res_99$estimate, 0.01) / 0.01
delta(res_2_80$estimate, 0.01) / 0.01
delta(res_10_80$estimate, 0.01) / 0.01
delta(res_99_80$estimate, 0.01) / 0.01

# Confidence interval stability
add_ci <- function(data) {
  data$conf.low <- data$estimate - qnorm(0.975)*data$std.error
  data$conf.high <- data$estimate + qnorm(0.975)*data$std.error
  data
}

res_2 <- add_ci(res_2)
res_10 <- add_ci(res_10)
res_99 <- add_ci(res_99)

res_2_80 <- add_ci(res_2_80)
res_10_80 <- add_ci(res_10_80)
res_99_80 <- add_ci(res_99_80)

res_01_01 <- rbindlist(lapply(res_01_01, \(x) tryCatch(ife::tidy(x$psi), error = \(e) NULL)))

res_01_01[, mean(conf.low <= 0 & conf.high >= 0)]

res_2[, mean(conf.low <= 0 & conf.high >= 0)]
res_10[, mean(conf.low <= 0 & conf.high >= 0)]
res_99[, mean(conf.low <= 0 & conf.high >= 0)]

res_2_80[, mean(conf.low <= 0 & conf.high >= 0)]
res_10_80[, mean(conf.low <= 0 & conf.high >= 0)]
res_99_80[, mean(conf.low <= 0 & conf.high >= 0)]