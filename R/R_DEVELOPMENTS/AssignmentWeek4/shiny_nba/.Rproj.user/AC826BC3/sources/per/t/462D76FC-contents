#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.

# load libraries
library(shiny)
library(tidyverse)
library(plotly)

# load data and source functions to make plot of basketball court
source("helpers.R")
load("nba_shots.RData")

# define plot of court
gg_court = make_court()

################################################################################
# Define server logic 
shinyServer(function(input, output) {
   
  # set range of seasons based on player choice
  # output$season_choice <- renderUI({
  #   seasons = nba_shots %>% filter(player_name == input$player_choice) %>% 
  #     distinct(season) %>% pull()
  #   
  #   selectizeInput("season_choice", label = h3("Select season"), choices = seasons,
  #               selected = seasons[1], multiple = TRUE)
  # })
  # 
  # output$court_shots <- renderPlot({
  #   # subset data by selected player and season(s)
  #   player_data = filter(nba_shots, player_name == input$player_choice,
  #                        season %in% input$season_choice)
  # 
  #   # create plot
  #   gg_court + geom_point(data = player_data, alpha = 0.75, size = 2.5,
  #                         aes(loc_x, loc_y, color = shot_made_flag, shape = season)) +
  #     scale_color_manual("", values = c(made = "blue", missed = "orange"))
  # })
  # 
  # 
  # output$shot_distances <- renderPlotly({
  #   nba_shots %>%
  #     filter(if(input$shots_made != 'all')  (shot_made_flag == input$shots_made) else TRUE) %>%
  #     plot_ly(y = ~shot_distance, color = ~player_name, type = "box") %>%
  #     layout(showlegend = FALSE)
  # })
  
})
