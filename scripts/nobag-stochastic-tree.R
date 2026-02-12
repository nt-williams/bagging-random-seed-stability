library(ranger)

source("R/generate_data.R")

# Size of training data
n <- 100
# Size of seed class
M <- .Machine$integer.max
# Number of models to train
no_runs <- 100
# difference threshold
epsilon <- 0.05

meta_seed <- 74653
set.seed(meta_seed)

train_seed <- sample.int(M, size = 1)
test_seed <- sample.int(M, size = 1)

fit_seeds <- sample.int(M, size = no_runs)

train <- generate_data(n = 100, seed = train_seed)
test <- generate_data(5, seed = test_seed)

predictions <- lapply(seq_along(fit_seeds), function(s) {
  set.seed(fit_seeds[s])
  fit <- ranger(Y ~ ., data = train, num.trees = 1)
  predict(fit, data = test)$predictions
})

prediction_comb <- t(combn(sapply(predictions, \(p) p[1]), 2))
no_comb <- nrow(prediction_comb)

epsilon <- seq(0.01, 0.5, length.out = 100)

sapply(epsilon, function(eps) {
  sum(abs(prediction_comb[, 1] - prediction_comb[, 2]) >= eps) / no_comb
})
