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



## Project Overview

This repository contains our **interactive Shiny dashboard** exploring **NYC 311 
service requests** filtered for the year 2024. Our goal is to provide a broad 
overview of complaint types, geographic distributions, and response times, 
allowing users to explore patterns and trends in a user-friendly fashion. 
This work is part of our BIS 412 Advanced Data Visualization course challenge 
(Challenge A: Exploratory Visualization).

**NOTE:** The NYC 311 system collects a wide range of information from citizens—including 
complaints, requests, reports, and even *compliments*. For the remainder of this 
README, we will refer to these entries as **"submissions**"

### Primary Dashboard Features: 
* Top 10 submission types by borough  
* Summary statistics on submission types, sources, and agencies
* Temporal trends in submission volume
* Geospatial distribution of submissions
* Response times by submission type
* Top 10 NYC Parks with the most submissions

We built this dashboard using **Shiny, Tidyverse, Leaflet, Plotly,** and other packages. 



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

3. **Data Dictionary**   
The NYC Open Data Portal provides a Data Dictionary (provided in the repository) explaining each 
field (e.g., Complaint Type, Borough, Created Date, etc.). We consulted it to clarify variable 
definitions and to make sure we were consistently interpreting the data correctly.



## Dashboard and Description

Our Shiny dashboard contains multiple tabs, each focusing on variable aspects of the NYC 311 Data.

1. **About**  
   This tab provides a brief overview of the dataset and the dashboard's purpose.

2. **General Overview**  
   This tab offers a general overview of the dataset, filterable by date ranges, and includes:
   - Total submissions, number of unique submission types, sources, and agencies
   - A heat map showing the distribution and counts of submissions across NYC boroughs
   - A horizontal bar chart displaying the number of submissions by method of reporting (online, phone, etc.)
   - A donut chart showing the distribution of submissions by agency (who is responsible for addressing the submission)

3. **Top 10 Submissions**  
   This tab highlights the top 10 most common submission types based on Borough, and includes:
   - Filtering by borough
   - A horizontal bar chart showing the top 10 submission types
   - A map highlighting the different boroughs of NYC.

4. **Average Response Time**  
   This tab displays response time by borough and over time.

5. **Top 10 Park Submissions**  
   This tab focuses on the NYC parks with the highest number of submissions. 





## How to View the Dashboard



## Data Biography



## References and Additional Resources

For more details on the different challenges and to see the original repository, 
please visit the [original NYC-complaints repository](https://github.com/UWB-Adv-Data-Vis/NYC-complaints).





