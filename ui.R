library(shinydashboard)

# creating a header for the dashboard
header = dashboardHeader(title = "311 Data Dashboard")

# creating a sidebar for the dashboard for page navigation
sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("About", tabName = "About", icon = icon("info-circle")),
    menuItem("viz 1", tabName = "viz_1"),
    menuItem("Average Response Time", tabName = "viz_2", icon = icon("clock")),
    menuItem("Summary Dashboard", tabName = "viz_3"),
    menuItem("viz 4", tabName = "viz_4")
  )
)

# creating the body of the dashboard to hold the page content
body = dashboardBody(
  tabItems(
    # about tab content
    tabItem(tabName = "About",
            fluidPage(
              h1("About"),
              
              h2("Purpose and Objective"),
              p("The primary purpose of this dashboard is to explore and 
                analyze NYC 311 Service Request data and to offer insights 
                into complaint patterns, geographic distribution, and response 
                times across different boroughs. The dashboard is designed 
                to guide users in understanding public service efficiency 
                and identifying potential areas for improvement."),
              
              h2("Statistical Analysis Documentation"),
              p("This dashboard includes a statistical analysis of average 
              response times by borough. 
                The analysis is performed by calculating the mean number of days
                between the creation and closure of service requests. 
                A lower average response time indicates more efficient handling 
                of service requests, whereas higher values may suggest delays."),
              p("Limitations: Data quality issues..."),
              
              h2("Challenge and Dashboard Goals"),
              p("The challenge addressed by this dashboard is to transform a large,
                multifaceted dataset into an interactive tool that not only visualizes 
                the data but also provides actionable insights for users. 
                The goals include enhancing transparency in NYC service operations, 
                enabling data-driven insights for policymakers and stakeholders, 
                and allowing interactive exploration of the data through filtering options."),
              p("For More Information Checkout the Link Below: ",
                a("https://github.com/UWB-Adv-Data-Vis/NYC-complaints.git", 
                  href = "https://github.com/UWB-Adv-Data-Vis/NYC-complaints.git", target = "_blank")
            ))
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
              
              # bottom row: left (slider) & right: time series chart
              fluidRow(
                column(6,  
                       sliderInput("date_range", "Select Date Range (2024):", 
                                   min = as.Date("2024-01-01"),
                                   max = as.Date("2024-12-31"),
                                   value = c(as.Date("2024-09-17"), as.Date("2024-12-31")),
                                   timeFormat = "%Y-%m-%d")
                ),
                column(6, plotlyOutput("response_time_trend"))
              ),
              
              # filters moved below the slider
              fluidRow(
                column(6,  
                       selectInput("borough_filter", "Select Borough(s):",
                                   choices = c("All Boroughs", borough_choices),
                                   selected = "All Boroughs",
                                   multiple = TRUE)
                ),
                column(6,  
                       selectInput("complaint_filter", "Select Complaint Type(s):",
                                   choices = c("All Complaints", sort(unique(data$Complaint_Type))),
                                   selected = "All Complaints",
                                   multiple = TRUE)
                )
              )
            )
    ),
    
    # third visualization tab content
    tabItem(tabName = "viz_3",
            fluidPage(
              titlePanel("Summary Dashboard"),
              
              # date selection & summary stats
              fluidRow(
                box(
                  title = "Select Date Range", status = "primary", solidHeader = TRUE,
                  selectInput("date_range_summary", "Choose a Date Range:",
                              choices = c("Past Month", "Past 3 Months", "Past 6 Months", "Past Year"),
                              selected = "Past Year")
                ),
                box(
                  title = "Summary Statistics", status = "info", solidHeader = TRUE, width = 6,
                  fluidRow(
                    column(6, div(h3(textOutput("total_requests")), "Requests")),
                    column(6, div(h3(textOutput("total_request_types")), "Request Types"))
                  ),
                  fluidRow(
                    column(6, div(h3(textOutput("total_sources")), "Sources")),
                    column(6, div(h3(textOutput("total_request_agencies")), "Request Agency"))
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
                box(title = "Total Requests by Source", status = "info", solidHeader = TRUE, width = 6,
                    plotOutput("requests_by_source")),
                box(title = "Division Handling Requests", status = "info", solidHeader = TRUE, width = 6,
                    plotOutput("division_handling"))
              )
            )
    ),
    
    # fourth visualization tab content
    tabItem(tabName = "viz_4",
            fluidPage()
    )
  )
)

# dashboard page
dashboardPage(header, sidebar, body)