dbCon <- function(dbname, user, password) {
  return(
    dbConnect(
      Postgres(),
      dbname = dbname,
      host = 'localhost',
      port = 5432,
      user = user,
      password = password
    )
  )
}

loginModal <- function(failed = FALSE) {
  modalDialog(
    
    textInput('user', 'Please type in user name', value = ''),
    passwordInput('pin', 'Please type in passwort', value = ''),
    
    if (failed)
      div(tags$b("Login failed. Please check user name and password.", style = "color: red;")),
    
    footer = tagList(
      actionButton("ok", "OK")
    )
  )
}

catchDbCon <- function(dbname, user, password) {
  
  dbCon <- tryCatch({
    dbCon(dbname, user, password)
    },
    ## show modal with login fail message if connection failed
    error = function(err) {
      print(err)
      showModal(loginModal(failed = TRUE))
      return()
    }
  )
  
  return(dbCon)
} 
