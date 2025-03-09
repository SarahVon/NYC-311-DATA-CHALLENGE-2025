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
  
  # output$viz2_plot <- renderPlot({...}) 
  # etc.
  
  # ────────────────────────────────────────────────────────────
  # VISUALIZATION 3: [Title of Viz]
  # Contributor: [Group Member]
  # ────────────────────────────────────────────────────────────
  
  # output$viz3_plot <- renderPlot({...}) 
  
  # ────────────────────────────────────────────────────────────
  # VISUALIZATION 4: [Title of Viz]
  # Contributor: [Group Member]
  # ────────────────────────────────────────────────────────────
  
  # output$viz4_plot <- renderPlot({...}) 
}