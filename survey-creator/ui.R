library(shiny)
library(shinysurveys)
library(shinyWidgets)
library(shinyalert)
library(DT)
library(colourpicker)
library(stringr)
library(dplyr)
library(RPostgres)

shinyUI(fluidPage(
    
    useShinyalert(),

    tags$head(
        tags$title('SurveyCreator')
    ),
    
    fluidRow(
        column(6, offset = 3,
               tags$p(style = 'padding-bottom: 13px;'),
               tags$h1("Create Survey")
        )
    ),
    
    sidebarLayout(
        sidebarPanel(
            tabsetPanel(
                tabPanel(
                    'general',
                    textInput('survey_title', 'Type in title for survey', value = 'Title'),
                    textInput('survey_description', 'Type in description for survey', value = 'Description'),
                    colourInput('theme', 'Choose color for survey (optional)', value = NULL),
                    dateRangeInput('dateRange', 'Choose duration of survey'),
                    actionButton('createSurvey', 'Create Survey', class = 'btn-primary')
                 ),
                tabPanel(
                    'Create Questions',
                    uiOutput('createQuestionUI'),
                    actionButton('appendQuestion', 'Append Question', class = 'btn-primary')
                )
            )
        ),

        mainPanel(
            tabsetPanel(
                tabPanel('Preview Table', DTOutput('surveyTable')),
                tabPanel('Preview Survey', uiOutput('surveyPreview'))
            )
        )
    )
))
