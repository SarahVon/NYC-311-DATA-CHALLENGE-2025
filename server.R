# server.R

server <- function(input, output) {  
  
  # ────────────────────────────────────────────────────────────
  # VISUALIZATION 1: NYC Borough Map + Top 10 Complaints
  # Contributor: Mia Keane
  # ────────────────────────────────────────────────────────────
  
  output$nyc_map <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addPolygons(
        data = nyc_map_data,  # precomputed spatial data from global.R
        fillColor = "gray",
        fillOpacity = 0.3,
        color = "black",
        weight = 1,
        label = ~NAME  
      ) %>%
      addPolygons(
        data = nyc_boroughs,  # precomputed borough boundaries
        fillColor = NA,  
        color = "purple",  # yay purple map
        weight = 2, 
        label = ~NAME  
      ) %>%
      setView(lng = -74, lat = 40.7, zoom = 10)  
  })
  
  output$complaint_plot <- renderPlot({
    req(input$borough)
    # Use the precomputed top_complaints_summary instead of the full data.
    top_complaints <- top_complaints_summary %>%
      filter(Borough == input$borough)
    
    if (nrow(top_complaints) == 0) {
      return(NULL)
    }
    
    ggplot(top_complaints, aes(x = reorder(Complaint_Type, Count), y = Count)) +
      geom_col(fill = "pink") +  # yay pink bar chart
      coord_flip() +  
      labs(title = paste("Top 10 Complaints in", input$borough),
           x = "Complaint Type", y = "Number of Complaints") +
      theme_minimal()
  })
  
  # ────────────────────────────────────────────────────────────
  # VISUALIZATION 2: Average Response Time by Borough
  # Contributor: May Benisa
  # ────────────────────────────────────────────────────────────
  
  # defining colors for each borough (keys in uppercase)
  borough_colorz <- c(
    "BRONX"         = "#1f77b4",
    "BROOKLYN"      = "#ff7f0e",
    "MANHATTAN"     = "#2ca02c",
    "QUEENS"        = "#d62728",
    "STATEN ISLAND" = "#9467bd"
  )
  
  aggregated_response_final <- reactive({
    if ("All Complaints" %in% input$complaint_filter) {
      data_temp <- aggregated_response_all
    } else {
      data_temp <- aggregated_response_by_complaint %>%
        filter(Complaint_Type %in% input$complaint_filter) %>%
        group_by(Borough) %>%
        summarise(
          Average_Duration = mean(Average_Duration, na.rm = TRUE),
          Count = sum(Count),
          .groups = "drop"
        )
    }
    # apply the borough filter
    if (!("All Boroughs" %in% input$borough_filter)) {
      data_temp <- data_temp %>% filter(Borough %in% input$borough_filter)
    }
    # remove "Unspecified"
    data_temp <- data_temp %>% filter(!str_detect(toupper(Borough), "UNSPECIFIED"))
    data_temp
  })
  
  output$avg_response_plot <- renderPlotly({
    agg_data <- aggregated_response_final()
    agg_data <- agg_data %>% mutate(Borough = toupper(Borough))
    
    if (nrow(agg_data) == 0) {
      return(plotly::plot_ly() %>% layout(title = "No data available for the selected filters"))
    }
    
    p <- ggplot(agg_data, aes(
      x = reorder(Borough, -Average_Duration),
      y = Average_Duration,
      fill = Borough,
      text = paste0("Borough: ", Borough,
                    "\nAverage Duration: ", round(Average_Duration, 2), " Days")
    )) +
      geom_bar(stat = "identity") +
      labs(
        title = "Average Response Time by Borough",
        subtitle = "Filtered by Date & Complaint Type",
        y = "Avg Response Time (Days)", 
        x = "Borough"
      ) +
      scale_fill_manual(values = borough_colorz) +
      scale_y_continuous(labels = scales::comma) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p, tooltip = "text") %>% layout(margin = list(t = 80))
  })
  
  trend_response_final <- reactive({
    # decide which daily trend data to use
    if ("All Complaints" %in% input$complaint_filter) {
      data_temp <- response_time_trend_all %>%
        filter(Created_Date >= input$date_range[1],
               Created_Date <= input$date_range[2])
    } else {
      data_temp <- response_time_trend_by_complaint %>%
        filter(Complaint_Type %in% input$complaint_filter,
               Created_Date >= input$date_range[1],
               Created_Date <= input$date_range[2]) %>%
        group_by(Created_Date, Borough) %>%
        summarise(
          Average_Duration = mean(Average_Duration, na.rm = TRUE),
          Count = sum(Count),
          .groups = "drop"
        )
    }
    # apply borough filter if needed
    if (!("All Boroughs" %in% input$borough_filter)) {
      data_temp <- data_temp %>% filter(Borough %in% input$borough_filter)
    }
    # remove "Unspecified"
    data_temp <- data_temp %>% filter(!str_detect(toupper(Borough), "UNSPECIFIED"))
    data_temp
  })
  
  output$response_time_trend <- renderPlotly({
    trend_data <- trend_response_final()
    
    if (nrow(trend_data) == 0) {
      return(plotly::plot_ly() %>% layout(title = "No data available for the selected filters"))
    }
    
    trend_data <- trend_data %>% mutate(Borough = toupper(Borough))
    
    p <- ggplot(trend_data, aes(
      x = Created_Date, 
      y = Average_Duration, 
      color = Borough, 
      group = Borough
    )) +
      geom_smooth(method = "loess", se = FALSE, size = 1.2) +
      scale_x_date(date_breaks = "1 month", date_labels = "%b %Y") +
      scale_color_manual(values = borough_colorz) +
      labs(
        title = "Response Time Trends: How Quickly Are Complaints Resolved?",
        subtitle = "Tracking changes in average response time",
        y = "Avg Response Time (Days)", 
        x = "Date"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p, tooltip = c("x", "y", "color"))
  })
  
  # ────────────────────────────────────────────────────────────
  # VISUALIZATION 3: Summary
  # Contributor: Sarah Anderson
  # ────────────────────────────────────────────────────────────
  
  # For summary stats, use the precomputed summary_stats_time by matching the selected Time_Frame.
  summary_stats <- reactive({
    req(input$date_range_summary)
    summary_stats_time %>% filter(Time_Frame == input$date_range_summary)
  })
  
  output$total_requests <- renderText({
    stats <- summary_stats()
    format(stats$Total_Requests, big.mark = ",")
  })
  
  output$total_request_types <- renderText({
    stats <- summary_stats()
    format(stats$Unique_Complaint_Types, big.mark = ",")
  })
  
  output$total_sources <- renderText({
    stats <- summary_stats()
    format(stats$Unique_Sources, big.mark = ",")
  })
  
  output$total_request_agencies <- renderText({
    stats <- summary_stats()
    format(stats$Unique_Agencies, big.mark = ",")
  })
  
  ### HEAT MAP ###
  output$complaint_heatmap <- renderPlotly({
    valid_boroughs <- c("Brooklyn", "Queens", "Bronx", "Manhattan", "Staten Island")
    original_cats <- c(
      "Public Safety & Crime",
      "Noise",
      "Housing & Building",
      "Sanitation and Environmental",
      "Transportation & Streets",
      "City Services & Local Businesses",
      "Other"
    )
    cat_recode <- c(
      "Public Safety & Crime"        = "Public Safety<br>& Crime",
      "Noise"                        = "Noise",
      "Housing & Building"           = "Housing &<br>Building",
      "Sanitation and Environmental" = "Sanitation &<br>Environmental",
      "Transportation & Streets"     = "Transportation<br>& Streets",
      "City Services & Local Businesses" = "City Services &<br>Local Businesses",
      "Other"                        = "Other"
    )
    
    df <- heatmap_summary %>% 
      filter(Time_Frame == input$date_range_summary) %>% 
      filter(Borough %in% valid_boroughs)
    
    df <- df %>%
      group_by(Borough, Category) %>%
      summarise(Count = sum(Count), .groups = "drop") %>% 
      tidyr::complete(
        Borough  = valid_boroughs,
        Category = original_cats,
        fill = list(Count = 0)
      ) %>%
      mutate(DisplayCat = cat_recode[as.character(Category)])
    
    max_count <- max(df$Count)
    
    p <- plot_ly(
      data = df,
      x = ~DisplayCat,
      y = ~Borough,
      z = ~Count,
      type = "heatmap",
      colorscale = list(c(0, "lavender"), c(1, "darkblue")),
      showscale = FALSE,
      hoverinfo = "z",
      hovertemplate = "borough: %{y}<br>category: %{x}<br>count: %{z:,.0f}<extra></extra>",
      textfont = list(size = 8)
    )
    
    annotations <- lapply(seq_len(nrow(df)), function(i) {
      this_count <- df$Count[i]
      text_color <- if (this_count > 0.55 * max_count) "white" else "black"
      list(
        x = df$DisplayCat[i],
        y = df$Borough[i],
        text = scales::comma(this_count),
        showarrow = FALSE,
        font = list(color = text_color, size = 12)
      )
    })
    
    p %>% layout(
      autosize = TRUE,
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
  
  ### HORIZONTAL BAR CHART FOR REQUESTS BY SOURCE
  # Use the precomputed requests_by_source_summary, filtering by the selected time frame.
  requests_by_source_data <- reactive({
    req(input$date_range_summary)
    # Just filter the precomputed summary for the chosen time frame
    requests_by_source_summary %>%
      filter(Time_Frame == input$date_range_summary)
  })
  
  output$requests_by_source <- renderPlot({
    df <- requests_by_source_data() %>%
      filter(!is.na(SourceCategory)) %>%
      arrange(desc(Count))
    
    ggplot(df, aes(x = Count, y = reorder(SourceCategory, Count))) +
      geom_col(fill = "thistle") +
      labs(x = "Number of Requests", y = NULL) +
      scale_x_continuous(labels = scales::comma) +
      theme_minimal(base_size = 13) +
      theme(
        axis.text = element_text(face = "bold"),
        axis.title.x = element_text(face = "bold", margin = margin(t = 15)),
        axis.title.y = element_blank()
      )
  })
  
  ### DIVISION DONUT CHART
  division_data <- reactive({
    req(input$date_range_summary)
    division_summary %>%
      filter(Time_Frame == input$date_range_summary)
  })
  
  output$division_handling <- renderPlotly({
    df <- division_data()
    if (nrow(df) == 0) return(NULL)
    
    slice_count <- nrow(df)
    all_blues <- RColorBrewer::brewer.pal(5, "Blues")
    color_palette <- rev(all_blues)[1:slice_count]
    
    plot_ly(
      data = df,
      labels = ~Agency_Name,
      values = ~Count,
      type = "pie",
      hole = 0.5,                    
      marker = list(colors = color_palette),
      textinfo = "none",
      hoverinfo = "text",
      text = ~paste0(Agency_Name, " - ", sprintf("%.1f%%", Percent)),
      hovertemplate = "%{text}<extra></extra>"
    ) %>% layout(showlegend = FALSE)
  })
  
  output$division_legend <- renderUI({
    df <- division_data()
    if (nrow(df) == 0) return(NULL)
    
    df <- df %>% arrange(desc(Count))
    slice_count <- nrow(df)
    all_blues <- RColorBrewer::brewer.pal(5, "Blues")
    color_palette <- rev(all_blues)[1:slice_count]
    
    legend_rows <- purrr::map2_df(df$Agency_Name, seq_len(nrow(df)), function(name, i) {
      tibble(name = name, color = color_palette[i], percent = sprintf("%.1f%%", df$Percent[i]))
    })
    
    legend_html <- purrr::map_chr(seq_len(nrow(legend_rows)), function(i) {
      row <- legend_rows[i,]
      sprintf(
        '<div style="display:flex; align-items:center; margin-bottom:4px;">
         <div style="width:15px; height:15px; background:%s; margin-right:8px;"></div>
         <span style="font-weight:bold;">%s</span>&nbsp; - %s
       </div>',
        row$color, row$name, row$percent
      )
    }) %>% paste0(collapse = "")
    
    HTML(legend_html)
  })
  
  # ────────────────────────────────────────────────────────────
  # VISUALIZATION 4: Top 10 Parks with Most 311 Complaints
  # Contributor: Aryana Villafuerte
  # ────────────────────────────────────────────────────────────
  
  output$viz4_plot <- renderPlotly({
    # Use the precomputed top_parks_summary directly
    p <- ggplot(top_parks_summary, aes(x = reorder(Park_Facility_Name, n), y = n, text = paste("BOROUGH: ", Borough))) +
      geom_bar(stat = "identity", fill = "steelblue") +
      coord_flip() +
      labs(x = "", y = "Number of Complaints") +
      theme_minimal()
    
    ggplotly(p, tooltip = "text") %>% 
      layout(hoverlabel = list(bgcolor = "lightblue", font = list(color = "black"))) %>%
      config(displayModeBar = FALSE)
  })
  
}