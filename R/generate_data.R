library(data.table)

# Complex DGP generated with Claude.
generate_data <- function(n = 1000, seed = NULL) {
  if (!is.null(seed)) {
    set.seed(seed)
  }

  # Generate 20 continuous covariates with some correlation structure
  # Block 1: correlated group (W1-W5)
  Sigma1 <- matrix(0.3, 5, 5)
  diag(Sigma1) <- 1
  W_block1 <- MASS::mvrnorm(n, mu = rep(0, 5), Sigma = Sigma1)

  # Block 2: correlated group (W6-W10)
  Sigma2 <- matrix(0.2, 5, 5)
  diag(Sigma2) <- 1
  W_block2 <- MASS::mvrnorm(n, mu = rep(1, 5), Sigma = Sigma2)

  # Block 3: independent (W11-W15)
  W_block3 <- matrix(rnorm(n * 5, mean = 0, sd = 1.5), ncol = 5)

  # Block 4: mixed distributions (W16-W20)
  W_block4 <- cbind(
    rgamma(n, shape = 2, rate = 1), # W16: right-skewed
    rbeta(n, 2, 5) * 4 - 1, # W17: skewed, rescaled
    rnorm(n, 0, 2), # W18
    rt(n, df = 5), # W19: heavy-tailed
    runif(n, -2, 2) # W20
  )

  W <- cbind(W_block1, W_block2, W_block3, W_block4)
  colnames(W) <- paste0("W", 1:20)

  # Complex logistic model for binary outcome
  logit_p <-
    # Main effects (some linear, some non-linear)
    0.5 *
    W[, 1] -
    0.3 * W[, 2]^2 +
    sin(W[, 3] * pi / 2) +
    0.4 * pmax(W[, 4], 0) + # ReLU-like
    -0.6 * abs(W[, 5]) +
    0.2 * W[, 6] +
    dnorm(W[, 7], mean = 1, sd = 0.5) * 5 - # bump at W7 ≈ 1
    0.3 * W[, 8] +
    log(abs(W[, 9]) + 1) * sign(W[, 9]) * 0.5 + # soft log transform
    -0.15 * W[, 10] +

    # Sparse signal from block 3
    0.8 * (W[, 11] > 1) * W[, 11] + # threshold effect
    -0.4 * W[, 13]^3 / 10 +

    # Block 4 effects
    0.3 * sqrt(pmax(W[, 16], 0)) -
    cos(W[, 18]) * 0.6 +
    0.2 * W[, 20] +

    # Two-way interactions
    0.5 * W[, 1] * W[, 6] + # cross-block interaction
    -0.4 * W[, 2] * W[, 3] + # within-block interaction
    0.6 * W[, 4] * (W[, 7] > 0.5) + # interaction with threshold
    -0.3 * W[, 5] * sin(W[, 18]) + # non-linear interaction
    0.7 * W[, 11] * W[, 16] / (1 + abs(W[, 11])) + # ratio interaction
    -0.5 * (W[, 8] > 0) * (W[, 13] > 0) + # indicator interaction

    # Three-way interaction
    0.4 * W[, 1] * W[, 7] * (W[, 20] > 0) +

    # Intercept to control baseline prevalence
    -0.5

  p <- plogis(logit_p)
  # Y <- rbinom(n, 1, p)
  Y <- p

  dt <- as.data.table(W)
  dt[, Y := Y]

  # Attach the true propensity as an attribute for evaluation
  attr(dt, "true_prob") <- p

  return(dt)
}
