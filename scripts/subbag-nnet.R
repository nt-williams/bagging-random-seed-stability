library(mlr3)
library(mlr3pipelines)
library(mlr3learners)
library(glue)
library(here)

source(here("R", "generate_data.R"))

i <- Sys.getenv("SLURM_ARRAY_TASK_ID")
if (i == "undefined" || i == "") i <- 1
i <- as.integer(i)

# Suppress mlr3 fitting messages
# lgr::get_logger("mlr3")$set_threshold("warn")

# Size of the largest sequence
N <- 1e6
# Size of training data
n <- 100
# Size of seed class
M <- .Machine$integer.max

# Number of complete models to train
no_runs <- 1e3

epsilon <- 0.1
delta <- 0.1
rho <- 1 - 1/exp(1) # Relative size of the resample
V <- 320 # Number of bags

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

subsample <- rsmp("subsampling", ratio = rho, repeats = V)

# Initialize single layer neural network with 20 hidden nodes
learner <- lrn("regr.nnet", size = 20, trace = FALSE)

set.seed(fit_seeds[i])

fit <- resample(task, learner, subsample, store_models = TRUE)

pred <- sapply(fit$learners, function(learner) {
  learner$predict_newdata(test, task = fit$task)$response |> 
    (\(x) pmax(0, pmin(x, 1)))()
}) |> 
  mean()

data.frame(run = i, pred = pred) |> 
  saveRDS(glue("../data/sims/bag-nnet/run_{i}_{epsilon}_{delta}.rds"))