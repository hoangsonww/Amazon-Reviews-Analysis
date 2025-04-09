## Project Instructions

## Authors:  
David Nguyen, Ayushi Mazumder, Charles Martin, Ryan Kuhn  
LING-460 — Spring 2025  
UNC-Chapel Hill

## Overview  
This project analyzes over 500,000 Amazon food product reviews to test whether negative reviews are more emotionally charged and lexically repetitive compared to positive ones. It uses Type-Token Ratio (TTR) and negative sentiment intensity as linguistic measures.

## Requirements

To run this project locally, you will need:

### 1. R (version ≥ 4.0 recommended)  
Download and install from: https://cran.r-project.org/

### 2. RStudio (optional but recommended)  
Download and install from: https://posit.co/download/rstudio-desktop/

### 3. Required R Packages  
The script installs missing packages automatically, but you can also install them manually:

```r
install.packages(c("tidyverse", "tidytext", "sentimentr", "lubridate"))
```

---

## Files in This Project

- `Reviews.csv` — The main dataset containing Amazon Fine Food Reviews  
- `analysis_script.R` — The primary R script containing all analysis steps  
- `report.pdf` — Final project write-up in report format  
- `division_of_labor.txt` — Describes who did what  
- `INSTRUCTIONS.md` — This setup and usage guide

---

## Setup Instructions

1. **Download the Dataset**
   - Place the `Reviews.csv` file in the same directory as the `analysis_script.R` file.
   - You can download the dataset from Kaggle or directly from the course-supplied Google Drive link.

2. **Open the Script**
   - Open `analysis_script.R` in RStudio or run it from your R console.

3. **Run the Script**
   - Run the full script from top to bottom. It will:
     - Load and preprocess the data
     - Calculate lexical diversity and sentiment metrics
     - Run statistical tests
     - Generate visualizations
     - Output regression results and conclusions

---

## Output

The script will display:
- Descriptive statistics comparing positive and negative reviews
- Two t-tests for TTR and negative sentiment intensity
- A regression analysis predicting lexical diversity
- Boxplots and regression plots

These outputs directly support the findings discussed in the final report.

---

## Notes

- The full project zip should include all required components for reproducibility.
- Be sure to run the script in an environment with sufficient memory; the dataset is large (~500,000 reviews).
- The code uses base R and tidyverse libraries for broad compatibility.

---
