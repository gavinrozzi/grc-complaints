# Scraper for New Jersey GRC Complaints

library(rvest)
library(dplyr)
library(lubridate)

# Get GRC complaints
content <- read_html('https://www.nj.gov/cgi-bin/dca/grc/decisionsearch.pl') %>%
  html_nodes("table")

# Extract the data from a specific table
complaints = html_table(content[8], header = TRUE)[[1]]

# Build URLs to link to PDFs and HTML of complaint decisions + summaries
baseurl <- "https://www.nj.gov/grc/decisions/pdf/"
baseurl_html <- "https://www.nj.gov/grc/decisions/"
baseurl_summary <- "https://www.nj.gov/grc/decisions/summary/"


# Generate HTML links if that complaint has an HTML version available, do the same for summaries and PDF
for (i in 1:nrow(complaints)) {
  if (complaints$HTML[i] == 'html') {
    complaints$HTML[i] <- paste0(baseurl_html,complaints$CaseNumber[i],".html")
  }
  if (complaints$Summary[i] == 'Summary') {
    complaints$Summary[i] <- paste0(baseurl_summary,complaints$CaseNumber[i],".html")
  }
  if (complaints$PDF[i] == 'pdf') {
    complaints$PDF[i] <- paste0(baseurl,complaints$CaseNumber[i],".pdf")
  }
}

# Manually fix problematic PDF urls
complaints$PDF[11] <- paste0(baseurl,"Mann v. Borough of Woodcliff Lake, 2005-69 (FD).pdf")

complaints$PDF[12] <- paste0(baseurl,"2005-125-FD.pdf")


# Parse raw text from PDF if there is a PDF associated with a complaint
for (i in 1:nrow(complaints)) {
    complaints$text[i] = pdf_text(complaints$PDF[i])
}


# Extract data from text
terms <- unlist(strsplit(complaints$text[2224], "\n"))
terms[grep("Date of Request:", terms)]
terms[grep("Date of Complaint:", terms)]

# Write out the scraped data
write.csv(complaints,'grc-complaints.csv',row.names = FALSE)