library(shinydashboard)

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