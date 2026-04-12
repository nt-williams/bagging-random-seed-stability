delta <- function(pred, epsilon) {
  diffs <- abs(outer(pred, pred, "-"))
  diffs <- sort(diffs[lower.tri(diffs)])
  n <- length(pred)
  m <- length(diffs)
  # findInterval gives count of diffs < eps; subtract from total
  (m - findInterval(epsilon, diffs)) / m
}