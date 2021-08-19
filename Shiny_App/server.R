library(shiny)
library(data.table)
library(stringr)
library(ggplot2)
library(tidyverse)
library(stringr)
library(ggrepel)
library(here)

netflix <- readRDS( "netflix_data.Rds")
netflix$selected <- "No"
netflix$genre <- str_to_title(netflix$genre) 

plot_ratings <- function(dataset, genreinput, titleinput){
  dataset %>% 
    ggplot(aes(x=genre,y=imdb_score)) +
    geom_boxplot(data = netflix[genre != genreinput], outlier.shape = NA) + 
    geom_jitter(data = netflix[genre != genreinput], width=0.1, alpha=0.8) +
    geom_boxplot(data = netflix[genre == genreinput], fill='indianred', alpha = 0.5, outlier.shape = NA) +
    geom_jitter(data = netflix[genre == genreinput], width=0.1,alpha=0.8, color = "darkred") +
    geom_label_repel(data = netflix[title == titleinput], aes(label = title), arrow = arrow(length = unit(0.02, "npc")), box.padding = 1) +
    xlab("") +
    ylab("") +
    theme_classic() +
    theme(axis.text=element_text(size=13, face = "bold")) 
}

plot_language <- function(dataset){
  popular_languages <- setorder(dataset[,.(.N, imdb_score = mean(imdb_score)),by = language], -N)[1:8]
  ggplot(aes(reorder(language,-imdb_score), imdb_score), data = popular_languages) +
    geom_bar(stat="identity", fill = "indianred") +
    scale_fill_brewer(palette="Pastel1") +
    xlab("") + 
    ylab("") + 
    ggtitle("") +
    coord_cartesian(ylim = c(5, 7.5)) + 
    theme_classic() +
    theme(axis.text=element_text(size=13, face = "bold")) +
    theme(axis.text.x = element_text(angle=60, vjust=1, hjust=1))
}

table_subset <- function(dataset, movieSelection, num_rows, dataset2){
  unique(rbind(head(dataset, num_rows-1), if(missing(dataset2)) {
    dataset[title == movieSelection]
  } else {
    dataset2[title == movieSelection]
  }))
}

shinyServer(
  function(input, output) {
    
    # Get filters from inputs
    movie_subset <- reactive({
      sort(netflix[genre == input$genre, title])
      })
    netflix_reactive <- reactive({
      netflix[title == input$Movie, selected := "Yes"]
      netflix
    })
    
    data_selected <- reactive({
      if(is.null(input$plot_brush)){
        table_subset(netflix_reactive(), input$Movie, input$slider_rows)
      } else {
        table_subset(brushedPoints(netflix_reactive(), input$plot_brush), input$Movie, input$slider_rows, netflix_reactive())[order(-imdb_score)]
      }
      
    })
    
    output$filtered_movies <- renderUI({
      selectInput(inputId = "Movie", "Select Movie", choices = movie_subset(), multiple = F)
    })
    
    output$plotted_ratings <- renderPlot({
      shiny::validate(
        need(input$Movie, "")
      )
      plot_ratings(netflix_reactive(), input$genre, input$Movie)
    })
    
    output$language_plot <- renderPlot({
      plot_language(netflix)
    })
    
    output$database <- DT::renderDataTable({
        options(DT.options = list(dom = 't', ordering = FALSE, scrollX = TRUE))
        DT::datatable(data_selected(), rownames = FALSE, selection = 'none') %>%
        DT::formatStyle('selected', target = 'row', 
        fontWeight = DT::styleEqual(unique(data_selected()$selected), ifelse(unique(data_selected()$selected) == 'Yes','bold','standard')),
        color = DT::styleEqual(unique(data_selected()$selected), ifelse(unique(data_selected()$selected) == 'Yes','red','black')),
        backgroundColor = DT::styleEqual(unique(data_selected()$selected), ifelse(unique(data_selected()$selected) == 'Yes','#ebecf0','white')))
    })
  }
)