shinyServer(function(input, output) {

    rv <- reactiveValues(
        db = NULL,
        df = NULL,
        survey_title = NULL,
        survey_description = NULL,
        theme = NULL
    )
    
# login
    showModal(loginModal())
    
    observeEvent(input$ok, {
        
        removeModal()
        
        ## users need connect privilege to surveys databank to use app
        rv$db <- catchDbCon('surveys', input$user, input$pin)
        
        query <- 'select * from surveys where now() between datum_start and datum_end'
        rv$availableSurveys <- dbGetQuery(rv$db, query)
    })
    
    output$selectSurveyUI <- renderUI(
        selectInput(
            inputId = 'chooseSurvey',
            label = 'Choose survey',
            choices = rv$availableSurveys$title,
            selected = NULL,
            multiple = FALSE,
            selectize = TRUE,
            width = NULL,
            size = NULL
        )
    )
    
    output$surveyTimeframeUI <- renderUI({
        output$start <- renderText(
            format(rv$currentSurvey$datum_start, format="%B %d %Y")
        )
        output$end <- renderText(
            format(rv$currentSurvey$datum_end, format="%B %d %Y")
        )
        fluidRow(
            column(
                6,
                tags$label('start'),
                verbatimTextOutput('start')   
            ),
            column(
                6,
                tags$label('end'),
                verbatimTextOutput('end')
            )
        )
    })
    
    observeEvent(input$chooseSurvey, {
        if(!is.null(rv$db)) {
            rv$currentSurvey <- rv$availableSurveys %>% filter(title == input$chooseSurvey)
            print(rv$currentSurvey)
            
            query <- paste0('select * from ', rv$currentSurvey$tablename_survey)
            rv$df <- dbGetQuery(rv$db, query)
        }
    })
    
    output$surveyUI <- renderUI(
        if(!is.null(rv$db)) {
            surveyOutput(
                df = rv$df,
                survey_title = rv$currentSurvey$title,
                survey_description = rv$currentSurvey$description,
                theme = rv$currentSurvey$theme
            )
        }
    )
    
    observeEvent(input$submit, {
        surveyData <- getSurveyData()
        surveyData <- surveyData %>% select(-subject_id)
        
        dbWriteTable(rv$db, Id(schema = 'public', table = rv$currentSurvey$tablename_result), value = surveyData, append = TRUE, overwrite = FALSE, row.names = FALSE)
        
        print(surveyData)
        
        shinyalert(
            title = 'Congratulations!',
            text = 'Your participation was submitted.'
        )
    })

})
