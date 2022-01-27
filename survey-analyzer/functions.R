getUI <- function(data) {

  question <- data$question[1]
  question_type <- data$question_type[1]
  result <- data %>% 
    count(response)

  if(question_type == 'text') {

    fig <- wordcloud2(data = result)

  } else if(question_type == 'numeric') {

    fig <- plot_ly(result, labels = ~response, values = ~n, type = 'pie')

  } else if(question_type == 'select') {

    fig <- plot_ly(result, x = ~n, y = ~response, type = 'bar', orientation = 'h')

  } else if(question_type == 'mc') {

    fig <- plot_ly(result, x = ~response, y = ~n, type = 'bar')

  } else if(question_type == 'y/n') {

    y <- c(question)
    x1 <- result$n[1]
    x2 <- result$n[2]

    fig <- plot_ly(
        result, x = ~x1, y = ~y, type = 'bar', orientation = 'h', name = 'yes'
      ) %>% 
      add_trace(
        x = ~x2, name = 'no'
      ) %>%
      layout(
        barmode = 'stack'
      )

  }

  return(fig)
}
