library(shinydashboard)

# creating a header for the dashboard
header = dashboardHeader(title = "311 Data Dashboard")

# creating a sidebar for the dashboard for page navigation
sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("About", tabName = "About", icon = icon("info-circle")),
    menuItem("viz 1", tabName = "viz_1"),
    menuItem("Average Response Time", tabName = "viz_2", icon = icon("clock")),
    menuItem("viz 3", tabName = "viz_3"),
    menuItem("viz 4", tabName = "viz_4")
  )
)

# creating the body of the dashboard to hold the page content
body = dashboardBody(
  tabItems(
    # about tab content
    tabItem(tabName = "About",
            fluidPage()
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
            fluidPage()
    ),
    
    # fourth visualization tab content
    tabItem(tabName = "viz_4",
            fluidPage()
    )
  )
)

# dashboard page
dashboardPage(header, sidebar, body)

