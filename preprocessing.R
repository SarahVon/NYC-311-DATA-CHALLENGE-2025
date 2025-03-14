# preprocessing.R
# ------------------------------------------------------------------------------
# This script preprocesses the full NYC 311 dataset for 2024 and creates summary 
# variables that can be read in by our global.R file. The goal is to perform the 
# heavy computations (data cleaning, category assignment, and time-based 
# filtering) once so that the Shiny app can load lightweight, precomputed summary 
# data instead of processing the full dataset at runtime. This makes sure that 
# our results remain consistent with the full dataset while improving the app's 
# performance and ablity to be deployed to shinyapps.io (on the free tier).
# ------------------------------------------------------------------------------

# loading libraries
library(tidyverse)
library(lubridate)
library(sf)
library(tigris)
library(spData)
library(stringr)

# dropbox direct download link to read in RDS file
dataset_url <- "https://www.dropbox.com/scl/fi/ktz8ts2t0i4hfp8mj1sgv/311_DATA.rds?rlkey=rllw5u7iqr3ddm75wp6xe8yeh&st=v1t72f4u&dl=1"

# creating a temp file path with .rds extension
temp_file <- tempfile(fileext = ".rds")

# downloading RDS file in binary mode
download.file(dataset_url, destfile = temp_file, mode = "wb")

# reading in the new local file
data <- readRDS(temp_file)

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

# making sure we have consistent borough names
data <- data %>%
  mutate(Borough = case_when(
    Borough == "Richmond" ~ "Staten Island",
    Borough == "Kings" ~ "Brooklyn",
    Borough == "New York" ~ "Manhattan",
    TRUE ~ str_to_title(Borough)  
  ))

# make sure col names don't have spaces
colnames(data) <- gsub(" ", "_", colnames(data))

# storing the unique borough choices for later use in drop down menus
borough_choices <- unique(data$Borough)

# storing unique complaint types (for the complaint filter)
complaint_type_choices <- sort(unique(data$Complaint_Type))

# calculating the duration of each complaint and filtering out negative or zero durations
data$Duration <- as.numeric(data$Closed_Date - data$Created_Date)
data <- data %>% filter(Duration >= 0)
data$Duration[is.na(data$Duration)] <- 0

