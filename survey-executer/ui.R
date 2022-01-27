library(shiny)
library(shinysurveys)
library(shinyWidgets)
library(shinyalert)
library(dplyr)
library(RPostgres)

source('LoginAndConnect.R')

shinyUI(fluidPage(

    useShinyalert(),

    tags$head(
        tags$title('take Survey')
    ),

    tags$script(HTML("
        $(document).keyup(function(event) {
            if (($('#pin').is(':focus') || $('#name').is(':focus')) && (event.keyCode == 13)) {
                $('#ok').click();
            } 
        });
    ")),

    fluidRow(
        column(4, offset = 4,
               tags$h1("Take Survey")
        ),
        column(2,
               uiOutput('surveyTimeframeUI')
        ),
        column(2,
               uiOutput('selectSurveyUI')
        )
    ),

    uiOutput('surveyUI')

))
