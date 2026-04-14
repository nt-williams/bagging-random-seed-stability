library(mlr3superlearner)
library(dplyr)
library(ife)
library(glue)
library(torch)

source("R/schader-generate_data.R")
source("R/ate_aipw_adaptive_crossbag.R")
source("R/ate_aipw_crossfit.R")

# Number of complete models to train
no_runs <- 1e3

# Size of seed class
M <- .Machine$integer.max

set.seed(845566370)

data <- schader_dgp_1(1e5)

# Sampling seeds 
fit_seed <- sample.int(M, size = 1, replace = TRUE)

# Number of bags
epsilon <- 0.01
delta <- 0.01
rho <- 1/2 # Relative size of the resample
V <- 1

learner <- "ranger"

n <- 100
foo <- data[seq_len(n), ]
foo1 <- mutate(foo, A = 1)
foo0 <- mutate(foo, A = 0)

microbenchmark::microbenchmark(
  ate_aipw_adaptive_crossbag(foo, foo1, foo0, learner, rho, epsilon, delta, V), 
  ate_aipw_crossfit(foo, foo1, foo0, 2, 80, learner), 
  ate_aipw_crossfit(foo, foo1, foo0, 10, 80, learner), 
  times = 4
)
