library(tidyverse)
library(stringr)
library(shiny)
library(readr)
library(leaflet)
library(sf)
library(tigris)  
options(tigris_use_cache = TRUE)
library(spData)
data("us_states", package = "spData")

# commenting the below out for now because my dropbox account was flagged again... 

# # dropbox direct download link to access large file (+2gb)
# dataset_url <- "https://www.dropbox.com/scl/fi/os1x9i7sx1io5ura5fjti/311_DATA.csv?rlkey=quw01tcso6lz3u3vtx7seoalc&st=634psn3v&dl=1"
# 
# # read data directly from Dropbox
# data <- read_csv(dataset_url)

# using local data for now
data <- read_csv("311_DATA.csv")