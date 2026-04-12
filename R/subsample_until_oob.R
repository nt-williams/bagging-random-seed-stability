subsample_until_oob <- function(n, rho, V) {
  m <- floor(rho * n)
  # conservative upper bound on draws needed
  expected <- ceiling(V / (1 - rho))
  capacity <- as.integer(expected + 4 * sqrt(expected * log(n)))
  print(capacity)
  
  subs <- matrix(0L, nrow = m, ncol = capacity)
  oob_counts <- integer(n)
  k <- 0L
  
  while (min(oob_counts) < V) {
    k <- k + 1L
    if (k > ncol(subs)) {
      subs <- cbind(subs, matrix(0L, nrow = m, ncol = capacity))
    }
    idx <- sample.int(n, size = m, replace = FALSE)
    subs[, k] <- idx
    oob_counts[-idx] <- oob_counts[-idx] + 1L
  }

  idx <- seq_len(n)

  out <- list(
    subsamples = subs[, seq_len(k), drop = FALSE],
    V = k,
    oob_counts = oob_counts
  )

  out$mask <- apply(out$subsamples, 2, \(v) as.numeric(!(idx %in% v)))
  out
}
