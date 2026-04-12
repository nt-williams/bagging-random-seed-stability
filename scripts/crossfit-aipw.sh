#!/bin/bash
#SBATCH --mem=5G
#SBATCH --time=1:00:00
#SBATCH --array=1-1000
#SBATCH --mail-user=ntw2117@cumc.columbia.edu
#SBATCH --mail-type=ALL

module load R

Rscript crossfit-aipw.R $1 $2

exit 0
