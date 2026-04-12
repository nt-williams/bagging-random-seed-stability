library(dplyr)
library(ife)
library(glue)
library(origami)
library(foreach)

source("../R/schader-generate_data.R")

i <- Sys.getenv("SLURM_ARRAY_TASK_ID")
if (i == "undefined" || i == "") i <- 1
i <- as.integer(i)

args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  args <- list(2, 80)
}

# Number of complete models to train
no_runs <- 1e3

# Size of seed class
M <- .Machine$integer.max

# Number of bags
no_folds <- as.numeric(args[[1]])

# Number of times to average
no_seeds <- as.numeric(args[[2]])

set.seed(845566370)

n <- 100

foo <- schader_dgp_1(n)
foo1 <- mutate(foo, A = 1)
foo0 <- mutate(foo, A = 0)

# Sampling seeds 
fit_seeds <- sample.int(M, size = no_runs, replace = TRUE)

learner <- "ranger"

set.seed(fit_seeds[i])

ate_aipw_crossfit(foo, foo1, foo0, no_folds, no_seeds, learner) |> 
  mutate(run = i, .before = estimate) |> 
  saveRDS(glue("../data/sims/crossfit/aipw_{i}_{no_folds}_{no_seeds}.rds"))