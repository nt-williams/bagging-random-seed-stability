# bags_needed(0.01, 0.025, 0.1, 100, 1 / ((2/3) * sqrt(n)))
bags_needed <- function(delta, epsilon, sigma2, gamma) {
  bern <- ceiling(log(2 / delta) / (epsilon^2) * (4 * sigma2 * gamma + (2 / 3)*epsilon))
  cheby <- ceiling((2 * sigma2) / (delta * epsilon^2) * gamma)
  pmin(cheby, bern)
}

png("paper/plots/bag-growth.png", width = 6, height = 4, units = "in", res = 300)
plot(\(s) bags_needed(0.01, 0.025, s, 1 / ((2/3) * sqrt(100))), from = 0, to = 0.25, 
     xlab = expression(sigma^2), ylab = "V")
plot(\(s) bags_needed(0.01, 0.025, s, 1 / ((2/3) * 100)), add = TRUE, col = "red")
plot(\(s) bags_needed(0.01, 0.025, s, 1 / ((2/3) * 100^0.25)), add = TRUE, col = "blue")
plot(\(s) bags_needed(0.01, 0.025, s, 1 / ((1/2) * sqrt(100))), add = TRUE, lty = 2)
plot(\(s) bags_needed(0.01, 0.025, s, 1 / ((1/2) * 100)), add = TRUE, col = "red", lty = 2)
plot(\(s) bags_needed(0.01, 0.025, s, 1 / ((1/2) * 100^0.25)), add = TRUE, col = "blue", lty = 2)
plot(\(s) bags_needed(0.01, 0.025, s, 1 / (sqrt(100))), add = TRUE, lty = 3)
plot(\(s) bags_needed(0.01, 0.025, s, 1 / (100)), add = TRUE, col = "red", lty = 3)
plot(\(s) bags_needed(0.01, 0.025, s, 1 / (100^0.25)), add = TRUE, col = "blue", lty = 3)
dev.off()
