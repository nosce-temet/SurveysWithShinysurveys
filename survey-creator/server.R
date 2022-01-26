df <- data.frame(matrix(nrow = 0, ncol = 7))
names(df) <- c('question', 'option', 'input_type', 'input_id', 'dependence', 'dependence_value', 'required')

# adjust databank login information
db <- dbConnect(
  Postgres(), 
  dbname = 'surveys', 
  host = 'localhost', 
  port = 5432, 
  user = 'username', 
  password = 'password'
)

shinyServer(function(input, output) {

    rv <- reactiveValues(
        df = df,
        n = 1
    )
    
    observeEvent(input$appendQuestion, {
        id <- paste0('id_', rv$n)
        
        if(input$input_type == 'y/n')
            option <- c('yes','no')
        else
            option <- unlist(str_split(input$option,','))
        
        data <- data.frame(
            question = input$question,
            option = option,
            input_type = input$input_type,
            input_id = id,
            dependence = NA,
            dependence_value = NA,
            required = input$required
        )
        rv$df <- rbind(rv$df, data)
        
        rv$n <- rv$n + 1
        
    })
    
    output$surveyTable <- renderDT(rv$df)
    
    output$surveyPreview <- renderUI(
        surveyOutput(
            df = rv$df,
            survey_title = input$survey_title,
            survey_description = input$survey_description,
            theme = input$theme
        )
    )
    
    output$createQuestionUI <- renderUI({
        fluidRow(
            tags$h2(paste('Question # ', rv$n, ':')),
            switchInput(
                inputId = 'required',
                label = 'required',
                onLabel = 'YES',
                offLabel = 'NO',
                onStatus = 'success',
                value = TRUE
            ),
            textInput('question','Type in question'),
            selectInput(
                'input_type','Choose question type',
                choices = c(
                    'Text' = 'text',
                    'Number' = 'numeric',
                    'Selection' = 'select',
                    'Multiple Choice' = 'mc',
                    'Yes-No' = 'y/n'
                )
            ),
            conditionalPanel(
                condition = "input.input_type == 'select' | input.input_type == 'mc'",
                textInput('option','Type in options for answers (separated by commas)')
            )
        )
    })
    
    
    observeEvent(input$createSurvey, {
        if(rv$n > 1) {
            # append public.surveys
            ## add additional special characters to be cut if applicable
            tablename <- tolower(str_replace_all(input$survey_title,'([äöüß]|\\W)',''))
            query <- paste0(
                "insert into public.surveys(title, description, theme, datum_start, datum_end, tablename_survey, tablename_result)
            values ('",input$survey_title,"','",input$survey_description,"','",input$theme,"','",input$dateRange[1],"','",input$dateRange[2],
                "','",tablename,"_survey','",tablename,"_result')"
            )
            print(query)
            tryCatch({
                    dbSendQuery(db, query)
                    # write table for survey
                    dbWriteTable(db, Id(schema = 'public', table = paste0(tablename,'_survey')), value = rv$df, append = FALSE, overwrite = TRUE, row.names = FALSE)
                    # grant select to PUBLIC
                    query <- paste0("GRANT SELECT ON TABLE public.",tablename,"_survey TO PUBLIC;")
                    dbSendQuery(db, query)
                    # write table for result
                    query <- paste0('
                        create table public.',tablename,'_result (
                            subject_id text default current_user,
                            question_id text,
                            question_type text,
                            response text,
                            zeitstempel timestamp default now()
                        )
                    ')
                    dbSendQuery(db, query)
                    # grant insert, update to PUBLIC
                    query <- paste0("GRANT INSERT ON TABLE public.",tablename,"_result TO PUBLIC;")
                    dbSendQuery(db, query)
                },
                error = function(err) {
                    shinyalert(text = paste(err))
                    return()
                }
            )
            shinyalert(text = 'Survey was created')
        } else {
            shinyalert(text = 'Please create questions first')
        }
    })
    
    observeEvent(input$submit, {
        print(getSurveyData())
    })

})
