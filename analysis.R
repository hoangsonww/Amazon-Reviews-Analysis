#########################################################################################
# Local R Script for Analysis of Amazon Fine Food Reviews
# Title: Lexical Diversity and Sentiment Intensity in Amazon Fine Food Reviews
# Authors: David Nguyen, Ayushi Mazumder, Charles Martin, Ryan Kuhn
#
# This script investigates whether negative reviews (1-2 stars) on the Amazon Fine Food 
# Reviews dataset exhibit:
#   1. Lower lexical diversity (measured by the type-token ratio, TTR)
#   2. Higher negative sentiment intensity (proportion of negative words)
# compared to positive reviews (those with 4-5 stars).
#
# The analysis involves data loading, preprocessing, computation of linguistic metrics,
# visualization, and statistical analysis including t-tests and regression modeling
#########################################################################################

# -------------------------------#
# 1. INSTALL & LOAD PACKAGES
#    Author: David Nguyen     
# -------------------------------#
# Define a vector of required packages for data manipulation, visualization, 
# text mining, sentiment analysis, and date handling
required_packages <- c("tidyverse", "tidytext", "sentimentr", "lubridate")

# Check if each required package is installed. If not, install it with dependencies
installed_packages <- rownames(installed.packages())
for (pkg in required_packages) {
  if (!pkg %in% installed_packages) {
    install.packages(pkg, dependencies = TRUE)
  }
}

# For data manipulation (dplyr) and visualization (ggplot2)
library(tidyverse)
# For text tokenization and sentiment lexicons
library(tidytext) 
# For handling date and time conversions
library(lubridate)

# -------------------------------#
# 2. LOAD DATA
#    Author: David Nguyen
# -------------------------------#
# IMPORTANT: Ensure that "Reviews.csv" is placed in the same directory as this script
# The dataset can be downloaded from:
#  https://www.kaggle.com/datasets/snap/amazon-fine-food-reviews (Download the "Reviews.csv" file)
#
# read_csv (from the readr package within tidyverse) is used to import the dataset, 
# instead of base R's read.csv for better performance and handling of such a large
# dataset
reviews_data <- read_csv("Reviews.csv")

# Display a preview of the data to ensure it loaded correctly
cat("Data Preview:\n")
print(head(reviews_data))
# Expected output: The first six rows of the Reviews.csv dataset. The printed tibble shows columns 
# including Id, ProductId, UserId, ProfileName, HelpfulnessNumerator, HelpfulnessDenominator,
# Score, Time, Summary, and Text

# -------------------------------#
# 3. PREPROCESSING
#    Author: David Nguyen
# -------------------------------#
# Preprocess the dataset by:
#   - Converting Unix timestamp (Time) to a human-readable date
#   - Ensuring the Score field is numeric
#   - Creating a new categorical variable "Sentiment" based on the Score:
#         * "Negative" if score is 1 or 2
#         * "Positive" if score is 4 or 5
#         * "Neutral" for any other scores (e.g., 3 stars), which are then excluded
#   - Filtering to only include Negative and Positive reviews
reviews_data <- reviews_data %>%
  mutate(
    Date = as_datetime(Time),       
    Score = as.numeric(Score),        
    Sentiment = case_when(    
      Score %in% c(1, 2) ~ "Negative",
      Score %in% c(4, 5) ~ "Positive",
      TRUE ~ "Neutral"
    )
  ) %>%
  # Retain only reviews with clear sentiment since neutral reviews are not of our interest
  filter(Sentiment %in% c("Negative", "Positive"))

# -------------------------------#
# 4. LEXICAL DIVERSITY (TTR)
#    Author: Ayushi Mazumder
# -------------------------------#
# Define a function to calculate the Type-Token Ratio (TTR), which is a measure of lexical diversity
# TTR = (# of unique tokens) / (total number of tokens)
compute_ttr <- function(text) {
  # Split the review text into tokens (words) using whitespace as the delimiter
  tokens <- unlist(str_split(text, "\\s+"))
  
  # Remove any empty tokens that may occur due to multiple spaces
  tokens <- tokens[tokens != ""]
  
  # Edge-case check: If no tokens exist, return NA
  if (length(tokens) == 0) return(NA)
  
  # Calculate and return the ratio of unique tokens to the total number of tokens
  return(length(unique(tokens)) / length(tokens))
}

# Compute TTR for each review and add it as a new column "TTR"
# map_dbl applies the compute_ttr function to each review's text in the 'Text' column,
# which returns a numeric vector of TTR values for each review
reviews_data <- reviews_data %>%
  mutate(TTR = map_dbl(Text, compute_ttr))
# Note: A lower TTR indicates lower lexical diversity (more repetition), while a higher TTR 
# indicates greater diversity.

