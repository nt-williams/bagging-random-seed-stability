library(mlr3superlearner)
library(ife)
library(torch)

source("R/subsample_until_oob.R")

estimate_propensity <- function(data, learners, valid) {
  fit <- mlr3superlearner(
    data, target = "A", library = learners, 
    outcome_type = "binomial"
  )
  predict(fit, valid)
}

estimate_outcome_reg <- function(data, learners, valid1, valid0) {
  fit <- tryCatch(
    mlr3superlearner(
      data, target = "Y", library = learners, 
      outcome_type = "binomial"
    ),
    error = function(e) NULL
  )
  if (is.null(fit)) {
    return(list(rep(NA_real_, nrow(valid1)), rep(NA_real_, nrow(valid0))))
  }
  list(predict(fit, valid1), predict(fit, valid0))
}

train_batch <- function(data, rho, min_oob, data1, data0, learners_outcome, learners_trt) {
  n <- nrow(data)
  # Draw subsamples
  subsamples <- subsample_until_oob(n, rho, min_oob)

  idx <- seq_len(n)
  ib <- subsamples$subsamples
  oob <- apply(ib, 2, \(b) setdiff(idx, b))

  # Estimate propensity scores
  g <- matrix(-999, nrow = n, ncol = subsamples$V)
  gvars <- setdiff(names(foo), c("Y", "Y_1", "Y_0"))
  for (j in seq_len(subsamples$V)) {
    g[oob[, j], j] <- estimate_propensity(data[ib[, j], gvars], learners_trt, data[oob[, j], ])
  }

  # Estimate outcome regression
  mvars <- setdiff(names(foo), c("Y_1", "Y_0"))
  m1 <- matrix(-999, nrow = n, ncol = subsamples$V)
  m0 <- matrix(-999, nrow = n, ncol = subsamples$V)

  for (j in seq_len(subsamples$V)) {
    tmp <- estimate_outcome_reg(data[ib[, j], mvars], learners_outcome, data1[oob[, j], ], data0[oob[, j], ])
    m1[oob[, j], j] <- tmp[[1]]
    m0[oob[, j], j] <- tmp[[2]]
  }

  list(
    subsamples = subsamples, 
    g = g, 
    m1 = m1, 
    m0 = m0
  )
}

combine_batches <- function(batch1, batch2) {
  subsamples <- list(
    subsamples = cbind(batch1$subsamples$subsamples, batch2$subsamples$subsamples), 
    V = batch1$subsamples$V + batch2$subsamples$V, 
    oob_counts = batch1$subsamples$oob_counts + batch2$subsamples$oob_counts,
    mask = cbind(batch1$subsamples$mask, batch2$subsamples$mask)
  )

  list(
    subsamples = subsamples, 
    g = cbind(batch1$g, batch2$g), 
    m1 = cbind(batch1$m1, batch2$m1), 
    m0 = cbind(batch1$m0, batch2$m0)
  )
}

# combine_batches(batch1, batch2)
is_seed_stable <- function(data, batch, epsilon, delta, p) {
  g <- batch$g
  m1 <- batch$m1
  m0 <- batch$m0
  mask <- batch$subsamples$mask
  oob_counts <- batch$subsamples$oob_counts

  # The Constants: Observed Data (No gradients needed)
  A <- torch_tensor(data$A)
  Y <- torch_tensor(data$Y)

  # The Variables: Pooled Consensus Predictions (\bar{\eta})
  # We turn ON requires_grad so torch tracks their derivatives!
  gbar <- torch_tensor(1 / oob_counts * rowSums(mask * g), requires_grad = TRUE)
  m1bar <- torch_tensor(1 / oob_counts * rowSums(mask * m1), requires_grad = TRUE)
  m0bar <- torch_tensor(1 / oob_counts * rowSums(mask * m0), requires_grad = TRUE)

  term1 <- (A / gbar) * (Y - m1bar) + m1bar
  term0 <- ((1 - A) / (1 - gbar)) * (Y - m0bar) + m0bar

  ate <- torch_mean(term1 - term0)
  # Traverse the computational graph backward to get exact gradients
  ate$backward()

  # Extract the n x 1 gradient vectors (\nabla \phi)
  grad_pi  <- gbar$grad
  grad_mu1 <- m1bar$grad
  grad_mu0 <- m0bar$grad

  M <- torch_tensor(mask)
  # C <- torch_tensor(oob_counts)
  g <- torch_tensor(g)
  m1 <- torch_tensor(m1)
  m0 <- torch_tensor(m0)

  Uv <- 
    torch_sum(grad_pi$unsqueeze(2) * M * (g - gbar$unsqueeze(2)), dim = 1) + 
    torch_sum(grad_mu1$unsqueeze(2) * M * (m1 - m1bar$unsqueeze(2)), dim = 1) + 
    torch_sum(grad_mu0$unsqueeze(2) * M * (m0 - m0bar$unsqueeze(2)), dim = 1)

  W <- torch_tensor(1 / (batch$subsamples$V * (1 - p)^2), dtype = torch_float32())
  variance_seed <- as.numeric(W * torch_sum(Uv^2)) / batch$subsamples$V

  error <- (qt(1 - delta / 2, batch$subsamples$V - 1) * sqrt(2 * variance_seed))

  stable <- error <= epsilon

  if (isTRUE(stable)) {
    return(
        list(
          stable = TRUE,
          error = error, 
          psi = ife(as.numeric(ate), as.numeric((term1 - term0) - ate)), 
          V = batch$subsamples$V
      )
    )
  } else {
    cat(error, "\n")
    return(list(stable = FALSE))
  }
}

ate_aipw_adaptive_crossbag <- function(data, data1, data0, learner, rho, epsilon, delta, V) {
  n <- nrow(data)
  p <- floor(rho * n) / n
  batch1 <- train_batch(data, rho, V, data1, data0, learner, learner)
  for (b in seq_len(100)) {
    res <- is_seed_stable(data, batch1, epsilon, delta, p)
    if (res$stable) break
    batch2 <- train_batch(data, rho, V, data1, data0, learner, learner)
    batch1 <- combine_batches(batch1, batch2)
  }
  res
}
