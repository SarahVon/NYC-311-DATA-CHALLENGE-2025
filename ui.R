## UI.R FILE ##

# creating a header for the dashboard
header = dashboardHeader(title = "311 Data Dashboard")

# creating a sidebar for the dashboard for page navigation
sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("About", tabName = "About", icon = icon("info-circle")),
    menuItem("General Overview", tabName = "viz_3", icon = icon("chart-bar")),
    menuItem("Top 10 Complaints", tabName = "viz_1", icon = icon("map")),
    menuItem("Average Response Time", tabName = "viz_2", icon = icon("clock")),
    menuItem("Parks Complaints", tabName = "viz_4", icon = icon("tree"))
  )
)

# creating the body of the dashboard to hold the page content
body = dashboardBody(
  tabItems(
    # about tab content
    tabItem(tabName = "About",
            fluidPage(
              h1("About"),
              
              h3("Purpose and Objective"),
              p("The primary purpose of this dashboard is to explore and 
                analyze NYC 311 Service Request data and to offer insights 
                into complaint patterns, geographic distribution, and response 
                times across different boroughs. The dashboard is designed 
                to guide users in understanding public service efficiency 
                and identifying potential areas for improvement."),
              
              h3("Statistical Analysis Documentation"),
              p("This dashboard dynamically filters and visualizes service request data 
              to provide insights into submission trends, response times, and public service
              efficiency across New York boroughs. The general overview section
              includes a heatmap which categorizes 191 unique submission types
              into seven distinct categories in order to highlight major trends.
              Users can also interact with a Leaflet map displaying
              the five boroughs while also looking at a plot of the top ten complaints
              for each borough. The average response time section includes an interactive
              bar chart comparing response efficiency by complaint type and a time series plot 
              tracking response time trends. Response time was calculated as the difference 
              between the creation date of each submission  and the close date. This allowed
              for a clear comparison of service efficiency across submission types and boroughs. This
              section also includes a requests-over-time plot which uses an average response time trendline 
              for each borough. These plots will allow users explore how submission response time changes throughout the year. 
              Users can filter data using dropdown menus and date sliders, allowing for an in-depth
              exploration of submission trends. Lastly, this dashboard includes an interactive plot
              showcasing the top ten parks with the most submissions, along with the borough each park 
              lies in."),
              
              h3("Limitations"),
              p("There are several limitations to consider. Data quality issues, such as missing
                or incomplete records, may impact the accuracy of the analysis. Additionally, certain boroughs
                may have more complaints reported due to higher awareness or easier access to reporting channels. 
                Response times may also vary depending on the nature of the complaint, and external factors like 
                seasonal trends or public events could influence complaint frequencies and response times."),
              
              h3("Challenge and Dashboard Goals"),
              p("The challenge addressed by this dashboard is to transform the NYC 311 service request dataset
                into an interactive tool that not only visualizes 
                the data but also provides actionable insights for users. 
                The goals include analyzing response efficiency, service trends, and borough-level variations."),
              
              h3("Links & Documentation"),
              p("This project is based on the NYC 311 service request dataset, which contains information on 
                complaints submitted by residents regarding various city issues. This challenge uses data from 2024"),
              p("View the Challenge: ",
                  a("Github Repository", href = "https://github.com/UWB-Adv-Data-Vis-2025-Wi-A/data-challenge-nyc-311-samm/blob/main/README.md", target = "_blank")),
              p("View The Team's Repository: ",
                a("Team Repository", href = "https://github.com/UWB-Adv-Data-Vis-2025-Wi-A/data-challenge-nyc-311-samm.git", target = "_blank")),
            )
    ),
    
    # first visualization tab content
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
              
              # full-width bar chart
              fluidRow(
                column(12, plotlyOutput("avg_response_plot"))
              ),
              
              
              # spacing before time series chart
              br(), br(),  # Two line breaks
              tags$hr(),   # Horizontal line for separation
              

              # left (Date Slider + Filters) & right (Time Series Chart)
              fluidRow(
                column(3,  
                       div(
                         # date Range Slider (Top)
                         sliderInput("date_range", "Select Date Range (2024):", 
                                     min = as.Date("2024-01-01"),
                                     max = as.Date("2024-12-31"),
                                     value = c(as.Date("2024-01-01"), as.Date("2024-12-31")),
                                     timeFormat = "%Y-%m-%d"),
                         br(),
                         
                         # borough Filter (Directly Below)
                         selectInput("borough_filter", "Select Borough(s):",
                                     choices = c("All Boroughs", borough_choices),
                                     selected = "All Boroughs",
                                     multiple = TRUE),
                         br(),  # Small spacing
                         
                         # complaint Type Filter (Stacked Below)
                         selectInput("complaint_filter", "Select Complaint Type(s):",
                                     choices = c("All Complaints", sort(unique(data$Complaint_Type))),
                                     selected = "All Complaints",
                                     multiple = TRUE)
                       )
                ),
                
                column(9, plotlyOutput("response_time_trend"))  # right Side: Time Series Chart
              )
            )
    ),
    
    # third visualization tab content
    tabItem(tabName = "viz_3",
            fluidPage(
              titlePanel("NYC 311 Data at a Glance"),
              
              # date selection & summary stats
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
              
              # complaint counts heatmap
              fluidRow(
                box(title = "Complaint Counts by Borough", status = "primary", solidHeader = TRUE, width = 12,
                    plotlyOutput("complaint_heatmap", height = "500px"))
              ),
              
              # requests by source & division handling requests
              fluidRow(
                box(title = "Total Requests by Source", status = "info",
                  solidHeader = TRUE, width = 6, height = "450px",
                  plotOutput("requests_by_source", height = "390px"),
                ),
                box( title = "Division Handling Requests (Top Five)", status = "info",
                  solidHeader = TRUE, width = 6, height = "450px",
                  plotlyOutput("division_handling", height = "250px"), 
                  uiOutput("division_legend")
                )
              )
            )
    ),
    
    # fourth visualization tab content
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

# dashboard page
dashboardPage(header, sidebar, body)