# Display the first few rows of the updated dataset to confirm the new TTR column
cat("Updated Data Preview with TTR:\n")
print(head(reviews_data))
# After this, our data should contain the following columns:
#   - Id: Unique identifier for each review
#   - ProductId: Unique identifier for each product
#   - UserId: Unique identifier for each user
#   - ProfileName: Name of the user who wrote the review
#   - HelpfulnessNumerator: Number of users who found the review helpful
#   - HelpfulnessDenominator: Total number of users who rated the review helpful
#   - Score: Rating given by the user (1-5 stars)
#   - Time: Date and time of the review
#   - Summary: Summary of the review
#   - Text: Full text of the review
#   - Date: Converted date from Unix timestamp
#   - Sentiment: Categorical variable indicating "Negative" or "Positive" sentiment
#   - TTR: Type-Token Ratio (lexical diversity) for each review

# -----------------------------------#
# 5. SENTIMENT INTENSITY (NEGATIVE)
#    Author: Charles Martin
# -----------------------------------#
# We measure negative sentiment intensity, defined as the proportion of negative words in the review
#
# First, use the "bing" sentiment lexicon from tidytext, which labels words as positive or negative,
# and filter for negative words since right now we're only interested in negative sentiment
negative_words <- get_sentiments("bing") %>%
  filter(sentiment == "negative")

# We tokenize the review text and count the number of negative words
# - unnest_tokens splits the "Text" column into individual words
# - inner_join with the negative_words lexicon selects only the negative words
# - group by the unique review Id to count the number of negative words in each review
sentiment_counts <- reviews_data %>%
  unnest_tokens(word, Text) %>%
  inner_join(negative_words, by = "word") %>%
  group_by(Id) %>%  # Group tokens by review identifier
  summarise(NegativeCount = n())

# Merge the negative word counts into the main dataset - reviews_data
# For any review that has no negative words (those that have NA values), replace NA with 0
# Also, calculate the total number of words in each review and derive NegativeIntensity - 
# a proportion of negative words to total words
reviews_data <- reviews_data %>%
  left_join(sentiment_counts, by = "Id") %>%
  mutate(
    NegativeCount = ifelse(is.na(NegativeCount), 0, NegativeCount),
    TotalWords = str_count(Text, "\\S+"),
    NegativeIntensity = NegativeCount / TotalWords # Proportion of negative words to total words
  )
# Expected output: NegativeIntensity values are higher for reviews with more negative words relative to review length

# Display the first few rows of the updated dataset to confirm the new NegativeIntensity column
cat("Updated Data Preview with Negative Intensity:\n")
print(head(reviews_data))
# After this, our data should contain the following columns:
#   - Id: Unique identifier for each review
#   - ProductId: Unique identifier for each product
#   - UserId: Unique identifier for each user
#   - ProfileName: Name of the user who wrote the review
#   - HelpfulnessNumerator: Number of users who found the review helpful
#   - HelpfulnessDenominator: Total number of users who rated the review helpful
#   - Score: Rating given by the user (1-5 stars)
#   - Time: Date and time of the review
#   - Summary: Summary of the review
#   - Text: Full text of the review
#   - Date: Converted date from Unix timestamp (converted to human-readable format from Time)
#   - Sentiment: Categorical variable indicating "Negative" or "Positive" sentiment
#   - TTR: Type-Token Ratio (lexical diversity) for each review
#   - NegativeCount: Number of negative words in each review
#   - TotalWords: Total number of words in each review
#   - NegativeIntensity: Proportion of negative words to total words in each review
# At this point, the dataset is ready for further analysis, with all necessary variables computed

# -------------------------------#
# 6. SUMMARY STATISTICS
#    Author: Ryan Kuhn
# -------------------------------#
# Compute descriptive statistics for TTR and Negative Sentiment Intensity,
# grouped by review sentiment (Negative vs. Positive). These stats include:
# - Mean and standard deviation of TTR
# - Mean and standard deviation of Negative Sentiment Intensity
# - Count of reviews in each sentiment category
# These should give us a good overview of the differences in lexical diversity and sentiment intensity
summary_stats <- reviews_data %>%
  group_by(Sentiment) %>%
  summarise(
    Mean_TTR = mean(TTR, na.rm = TRUE),           
    SD_TTR = sd(TTR, na.rm = TRUE),          
    Mean_NegIntensity = mean(NegativeIntensity, na.rm = TRUE),
    SD_NegIntensity = sd(NegativeIntensity, na.rm = TRUE),  
    Count = n()
  )

# Print the summary statistics.
cat("Summary Statistics:\n")
print(summary_stats)
# Expected summary output:
# For "Negative" reviews:
#   - Mean_TTR ~ 0.807, SD_TTR ~ 0.102, Mean_NegIntensity ~ 0.0368, SD_NegIntensity ~ 0.0296, Count = ~82,037
# For "Positive" reviews:
#   - Mean_TTR ~ 0.827, SD_TTR ~ 0.100, Mean_NegIntensity ~ 0.0179, SD_NegIntensity ~ 0.0206, Count = ~443,777
# Interpretation:
#   - Negative reviews show lower lexical diversity and higher proportion of negative words. This is shown through
# their lower mean TTR and higher mean negative intensity compared to Positive reviews

# -------------------------------#
# 7. VISUALIZATIONS
#    Author: Charles Martin
# -------------------------------#
# Create boxplots to compare the distribution of TTR and Negative Sentiment Intensity between review sentiments

