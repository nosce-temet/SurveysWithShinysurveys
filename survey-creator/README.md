# Databank
This App connects to PostgreSQL-Databank. 

1. Adjust dbConnect-Function in server.R (lines 5-12)
2. Create table to hold information about the surveys. This table will be used in the SurveyExecuter and SurveyAnalyzer.

  create table surveys (
    id serial primary key,
    title text not null unique,
    description text,
    theme text,
    datum_start date not null,
    datum_end date not null,
    tablename_survey text not null,
    tablename_result text not null
  )
  
3. User that is used to login with app needs the following privileges
  + INSERT privileges on table *surveys* 
  + USAGE privileges on id-sequence
  + CREATE and USAGE privileges on schema *public*
