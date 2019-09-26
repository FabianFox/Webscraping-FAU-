# Data on temporarily reinstated border controls in the Schengen Area

# Source: https://ec.europa.eu/home-affairs/what-we-do/policies/borders-and-visas/schengen/reintroduction-border-control_en
# pdf: https://ec.europa.eu/home-affairs/sites/homeaffairs/files/what-we-do/policies/borders-and-visas/schengen/reintroduction-border-control/docs/ms_notifications_-_reintroduction_of_border_control_en.pdf

# Load/install packages
### ------------------------------------------------------------------------###
if (!require("pacman")) install.packages("pacman")
p_load(tidyverse, curl, janitor, tabulizer, cowplot, ggwaffle)

# Temporary border checks
### ------------------------------------------------------------------------###
# Location of file
loc <- "https://ec.europa.eu/home-affairs/sites/homeaffairs/files/what-we-do/policies/borders-and-visas/schengen/reintroduction-border-control/docs/ms_notifications_-_reintroduction_of_border_control_en.pdf"

# Download file
curl_download(loc, "./data/Schengen.pdf")

# Load the data
# automatic detection of tables
bcontrol <- extract_tables("./data/Schengen.pdf", pages = 2) %>%
  .[[1]]

# manually detect the boundaries of the table
# bcontrol.df <- extract_areas("./data/Schengen.pdf", pages = 2)

# only approximately (needs further checks)
area <- list(
  c(110, 30, 710, 550),
  c(60, 30, 725, 550),
  c(60, 30, 705, 550),
  c(60, 30, 710, 550),
  c(60, 30, 750, 550),
  c(60, 30, 745, 550),
  c(60, 30, 740, 550),
  c(60, 30, 690, 550),
  c(60, 30, 650, 550)
)

# Multiple pages (supply columns)
#bcontrol <- extract_tables("./data/Schengen.pdf", guess = FALSE, 
#                           area = area, pages = c(2:10))

bnames <- bcontrol[1,]
bcontrol <- bcontrol[-1,]

bcontrol.df <- bcontrol %>%
  as_tibble() %>%
  set_names(nm = bnames) %>%
  clean_names() %>%
  mutate(nb = ifelse(nb == "", NA, nb),
         member_state = ifelse(member_state == "", NA, member_state)) %>%
  fill(nb, member_state, .direction = "down") %>%
  group_by(nb, member_state) %>%
  summarise(reasons_scope = paste0(reasons_scope, collapse = " "),
            duration = paste0(duration, collapse = " ")) %>%
  separate(duration, into = c("begin", "end"), sep = "[-]")