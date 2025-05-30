# Load required libraries
library("nycflights13")  # for data
library("tidyverse")     # for data manipulation (includes dplyr, tidyr)

# Check the structure of the flights dataset
glimpse(flights)

# ============================================================================
# 1. RESHAPING DATA
# ============================================================================

# delays by month and carrier:
monthly_delays <- flights |>
  filter(!is.na(arr_delay)) |>
  group_by(month, carrier) |>
  summarise(
    avg_delay = mean(arr_delay),
    .groups = "drop"
  )

print(monthly_delays)
# This is a "long" format: each row = a month-carrier pair

# pivot_wider use case:
# a table that has one row per month and one column per carrier's average delay
wide_delays <- monthly_delays |>
  pivot_wider(
    names_from = carrier,
    values_from = avg_delay
  )

print(wide_delays)


# Reverse operation: wide table back to long:
long_delays <- wide_delays |>
  pivot_longer(
    cols = -month,
    names_to = "carrier",
    values_to = "avg_delay"
  )

print(long_delays)
# collapses multiple columns into key-value pairs

# --------------- separate() ---------------
datetime_example <- flights |>
  select(time_hour) |>
  slice(1:5) |>
  mutate(time_hour_char = as.character(time_hour))

print(datetime_example)

# separate() splits a column into multiple columns by a separator
datetime_separated <- datetime_example |>
  separate(
    col = time_hour_char,
    into = c("date", "time"),
    sep = " "
  )

print(datetime_separated)

# --------------- unite() ---------------
flights |> select(year, month, day)

date_united <- flights |>
  select(year, month, day) |>
  slice(1:5) |>
  unite(
    col = "date",
    year, month, day,
    sep = "-"
  )

print(date_united)


date_united <- flights |>
  slice(1:5) |>
  mutate(
    year = as.character(year),
    month = sprintf("%02d", month),
    day = sprintf("%02d", day)
  ) |>
  unite(col = "date", year, month, day, sep = "-") |>
  select(date)

print(date_united)


# --- Summary ---
# pivot_wider(): Long -> Wide (spread key-value pairs into multiple columns)
# pivot_longer(): Wide -> Long (collapse multiple columns into key-value pairs)
# separate(): Split one column into multiple columns by separator
# unite(): Combine multiple columns into one column, joining by separator


# ============================================================================
# 2. JOINING TABLES
# ============================================================================
# - flights: flight-level data
# - airlines: carrier codes and full names

# airlines data:
print(head(airlines))

# flights data (select a few columns):
print(head(flights |> select(year, month, day, carrier, flight)))

# --- MUTATING JOINS ---
# These join columns from another table to the original

# INNER JOIN: keep only rows that have matching keys in both tables

inner_join_example <- flights |>
  select(year, month, day, carrier, flight) |>
  inner_join(airlines, by = "carrier") |>
  slice(1:10)

print(inner_join_example)

# Keeps only flights with carriers present in airlines.
# 'name' column from airlines is added.

## error case
flights |>
  select(year, month, day, flight) |>
  inner_join(airlines) # use 'by' and common column


# LEFT JOIN: keep all rows from left table, add matching columns from right, fill unmatched with NA

left_join_example <- flights |>
  select(year, month, day, carrier, flight) |>
  left_join(airlines, by = "carrier") |>
  slice(1:10)

print(left_join_example)
anyNA(left_join_example)

flights_extra <- flights |>
  select(year, month, day, carrier, flight) |>
  slice(1:5) |>
  mutate(carrier = c("AA", "ZZ", "DL", "XX", "UA"))

result <- flights_extra |>
  left_join(airlines, by = "carrier")

print(result) ## NAs present

## replace
result <- flights_extra |>
  left_join(airlines, by = "carrier") |>
  mutate(name = replace_na(name, "Unknown carrier"))

print(result)

# RIGHT JOIN: keep all rows from right table, add matching columns from left

right_join_example <- flights_extra |>
  select(year, month, day, carrier, flight) |>
  right_join(airlines, by = "carrier")

print(head(right_join_example))

# All airlines kept, even if no flights for that carrier.
# Flights info may be NA if no match.
right_join_example <- flights |>
  select(year, month, day, carrier, flight) |>
  right_join(airlines, by = "carrier")

print(head(right_join_example))

# FULL JOIN: keep all rows from both tables, fill NA where no match

