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