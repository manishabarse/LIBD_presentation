# Data Wrangling in R

This repository contains R script, RMarkdown (`.Rmd`) files, and their HTML outputs that demonstrate key data wrangling techniques in R using the **tidyverse** suite of packages.

## Topics Covered

### 1. Reshaping Data
- `pivot_wider()`: Transform long data into wide format
- `pivot_longer()`: Transform wide data into long format
- `separate()`: Split a single column into multiple columns
- `unite()`: Combine multiple columns into a single column

### 2. Joining Tables
#### Mutating Joins
- `inner_join()`
- `right_join()`
- `left_join()`
- `full_join()`

#### Filtering Joins
- `semi_join()`
- `anti_join()`

### 3. Binding Rows and Columns
- `bind_cols()`: Combine data frames side by side
- `bind_rows()`: Stack data frames on top of each other

### 4. Set Operations
- `intersect()`: Common rows between datasets
- `union()`: All unique rows from both datasets
- `setdiff()`: Rows in one dataset but not in the other
- `setequal()`: Check if two datasets have the same rows, regardless of order

## Files
- `*.R` — R script with code examples
- `*.Rmd` — RMarkdown file containing code, output, and explanations
- `*.html` — Rendered HTML outputs from the RMarkdown files

## Usage
You can open and explore the `.Rmd` file in RStudio to interactively run and understand the code, or simply view the `.html` outputs for a static view.

---

> **Note**: All examples use packages from the `tidyverse`. Make sure to install it using `install.packages("tidyverse")` before running the code.
