bernstein_bound <- function(V, rate) {
  function(epsilon) {
    2 * exp(- (V * epsilon^2) / (4 * (0.25 * rate) + (2 / 3) * epsilon))
  }
} 

rho <- 0.51
n <- 100

plot(bernstein_bound(2000, 1 / floor(rho * n)), from = 0.005, to = 0.01, 
     xlab = expression(epsilon), ylab = expression(delta))
plot(bernstein_bound(3000, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(1750, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(1500, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(1000, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(750, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)

n <- 200

plot(bernstein_bound(2000, 1 / floor(rho * n)), from = 0.005, to = 0.01, 
     xlab = expression(epsilon), ylab = expression(delta))
plot(bernstein_bound(3000, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(1750, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(1500, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(1000, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(750, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)

n <- 500

plot(bernstein_bound(1000, 1 / floor(rho * n)), from = 0.005, to = 0.01, 
     xlab = expression(epsilon), ylab = expression(delta), 
    ylim = c(0, 0.5))
plot(bernstein_bound(750, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(500, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(250, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(100, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)

n <- 1000

plot(bernstein_bound(1000, 1 / floor(rho * n)), from = 0.005, to = 0.01, 
     xlab = expression(epsilon), ylab = expression(delta), 
    ylim = c(0, 0.2))
plot(bernstein_bound(750, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(500, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(250, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)
plot(bernstein_bound(100, 1 / floor(rho * n)), from = 0.005, to = 0.01, add = TRUE)