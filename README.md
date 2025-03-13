# NYC 311 Complaints: Interactive Dashboard
  
**Course:** BIS 412 Advanced Data Visualization (Winter 2025, University of Washington Bothell)  
**Challenge:** A (Exploratory Visualization)

**Authors (Team):**

* Sarah Anderson [@sarahvon](https://github.com/SarahVon)
* Mia Keane [@mkeane0202](https://github.com/mkeane0202)
* Aryana Villafuerte [@4ryana](https://github.com/4ryana)
* May Benisa [@maybenisa](https://github.com/maybenisa)


## Table of Contents

- [Project Overview](#project-overview)
- [Data Source and Access](#data-source-and-access)
- [Dashboard Description](#dashboard-description)
- [How to View the Dashboard](#how-to-view-the-dashboard)
- [Data Biography](#data-biography)
- [References and Additional Resources](#references-and-additional-resources)

---

## Project Overview

This repository contains our **interactive Shiny dashboard** exploring **NYC 311 
service requests** filtered for the year 2024. Our goal is to provide a broad 
overview of complaint types, geographic distributions, and response times, 
allowing users to explore patterns and trends in a user-friendly fashion. 
This work is part of our BIS 412 Advanced Data Visualization course challenge 
(Challenge A: Exploratory Visualization).

**NOTE:** The NYC 311 system collects a wide range of information from citizens—including 
complaints, requests, reports, and even *compliments*. For the remainder of this 
README, we will refer to these entries as **"submissions**."

### Primary Dashboard Features: 
* Top 10 submission types by borough  
* Summary statistics on submission types, sources, and agencies
* Temporal trends in submission volume
* Geospatial distribution of submissions
* Response times by submission type
* Top 10 NYC Parks with the most submissions

We built this dashboard using **Shiny, Tidyverse, Leaflet, Plotly,** and other packages. 

---

## Data Source and Access

The data used in this project is sourced from the [NYC Open Data](https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9/about_data)

1. **Filtering for 2024**
We used NYC Open Data’s “Query Data” feature (found under the “Actions” button 
on the dataset’s page) to filter submissions *Created Date* for the year 2024 only. 
That produced a file with over 3 million rows.

2. **Exporting & Hosting**
Because GitHub’s size limits prevent hosting multi-gigabyte files, we stored 
the dataset on Dropbox. We then modified our Dropbox share link to create a direct 
download URL, which allowed our Shiny app to read the CSV file dynamically.
    + **Example of Converting a Dropbox Share Link to a Direct Download URL:**  
         - Suppose your Original Dropbox share link is: 
         `https://www.dropbox.com/s/abc123/311_data.csv?**dl=0`  
      
            To force a *direct download*, change the **`dl=0`** parameter to **`dl=1`**:   
      
         - Direct Download URL: `https://www.dropbox.com/s/abc123/311_data.csv?dl=1`  



---

## Dashboard and Description

The challenge is to develop an interactive dashboard that analyzes NYC 311 service requests from NYCOpenData. 
This dashboard's objective is to use historical and real-time data visualizations to give relevant insights to viewers. 

This is the data dashboard challenge for the Winter 2025 BIS 412 Advanced Data 
Visualization course. The challenge uses data from New York City's 311 complaint 
data to visualize the temporal and spatial aspects of common issues raised by 
residents.

---

## How to View the Dashboard

---

## Data Biography

---

## References and Additional Resources

For more details on the different challenges and to see the original repository, 
please visit the [original NYC-complaints repository](https://github.com/UWB-Adv-Data-Vis/NYC-complaints).





