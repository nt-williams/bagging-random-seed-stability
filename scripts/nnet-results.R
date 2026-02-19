library(data.table)

devtools::source_gist("https://gist.github.com/nt-williams/3afb56f503c7f98077722baf9c7eb644")

res_01_01 <- read_zip_rds("data/sims/bag-nnet/sim_0.01_0.01.zip")
res_025_025 <- read_zip_rds("data/sims/bag-nnet/sim_0.025_0.025.zip")
res_05_05 <- read_zip_rds("data/sims/bag-nnet/sim_0.05_0.05.zip")
res_01_01 <- rbindlist(res_01_01)
res_025_025 <- rbindlist(res_025_025)
res_05_05 <- rbindlist(res_05_05)

res_nobag <- readRDS("data/sims/nobag-nnet.rds")
setDT(res_nobag)

delta <- function(pred, epsilon) {
  diffs <- abs(outer(pred, pred, "-"))
  diffs <- sort(diffs[lower.tri(diffs)])
  n <- length(pred)
  m <- length(diffs)
  # findInterval gives count of diffs < eps; subtract from total
  (m - findInterval(epsilon, diffs)) / m
}

epsilon <- seq(0.001, 0.7, length.out = 1e4)

png("paper/plots/estimated-phase-with-nobag.png", width = 6, height = 4, units = "in", res = 300)
plot(epsilon, delta(res_05_05$pred, epsilon), type = "l", 
     xlab = expression(epsilon), 
     ylab = expression(delta), 
     ylim = c(0, 0.7), xlim = c(0, 0.65), col = "red")
lines(epsilon, delta(res_nobag$pred, epsilon), col = "blue")
lines(epsilon, delta(res_025_025$pred, epsilon))
lines(epsilon, delta(res_01_01$pred, epsilon), col = "green")
points(0.05, 0.05, pch = 3)
points(0.025, 0.025, pch = 3)
points(0.01, 0.01, pch = 3)
dev.off()

png("paper/plots/estimated-phase-without-nobag.png", width = 6, height = 4, units = "in", res = 300)
plot(epsilon, delta(res_05_05$pred, epsilon), type = "l", 
     xlab = expression(epsilon), 
     ylab = expression(delta), 
     ylim = c(0, 0.15), xlim = c(0, 0.15), col = "red")
lines(epsilon, delta(res_025_025$pred, epsilon))
lines(epsilon, delta(res_01_01$pred, epsilon), col = "green")
points(0.05, 0.05, pch = 3)
points(0.025, 0.025, pch = 3)
points(0.01, 0.01, pch = 3)
dev.off()