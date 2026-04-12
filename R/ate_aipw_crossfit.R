library(mlr3superlearner)
library(origami)
library(foreach)

estimate_propensity <- function(data, learners, valid) {
  fit <- mlr3superlearner(
    data, target = "A", library = learners, 
    outcome_type = "binomial"
  )
  predict(fit, valid)
}

estimate_outcome_reg <- function(data, learners, valid1, valid0) {
  fit <- mlr3superlearner(
    data, target = "Y", library = learners, 
    outcome_type = "binomial"
  )
  list(predict(fit, valid1), predict(fit, valid0))
}

ate_aipw_crossfit <- function(data, data1, data0, no_folds, no_seeds, learner) {
  n <- nrow(data)
  folds <- make_folds(n, V = no_folds)

  idx <- seq_len(n)

  g <- matrix(nrow = n, ncol = 1)
  gvars <- setdiff(names(data), c("Y", "Y_1", "Y_0"))

  mus <- vector("numeric", no_seeds)

  x <- foreach(ix = seq_len(no_seeds), .combine = "rbind") %do% {
    for (j in seq_len(no_folds)) {
      g[folds[[j]]$validation_set, 1] <- estimate_propensity(data[folds[[j]]$training_set, gvars], learner, data[folds[[j]]$validation_set, ])
    }

    mvars <- setdiff(names(data), c("Y_1", "Y_0"))
    m1 <- matrix(nrow = n, ncol = 1)
    m0 <- matrix(nrow = n, ncol = 1)

    for (j in seq_len(no_folds)) {
      tmp <- estimate_outcome_reg(data[folds[[j]]$training_set, mvars], learner, 
                                data1[folds[[j]]$validation_set, ], data0[folds[[j]]$validation_set, ])
      m1[folds[[j]]$validation_set, 1] <- tmp[[1]]
      m0[folds[[j]]$validation_set, 1] <- tmp[[2]]
    }

    if1 <- rowMeans(data$A / g * (data$Y - m1) + m1, na.rm = TRUE)
    if0 <- rowMeans((1 - data$A) / (1 - g) * (data$Y - m0) + m0, na.rm = TRUE)

    ife::tidy(ife(mean(if1) - mean(if0), if1 - if0)) 
  }

  summarise(x, estimate = mean(estimate), std.error = mean(std.error))
}