# 1. Boxplot for Type-Token Ratio (TTR) by review sentiment.
ggplot(reviews_data, aes(x = Sentiment, y = TTR, fill = Sentiment)) +
  geom_boxplot() +
  labs(title = "Type-Token Ratio by Sentiment",
       x = "Sentiment (Negative vs. Positive)",
       y = "Type-Token Ratio (TTR)") +
  theme_minimal()
# Expected visualization output:
#   - A boxplot showing that Positive reviews have a slightly higher median TTR (lexical diversity) compared
#     to Negative reviews. The spread of TTR values is also visible, with Negative reviews showing more variability

# 2. Boxplot for Negative Sentiment Intensity by review sentiment.
ggplot(reviews_data, aes(x = Sentiment, y = NegativeIntensity, fill = Sentiment)) +
  geom_boxplot() +
  labs(title = "Negative Sentiment Intensity by Sentiment",
       x = "Sentiment (Negative vs. Positive)",
       y = "Negative Sentiment Intensity") +
  theme_minimal()
# Expected visualization output:
#   - A boxplot showing that Negative reviews have a much higher median negative intensity than Positive reviews. Also
#     the spread of negative intensity values is slightly wider for Negative reviews, which shows more variability in the proportion
#     of negative words in these reviews. The boxplot also shows that there are some outliers in the Negative reviews
#     with very high negative intensity values, which also shows that some reviews are extremely negative

# -------------------------------#
# 8. STATISTICAL TESTS
#    Author: David Nguyen
# -------------------------------#
# Perform independent-sample t-tests to test if the differences in TTR and Negative Sentiment 
# Intensity between Negative and Positive reviews are statistically significant

# T-test for TTR (lexical diversity)
cat("T-Test for Type-Token Ratio (TTR):\n")
ttr_test <- t.test(TTR ~ Sentiment, data = reviews_data)
print(ttr_test)
# Expected T-test output:
#   - t = -52.16, df ~ 113371, p-value < 2.2e-16
#   - 95% confidence interval: approximately [-0.02093, -0.01941]
# Interpretation:
#   - A highly significant difference in TTR exists between Negative and Positive reviews,
#     with Negative reviews having a lower TTR (indicating lower lexical diversity)

# T-test for Negative Sentiment Intensity
cat("T-Test for Negative Sentiment Intensity:\n")
neg_intensity_test <- t.test(NegativeIntensity ~ Sentiment, data = reviews_data)
print(neg_intensity_test)
# Expected T-test output:
#   - t = 174.36, df ~ 97254, p-value < 2.2e-16
#   - 95% confidence interval: approximately [0.01861, 0.01903]
# Interpretation:
#   - There is a highly significant difference in negative sentiment intensity,
#     with Negative reviews having a higher intensity (i.e., a larger proportion of negative words)

# -------------------------------#
# 9. REGRESSION ANALYSIS
#    Author: David Nguyen
# -------------------------------#
# For the regression analysis, create a binary variable representing review sentiment:
#   - 1 for Negative reviews
#   - 0 for Positive reviews
reviews_data <- reviews_data %>%
  mutate(SentimentBinary = ifelse(Sentiment == "Negative", 1, 0))

# Build a linear regression model to predict TTR (lexical diversity) using:
#   - SentimentBinary: captures the effect of review sentiment
#   - NegativeIntensity: captures the effect of the proportion of negative words
reg_model <- lm(TTR ~ SentimentBinary + NegativeIntensity, data = reviews_data)
cat("Regression Analysis Summary:\n")
summary(reg_model)
# Expected regression output:
#   - Intercept: ~0.827 (mean TTR for Positive reviews)
#   - Coefficient for SentimentBinary: ~ -0.02039, highly significant (p < 2e-16), indicating that being
#     a Negative review reduces the TTR by about 0.02 on average
#   - Coefficient for NegativeIntensity: ~0.01196, marginally significant (p ~ 0.055), suggesting a slight 
#     positive association between negative intensity and TTR
# Interpretation:
#   - The regression confirms that review sentiment is a significant predictor of lexical diversity,
#     with Negative reviews exhibiting lower diversity. The effect of negative intensity on TTR is less clear

# -------------------------------#
# 10. CONCLUSIONS
#     Author: David Nguyen
# -------------------------------#
# After performing several statistical tests and visualizations, our group conclude that:
#   - The t-tests confirmed statistically significant differences between Negative and Positive reviews:
#         * Negative reviews have lower lexical diversity (lower TTR)
#         * Negative reviews have higher negative sentiment intensity
#   - The regression model further demonstrates that review sentiment is a significant predictor 
#     of TTR, even though the contribution of negative intensity is less pronounced
cat("\nConclusions:\n")
cat("- T-test results determine that both lexical diversity (TTR) and negative sentiment intensity differ significantly between review groups.\n")
cat("- The regression model confirms that review sentiment (Negative vs. Positive) significantly influences TTR.\n")
cat("- Visualizations further support these findings by showing clear distributional differences.\n")
