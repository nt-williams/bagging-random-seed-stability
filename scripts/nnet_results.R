library(data.table)

source("R/helpers.R")

devtools::source_gist("https://gist.github.com/nt-williams/3afb56f503c7f98077722baf9c7eb644")

res <- read_zip_rds("data/sims/bag-nnet/sim_0.1_0.1.zip")
res <- rbindlist(res)

res_nobag <- readRDS("data/sims/nobag-nnet.rds")
setDT(res_nobag)

epsilon <- seq(0.001, 0.7, length.out = 1e4)

bound <- function(epsilon) {
    2 * exp(-(320 * epsilon^2) / (4 * (1/4) + (2 / 3) * epsilon))
}

png("plots/nnet-phase.png", width = 3, height = 2.5, units = "in", res = 600)
par(mar = c(3, 3, 0.5, 0.5), mgp = c(2, 0.6, 0), cex.axis = 0.8, cex.lab = 0.9)
plot(epsilon, delta(res$pred, epsilon), type = "l", 
     xlab = expression(paste("Tolerance ", epsilon)), 
     ylab = expression(paste("Probability ", delta)), 
     ylim = c(0, 0.7), xlim = c(0, 0.65))
lines(epsilon, delta(res_nobag$pred, epsilon), col = "red")
lines(epsilon, bound(epsilon), lty = "dashed")
dev.off()