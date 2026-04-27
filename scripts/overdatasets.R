library(mlr3superlearner)
library(mlr3extralearners)
library(dplyr)
library(ife)
library(glue)
library(torch)
library(here)

source(here("R", "schader-generate_data.R"))
source(here("R", "ate_aipw_adaptive_crossbag.R"))
source(here("R", "ate_aipw_crossfit.R"))

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

# Sampling seeds 
seeds <- sample.int(M, size = no_runs, replace = TRUE)

n <- as.numeric(args[[3]])

set.seed(seeds[i])
foo <- schader_dgp_1(n)
foo1 <- mutate(foo, A = 1)
foo0 <- mutate(foo, A = 0)

# Number of bags
epsilon <- as.numeric(args[[1]])
delta <- as.numeric(args[[2]])
rho <- 1 - 1/exp(1) # Relative size of the resample
V <- 5

learner <- "ranger"

res <- ate_aipw_adaptive_crossbag(foo, foo1, foo0, learner, rho, epsilon, delta, V)
res2 <- ate_aipw_crossfit(foo, foo1, foo0, 2, 1, learner)
res10 <- ate_aipw_crossfit(foo, foo1, foo0, 10, 1, learner)

saveRDS(list(
  adaptive_crossbag = res, 
  crossfit2 = res2, 
  crossfit10 = res10
), glue("../data/sims/adaptive_aipw_overdatasets_{i}_{n}_{epsilon}_{delta}.rds"))
