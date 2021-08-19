library(shiny)
library(shinydashboard)
library(shinyWidgets)
library(stringr)
library(here)

netflix <- readRDS("netflix_data.Rds")
netflix$genre <- str_to_title(netflix$genre) 

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Netflix Originals", tabName = "netflix_originals", icon = icon("angle-double-right")),
    menuItem("Data Exploration", icon = icon("search"), badgeLabel = "link", badgeColor = "green", 
              href = "https://rpubs.com/swerner1896/800267"),
    menuItem("Github", icon = icon("file-code-o"), badgeLabel = "link", badgeColor = "green", 
             href = "https://github.com/Stefan1896/Netflix_Project/")
  )
)

body <- dashboardBody(
  chooseSliderSkin("Flat"),
  tabItems(
    tabItem(tabName = "netflix_originals",
            fluidRow(
              br(),
              column(width = 12, box(
                title = HTML('<span class="fa-stack fa-lg" style="color:#FF0000">
                                        <i class="fa fa-square fa-stack-2x"></i>
                                        <i class="fa fa-mouse-pointer fa-inverse fa-stack-1x"></i>
                                        </span> <span style="font-weight:bold;font-size:20px">
                                          Please select a movie</span>'),
                width = 4,
                "The table below covers more information about your selected movie and the highest rated movies from the Netflix Originals database. You can also mark an area in the plot on the right, to see the top rated movies from this area along with your selected movie in the table below!",
                br(),
                br(),
                selectInput("genre", "Genre", selected = "documentary", choices = sort(unique(netflix$genre))),
                uiOutput("filtered_movies"),
                
                #tags$img(src = "NetflixLogo.PNG", style="max-height: 150px; max-width: 600px")
                ),
                box(
                  title = HTML('<span class="fa-stack fa-lg" style="color:#FF0000">
                                        <i class="fa fa-square fa-stack-2x"></i>
                                        <i class="fa fa-chart-bar fa-inverse fa-stack-1x"></i>
                                        </span> <span style="font-weight:bold;font-size:20px">
                                          Movie Ratings - IMDB Scores by Genre</span>'),
                  plotOutput("plotted_ratings", brush = "plot_brush"),
                  width = 8
              )
            )
          ),
          fluidRow(
            br(),
            column(width = 12, offset = 0, box(
                  title = HTML('<span class="fa-stack fa-lg" style="color:#FF0000">
                                        <i class="fa fa-square fa-stack-2x"></i>
                                        <i class="fa fa-info fa-inverse fa-stack-1x"></i>
                                        </span> <span style="font-weight:bold;font-size:20px">
                                          More Information</span>'),
                  width = 7,
                  hr(),
                  DT::dataTableOutput("database"),
                  tags$style(type="text/css",
                             ".shiny-output-error { visibility: hidden; }",
                             ".shiny-output-error:before { visibility: hidden; }"),
                  hr(),
                  tags$style("#slider_rows {font-size:30px;}"),
                  setSliderColor("indianred",1),
                  tagList(
                    tags$style(type = 'text/css', '#big_slider .irs-grid-text {font-size: 12px}
                                .irs-grid-pol {display: none;}
                                .irs-min {display: none;}
                                .irs-max {display: none;}
                                .irs-single {font-size: 12px}'), 
                    div(id = 'big_slider',
                        sliderInput("slider_rows", "max Rows:", min = 1, max = 10, value = 5)
                    ) #div close
                  ) #taglist close
              ),
              box(
                title = HTML('<span class="fa-stack fa-lg" style="color:#FF0000">
                                        <i class="fa fa-square fa-stack-2x"></i>
                                        <i class="fa fa-chart-bar fa-inverse fa-stack-1x"></i>
                                        </span> <span style="font-weight:bold;font-size:20px">
                                          IMDB score by language</span>'),
                hr(),
                plotOutput("language_plot"),
                width = 5
              )
            ),
          )
    )
  ),
  tags$head(tags$style(HTML('
      .content-wrapper {
        background-color: #fff;
      }
    '
  )))
)

# Put them together into a dashboardPage
dashboardPage(
  skin = "red",
  dashboardHeader(title = "Netflix analysis"),
  sidebar,
  body
)