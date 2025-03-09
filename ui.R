library(shinydashboard)

# creating a header for the dashboard
header = dashboardHeader(title = "311 Data Dashboard")

# creating a sidebar for the dashboard for page navigation
sidebar = dashboardSidebar(
  sidebarMenu(
    menuItem("About", tabName = "About", icon = icon("info-circle")),
    menuItem("viz 1", tabName = "viz_1"),
    menuItem("viz 2", tabName = "viz_2"),
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
            fluidPage()
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