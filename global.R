library(tidyverse)
library(stringr)
library(shiny)
library(readr)
library(leaflet)
library(sf)
library(tigris)  
options(tigris_use_cache = TRUE)
library(spData)
library(plotly)
data("us_states", package = "spData")
library(lubridate)

# commenting the below out for now because my dropbox account was flagged again... 

# # dropbox direct download link to access large file (+2gb)
# dataset_url <- "https://www.dropbox.com/scl/fi/os1x9i7sx1io5ura5fjti/311_DATA.csv?rlkey=quw01tcso6lz3u3vtx7seoalc&st=634psn3v&dl=1"
# 
# # read data directly from Dropbox
# data <- read_csv(dataset_url)

# using local data for now
data <- read_csv("311_DATA.csv")

# splitting 'Created Date' into separate date and time columns
data <- data %>%
  mutate(`Created Date Only` = as.Date(`Created Date`, format = "%m/%d/%Y"),
         `Created Time Only` = format(strptime(`Created Date`, format = "%m/%d/%Y %I:%M:%S %p"), "%H:%M:%S"))

# splitting 'Closed Date' into separate date and time columns
data <- data %>%
  mutate(`Closed Date Only` = as.Date(`Closed Date`, format = "%m/%d/%Y"),
         `Closed Time Only` = format(strptime(`Closed Date`, format = "%m/%d/%Y %I:%M:%S %p"), "%H:%M:%S"))

# selecting only the necessary columns
data <- data %>%
  select(
    `Created Date Only`,
    `Closed Date Only`,
    `Created Time Only`,
    `Closed Time Only`,
    `Agency Name`,
    `Complaint Type`,
    `Descriptor`,
    `Location Type`,
    `Incident Zip`,
    `Incident Address`,
    `Status`,
    `Resolution Description`,
    `Borough`,
    `Street Name`,
    `City`,
    `Park Facility Name`,
    `Open Data Channel Type`,
    `Latitude`,
    `Longitude`,
    `Location`
  )

# renaming the new cols back to the original names so the code them doesn't break
data <- data %>%
  rename(
    Created_Date = `Created Date Only`,
    Closed_Date = `Closed Date Only`,
    Created_Time = `Created Time Only`,
    Closed_Time = `Closed Time Only`
  )

# converting "N/A" strings to proper NA values across all columns
data <- data %>% mutate(across(where(is.character), ~ na_if(., "N/A")))

# making sure there are no rows with missing Borough values
data <- data %>% filter(!is.na(Borough) & Borough != "")

# make sure col names don't have spaces
colnames(data) <- gsub(" ", "_", colnames(data))

# getting NYC borough data
nyc_map_data <- us_states %>% filter(NAME == "New York")

nyc_boroughs <- counties(state = "NY", cb = TRUE) %>%
  filter(NAME %in% c("Bronx", "Kings", "New York", "Queens", "Richmond")) %>%
  mutate(NAME = case_when(
    NAME == "Kings" ~ "Brooklyn",
    NAME == "New York" ~ "Manhattan",
    NAME == "Richmond" ~ "Staten Island",
    TRUE ~ NAME
  ))

# storing borough choices for dropdown
borough_choices <- unique(data$Borough)

# creating duration variable
data$Duration <- as.numeric(data$Closed_Date - data$Created_Date)

# removing rows where Duration is negative or NA
data <- data %>%
  filter(Duration >= 0)

# handling any NA values
data$Duration[is.na(data$Duration)] <- 0