# creating a list of complaint categories (note: many of these could have
# been put into multiple categories, but for simplicity I used my best judgment
# to place them into a single category where I thought they best fit.)
complaint_categories <- list(
  
  # OTHER
  "Other" = c(
    "Lost Property",
    "Bench",
    "Incorrect Data",
    "Posting Advertisement",
    "Found Property",
    "GENERAL",
    "Squeegee"
  ),
  
  # CITY SERVICES & LOCAL BUSINESSES
  "City Services & Local Businesses" = c(
    "Food Establishment",
    "Day Care",
    "Borough Office",
    "Municipal Parking Facility",
    "Pet Shop",
    "Taxi Report",
    "Green Taxi Complaint",
    "AHV Inspection Unit",
    "New Tree Request",
    "Retailer Complaint",
    "Sanitation Worker or Vehicle Complaint",
    "Lifeguard",
    "Ferry Complaint",
    "Taxi Complaint",
    "Taxi Compliment",
    "LinkNYC",
    "Institution Disposal Complaint",
    "Transfer Station Complaint",
    "FHV Licensee Complaint",
    "Consumer Complaint",
    "Facade Insp Safety Pgm",
    "Building Marshals office",
    "Mobile Food Vendor",
    "Outdoor Dining",
    "Tattooing",
    "Bus Stop Shelter Complaint",
    "For Hire Vehicle Complaint",
    "Dispatched Taxi Complaint",
    "For Hire Vehicle Report",
    "Taxi Licensee Complaint",
    "Street Sweeping Complaint",
    "Homeless Person Assistance",
    "Calorie Labeling"
  ),
  
  # TRANSPORTATION & STREETS
  "Transportation & Streets" = c(
    "Traffic Signal Condition",
    "Street Condition",
    "Bridge Condition",
    "Street Light Condition",
    "Ferry Inquiry",
    "Derelict Vehicles",
    "Traffic",
    "Obstruction",
    "Abandoned Vehicle",
    "Bike/Roller/Skate Chronic",
    "Highway Condition",
    "Abandoned Bike",
    "Broken Parking Meter",
    "Street Sign - Damaged",
    "Street Sign - Dangling",
    "Street Sign - Missing",
    "Snow or Ice",
    "Highway Sign - Missing",
    "Highway Sign - Damaged",
    "Highway Sign - Dangling",
    "Bike Rack Condition",
    "Curb Condition",
    "Sidewalk Condition",
    "DEP Highway Condition",
    "DEP Sidewalk Condition",
    "Bus Stop Shelter Placement",
    "Tunnel Condition",
    "DEP Street Condition",
    "Bike Rack",
    "E-Scooter",
    "Root/Sewer/Sidewalk Condition",
    "Wayfinding"
  ),
  
  # PUBLIC SAFETY & CRIME
  "Public Safety & Crime" = c(
    "Illegal Fireworks",
    "Illegal Parking",
    "Blocked Driveway",
    "Emergency Response Team (ERT)",
    "Non-Emergency Police Matter",
    "Encampment",
    "Vendor Enforcement",
    "SAFETY",
    "Panhandling",
    "Drug Activity",
    "Animal-Abuse",
    "Violation of Park Rules",
    "Special Projects Inspection Team (SPIT)",
    "Real Time Enforcement",
    "Investigations and Discipline (IAD)",
    "Illegal Animal Sold",
    "Disorderly Youth",
    "Special Operations",
    "Dept of Investigations",
    "Executive Inspections",
    "Animal in a Park",
    "Illegal Dumping",
    "Urinating in Public",
    "Unleashed Dog",
    "Illegal Animal Kept as Pet",
    "Animal Facility - No Permit",
    "Illegal Tree Damage",
    "Scaffold Safety",
    "BEST/Site Safety",
    "Illegal Posting"
  ),
  
  # HOUSING & BUILDING
  "Housing & Building" = c(
    "HEAT/HOT WATER",
    "Elevator",
    "General Construction/Plumbing",
    "Lead",
    "Plumbing",
    "ELEVATOR",
    "OUTSIDE BUILDING",
    "PAINT/PLASTER",
    "Building/Use",
    "DOOR/WINDOW",
    "PLUMBING",
    "WATER LEAK",
    "Electrical",
    "FLOORING/STAIRS",
    "APPLIANCE",
    "Maintenance or Facility",
    "Boilers",
    "Cranes and Derricks",
    "Non-Residential Heat",
    "Building Drinking Water Tank",
    "Building Marshal's Office",
    "Stalled Sites",
    "Building Condition",
    "Construction Safety Enforcement",
    "School Maintenance",
    "Window Guard",
    "Leaning Bar",
    "ELECTRIC",
    "Cooling Tower",
    "Mold",
    "Asbestos"
  ),
  
  # SANITATION AND ENVIRONMENTAL
  "Sanitation and Environmental" = c(
    "Indoor Sewage",
    "Dead Animal",
    "Missed Collection",
    "UNSANITARY CONDITION",
    "Commercial Disposal Complaint",
    "Rodent",
    "Dirty Condition",
    "Drinking",
    "Residential Disposal Complaint",
    "Litter Basket Request",
    "Air Quality",
    "Graffiti",
    "Unsanitary Animal Pvt Property",
    "Dumpster Complaint",
    "Damaged Tree",
    "Lot Condition",
    "Special Natural Area District (SNAD)",
    "Indoor Air Quality",
    "Dead/Dying Tree",
    "Water Quality",
    "Hazardous Materials",
    "Water Conservation",
    "Unsanitary Pigeon Condition",
    "Food Poisoning",
    "Beach/Pool/Sauna Complaint",
    "Smoking or Vaping",
    "Litter Basket Complaint",
    "Wood Pile Remaining",
    "Recycling Basket Complaint",
    "Unsanitary Animal Facility",
    "Radioactive Material",
    "Poison Ivy",
    "Standing Water",
    "Mosquitoes",
    "Oil or Gas Spill",
    "X-Ray Machine/Equipment",
    "Sustainability Enforcement",
    "Smoking",
    "Tanning",
    "Seasonal Collection",
    "DSNY Internal",
    "Overgrown Tree/Branches",
    "Industrial Waste",
    "Uprooted Stump",
    "Plant",
    "Adopt-A-Basket",
    "Sewer",
    "Water System",
    "Drinking Water",
    "Public Toilet"
  ),
  
  # NOISE
  "Noise" = c(
    "Noise - Residential",
    "Noise - Commercial",
    "Noise - Park",
    "Noise - Street/Sidewalk",
    "Noise - House of Worship",
    "Noise",
    "Noise - Vehicle",
    "Noise - Helicopter"
  )
)

