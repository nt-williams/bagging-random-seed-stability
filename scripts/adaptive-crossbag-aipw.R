library(mlr3superlearner)
library(dplyr)
library(ife)
library(glue)
library(torch)

source("../R/schader-generate_data.R")
source("../R/ate_aipw_adaptive_crossbag.R")

i <- Sys.getenv("SLURM_ARRAY_TASK_ID")
if (i == "undefined" || i == "") i <- 1
i <- as.integer(i)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  args <- list(0.01, 0.01, 100)
}

# Number of complete models to train
no_runs <- 1e3

# Size of seed class
M <- .Machine$integer.max

set.seed(845566370)

n <- as.numeric(args[[3]])

foo <- schader_dgp_1(n)
foo1 <- mutate(foo, A = 1)
foo0 <- mutate(foo, A = 0)

# Sampling seeds 
fit_seeds <- sample.int(M, size = no_runs, replace = TRUE)

# Number of bags
epsilon <- as.numeric(args[[1]])
delta <- as.numeric(args[[2]])
rho <- 1/2 # Relative size of the resample
V <- 5

learner <- "ranger"

set.seed(fit_seeds[i])
res <- ate_aipw_adaptive_crossbag(foo, foo1, foo0, learner, rho, epsilon, delta, V)

saveRDS(res, glue("../data/sims/crossbag/adaptive2_aipw_{i}_{n}_{epsilon}_{delta}.rds"))
