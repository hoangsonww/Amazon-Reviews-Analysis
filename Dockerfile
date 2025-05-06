# Use rocker/tidyverse as base
FROM rocker/tidyverse:4.2.2

# Install additional R packages
RUN R -e "install.packages(c('tidytext','sentimentr','lubridate'), repos='https://cloud.r-project.org')"

# Create working dir and copy files
WORKDIR /home/rstudio/project
COPY . .

# Default command: render the report
CMD ["Rscript", "-e", "rmarkdown::render('report.Rmd')"]
