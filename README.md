# NYC 311 Complaints: Interactive Dashboard

An interactive Shiny dashboard exploring NYC 311 service requests created during 2024.

## Purpose

I built this dashboard to compare complaint types, reporting sources, agencies, geography, and response times across New York City, with additional attention to parks receiving the most submissions.

## Data source and preparation

The project uses the [NYC Open Data 311 Service Requests dataset](https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9/about_data), filtered to 2024. Because the extract contains more than three million rows, preprocessing performs cleaning, category assignment, time filtering, and aggregation before the app loads. The dashboard uses the resulting summary objects rather than recomputing every operation at runtime. Consult the NYC Open Data data dictionary for field definitions.

## Dashboard views

- **General Overview:** totals, unique types, sources, agencies, borough distribution, reporting methods, and agency summaries.
- **Top 10 Submissions:** most common submission types by borough.
- **Average Response Time:** response-time patterns by borough and over time.
- **Top 10 Park Submissions:** parks with the most submissions.

The dashboard was deployed to [shinyapps.io](https://sarahvon.shinyapps.io/NYC-311-DASHBOARD-SAMM/).

## Data notes and limitations

The 311 system includes complaints, requests, reports, and compliments; this README uses “submissions” for the full set. Coverage includes all five boroughs. Some fields are incomplete or unspecified, and response times depend on agency close-out recording. The dataset is updated over time, so results depend on the 2024 extract used for the dashboard.

## References

- [NYC 311 Service Requests](https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9)
- [Socrata Developer Portal](https://dev.socrata.com/)
- [RSocrata](https://cran.r-project.org/web/packages/RSocrata/RSocrata.pdf)

The dashboard's original team repository is [NYC-complaints](https://github.com/UWB-Adv-Data-Vis/NYC-complaints).
