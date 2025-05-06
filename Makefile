# Makefile for project

.Rmd      = report.Rmd
HTML      = report.html

all: knit

## Knit the R Markdown report
knit:
	Rscript -e "rmarkdown::render('$(.Rmd)')"

## Run the main analysis script
run:
	Rscript analysis.R

## Clean generated files
clean:
	rm -f $(HTML)
	rm -rf _bookdown_files/

## Check for missing packages
check-packages:
	Rscript -e "req <- c('tidyverse','tidytext','sentimentr','lubridate'); \
	            inst <- rownames(installed.packages()); \
	            if (any(!req %in% inst)) stop('Missing packages: ', paste(setdiff(req,inst), collapse=','))"
