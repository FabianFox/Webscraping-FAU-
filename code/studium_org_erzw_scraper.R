# studium.org: Studiengänge
# Erziehungswissenschaftliche Studienorte

# Load packages
if (!require("pacman")) install.packages("pacman")
p_load(tidyverse, rvest, qdap, janitor, robotstxt)

# General scheme
# (1) Inspect the website
# (a) Is the information available
# (b) Am I allowed to scrape the page
# (2) Retrieve the HTML data
# (3) Parse the data for the interesting chunk of information
# (4) Store the data
# (5) Repeat (loops)
# (6) Clean data

# (1) Inspect the URL
## ---------------------------------------------------------------------- ##

# (a) Is the information available
# Page listing all universities that grant degrees in "pedagogy" (BA&MA)
url <- "https://www.studium.org/erziehungswissenschaft/uebersicht-universitaeten"

# Each university has its' own page with additional information; grab all links
links <- url %>%
  read_html() %>%
  html_nodes(".lh1 a") %>%
  html_attr("href") %>%
  tibble(paste0("http://www.studium.org/", .)) %>%
  set_names(., nm = c("uni", "link"))

# (b) I scraping allowed/prohibited?
paths_allowed("http://www.studium.org/") # No robots.txt; check "impressum"


# (2) Retrieve the html data / (3) Parse data
## ---------------------------------------------------------------------- ##

# Get the information from all university pages
# Function applicable to all pages
steckbrief_fun <- function(x) {
  read_html(x) %>%           # (2) Import
    html_nodes(".right") %>% # (3) Retrieve
    html_text()              # (4) as text
}

# Save scraping
save_steckbrief_fun <- possibly(steckbrief_fun, NA_real_)

# (4) Store the data / (5) Repeat in a loop
## ---------------------------------------------------------------------- ##

# Apply to all pages using purrr::map
steckbrief.info <- map(.x = links$link, ~ {
  Sys.sleep(sample(seq(2, 5, by = .5), 1))   # friendly scraping
  save_steckbrief_fun(.x)
})

# (6) Clean data
## ---------------------------------------------------------------------- ##

# General data cleaning (RegEx, tidying)
# (A) Name the list
names(steckbrief.info) <- str_extract_all(links$uni, "(?<=/)[:alpha:].*")

# (B) Turn into long dataframe
uni.df <- steckbrief.info %>%
  enframe() %>%
  unnest()

# (C) RegEx: Transform messy numbers to tidy ones
uni.df <- uni.df %>%
  mutate(value = 
           str_extract(value, "[:digit:]+(,?|.?)[:digit:]+") %>%
           str_replace_all(., "\\.", "") %>%
           str_replace_all(., ",", ".") %>%
           parse_number() 
         )

# (D) Scrape variable names
# Scrape variable names for the construction of a data frame
# Variables should be constant over pages (better check this assumption)
var_names <- read_html(links$link[1]) %>%
  html_nodes(".rel.fs4") %>%
  html_text() %>%
  bracketX() %>%         # Cleaning
  tolower() %>%          # ...
  str_replace_all(.,     # ...
                  " ", 
                  replacement = "_") 

# (E) 
uni.df <- uni.df %>%
  mutate(
    var_names = rep(var_names, length(unique(name)))
  ) 

# Visualize
## ---------------------------------------------------------------------- ##

uni.df %>% 
  filter(var_names == "sonnenstunden_pro_jahr") %>%
  ggplot() +
  geom_point(aes(fct_reorder(name, value), value), 
             stat = "identity") +
  labs(title = "Deutschsprachige Erzw.-Institute nach Sonnenstunden im Jahr",
       subtitle = paste0("Die Differenz zwischen Berlin und Erlangen-Nürnberg beträgt ", 
                         round(
                           abs(
                             uni.df$value[uni.df$name == "erlangen-nürnberg" & var_names == "sonnenstunden_pro_jahr"] -
                               uni.df$value[uni.df$name == "hu-berlin" & var_names == "sonnenstunden_pro_jahr"]),
                           digits = 1),
                         " Sonnenstunde im Jahr."),
       x = "", y = "", caption = "Quelle: studium.org") +
  geom_point(data = subset(uni.df, name %in% c("erlangen-nürnberg", "hu-berlin") & var_names == "sonnenstunden_pro_jahr"),
             aes(fct_reorder(name, value), value), 
             stat = "identity", color = "red", size = 4) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        text = element_text(size = 14),
        axis.ticks = element_line(size = .5))
