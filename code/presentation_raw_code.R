# Raw code for ""Web Scraping mit R"
# Webscraping_FAU.Rmd


# Load/install packages
## ---------------------------------------------------------------------- ##
if(!require("pacman")) install.packages(pacman)
p_load(tidyverse, rvest, lubridate,                      # tidyverse
       httr, robotstxt, qdap, janitor, devtools, rzeit2)


# SLIDE 5: Sinkende Ausschöpfungsquoten (vgl. Carsten Schwemmer)
## ---------------------------------------------------------------------- ##
# - GitHub: https://github.com/cschwem2er/allbus_responserates


# SLIDE 6: Internetnutzung
## ---------------------------------------------------------------------- ##
# - GitHub: https://github.com/FabianFox/Webscraping-FAU-/blob/master/code/internet_use_de_eurostat.R


# SLIDE 14: Beispiel: HTTP
## ---------------------------------------------------------------------- ##
response <- GET("https://www.studium.org/erziehungswissenschaft/suche/?view=uni") %>%
  print()


# SLIDE 16: Beispiel: HTTP
## ---------------------------------------------------------------------- ##
study.df <- response %>% 
  read_html() %>% 
  html_nodes(".fs3.mr_1b") %>%
  html_text() %>%
  tibble(studienort = .)

# - Grafik auf GitHub: 
# https://github.com/FabianFox/Webscraping-FAU-/blob/master/code/pedagogy_programs_example.R


# SLIDE 25: Studium.org: Internetseite kennenlernen
## ---------------------------------------------------------------------- ##
# /robots.txt

paths_allowed(
  paths  = c("/erziehungswissenschaft"), 
  domain = c("studium.org"), 
)


# SLIDE 27: Studium.org: Import von HTML-Seiten
## ---------------------------------------------------------------------- ##
html.page <- read_html("https://www.studium.org/erziehungswissenschaft/erlangen-n%C3%BCrnberg")


# SLIDE 30: Studium.org: CSS-Selektor
## ---------------------------------------------------------------------- ##
html.nodes <- html_nodes(html.page, css = ".right")


# SLIDE 31: Studium.org: Umwandeln in Text/Tabelle
## ---------------------------------------------------------------------- ##
html.text <- html.nodes %>%
  html_text()


# SLIDE 32: Datenaufbereitung: RegEx
## ---------------------------------------------------------------------- ##
str_view(string = "Wichtig ist die Zahl 42!",
         pattern = "[:digit:]+")


# SLIDE 33: RegEx: Studium.org
## ---------------------------------------------------------------------- ##
html.text <- html.text %>%
  str_extract(., "[:digit:]+(,?|.?)[:digit:]+") %>%
  str_replace_all(., "\\.", "") %>%
  str_replace_all(., ",", ".") %>%
  parse_number() %>%
  enframe()


# SLIDE 35: URLs zu den Einzelseiten
## ---------------------------------------------------------------------- ##
# (A) Liste mit Links zu den Einzelseiten
url <- "https://www.studium.org/erziehungswissenschaft/uebersicht-universitaeten"

# (B) Node-Attribut mit Link ("href")
links <- url %>%
  read_html() %>%
  html_nodes(".lh1 a") %>%
  html_attr("href") %>%
  tibble(paste0("http://www.studium.org/", .)) %>%
  set_names(., nm = c("uni", "link"))


# SLIDE 36: 2. Funktionen erstellen
## ---------------------------------------------------------------------- ##
# Some data
test <- tibble(
  var1 = c(1, 3, 5, 9),
  var2 = c(5, 5, 5, 5)
)
# Function
perc_fun <- function(x){  # formals
  x / sum(x) * 100        # body
}
# Apply
map(test, perc_fun) # Loop


# SLIDE 36: 2. Funktionen erstellen (Studium.org)
## ---------------------------------------------------------------------- ##
steckbrief_fun <- function(x) {
  read_html(x) %>%           # (2) Import      # Body besteht
    html_nodes(".right") %>% # (3) Extrahieren # aus Einzelfall-
    html_text()              # (4) als Text    # Vorgehen
}
# Save scraping
save_steckbrief_fun <- possibly(steckbrief_fun, NA_real_)


# SLIDE 37: 3. Iteration über alle Seiten
## ---------------------------------------------------------------------- ##
steckbrief.info <- map(.x = links$link, ~ {
  Sys.sleep(sample(seq(2, 5, by = .5), 1)) # friendly scraping
  save_steckbrief_fun(.x)
})


# SLIDE 40: Datenaufbereitung (A & B)
## ---------------------------------------------------------------------- ##
# (A) Liste benennen
names(steckbrief.info) <- str_extract_all(links$uni, "(?<=/)[:alpha:].*")

# (B) "long"-Format
uni.df <- steckbrief.info %>%
  enframe() %>%
  unnest()

# SLIDE 41: Datenaufbereitung (C)
## ---------------------------------------------------------------------- ##
# (C) Daten bereinigen
uni.df <- uni.df %>%
  mutate(value = 
           str_extract(value, "[:digit:]+(,?|.?)[:digit:]+") %>%
           str_replace_all(., "\\.", "") %>%
           str_replace_all(., ",", ".") %>%
           parse_number() 
  )


# SLIDE 42: Datenaufbereitung (D)
## ---------------------------------------------------------------------- ##
# (D) Variablennamen ergänzen: Scrapen
var_names <- read_html(links$link[1]) %>%
  html_nodes(".rel.fs4") %>%
  html_text() %>%
  bracketX() %>%         # Cleaning (qdap::bracketX)
  tolower() %>%          # ...
  str_replace_all(.,     # ...
                  " ", 
                  replacement = "_") 

# ...: Ergänzen
uni.df <- uni.df %>%
  mutate(
    var_names = rep(var_names, length(unique(name)))
  ) 


# SLIDE 44: Ergebnis: Visualisierung
## ---------------------------------------------------------------------- ##
# - GitHub: https://github.com/FabianFox/Webscraping-FAU-/blob/master/code/studium_org_erzw_scraper.R


# SLIDE 46: API: Steigende Relevanz
## ---------------------------------------------------------------------- ##
# - GitHub: https://github.com/FabianFox/Webscraping-FAU-/blob/master/code/programmableweb-Scraper.R


# SLIDE 49: Kulturelle Bildung in der "Die Zeit"
## ---------------------------------------------------------------------- ##
query <- get_content(query = "\"kulturelle Bildung\"", limit = 250,
                     api_key = api_key) # authentifizieren

names(query$content)


# SLIDE 50: rzeit2: Informationen verwenden
## ---------------------------------------------------------------------- ##
# Distribution of articles over time
zeit.df <- tibble(
  date = query$content$release_date) %>%
  mutate(year = strtoi(str_extract(date, "[:digit:]{4}")),
         groups = cut(year, seq(1965, 2020, 5)))

# nicht auf der Folie
zeit.df %>%
  count(groups) %>%
  ggplot() +
  geom_bar(aes(x = groups, y = n), stat = "identity") +
  theme_minimal()