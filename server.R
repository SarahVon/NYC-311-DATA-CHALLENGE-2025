library(shiny)
library(shinydashboard)

server <- function(input, output) {  
  
  # ────────────────────────────────────────────────────────────
  # VISUALIZATION 1: NYC Borough Map + Top 10 Complaints
  # Contributor: Mia Keane
  # ────────────────────────────────────────────────────────────
  
  output$nyc_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addPolygons(
        data = nyc_map_data,
        fillColor = "gray",
        fillOpacity = 0.3,
        color = "black",
        weight = 1,
        label = ~NAME  
      ) %>%
      addPolygons(
        data = nyc_boroughs,  
        fillColor = NA,  
        color = "purple",  # yay purple map
        weight = 2, 
        label = ~NAME  
      ) %>%
      setView(lng = -74, lat = 40.7, zoom = 10)  
  })
  
  output$complaint_plot <- renderPlot({
    req(input$borough)
    
    top_complaints <- data %>%
      filter(Borough == input$borough) %>%
      group_by(Complaint_Type) %>%
      summarise(Count = n(), .groups = "drop") %>%
      arrange(desc(Count)) %>%
      head(10)
    
    if (nrow(top_complaints) == 0) {
      return(NULL)
    }
    
    ggplot(top_complaints, aes(x = reorder(Complaint_Type, Count), y = Count)) +
      geom_col(fill = "pink") + # yay pink bar chart
      coord_flip() +  
      labs(title = paste("Top 10 Complaints in", input$borough),
           x = "Complaint Type", y = "Number of Complaints") +
      theme_minimal()
  })
  
  # ────────────────────────────────────────────────────────────
  # VISUALIZATION 2: Average Response Time by Borough
  # Contributor: May Benisa
  # ────────────────────────────────────────────────────────────
  
  # reactive dataset based on user selections
  filtered_data <- reactive({
    req(input$date_range)
    
    # start with the full data
    filtered <- data %>%
      #filter based on date range
      filter(Created_Date >= input$date_range[1] &
               Created_Date <= input$date_range[2])
    
    # if specific boroughs are selected, filter accordingly
    if (!("All Boroughs" %in% input$borough_filter)) {
      filtered <- filtered %>% filter(Borough %in% input$borough_filter)
    }
    
    # if "All Complaints" is not selected, filter accordingly
    if (!("All Complaints" %in% input$complaint_filter)) {
      filtered <- filtered %>% filter(Complaint_Type %in% input$complaint_filter)
    }
    
    # making sure rows with missing Duration or Created_Date values are gone
    filtered <- filtered %>%
      filter(!is.na(Duration), !is.na(Created_Date))
    
    filtered
  })
  
  # aggregating data for plotting and table
  aggregated_data <- reactive({
    filtered_data() %>%
      filter(Borough != "Unspecified") %>% # removing unspecified borough
      group_by(Borough) %>%
      summarise(Average_Duration = mean(Duration, na.rm = TRUE),
                Count = n(),
                .groups = "drop")
  })
  
  # rendering interactive Plotly plot
  output$avg_response_plot <- renderPlotly({
    agg_data <- aggregated_data()
    
    # in case no data is available, return an empty plot with a message
    if(nrow(agg_data) == 0) {
      return(plotly::plot_ly() %>% 
               plotly::layout(title = "No data available for the selected filters"))
    }
    
    p <- ggplot(agg_data, aes(x = Borough, y = Average_Duration, fill = Borough)) +
      geom_bar(stat = "identity") +
      labs(title = "Average Response Time by Borough", 
           y = "Average Duration (Days)", x = "Borough") +
      scale_y_continuous(labels = scales::comma) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p)
  })
  
  # rendering
  output$data_table <- DT::renderDT({
    aggregated_data()
  })
  
  # ────────────────────────────────────────────────────────────
  # VISUALIZATION 3: Summary
  # Contributor: Sarah Anderson
  # ────────────────────────────────────────────────────────────

  # filtering data based on selection
  filtered_summary_data <- reactive({
    req(input$date_range_summary)
    
    # getting date range based on input
    end_date <- as.Date("2024-12-31") 
    start_date <- switch(input$date_range_summary,
                         "Past Month" = end_date - 30,
                         "Past 3 Months" = end_date - 90,
                         "Past 6 Months" = end_date - 180,
                         "Past Year" = as.Date("2024-01-01"))
    
    data %>%
      filter(Created_Date >= start_date & Created_Date <= end_date)
  })
  
  # summary statistics outputs
  output$total_requests <- renderText({
    # total requests count
    nrow(filtered_summary_data())  
  })
  
  output$total_request_types <- renderText({
    # unique complaint types 
    length(unique(filtered_summary_data()$Complaint_Type))
  })
  
  output$total_sources <- renderText({
    # unique request sources
    length(unique(filtered_summary_data()$Open_Data_Channel_Type))
  })
  
  output$total_request_agencies <- renderText({
    # unique agencies
    length(unique(filtered_summary_data()$Agency_Name))  
  })
  
  # ────────────────────────────────────────────────────────────
  # VISUALIZATION 4: [Title of Viz]
  # Contributor: [Group Member]
  # ────────────────────────────────────────────────────────────
  
  # output$viz4_plot <- renderPlot({...}) 
  
}