assign_category <- function(complaint_type) {
  for (category in names(complaint_categories)) {
    if (complaint_type %in% complaint_categories[[category]]) {
      return(category)
    }
  }
  # put in 'other' if not found in above categories
  return("Other") 
}

# adding a new column "Category" to the data
data <- data %>%
  mutate(Category = sapply(Complaint_Type, assign_category))

# setting a fixed reference date so time-based summaries remain consistent 
ref_date <- as.Date("2024-12-31")

# calculating 'Days_Ago' as the num of days from the creation date to the ref date.
data <- data %>%
  mutate(Days_Ago = as.numeric(ref_date - Created_Date))

# defining the end date and the start dates for each filter option.
end_date <- as.Date("2024-12-31")
time_frames <- list(
  "Past Month" = end_date - 30,
  "Past 3 Months" = end_date - 90,
  "Past 6 Months" = end_date - 180,
  "Past Year" = as.Date("2024-01-01")
)

# getting summary statistics for each time frame.
summary_stats_time <- map_dfr(names(time_frames), function(tf) {
  start_date <- time_frames[[tf]]
  d <- data %>% filter(Created_Date >= start_date & Created_Date <= end_date)
  tibble(
    Time_Frame = tf,
    Total_Requests = nrow(d),
    Unique_Complaint_Types = n_distinct(d$Complaint_Type),
    Unique_Sources = n_distinct(d$Open_Data_Channel_Type),
    Unique_Agencies = n_distinct(d$Agency_Name)
  )
})

# heatmap summary for each time frame, count complaints by Borough and Category.
heatmap_summary <- map_dfr(names(time_frames), function(tf) {
  start_date <- time_frames[[tf]]
  d <- data %>% filter(Created_Date >= start_date & Created_Date <= end_date)
  d %>%
    group_by(Borough, Category) %>%
    summarise(Count = n(), .groups = "drop") %>%
    mutate(Time_Frame = tf)
})

# getting the count of requests by source category for each time frame
requests_by_source_summary <- map_dfr(names(time_frames), function(tf) {
  start_date <- time_frames[[tf]]
  d <- data %>% filter(Created_Date >= start_date & Created_Date <= end_date)
  d %>%
    mutate(SourceCategory = case_when(
      Open_Data_Channel_Type %in% c("UNKNOWN", "OTHER") ~ "OTHER",
      Open_Data_Channel_Type == "ONLINE" ~ "WEBSITE",
      Open_Data_Channel_Type == "PHONE"  ~ "PHONE CALL",
      Open_Data_Channel_Type == "MOBILE" ~ "MOBILE APP",
      TRUE ~ as.character(Open_Data_Channel_Type)
    )) %>%
    group_by(SourceCategory) %>%
    summarise(Count = n(), .groups = "drop") %>%
    mutate(Time_Frame = tf)
})

