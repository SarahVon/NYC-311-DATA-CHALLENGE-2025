# ui.R

# creating a header for the dashboard
header <- dashboardHeader(title = "311 Data Dashboard")

# creating a sidebar for the dashboard for page navigation
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("About", tabName = "About", icon = icon("info-circle")),
    menuItem("General Overview", tabName = "viz_3", icon = icon("chart-bar")),
    menuItem("Top 10 Complaints", tabName = "viz_1", icon = icon("map")),
    menuItem("Average Response Time", tabName = "viz_2", icon = icon("clock")),
    menuItem("Parks Complaints", tabName = "viz_4", icon = icon("tree"))
  )
)

# creating the body of the dashboard to hold the page content
body <- dashboardBody(
  tabItems(
    # About tab content
    tabItem(tabName = "About",
            fluidPage(
              h1("About"),
              h3("Purpose and Objective"),
              p("The primary purpose of this dashboard is to explore and analyze the NYC 311 Service Request data and to offer insights into complaint patterns, geographic distribution, and response times across different boroughs. The dashboard is designed to help users understand public service efficiency and to identify potential areas for improvement."),
              
              h3("Statistical Analysis Documentation"),
              p("This dashboard dynamically filters and visualizes service request data to provide insights into submission trends, response times, and public service efficiency across New York boroughs. The general overview section includes a heatmap that categorizes 191 unique submission types into seven distinct categories to highlight major trends. Users can interact with a Leaflet map displaying the five boroughs, view a plot of the top ten complaints for each borough, and explore response times by complaint type through an interactive bar chart and a time series plot. These visualizations allow for an in-depth exploration of submission trends over the year."),
              
              h3("Preprocessing and Data Management"),
              p("To ensure the dashboard runs quickly and remains manageable for deployment on shinyapps.io, we created a separate preprocessing.R file. This script performs all heavy computations—such as data cleaning, category assignment, and time-based filtering—once and saves the results in a summary_data.rds file. Our global.R file then reads this summary file so that the app uses only precomputed summary objects. This approach maintains data integrity while significantly reducing file size and improving load times."),
              
              h3("Limitations"),
              p("There are several limitations to consider. Data quality issues, such as missing or incomplete records, may affect the accuracy of our analysis. Additionally, certain boroughs may have more complaints reported due to higher awareness or easier access to reporting channels. Response times may also vary depending on the nature of the complaint, and external factors like seasonal trends or public events could influence complaint frequencies and response times."),
              
              h3("Challenge and Dashboard Goals"),
              p("The challenge addressed by this dashboard is to transform the NYC 311 service request dataset into an interactive tool that not only visualizes the data but also provides actionable insights. The dashboard goals include analyzing response efficiency, identifying service trends, and comparing borough-level variations."),
              
              h3("Links & Documentation"),
              p("This project is based on the NYC 311 service request dataset for 2024, which contains information on complaints submitted by residents regarding various city issues."),
              p("View the Challenge: ", a("Github Repository", href = "https://github.com/UWB-Adv-Data-Vis-2025-Wi-A/data-challenge-nyc-311-samm/blob/main/README.md", target = "_blank")),
              p("View The Team's Repository: ", a("Team Repository", href = "https://github.com/UWB-Adv-Data-Vis-2025-Wi-A/data-challenge-nyc-311-samm.git", target = "_blank"))
            )
    ),
    
    # Viz_1: Top 10 Complaints & Map
    tabItem(tabName = "viz_1",
            fluidPage(
              titlePanel("NYC 311 Complaints Dashboard"),
              sidebarLayout(
                sidebarPanel(
                  selectInput("borough", "Select Borough:", 
                              choices = borough_choices, 
                              selected = borough_choices[1])
                ),
                mainPanel(
                  leafletOutput("nyc_map", height = 400),
                  plotOutput("complaint_plot")
                )
              )
            )
    ),
    
    # second visualization tab content
    tabItem(tabName = "viz_2",
            fluidPage(
              titlePanel("Average Response Time"),
              fluidRow(
                column(12, plotlyOutput("avg_response_plot"))
              ),
              br(), br(), tags$hr(),
              fluidRow(
                column(3,  
                       div(
                         sliderInput("date_range", "Select Date Range (2024):", 
                                     min = as.Date("2024-01-01"),
                                     max = as.Date("2024-12-31"),
                                     value = c(as.Date("2024-01-01"), as.Date("2024-12-31")),
                                     timeFormat = "%Y-%m-%d"),
                         br(),
                         selectInput("borough_filter", "Select Borough(s):",
                                     choices = c("All Boroughs", borough_choices),
                                     selected = "All Boroughs",
                                     multiple = TRUE),
                         br(),
                         selectInput("complaint_filter", "Select Complaint Type(s):",
                                     choices = c("All Complaints", complaint_type_choices),
                                     selected = "All Complaints",
                                     multiple = TRUE)
                       )
                ),
                column(9, plotlyOutput("response_time_trend"))
              )
            )
    ),
    
    # Viz_3: Summary
    tabItem(tabName = "viz_3",
            fluidPage(
              titlePanel("NYC 311 Data at a Glance"),
              fluidRow(
                box(
                  title = "Select Date Range", status = "primary", solidHeader = TRUE, height = "204px", width = 6,
                  selectInput("date_range_summary", "Choose a Date Range:",
                              choices = c("Past Month", "Past 3 Months", "Past 6 Months", "Past Year"),
                              selected = "Past Year")
                ),
                box(
                  title = "Summary Statistics", status = "info", solidHeader = TRUE, width = 6,
                  fluidRow(
                    column(6,
                           div(style = "text-align:center; border: 1px solid #ddd; margin: 5px; padding: 5px; border-radius: 5px;",
                               h2(textOutput("total_requests"), style = "margin:0;"),
                               h5("Requests", style = "margin:0;")
                           )
                    ),
                    column(6,
                           div(style = "text-align:center; border: 1px solid #ddd; margin: 5px; padding: 5px; border-radius: 5px;",
                               h2(textOutput("total_request_types"), style = "margin:0;"),
                               h5("Request Types", style = "margin:0;")
                           )
                    )
                  ),
                  fluidRow(
                    column(6,
                           div(style = "text-align:center; border: 1px solid #ddd; margin: 5px; padding: 5px; border-radius: 5px;",
                               h2(textOutput("total_sources"), style = "margin:0;"),
                               h5("Sources", style = "margin:0;")
                           )
                    ),
                    column(6,
                           div(style = "text-align:center; border: 1px solid #ddd; margin: 5px; padding: 5px; border-radius: 5px;",
                               h2(textOutput("total_request_agencies"), style = "margin:0;"),
                               h5("Request Agency", style = "margin:0;")
                           )
                    )
                  )
                )
              ),
              fluidRow(
                box(title = "Complaint Counts by Borough", status = "primary", solidHeader = TRUE, width = 12,
                    plotlyOutput("complaint_heatmap", height = "500px"))
              ),
              fluidRow(
                box(title = "Total Requests by Source", status = "info",
                    solidHeader = TRUE, width = 6, height = "450px",
                    plotOutput("requests_by_source", height = "390px")),
                box(title = "Division Handling Requests (Top Five)", status = "info",
                    solidHeader = TRUE, width = 6, height = "450px",
                    plotlyOutput("division_handling", height = "250px"), 
                    uiOutput("division_legend"))
              )
            )
    ),
    
    # Viz_4: Top 10 Parks with Complaints
    tabItem(tabName = "viz_4",
            fluidRow(
              box(
                title = "Top 10 Parks with Most 311 Complaints",
                status = "primary",
                solidHeader = TRUE,
                width = 12,
                plotlyOutput("viz4_plot", height = "500px")
              )
            )
    )
  )
)

dashboardPage(header, sidebar, body)