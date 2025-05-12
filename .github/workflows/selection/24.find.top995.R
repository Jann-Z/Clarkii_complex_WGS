#### find 99.5th percentile ####
library(dplyr)

# Load the CSV file
df <- read.csv("AllSamples.uncalibrated.3pop_popgenWindows.w50m100.csv")
df <- na.omit(df)

# Function to filter top 0.5% and write to CSV
filter_top_1percent <- function(df, column) {
  # Ensure the column is numeric
  df[[column]] <- as.numeric(df[[column]])
  
  # Calculate the 99.5th percentile threshold
  threshold <- quantile(df[[column]], 0.995, na.rm = TRUE)
  
  # Filter rows that are above the threshold
  filtered_df <- df %>%
    filter(df[[column]] >= threshold) %>%
    select(scaffold, start, end, all_of(column))
  
  # Write the filtered data to a CSV file
  write.csv(filtered_df, paste0(column, ".995th.csv"), row.names = FALSE)
}

# Get the list of columns that start with pi, fst, or dxy
columns_of_interest <- grep("^(dxy|Fst|pi)", names(df), value = TRUE)

# Apply the filtering function for each column
lapply(columns_of_interest, function(col) filter_top_1percent(df, col))
