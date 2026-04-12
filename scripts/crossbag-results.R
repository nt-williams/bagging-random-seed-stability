library(data.table)

source("R/helpers.R")
source("R/bags_needed.R")

devtools::source_gist("https://gist.github.com/nt-williams/3afb56f503c7f98077722baf9c7eb644")

rzrds <- \(path) rbindlist(read_zip_rds(path))

res_05_01 <- rzrds("data/sims/crossbag/aipw_0.05_0.01.zip")
res_01_01 <- rzrds("data/sims/crossbag/aipw_0.01_0.01.zip")

epsilon <- seq(0.001, 0.7, length.out = 1e4)

# Number of bags
V_0.01_0.05 <- bags_needed(0.01, 0.05, 0.11, 1 / (rho * n))
V_0.01_0.01 <- bags_needed(0.01, 0.01, 0.11, 1 / (rho * n))

png("paper/plots/crossbag-aipw.png", width = 6, height = 4, units = "in", res = 300)
plot(epsilon, delta(res_2$estimate, epsilon), type = "l", 
     xlab = expression(epsilon), 
     ylab = expression(delta), 
     ylim = c(0, 0.7), xlim = c(0, 0.2))
lines(epsilon, delta(res_05_01$estimate, epsilon), col = "blue")
plot(\(epsilon) 2 * exp(- (V_0.01_0.05 * epsilon^2) / (4 * (0.11 * (1 / (rho * n))) + (2 / 3) * epsilon)), 
     add = TRUE, from = 0.001, to = 0.2, lty = "dashed", col = "blue")
lines(epsilon, delta(res_01_01$estimate, epsilon), col = "red")
plot(\(epsilon) 2 * exp(- (V_0.01_0.01 * epsilon^2) / (4 * (0.11 * (1 / (rho * n))) + (2 / 3) * epsilon)), 
     add = TRUE, from = 0.001, to = 0.2, lty = "dashed", col = "red")
# points(0.05, 0.01, pch = 3)
# points(0.01, 0.01, pch = 3)
dev.off()

# ri <- sample.int(1000, 100)
# plot(seq_len(100), res_05_01$estimate[ri], ylim = c(-0.25, 0.15), 
#      xlab = "Run", ylab = "ATE")
# arrows(seq_len(100), res_05_01$conf.low[ri], seq_len(100), res_05_01$conf.high[ri],
#        length = 0.05,  # width of the arrow heads
#        angle = 90,     # makes flat caps instead of arrow points
#        code = 3)  

# plot(seq_len(100), res_01_01$estimate[ri], ylim = c(-0.25, 0.15), 
#      xlab = "Run", ylab = "ATE")
# arrows(seq_len(100), res_01_01$conf.low[ri], seq_len(100), res_01_01$conf.high[ri],
#        length = 0.05,  # width of the arrow heads
#        angle = 90,     # makes flat caps instead of arrow points
#        code = 3)  