sigma2 <- 0.001
bernstein_bound <- function(V, rate) {
  function(epsilon) {
    2 * exp(- (V * epsilon^2) / (4 * (sigma2 * rate) + (2 / 3) * epsilon))
  }
} 

rho <- 0.51
n <- 100

plot(bernstein_bound(2000, 1 / floor(rho * n)), from = 0.005, to = 0.01, 
     xlab = expression(epsilon), ylab = expression(delta), col = "red")
plot(bernstein_bound(3000, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE, col = "blue")
plot(bernstein_bound(1750, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE, col = "green")
plot(bernstein_bound(1500, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE, col = "pink")
plot(bernstein_bound(1000, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE, col = "orange")
plot(bernstein_bound(750, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)

n <- 200

plot(bernstein_bound(2000, 1 / floor(rho * n)), from = 0.005, to = 0.01, 
     xlab = expression(epsilon), ylab = expression(delta), col = "red", 
     ylim = c(0, 0.1))
plot(bernstein_bound(3000, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE, col = "blue")
plot(bernstein_bound(1750, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE, col = "green")
plot(bernstein_bound(1500, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE, col = "pink")
plot(bernstein_bound(1000, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE, col = "orange")
plot(bernstein_bound(750, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)

n <- 500

plot(bernstein_bound(250, 1 / floor(rho * n)), from = 0, to = 0.025, 
     xlab = expression(epsilon), ylab = expression(delta), col = "red", 
     ylim = c(0, 0.06))
plot(bernstein_bound(1500, 1 / floor(rho * n)), from = 0, to = 0.025, add = TRUE, col = "blue")
plot(bernstein_bound(1250, 1 / floor(rho * n)), from = 0, to = 0.025, add = TRUE, col = "green")
plot(bernstein_bound(1000, 1 / floor(rho * n)), from = 0, to = 0.025, add = TRUE, col = "pink")
plot(bernstein_bound(750, 1 / floor(rho * n)), from = 0, to = 0.025, add = TRUE, col = "orange")
plot(bernstein_bound(500, 1 / floor(rho * n)), from = 0, to = 0.025, add = TRUE)

n <- 1000

plot(bernstein_bound(250, 1 / floor(rho * n^2)), from = 0, to = 0.025, 
     xlab = expression(epsilon), ylab = expression(delta), col = "red", 
     ylim = c(0, 0.06))
plot(bernstein_bound(1500, 1 / floor(rho * n^2)), from = 0, to = 0.025, add = TRUE, col = "blue")
plot(bernstein_bound(1250, 1 / floor(rho * n^2)), from = 0, to = 0.025, add = TRUE, col = "green")
plot(bernstein_bound(1000, 1 / floor(rho * n^2)), from = 0, to = 0.025, add = TRUE, col = "pink")
plot(bernstein_bound(750, 1 / floor(rho * n^2)), from = 0, to = 0.025, add = TRUE, col = "orange")
plot(bernstein_bound(100, 1 / floor(rho * n^2)), from = 0, to = 0.025, add = TRUE)