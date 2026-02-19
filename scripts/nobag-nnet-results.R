library(data.table)

res <- readRDS("data/sims/nobag-nnet.rds")
setDT(res)

pred_pairs <- t(combn(res$pred, 2))
no_pairs <- nrow(pred_pairs)

epsilon <- seq(0.01, 0.5, length.out = 100)

delta_hat <- sapply(epsilon, function(eps) {
  sum(abs(pred_pairs[, 1] - pred_pairs[, 2]) >= eps) / no_pairs
})

png("paper/plots/nobag-nnet-estimated-phase.png", width = 6, height = 4, units = "in", res = 300)
par(mar = c(5, 5, 4, 2))
plot(epsilon, delta_hat, type = "l", 
     xlab = expression(epsilon), 
     ylab = expression(delta))
dev.off()