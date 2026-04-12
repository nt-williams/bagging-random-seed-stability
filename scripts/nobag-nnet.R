library(mlr3)
library(mlr3pipelines)
library(mlr3learners)
library(future)
library(foreach)
library(doFuture)
library(glue)

source("R/generate_data.R")

# Suppress mlr3 fitting messages
lgr::get_logger("mlr3")$set_threshold("warn")

# Size of the largest sequence
N <- 1e6
# Size of training data
n <- 100
# Size of seed class
M <- .Machine$integer.max
# Number of models to train
no_runs <- 1e3

# Initial random number generated from Claude Sonnet 4.6 with prompt
# "Generate a random integer between 1 and 2147483647"
meta_seed <- 699004152
set.seed(meta_seed)

# Sampling seeds for drawing the training data and test data
train_seed <- sample.int(M, size = 1, replace = TRUE)
test_seed <- sample.int(M, size = 1, replace = TRUE)

# Sampling seeds 
fit_seeds <- sample.int(M, size = no_runs, replace = TRUE)

train_large <- generate_data(n = N, seed = train_seed)
train <- train_large[seq_len(n), ]
test <- generate_data(5, seed = test_seed)[1, drop = FALSE]

task <- as_task_regr(train, "Y")

subsample <- rsmp("subsampling", ratio = 1, repeats = 1)

# Initialize single layer neural network with 20 hidden nodes
learner <- lrn("regr.nnet", size = 20, trace = FALSE)

plan(multisession, workers = 10)

preds <- foreach(i = seq_len(no_runs), 
                 .combine = "c", 
                 .options.future = list(seed = TRUE)) %dofuture% {
  set.seed(fit_seeds[i])

  fit <- resample(task, learner, subsample, store_models = TRUE)

  sapply(fit$learners, function(learner) {
    learner$predict_newdata(test, task = fit$task)$response |> 
      (\(x) pmax(0, pmin(x, 1)))()
  }) |> 
    mean()
}

plan(sequential)

data.frame(run = seq_len(no_runs), pred = preds) |> 
  saveRDS(glue("data/sims/nobag-nnet-{n}.rds"))

#  |> 
#   plot(ylim = c(0, 1), ylab = expression(paste(hat(f), "(x)")))
