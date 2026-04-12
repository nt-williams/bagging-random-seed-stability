# Bagging Random Seed Stability

Research code investigating the random-seed stability of bagged nuisance estimators used in semiparametric causal inference, with a focus on AIPW (Augmented Inverse Probability Weighting) estimation of the average treatment effect (ATE).

## Overview

When fitting machine learning nuisance models (propensity scores, outcome regressions) via bagging or cross-fitting, the resulting causal estimates can vary across random seeds. This project develops and evaluates an **adaptive cross-bagging** procedure that draws subsamples iteratively until a formal stability criterion is satisfied — bounding the seed-induced variance in the ATE estimate to within a user-specified tolerance `(epsilon, delta)`.

## Methods

- **Cross-fitting** (`scripts/crossfit-aipw.R`): Standard V-fold cross-fit AIPW with configurable folds and seed averaging.
- **Adaptive cross-bagging** (`scripts/adaptive-crossbag-aipw.R`): Draws subsamples until the seed-stability criterion is met, using automatic differentiation (via `torch`) to compute the gradient-based variance bound.
- **Stability diagnostic** (`R/helpers.R`): `delta()` function measuring the fraction of pairwise prediction differences exceeding a threshold `epsilon`.
- **Neural network baseline** (`scripts/nobag-nnet.R`, `scripts/subbag-nnet.R`): Comparison of bagged vs. unbagged neural net nuisance estimators.

## Repository Structure

```
R/                          # Core functions
  ate_aipw_adaptive_crossbag.R  # Adaptive cross-bagging AIPW estimator
  subsample_until_oob.R         # Subsampling until all obs appear OOB V times
  generate_data.R               # Complex synthetic DGP (20 covariates)
  schader-generate_data.R       # Alternative DGP
  helpers.R                     # Stability diagnostic utilities

scripts/                    # Simulation scripts (designed for SLURM arrays)
  adaptive-crossbag-aipw.R      # Run adaptive cross-bagging simulation
  crossfit-aipw.R               # Run cross-fit AIPW simulation
  crossbag-coverage.R           # Coverage evaluation
  nnet_results.R                # Summarize neural network results
  adaptive-crossbag-results.R   # Summarize adaptive cross-bagging results
  *.sh                          # SLURM batch submission scripts

data/sims/                  # Simulation output
  crossfit/                     # Cross-fit AIPW results
  crossbag/                     # Adaptive cross-bagging results
  bag-nnet/                     # Bagged neural network results
```

## Dependencies

R packages: `mlr3superlearner`, `ife`, `torch`, `origami`, `ranger`, `dplyr`, `data.table`, `glue`, `foreach`, `MASS`

## Usage

Simulations are designed to run as SLURM job arrays. The `SLURM_ARRAY_TASK_ID` environment variable selects the simulation replicate. For local runs, scripts default to replicate 1.

```bash
# Example: run adaptive cross-bagging with epsilon=0.01, delta=0.01, n=100
Rscript scripts/adaptive-crossbag-aipw.R 0.01 0.01 100

# Example: run cross-fit AIPW with 2 folds, 80 seed averages
Rscript scripts/crossfit-aipw.R 2 80
```
