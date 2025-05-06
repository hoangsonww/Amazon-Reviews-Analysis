#!/usr/bin/env bash
# run_analysis.sh: Download data, run analysis, render report

set -e

# 1. Check data
if [ ! -f data/Reviews.csv ]; then
  echo "Error: data/Reviews.csv not found. Please download from Kaggle and place in data/."
  exit 1
fi

# 2. Run R script
echo "Running main analysis..."
Rscript analysis.R

# 3. Knit report
echo "Rendering R Markdown..."
Rscript -e "rmarkdown::render('report.Rmd')"

echo "All done. See report.html for results."
