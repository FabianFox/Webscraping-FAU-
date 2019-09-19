# Load required packages
pacman::p_load(tidyverse, httr, rvest)

# Request/Response-Pair
response <- GET("https://www.studium.org/erziehungswissenschaft/suche/?view=uni")

# Extract information
study.df <- response %>% 
  read_html() %>%                # (a) Import
  html_nodes(".fs3.mr_1b") %>%   # (b) Identify
  html_text() %>%                # (c) Extract
  tibble(studienort = .)         # 

# Create a plot of federal states with pedagogy programmes
studienort.fig <- study.df %>%
  count(studienort) %>%
  mutate(studienort = str_to_title(tolower(studienort))) %>%
  ggplot(aes(x = studienort, y = n)) +
  geom_bar(stat = "identity") +
  labs(x = "", y = "", 
       title = "Erziehungswiss. Studiengänge im deutschsprachigen Raum",
       caption = "Quelle: studium.org") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        text = element_text(size = 10),
        axis.ticks = element_line(size = .5))
