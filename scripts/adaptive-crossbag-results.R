library(data.table)
library(purrr)

source("R/helpers.R")

devtools::source_gist("https://gist.github.com/nt-williams/3afb56f503c7f98077722baf9c7eb644")

# Empirical stability
res_01_01 <- read_zip_rds("data/sims/crossbag/adaptive2_aipw_0.01_0.01.zip")

res_2 <- read_zip_rds("data/sims/crossfit/aipw_2.zip")
res_2 <- rbindlist(res_2)

res_10 <- read_zip_rds("data/sims/crossfit/aipw_10.zip")
res_10 <- rbindlist(res_10)

res_50 <- read_zip_rds("data/sims/crossfit/aipw_50.zip")
res_50 <- rbindlist(res_50)

res_99 <- read_zip_rds("data/sims/crossfit/aipw_100.zip")
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

png("paper/plots/adaptive-crossbag-aipw.png", width = 3, height = 2.5, units = "in", res = 600)
par(mar = c(3, 3, 0.5, 0.5), mgp = c(2, 0.6, 0), cex.axis = 0.8, cex.lab = 0.9)
plot(epsilon, delta(pointval(res_01_01), epsilon), type = "l", 
     xlab = expression(paste("Tolerance ", epsilon)), 
     ylab = expression(paste("Probability ", delta)), 
     ylim = c(0, 0.5), xlim = c(0, 0.2))
# points(0.01, 0.01, pch = 3)
lines(epsilon, delta(res_2$estimate, epsilon), col = "blue", lty = "dashed")
lines(epsilon, delta(res_10$estimate, epsilon), col = "red", lty = "dashed")
lines(epsilon, delta(res_99$estimate, epsilon), col = "darkgreen", lty = "dashed")
lines(epsilon, delta(res_2_80$estimate, epsilon), col = "blue", lty = "dotted")
lines(epsilon, delta(res_10_80$estimate, epsilon), col = "red", lty = "dotted")
lines(epsilon, delta(res_99_80$estimate, epsilon), col = "darkgreen", lty = "dotted")
dev.off()

res_01_01 <- rbindlist(lapply(res_01_01, \(x) tryCatch(ife::tidy(x$psi), error = \(e) NULL)))
res_025_025 <- rbindlist(lapply(res_025_025, \(x) tryCatch(ife::tidy(x$psi), error = \(e) NULL)))
res_05_05 <- rbindlist(lapply(res_05_05, \(x) tryCatch(ife::tidy(x$psi), error = \(e) NULL)))


res_01_01[, mean(conf.low <= 0 & conf.high >= 0)]
res_025_025[, mean(conf.low <= 0 & conf.high >= 0)]
res_05_05[, mean(conf.low <= 0 & conf.high >= 0)]

res_2[, mean(conf.low <= 0 & conf.high >= 0)]

# Coverage

n100 <- read_zip_rds("data/sims/crossbag/adaptive_aipw_dataset_100_0.025_0.025.zip")
cat("Avg. V: ", mean(purrr::list_c(lapply(n100, \(x) x$V))))

n100 <- rbindlist(lapply(n100, \(x) tryCatch(ife::tidy(x$psi), error = \(e) NULL)))
n100[, .(bias = mean(estimate), coverage = mean(conf.low <= 0 & conf.high >= 0))]

n1000 <- read_zip_rds("data/sims/crossbag/adaptive_aipw_dataset_1000_0.025_0.025.zip")
cat("Avg. V: ", mean(purrr::list_c(lapply(n1000, \(x) x$V))))

n1000 <- rbindlist(lapply(n1000, \(x) tryCatch(ife::tidy(x$psi), error = \(e) NULL)))
n1000[, .(bias = mean(estimate), coverage = mean(conf.low <= 0 & conf.high >= 0))]
