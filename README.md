# NYC-complaints
[Replace this page with your README]
This is the data dashboard challenge for the Winter 2025 BIS 412 Advanced Data Visualization course. The challenge uses data from New York City's 311 complaint data to visualize the temporal and spatial aspects of common issues raised by residents.

# Overview

Challenge created by and made for the BIS 412 Advanced Data Visualization course at the University of Washington Bothell.

- 📊 Challenge created by and made for the Winter 2025 BIS 412 Advanced Data Visualization course at the University of Washington Bothell.
- ✍️ Authored by Yared A, Sakaria D, and Mohamed M 
- 🔍 Challenge review committee: Yared A., 
- 🔍 Committee chair: Yared A.
- 🛠️ Edited and supervised by Prof. Caleb Trujillo

# Description

The challenge is to develop an interactive dashboard that analyzes NYC 311 service requests from NYCOpenData. 
This dashboard's objective is to use historical and real-time data visualizations to give relevant insights to various stakeholders. By showing patterns and trends in service requests, decision-makers may improve response processes, allocate resources more efficiently, and identify problem areas. Stakeholders are city officials, government agencies, community leaders, and residents.
The dashboards aim to present exploratory data analysis or narrative-driven insights through visual media. 

## The tasks to address our challenge have two options:

### Challenge A: Exploratory visualization

Create a platform that gives a broad overview of the data and supports user choice to explore specifics and details.

-    Make an interactive dashboard.
-    Create descriptive and comparison displays that enable users to filter the most common complaints overall by complaint type (using a reactive feature), borough, agency, time of day, day of week, or month  
-    Display comparisons over successive years to show the leading variables in car accidents
-    Provide a geographical map of where filtered complaints occur

### Challenge B: Storytelling through visualization
Create a platform that focuses on an issue, problem, or question, invites users to learn more, and presents specifics and details through user interactions.

–    Identify a central question or issue to tell a data-driven story about complaints
-    Create an interactive dashboard that leads users through a story
-    Find correlations and co-occurrences of different variables
-    Provide insights into the missing data
-    Enable users to download their data and images after their interactions.

### Example Analytical Questions
The visual analytics techniques implemented in this dashboard should address the following questions:

- Complaint Trends:
    - What are the most common types of complaints in NYC in 2024?
    - How do these complaint types vary across boroughs and change month by month?
- Response Times:
    - How long does it usually take to close or review a request?
    - Are there variations in response times based on complaint type, borough, or the agency involved?
- Agency Involvement: Which agency receives the most 311 requests, and what complaints do they handle most frequently?
- Communication Channels: What is the most common method  by which residents submit their 311 requests?
- Temporal Patterns: When are most service requests submitted throughout the day?

By answering these questions in an exploratory or narrative fashion, the dashboard helps uncover service bottlenecks and inefficiencies while equipping stakeholders with the insights they need to take targeted action. With this data, they can implement strategic improvements to streamline operations and enhance efficiency.
 
# Proposed Project Plan

The project will span 2-3 weeks with the following phases and tasks:

1. Data Exploration & Design Ideation
-	Data Import
  -	Import the 311 dataset using an API or RSocratic with a filter to dates in the last year to represent
  - Clean the pre-processing of the data (e.g., parsing dates for created_date and closed_date).
- Initial Sketch
    - Identify with a purpose
    - Brainstorm and sketch initial dashboard layouts
    - Define key metrics and determine which visualizations best address the purpose
- Meetings:
  -	Discuss roles and responsibilities and set communication channels among team members.
2. Visualization Prototyping
  -	Great rough ggplots
  -	Iterative feedback
3. Dashboard Build & Integration
    - Dashboard Development:
        - Integrate the refined visualizations into an interactive dashboard framework. 
        - Develop interactive filtering and drill-down capabilities.
        - User Interface & Aesthetics:
        - Focus on the dashboard's overall layout, color schemes, and responsiveness.
        - Incorporate the sidebar with filtering options and a dynamic header.     
4. Testing, Feedback, and Deployment
- User Testing & Feedback Collection:
    - Share the dashboard with a small group of target users (stakeholders, peers) to collect feedback on usability and insights.
    - Identify and fix any bugs or usability issues.
- Final Adjustments & Deployment:
    - Finalize the dashboard design, ensuring all visualizations and interactive elements work as intended.
    - Deploy the dashboard on a hosting platform and ensure the live data connection functions.
- Documentation & Final Presentation:
    - Document the design process, coding decisions, and any challenges faced.
    - Prepare a final presentation outlining the project’s insights and outcomes.
 
Possible Team Roles

-	Everyone: Develop one original graphic data visualization
-	Project Manager: Oversees the timeline, Git teams, and Issues and coordinates group meetings.
-	Data Analyst/Engineer: Handles data cleaning, transformation, and calculations.
-	Visualization Specialist: Supports static and interactive visualizations.


# Background
## Data Biography
The dataset used for this challenge is the "311 Service Requests from 2010 to Present" dataset provided by NYC OpenData. Updated daily, this comprehensive dataset includes over 39 million rows, each representing a unique service request (filtered here to focus on 2024). For this analysis, we are concentrating on a subset of fields critical for understanding and mapping car-related issues and broader service request trends:

- Address Type, City, and Landmark: These fields help categorize the location and context of the service request.
- Status & Due Date: Provide insights into the progress and timeliness of service resolution.
- Borough & Incident Zip: Essential for geographic visualization and borough-level comparisons.
- Open Data Channel Type: Indicates how requests are submitted, which helps understand citizen engagement.
- Vehicle Type & Agency: Offer details on the nature of the complaint and the responsible agency.
- Complaint Type & Descriptor: These fields form the basis for analyzing the nature of the issues reported.
- Unique Key, Created Date, Closed Date, Resolution Description: Serve as identifiers and time stamps to calculate response times and track the lifecycle of each request.
  
The dataset is invaluable for public sector analysis, providing real-time insights into community needs and government responsiveness. It supports evidence-based decision-making for improving service delivery and urban management in NYC.

## Resources
Given the size of the data and the different platforms available, the OpenNewYork offers several ways to access it. Some pathways are listed below:

- **OData** options <https://support.socrata.com/hc/en-us/articles/115005364207-Access-Data-Insights-Data-using-OData>
- **Socrata** documentation <https://dev.socrata.com/>
    - Getting started <https://dev.socrata.com/consumers/getting-started.html>
- **RSocrata** package <https://cran.r-project.org/web/packages/RSocrata/RSocrata.pdf>
    - Examples <https://rpubs.com/briankusiak/lab_ex_1>
    - First 100 rows
    - `data <- read.socrata("https://data.cityofnewyork.us/resource/erm2-nwe9.json?$limit=100")`

## References
311 (2025) 311 service requests from 2010 to present: NYC Open Data, 311 Service Requests from 2010 to Present | NYC Open Data. Available at: https://data.cityofnewyork.us/Social-Services/311-Service-Requests-from-2010-to-Present/erm2-nwe9 (Accessed: 13 February 2025). 
Andrews, C. (2024) From calls to insights: Analyzing service requests in Calgary, Medium. Available at: https://medium.com/@carolyn.A13/from-calls-to-insights-analyzing-311-service-requests-in-calgary-bc24d917d5c9 (Accessed: 13 February 2025). 
