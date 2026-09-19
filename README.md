# NYC 311 Complaints: Interactive Dashboard
   
**Challenge:** Exploratory Visualization

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

_**NOTE:**_ The NYC 311 system collects a wide range of information from citizens—including 
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
Because GitHub’s size limits prevent hosting multi-gigabyte files, we stored the 
dataset on Dropbox. We then modified our Dropbox share link to create a direct 
download URL, which allowed our Shiny app to read the data dynamically.
    + **Example of Converting a Dropbox Share Link to a Direct Download URL:**  
         - Suppose your Original Dropbox share link is: 
         `https://www.dropbox.com/s/abc123/311_data.csv?**dl=0`  
      
            To force a *direct download*, change the **`dl=0`** parameter to **`dl=1`**:   
      
         - Direct Download URL: `https://www.dropbox.com/s/abc123/311_data.csv?dl=1`  

3. **Data Cleaning & Preparation**  
To improve performance and ensure our app can be deployed on shinyapps.io, we 
created a new script (**preprocessing.R**) that performs all heavy computations—data 
cleaning, category assignment, and time-based filtering—once, rather than doing 
them at runtime. This script downloads the data from Dropbox in RDS format by 
creating a temporary file, downloading in binary mode, and reading that file. 
It then computes all the necessary summary statistics and aggregates, storing 
the results in a file called **summary_data.rds**. Our **global.R** file then 
loads this summary file so that the Shiny app works solely with these precomputed 
summary objects. This method maintains data integrity while drastically reducing 
file size and improving dashboard responsiveness.

4. **Data Dictionary**   
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
This dashboard was deployed to shinyapps.io and can be accessed using the following link:  
[**NYC 311 Data Dashboard - Team SAMM**](https://sarahvon.shinyapps.io/NYC-311-DASHBOARD-SAMM/)


## Data Biography

The **311 Service Requests from 2010 to Present** dataset is maintained by NYC Open Data and updated daily. Each row represents a unique complaint or service request submitted by NYC residents.

- **Temporal Coverage:** We specifically used 2024 data.  
- **Geographic Coverage:** All five NYC boroughs (Manhattan, Brooklyn, Queens, The Bronx, Staten Island).  
- **Size:** 3+ million rows for 2024 alone.  
- **Data Fields:** Key fields include `Complaint_Type`, `Borough`, `Created_Date`, `Closed_Date`, `Park_Facility_Name`, `Open_Data_Channel_Type`, and more.  
- **Uses:** Government agencies, city planners, and the public can track issues and allocate resources.  
- **Limitations:** Some requests may contain incomplete or “Unspecified” data. Response time can be affected by how agencies record close-out dates.


## References and Additional Resources

- **NYC Open Data Portal**  
  - [311 Service Requests from 2010 to Present](https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9)
- **NYC 311 Data Dictionary**  
  Provided under “Attachments” on the dataset page or in this repository (`311_Data_Dictionary.xlsx`).
- **Socrata / RSocrata**  
  - [Socrata Developer Portal](https://dev.socrata.com/)  
  - [RSocrata R Package](https://cran.r-project.org/web/packages/RSocrata/RSocrata.pdf)


For more details on the different challenges and to see the original repository, 
please visit the [original NYC-complaints repository](https://github.com/UWB-Adv-Data-Vis/NYC-complaints).


**CITATIONS**  

- **311 (2025)**  
  *311 Service Requests from 2010 to Present: NYC Open Data, 311 Service Requests from 2010 to Present | NYC Open Data.*  
  Available at: [https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9](https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9)  
  (Accessed: 13 February 2025).

- **Andrews, C. (2024)**  
  *From calls to insights: Analyzing service requests in Calgary, Medium.*  
  Available at: [https://medium.com/@carolyn.A13/from-calls-to-insights-analyzing-311-service-requests-in-calgary-bc24d917d5c9](https://medium.com/@carolyn.A13/from-calls-to-insights-analyzing-311-service-requests-in-calgary-bc24d917d5c9)  
  (Accessed: 13 February 2025).





