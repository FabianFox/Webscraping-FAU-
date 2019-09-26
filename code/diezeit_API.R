# DieZeit-API (Beispiel)
# Artikel zum Thema "kulturelle Bildung"

# Load packages
if (!require("pacman")) install.packages("pacman")
p_load(tidyverse, rvest, lubridate, rzeit2, httr)

# General scheme
# (1) Authenticate (requires API-key)
# (2) Use the respective R package for queries
#     - if none is available: 
#       - httr / curl / plumber

# Basic use of an API
# ------------------------------------------------ #
api_key <- read_lines("C:/Users/guelzauf/Seafile/Meine Bibliothek/Projekte/diezeit_apikey.txt")

# Search for articles
query <- get_content(query = "\"kulturelle Bildung\"", limit = 250,
                     api_key = api_key)

# What does the query return?
str(query, max.level = 1)

# Which information is available for each result?
names(query$content)

# Distribution of articles over time
zeit.df <- tibble(
  date = query$content$release_date) %>%
  mutate(year = strtoi(str_extract(date, "[:digit:]{4}")),
         groups = cut(year, seq(1965, 2020, 5)))

# Plot
zeit.df %>%
  count(groups) %>%
  ggplot() +
  geom_bar(aes(x = groups, y = n), stat = "identity") +
  theme_minimal()

# Get the articles from DIE ZEIT 
# using the API and rvest
# ------------------------------------------------ #
# Get the articles
query.df <- tibble(
  links = paste0(map(query, "href")$content, "/komplettansicht"))
  
# Check for multiple pages
multipage <- map(query.df$links, ~{
  Sys.sleep(sample(seq(0, 3, 0.5), 1))
  http_error(.)})

# Append URL for those with multiple pages
query.df <- tibble(
  links = map(query[1], "href")$content,
  test = unlist(multipage)
) %>%
  mutate(links =
           case_when(test == FALSE ~ paste0(links, "/komplettansicht"),
                     test == TRUE ~ links))

# Define a function that get the articles
zeit_scraper <- function(x) {
  read_html(x) %>%
    html_nodes(".article-page p") %>% # Check the node
    html_text() 
}

# Works but due to limited number of queries articles are behind a paywall
# RSelenium might be a solution (using phantomJS)
query.df <- query.df %>%
  mutate(articles = 
           map(links, ~{
             Sys.sleep(sample(seq(0, 3, 0.5), 1))
             zeit_scraper(.)
             })
         )

# This is also available through the package:
# kult_bildung.df <- get_article_text(url = query$content$href, 
#                                   timeout = 2)