full_join_example <- flights_extra |>
  select(year, month, day, carrier, flight) |>
  full_join(airlines, by = "carrier")

print(head(full_join_example))

# Explanation:
# Combines all flights and airlines.
# Flights with unknown carriers or airlines without flights get NA in missing columns.


# --- FILTERING JOINS ---
# Filter rows in one table based on presence/absence in another

# Semi join: keep rows in flights where carrier exists in airlines

semi_join_example <- flights_extra |>
  select(year, month, day, carrier, flight) |>
  semi_join(airlines, by = "carrier") |>
  slice(1:10)

print(semi_join_example)

# Anti join: keep rows in flights where carrier does NOT exist in airlines

anti_join_example <- flights_extra |>
  select(year, month, day, carrier, flight) |>
  anti_join(airlines, by = "carrier") |>
  distinct(carrier)

print(anti_join_example)

# Explanation:
# anti_join finds carriers not in airlines 

anti_join_example <- flights |>
  select(year, month, day, carrier, flight) |>
  anti_join(airlines, by = "carrier") |>
  distinct(carrier)

print(anti_join_example) # empty


# ## Comparing to base R functions:
df <- as.data.frame(flights)
al <- as.data.frame(airlines)

# --- JOINS ---
# Inner join
inner_merge <- merge(df, al, by = "carrier")

# Left join
left_merge <- merge(df, al, by = "carrier", all.x = TRUE)
head(left_merge)
# Right join
right_merge <- merge(df, al, by = "carrier", all.y = TRUE)
head(right_merge)
# Full join
full_merge <- merge(df, al, by = "carrier", all = TRUE)
# 
# # Tidyverse joins
inner_join_result <- inner_join(df, al, by = "carrier")
left_join_result <- left_join(df, al, by = "carrier")
right_join_result <- right_join(df, al, by = "carrier")
full_join_result <- full_join(df, al, by = "carrier")


# ============================================================================
# 3. BINDING
# ============================================================================

# By rows (rbind): stacking datasets with same columns

flights_jan <- flights |>
  filter(month == 1) |>
  slice(1:5)

flights_feb <- flights |>
  filter(month == 2) |>
  slice(1:5)

# Bind rows - combines the two smaller datasets vertically

bind_rows_example <- bind_rows(flights_jan, flights_feb)

print(bind_rows_example)

flights_jan_extra <- flights_jan |>
  mutate(extra_col = "extra")  # add a new column

# Bind rows with different columns

bind_rows_extra <- bind_rows(flights_jan, flights_jan_extra) |>
  slice(1:5)
bind_rows_extra$extra_col


# By columns (cbind): side-by-side combining datasets with same number of rows

# Select two datasets with same number of rows:

df1 <- flights_jan |> select(year, month, day)
df2 <- flights_jan |> select(carrier, flight, tailnum)

bind_cols_example <- bind_cols(df1, df2)
print(bind_cols_example)


# rbind: works only if both data frames have exactly the same columns
rbind_example <- rbind(flights_jan, flights_feb)
print(rbind_example)

rbind(flights_jan, flights_jan_extra) ## error
bind_rows_example2 <- bind_rows(flights_jan, flights_jan_extra)
print(bind_rows_example2)
anyNA(bind_rows_example2)

cbind_example <- cbind(df1, df2)
print(cbind_example)

df_short <- flights_jan |> select(carrier) |> slice(1:3)
cbind_mismatch <- cbind(df1, df_short) ## error
bind_cols(df1, df_short) #error

cbind(a = 1:5, b = 1:3)# recycles: caution
bind_cols(a=1:5,b=1:3)# error


# ============================================================================
# 4. SET OPERATORS
# ============================================================================
# Create two small flight subsets with some overlap:

flights1 <- flights |>
  filter(month == 1, day <= 10) |>
  select(year, month, day, carrier, flight)

flights2 <- flights |>
  filter(month == 1, day >= 5, day <= 15) |>
  select(year, month, day, carrier, flight)

# INTERSECT: rows common to both

intersect_example <- intersect(flights1, flights2)
print(intersect_example)

# UNION: all unique rows from both

union_example <- union(flights1, flights2)
print(union_example)

# SET DIFF: rows in flights1 not in flights2

setdiff_example <- setdiff(flights1, flights2)
print(setdiff_example)

# SET EQUAL: check if sets are identical

setequal_example <- setequal(flights1, flights2)
print(setequal_example)
