# global.R

# uncomment if you need to install rsconnect (used to deploy to shinyapps.io)
# install.packages("rsconnect")
# install.packages("arrow")
# loading libraries
library(shiny)
library(shinydashboard)
library(tidyverse)
library(leaflet)
library(sf)
library(tigris)
library(spData)
library(plotly)
library(lubridate)
library(scales)
library(RColorBrewer)
library(rsconnect)
library(arrow)
library(stringr)


# loading in the summary data
summary_data <- readRDS("summary_data.rds")

# extracting the data from the list
borough_choices               <- summary_data$borough_choices
complaint_type_choices        <- summary_data$complaint_type_choices
summary_stats_time            <- summary_data$summary_stats_time
heatmap_summary               <- summary_data$heatmap_summary
top_complaints_summary        <- summary_data$top_complaints_summary
aggregated_response_all       <- summary_data$aggregated_response_all
aggregated_response_by_complaint <- summary_data$aggregated_response_by_complaint
response_time_trend_all       <- summary_data$response_time_trend_all
response_time_trend_by_complaint <- summary_data$response_time_trend_by_complaint
requests_by_source_summary    <- summary_data$requests_by_source_summary
division_summary              <- summary_data$division_summary
top_parks_summary             <- summary_data$top_parks_summary
nyc_map_data                  <- summary_data$nyc_map_data
nyc_boroughs                  <- summary_data$nyc_boroughs

