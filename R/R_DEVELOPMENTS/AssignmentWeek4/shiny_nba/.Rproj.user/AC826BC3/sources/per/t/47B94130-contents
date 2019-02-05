#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#

# load libraries and data
library(shiny)
library(tidyverse)
load("nba_shots.RData")

# data management
players = nba_shots %>% distinct(player_name) %>% pull()
made = nba_shots %>% distinct(shot_made_flag ) %>% pull()

# Define UI for application
shinyUI(fluidPage(
  
  # Application title
  titlePanel("NBA Shot Attempts"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      
      
      # # drop down menu for player
      # selectInput("player_choice", label = h2("Select player"),
      #             choices = players, selected = "LeBron James") #, # uncomment comma to add another widget
      # 
      # # drop down menu for season based on a certain player
      # uiOutput("season_choice") #,
      # 
      # radioButtons("shots_made", label = h3("Shot status"), choices = list("all", "made", "missed"))
      
    ),
    
    # Show output based on user selections
    mainPanel(
      
      # # spatial plot of shots made
      # plotOutput("court_shots") #,
      # 
      # # box plot of shot distances
      # plotlyOutput("shot_distances")
      
    )
  )
))
