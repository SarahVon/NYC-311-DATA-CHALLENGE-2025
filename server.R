library(shiny)
library(shinydashboard)
library(scales)

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
    format(nrow(filtered_summary_data()), big.mark = ",") 
  })
  
  output$total_request_types <- renderText({
    # unique complaint types 
    format(length(unique(filtered_summary_data()$Complaint_Type)), big.mark = ",")
  })
  
  output$total_sources <- renderText({
    # unique request sources
    format(length(unique(filtered_summary_data()$Open_Data_Channel_Type)), big.mark = ",")
  })
  
  output$total_request_agencies <- renderText({
    # unique agencies
    format(length(unique(filtered_summary_data()$Agency_Name)), big.mark = ",")
  })
  
  ### HEAT MAP ###
  output$complaint_heatmap <- renderPlotly({
    # define the borough order from top to bottom
    valid_boroughs <- c("BROOKLYN","QUEENS","BRONX","MANHATTAN","STATEN ISLAND")
    
    # define categories in the desired order
    original_cats <- c(
      "Public Safety & Crime",
      "Noise",
      "Housing & Building",
      "Sanitation and Environmental",
      "Transportation & Streets",
      "City Services & Local Businesses",
      "Other"
    )
    
    # define multiline labels for categories
    cat_recode <- c(
      "Public Safety & Crime"        = "Public<br>Safety & Crime",
      "Noise"                        = "Noise",
      "Housing & Building"           = "Housing<br>& Building",
      "Sanitation and Environmental" = "Sanitation<br>& Environmental",
      "Transportation & Streets"     = "Transportation<br>& Streets",
      "City Services & Local Businesses" = "City Services<br>& Local Businesses",
      "Other"                        = "Other"
    )
    
    # filtering data by date range, group by borough + category
    df <- filtered_summary_data() %>%
      filter(Borough %in% valid_boroughs) %>%
      group_by(Borough, Category) %>%
      summarise(Count = n(), .groups = "drop") %>%
      tidyr::complete(
        Borough  = valid_boroughs,
        Category = original_cats,
        fill = list(Count = 0)
      )
    
    # creating a DisplayCat column for multiline category labels
    df <- df %>%
      mutate(DisplayCat = cat_recode[as.character(Category)])
    
    # finding the maximum count (used to know when to switch text color to white)
    max_count <- max(df$Count)
    
    p <- plot_ly(
      data = df,
      x = ~DisplayCat,
      y = ~Borough,
      z = ~Count,
      type = "heatmap",
      colorscale = list(c(0, "lavender"), c(1, "darkblue")),
      showscale = FALSE,
      # use z in hover with commas => %{z:,.0f}
      hoverinfo = "z",
      hovertemplate = "borough: %{y}<br>category: %{x}<br>count: %{z:,.0f}<extra></extra>"
    )
    
    # add tile annotations with commas
    annotations <- lapply(seq_len(nrow(df)), function(i) {
      this_count <- df$Count[i]
      # switch to white text if above 75% of max
      text_color <- if (this_count > 0.75 * max_count) "white" else "black"
      
      list(
        x = df$DisplayCat[i],
        y = df$Borough[i],
        # adding commas to counts
        text = scales::comma(this_count),
        showarrow = FALSE,
        font = list(color = text_color, size = 12)
      )
    })
    
    # placing categories on top
    p %>% layout(
      annotations = annotations,
      xaxis = list(
        side = "top",
        title = "",
        tickangle = 0,
        categoryorder = "array",
        categoryarray = cat_recode[original_cats]
      ),
      yaxis = list(
        title = "",
        categoryorder = "array",
        categoryarray = valid_boroughs,
        autorange = "reversed"
      ),
      margin = list(l = 50, r = 50, t = 50, b = 50)
    )
  })
  
  ### HORIZONTAL BAR CHART FOR SOURCEES** 
  # reactive data that groups by open_data_channel_type
  requests_by_source_data <- reactive({
    filtered_summary_data() %>%
      mutate(
        SourceCategory = case_when(
          # combining unknown and other
          Open_Data_Channel_Type %in% c("UNKNOWN", "OTHER") ~ "OTHER",
          Open_Data_Channel_Type == "ONLINE" ~ "WEBSITE",
          Open_Data_Channel_Type == "PHONE"  ~ "PHONE CALL",
          Open_Data_Channel_Type == "MOBILE" ~ "MOBILE APP",
          TRUE ~ as.character(Open_Data_Channel_Type)
        )
      ) %>%
      group_by(SourceCategory) %>%
      summarise(Count = n(), .groups = "drop")
  })
  
  # rendering the horizontal bar chart
  output$requests_by_source <- renderPlot({
    df <- requests_by_source_data() %>%
      # removing any NA categories if present
      filter(!is.na(SourceCategory)) %>%
      arrange(desc(Count))
    
    ggplot(df, aes(x = Count, y = reorder(SourceCategory, Count))) +
      geom_col(fill = "thistle") +
      labs(x = "Number of Requests", y = NULL) +
      scale_x_continuous(labels = scales::comma) +
      theme_minimal(base_size = 13) +  
      theme(
        axis.text = element_text(face = "bold"),  
        axis.title.x = element_text(
          face = "bold", 
          # extra space for x-axis title
          margin = margin(t = 15)  
        ),
        axis.title.y = element_blank()
      )
  })
  
  # ────────────────────────────────────────────────────────────
  # VISUALIZATION 4: [Title of Viz]
  # Contributor: [Group Member]
  # ────────────────────────────────────────────────────────────
  
  # output$viz4_plot <- renderPlot({...}) 
  
}

