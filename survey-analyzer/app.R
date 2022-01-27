library(shiny)
library(shinydashboard)
library(shinyalert)
library(dplyr)
library(stringr)
library(DT)
library(ggplot2)
library(plotly)
library(wordcloud2)
library(lubridate)
library(RPostgres)

source('functions.R')

# adjust login data for databank
db <- dbConnect(
  Postgres(),
  dbname = 'surveys',
  host = 'localhost',
  port = 5432,
  user = 'username',
  password = 'password'
)

availableSurveys <- dbGetQuery(db, 'select * from surveys where datum_end < now() order by title;')

ui <- dashboardPage(

  dashboardHeader(title = 'Analyze Survey Results'),
  dashboardSidebar(
    selectInput(
      "chooseSurvey", 
      label = "Choose survey",
      choices = availableSurveys$title
    ),
    tags$p('In this dashboard you can view results of finished surveys.')
  ),
  dashboardBody(
    fluidRow(
      valueBoxOutput('n_user'),
      valueBoxOutput('n_quests')
    ),
    div(id="placeholder")
  ),

  useShinyalert()
)

server <- function(input, output, session) {
  rv <- reactiveValues(
    idUI = NULL
  )

  observeEvent(input$chooseSurvey, {
    if(!is.null(rv$idUI)) {
      for(ui in rv$idUI)
        removeUI(
          selector = paste0("#",ui)
        )
    }

    rv$currentSurvey <- availableSurveys %>% 
      filter(title == input$chooseSurvey)

    rv$currentSurveyInfo <- dbGetQuery(db, paste0('select * from ',rv$currentSurvey$tablename_survey))

    query <- paste0(
      'SELECT DISTINCT ON (subject_id, question_id)
          subject_id, question_id, question_type, response, zeitstempel 
       FROM ', rv$currentSurvey$tablename_result,
      ' ORDER BY subject_id, question_id, zeitstempel DESC;'
    )
    rv$currentSurveyData <- dbGetQuery(db, query)

    rv$n_user <- length(unique(rv$currentSurveyData$subject_id))
    rv$n_quests <- length(unique(rv$currentSurveyData$question_id))

    quests <- unique(rv$currentSurveyInfo %>% select(question, input_id) %>% arrange(desc(input_id)))

    if(rv$n_user > 0)
      for (id in quests$input_id) {

        rv$idUI <- c(rv$idUI, id)

        data <- rv$currentSurveyData %>%
          inner_join(quests, by = c("question_id" = "input_id")) %>%
          filter(question_id == id)

        insertUI(
          selector = "#placeholder",
          where = "afterEnd",
          ui = fluidRow(id = id,
            tags$h3(data$question[1]),
            getUI(data)
          )
        )
      }
    else
      shinyalert('No participants.')
  })

  output$n_user <- renderValueBox({
    if(!is.null(input$chooseSurvey)) {
      valueBox(
        value = rv$n_user,
        subtitle = 'Number of Participants',
        icon = icon("user"),
        color = 'blue'
      )
    }
  })

  output$n_quests <- renderValueBox({
    valueBox(
      value = rv$n_quests,
      subtitle = 'Number of Questions',
      icon = icon("question"),
      color = 'orange'
    )
  })
}

shinyApp(ui = ui, server = server)
