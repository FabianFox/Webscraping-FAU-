# Internet availability in German households
# Eurostat-API

# Load required packages
if(!require(pacman)) install.packages(pacman)
pacman::p_load(tidyverse, 
               eurostat, ggrepel) # example specific

# Get the data using the eurostat-API and plot with ggplot2
get_eurostat("isoc_r_iacc_h", time_format = "date",
             stringsAsFactors = FALSE, filters = 
               list(geo = "DE")) %>%
  mutate(time = strtoi(str_extract(time, "[:digit:]{4}")),
         highlight = ifelse(time %in% c(2006, 2018), paste0(values, "%"), NA)) %>%
  ggplot(aes(x = time, y = values)) +
  geom_line(stat = "identity", size = 1, color = '#377eb8') +
  geom_point(stat = "identity", size = 4, color = '#377eb8') +
  geom_text_repel(aes(label = highlight), vjust = -1.05, nudge_y = 1) +
  scale_y_continuous(labels = function(x) paste0(x, "%")) +
  scale_x_continuous(breaks = seq(2006, 2020, 2)) +
  labs(x = "", y = "", 
       title = "Anteil der Haushalte in Deutschland mit Internetzugang",
       caption = "Quelle: Eurostat (Variable: isoc_r_iacc_h)") +
  theme_minimal() +
  theme(panel.grid.minor.x = element_blank(),
        panel.grid.major.x = element_blank(),
        text = element_text(size = 12),
        axis.ticks = element_line(size = .5))
