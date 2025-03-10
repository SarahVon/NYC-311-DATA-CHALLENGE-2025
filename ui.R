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
              sidebarLayout(
                sidebarPanel(
                  # multiple selection for boroughs
                  selectInput("borough_filter", "Select Borough(s):",
                              choices = c("All Boroughs", borough_choices),
                              selected = "All Boroughs",
                              multiple = TRUE),
                  
                  # multiple selection for complaint types
                  selectInput("complaint_filter", "Select Complaint Type(s):",
                              choices = c("All Complaints", sort(unique(data$Complaint_Type))),
                              selected = "All Complaints",
                              multiple = TRUE),
                  
                  # slider for selecting date range (only 2024)
                  sliderInput("date_range", "Select Date Range (2024):", 
                              min = as.Date("2024-01-01"),
                              max = as.Date("2024-12-31"),
                              value = c(as.Date("2024-09-17"), as.Date("2024-12-31")),
                              timeFormat = "%Y-%m-%d")
                ),
                mainPanel(
                  plotlyOutput("avg_response_plot")
                  # DT::DTOutput("data_table") not sure if I want to include a DT
                )
              )
            )
    ),
    
    # third visualization tab content
    tabItem(tabName = "viz_3",
            fluidPage(
              titlePanel("Summary Dashboard"),
              fluidRow(
                
                # date selection box
                column(6, 
                       box(title = "Select Date Range", width = NULL, solidHeader = TRUE, status = "primary",
                           selectInput("summary_date_range", 
                                       "Choose a Date Range:", 
                                       choices = c("Past Month" = "1m", 
                                                   "Past 3 Months" = "3m",
                                                   "Past 6 Months" = "6m",
                                                   "Past Year" = "12m"),
                                       selected = "12m"))
                ),
                
                # summary statistics box with four quadrants
                column(6, 
                       box(title = "Summary Statistics", width = NULL, solidHeader = TRUE, status = "info",
                           fluidRow(
                             column(6, valueBoxOutput("total_requests")),
                             column(6, valueBoxOutput("total_types"))
                           ),
                           fluidRow(
                             column(6, valueBoxOutput("total_sources")),
                             column(6, valueBoxOutput("total_agencies"))
                           )
                       )
                )
              ),
              
              # complaint heatmap
              fluidRow(
                column(12, 
                       box(title = "Complaint Counts by Borough", width = 12, solidHeader = TRUE, status = "primary",
                           plotOutput("complaint_heatmap"))
                )
              ),
              
              # request source & division distribution
              fluidRow(
                column(6, 
                       box(title = "Total Requests by Source", width = 12, solidHeader = TRUE, status = "info",
                           plotOutput("request_source_chart"))
                ),
                column(6, 
                       box(title = "Division Handling Requests", width = 12, solidHeader = TRUE, status = "info",
                           plotOutput("request_division_chart"))
                )
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

