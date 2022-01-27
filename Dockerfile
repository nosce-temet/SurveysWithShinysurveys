FROM r-base:4.1.1

ENV DEBIAN_FRONTEND=noninteractive

# Install dependency libraries
RUN apt-get update && apt-get install -y  \
            sudo \
            pandoc \
            pandoc-citeproc \
            libpq-dev \
            libgdal-dev \
            libcairo2-dev \
            libxt-dev \
            libssl-dev \
            libxml2-dev \
            libudunits2-dev \
            libssh2-1-dev \
            libcurl4-openssl-dev \
            libsasl2-dev \
	          libv8-dev \
            && rm -rf /var/lib/apt/lists/*

# uncomment to build survey-creator
#RUN Rscript -e "install.packages(c('shiny','shinysurveys','shinyWidgets','shinyalert','DT','colourpicker','stringr','dplyr','RPostgres'))"
#COPY survey-creator /survey-creator
#WORKDIR /survey-creator

# uncomment to build survey-executer
#RUN Rscript -e "install.packages(c('shiny','shinysurveys','shinyWidgets','shinyalert','dplyr','RPostgres'))"
#COPY survey-executer /survey-executer
#WORKDIR /survey-executer

# uncomment to build survey-analyzer
#RUN Rscript -e "install.packages(c('shiny','shinyalert','dplyr','DT','ggplot2','shinydashboard','plotly','stringr','RPostgres','lubridate','wordcloud2'))"
#COPY survey-analyzer /survey-analyzer
#WORKDIR /survey-analyzer

CMD [ "Rscript", "-e", "shiny::runApp(host='0.0.0.0', port=3838)" ]

EXPOSE 3838
