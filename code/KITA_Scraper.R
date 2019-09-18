############################
#     KiTa-Scraper         #
#                          #
#     Created on:          #
############################     

# Setup
# Load required packages
## ----------------------------------------------------------- ##
if (!require("pacman")) install.packages("pacman")
p_load(tidyverse, ggmap)

# GoogleMaps-API (for later geocoding)
gmap_api <- readLines("C:/Users/guelzauf/Seafile/Meine Bibliothek/Projekte/googlemaps_apikey.txt")
register_google(key = gmap_api)

# Go to the digital register of Berlin kindergartens and inspect
# the URL
## ----------------------------------------------------------- ##
# URL 
# Base URL
base_url <- "https://www.berlin.de/sen/jugend/familie-und-kinder/kindertagesbetreuung/kitas/verzeichnis/"

# Because the results are filtered through a form (and not through the URL), we 
# have to fill the form in a session
kita_session <- html_session(base_url)

# Request KiTas with emphasis on "aestehtic education"
fill_form <- kita_session %>%
  html_node("#Form1") %>%
  html_form() %>%
  set_values("ddlThemSchwerpunkt" = "8")

# Fill the form and work on the resulting URL
query <- kita_session %>%
  submit_form(fill_form)

# Extract the desired information
# (A) Name
kita_name <- query %>%
  html_nodes("#DataList_Kitas a") %>%
  html_text()

# (B) Address
kita_address <- query %>%
  html_nodes("span:nth-child(6)") %>%
  html_text() %>%
  paste0(., ", Berlin, Germany")

# Combine into a dataframe
kita.df <- tibble(
  name = kita_name,
  address = kita_address
)

# 


# Add the longitudes and latitudes
for(i in 1:nrow(kita.df)) {
  result <- tryCatch(geocode(kita.df$address[i], output = "latlon", source = "google"),
                     warning = function(w) data.frame(lon = NA, lat = NA, address = NA))
  kita.df$lat[i] <- as.numeric(result[1])
  kita.df$lon[i] <- as.numeric(result[2])
}

# Three kindergarten had to be manually geocoded because their address were ambiguous.
# They are:
# id: "02060350" "02051270" "12201490"
# In addition, for a small set of kindergarten, I used their name as search key.

# Save the DF including lat/lon
#saveRDS(object = kita.df, file = "C:\\Users\\User\\HU-Box\\Seafile\\Meine Bibliothek\\Seminare\\WS 2017\\Code\\Berlin KiTA\\KitaDF")
kita.df <- readRDS(file = "C:\\Users\\User\\HU-Box\\Seafile\\Meine Bibliothek\\Seminare\\WS 2017\\Code\\Berlin KiTA\\KitaDF")

# Scrape further information on the KiTAs
## ----------------------------------------------------------- ##

# URL 
url <- "https://www.berlin.de/sen/jugend/familie-und-kinder/kindertagesbetreuung/kitas/verzeichnis/ListeKitas.aspx?aktSuchbegriff="

# Get the links that lead to the sub-pages
links <- html_attr(html_nodes(read_html(url), css = "#DataList_Kitas a"), "href")

# I need just the end of the links
links.no <- unlist(stringr::str_extract_all(links, pattern = "[:digit:]+"))

# This is the URL that is appended using links.no
url <- "https://www.berlin.de/sen/jugend/familie-und-kinder/kindertagesbetreuung/kitas/verzeichnis/"

# Initiate the objects necessary for the loop
kita.mat <- matrix(nrow = length(links.no), ncol = 6)
j <- 1

# The actual loop [should be ready to run in this state]
for(i in links.no){
  
  print(paste0("Scraping information on KiTa ", j, " of ", length(links.no)))
     
  # Go to link
  page <- read_html(paste0(url, "KitaDetailsNeu.aspx?ID=%20", i))
  
  # Get the information on:
  
  # Einrichtungsart (node: #lblEinrichtungsart)
  Einrichtungsart <- html_nodes(page, css = "#lblEinrichtungsart") %>%
    html_text()

  # Mehrsprachigkeit (node: #lblMehrsprachigkeit)
  Mehrsprachigkeit <- html_nodes(page, css = "#lblMehrsprachigkeit") %>%
    html_text()
  
  # P?dagogische Schwerpunkte (node: #lblPaedSchwerpunkte)
  PSchwerpunkt <- html_nodes(page, css = "#lblPaedSchwerpunkte") %>%
    html_text()
  
  # P?dagogische Ans?tze (node: #lblPaedAnsaetze)
  Ansaetze <- html_nodes(page, css = "#lblPaedAnsaetze") %>%
    html_text()
  
  # Besondere Angebote (node: #lblBesondereAngebote)
  Angebote <- html_nodes(page, css = "#lblBesondereAngebote") %>%
    html_text()
  
  # Thematische Schwerpunkt (node: #lblThemSchwerpunkte)
  TSchwerpunkt <- html_nodes(page, css = "#lblThemSchwerpunkte") %>%
    html_text() 
  
  kita.mat[[j, 1]] <- ifelse(length(Einrichtungsart) == 0, NA, Einrichtungsart)
  kita.mat[[j, 2]] <- ifelse(length(Mehrsprachigkeit) == 0, NA, Mehrsprachigkeit)
  kita.mat[[j, 3]] <- ifelse(length(PSchwerpunkt) == 0, NA, PSchwerpunkt)
  kita.mat[[j, 4]] <- ifelse(length(Ansaetze) == 0, NA, Ansaetze)
  kita.mat[[j, 5]] <- ifelse(length(Angebote) == 0, NA, Angebote)
  kita.mat[[j, 6]] <- ifelse(length(TSchwerpunkt) == 0, NA, TSchwerpunkt)

  j <- j + 1
  
  Sys.sleep(sample(seq(0,2,0.5), 1))  
}

# The loop above was one in a piecemeal way in order to avoid web errors

# Combine
kitam.df <- m

colnames(kitam.df) <- c("Einrichtungsart", "Mehrsprachigkeit", "P?dSchwerpunkt", "P?dAnsatz",
                        "BesAngebote", "ThemSchwerpunkt")

#saveRDS(object = kitam.df, file = "C:\\Users\\User\\HU-Box\\Seafile\\Meine Bibliothek\\Seminare\\WS 2017\\Code\\Berlin KiTA\\KitaMatDF")

# Combine the data frame with id and geographical location (kita.df) and the 
# information on programmes (kitam.df).

# Load
#kita.df <- readRDS(file = "C:\\Users\\User\\HU-Box\\Seafile\\Meine Bibliothek\\Seminare\\WS 2017\\Code\\Berlin KiTA\\KitaDF")
#kitam.df <- readRDS(file = "C:\\Users\\User\\HU-Box\\Seafile\\Meine Bibliothek\\Seminare\\WS 2017\\Code\\Berlin KiTA\\KitaMatDF")

# Combine
kita.df <- cbind(kita.df, kitam.df)

# Save
#saveRDS(object = kita.df, file = "C:\\Users\\User\\HU-Box\\Seafile\\Meine Bibliothek\\Seminare\\WS 2017\\Code\\Berlin KiTA\\KitaCDF")
 
# Read the final data set
kita.df <- readRDS(file = "C:\\Users\\User\\HU-Box\\Seafile\\Meine Bibliothek\\Seminare\\WS 2017\\Code\\Berlin KiTA\\KitaCDF")

###
#rm(list=setdiff(ls(), c("kitam.df")))
