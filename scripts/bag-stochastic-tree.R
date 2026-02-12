library(mlr3)
library(ranger)

source("R/generate_data.R")

# Size of the largest sequence
N <- 1e6
# Size of training data
n <- 100
# Size of seed class
M <- .Machine$integer.max
# Number of models to train
no_runs <- 100
# difference threshold
epsilon <- 0.05

V <- 1000
rho <- 0.51

meta_seed <- 74653
set.seed(meta_seed)

train_seed <- sample.int(M, size = 1)
test_seed <- sample.int(M, size = 1)

fit_seeds <- replicate(no_runs, sample.int(M, size = V))

train <- generate_data(n = N, seed = train_seed)
test <- generate_data(5, seed = test_seed)

subbag_tree <- function(data, seeds, test) {
  subsampling <- rsmp("subsampling", repeats = V, ratio = rho)
  subsampling$instantiate(as_task_regr(data, "Y"))

  preds <- sapply(seq_along(seeds), function (s) {
    set.seed(seeds[s])
    fit <- ranger(Y ~ ., data = data[subsampling$train_set(s), ], num.trees = 1)
    predict(fit, data = test)$predictions
  })

  rowMeans(preds)
}

predictions <- lapply(seq_len(ncol(fit_seeds)), function(s) {
  subbag_tree(train, fit_seeds[, s], test)
})

prediction_comb <- t(combn(sapply(predictions, \(p) p[1]), 2))
no_comb <- nrow(prediction_comb)

epsilon <- seq(0.01, 0.1, length.out = 100)

sapply(epsilon, function(eps) {
  sum(abs(prediction_comb[, 1] - prediction_comb[, 2]) >= eps) / no_comb
})