# getting the top 5 agencies with the most complaints for each time frame
division_summary <- map_dfr(names(time_frames), function(tf) {
  start_date <- time_frames[[tf]]
  d <- data %>% filter(Created_Date >= start_date & Created_Date <= end_date)
  # group by Agency_Name, keep top 5
  summary_df <- d %>%
    group_by(Agency_Name) %>%
    summarise(Count = n(), .groups = "drop") %>%
    arrange(desc(Count))
  top5 <- summary_df[1:5, ]
  total_requests <- sum(top5$Count)
  
  top5 %>%
    mutate(
      Percent = (Count / total_requests) * 100,
      Time_Frame = tf
    )
})

# getting top 10 complaints data for each Borough for our summary file
top_complaints_summary <- data %>%
  group_by(Borough, Complaint_Type) %>%
  summarise(Count = n(), .groups = "drop") %>%
  arrange(Borough, desc(Count)) %>%
  group_by(Borough) %>%
  slice_max(Count, n = 10) %>%
  ungroup()

# precompute overall daily avg response times for all complaints 
response_time_trend_all <- data %>%
  group_by(Created_Date, Borough) %>%
  summarise(Average_Duration = mean(Duration, na.rm = TRUE), Count = n(), .groups = "drop")

aggregated_response_all <- data %>%
  group_by(Borough) %>%
  summarise(Average_Duration = mean(Duration, na.rm = TRUE), Count = n(), .groups = "drop")

# precomputing daily averages by complaint type (for when a specific complaint filter is used)
response_time_trend_by_complaint <- data %>%
  group_by(Created_Date, Borough, Complaint_Type) %>%
  summarise(Average_Duration = mean(Duration, na.rm = TRUE), Count = n(), .groups = "drop")

aggregated_response_by_complaint <- data %>%
  group_by(Borough, Complaint_Type) %>%
  summarise(Average_Duration = mean(Duration, na.rm = TRUE), Count = n(), .groups = "drop")

# counting complaints per Park_Facility_Name (ignoring blanks and "Unspecified") and keep the top 10.
top_parks_summary <- data %>%
  filter(!is.na(Park_Facility_Name),
         Park_Facility_Name != "",
         Park_Facility_Name != "Unspecified") %>%
  group_by(Park_Facility_Name, Borough) %>%
  summarise(n = n(), .groups = "drop") %>%
  arrange(desc(n)) %>%
  slice_max(n, n = 10)

# loading spatial data for New York State and extract the NYC borough boundaries.
nyc_map_data <- spData::us_states %>% filter(NAME == "New York")
nyc_boroughs <- tigris::counties(state = "NY", cb = TRUE) %>%
  filter(NAME %in% c("Bronx", "Kings", "New York", "Queens", "Richmond")) %>%
  mutate(NAME = case_when(
    NAME == "Kings" ~ "Brooklyn",
    NAME == "New York" ~ "Manhattan",
    NAME == "Richmond" ~ "Staten Island",
    TRUE ~ NAME
  ))

# combining all precomputed objects into a list. This summary list will be loaded by
# global.R in the Shiny app so that interactive filters can quickly retrieve precomputed values.
# ... that's the goal any way
summary_data <- list(
  borough_choices = borough_choices,
  complaint_type_choices = complaint_type_choices,
  summary_stats_time = summary_stats_time,
  heatmap_summary = heatmap_summary,
  top_complaints_summary = top_complaints_summary,
  aggregated_response_all = aggregated_response_all,
  aggregated_response_by_complaint = aggregated_response_by_complaint,
  response_time_trend_all = response_time_trend_all,
  response_time_trend_by_complaint = response_time_trend_by_complaint,
  requests_by_source_summary = requests_by_source_summary,
  division_summary = division_summary,
  top_parks_summary = top_parks_summary,
  nyc_map_data = nyc_map_data,
  nyc_boroughs = nyc_boroughs
)

# saving the summary data to an RDS file
saveRDS(summary_data, "summary_data.rds")


