# Project Instructions

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

## Setup Instructions

1. **Download the Dataset**
   - Place the `Reviews.csv` file in the same directory as the `analysis.R` file.
   - You can download the dataset here: [https://www.kaggle.com/datasets/snap/amazon-fine-food-reviews?resource=download](https://www.kaggle.com/datasets/snap/amazon-fine-food-reviews?resource=download).

2. **Open the Script**
   - Open `analysis.R` in RStudio or run it from your R console.

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
