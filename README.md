# Webscraping-FAU-
Web Scraping und Text Mining Workshop - FAU Erlangen-Nürnberg (2019/09/28)

## Ankündigung

**Abstract**

> If programming is magic, then *web scraping* is wizardry ([Mitchell 2015: vii](https://www.oreilly.com/library/view/web-scraping-with/9781491985564/))

Der Workshop führt die TeilnehmerInnen in die Techniken des Web Scraping und Text 
Mining ein. Digitale Daten bieten der (sozial-)wissenschaftlichen Forschung eine
ungeahnte Fülle an Informationen über menschliches Handeln. Dennoch sind die 
notwendigen Methoden der "computational social sciences" (CSS) und "digital 
humanities" (DH), die es erlauben das Potential digitaler Daten zu nutzen, in 
einschlägigen Curricula bisher kaum integriert. Der Workshop nutzt die 
Programmiersprache R, um den TeilnehmerInnen anhand von "hands-on"-Beispielen das
Feld der CSS/DH zu eröffnen. 
Dabei wird zunächst anhand von einschlägigen Studien das Potential digitaler
Daten demonstriert. Im Anschluss gibt es eine Einführung in die grundlegenden 
Technologien des WWW, welche wir benötigen, um erste eigene "Web Scraper" zu 
programmieren. Darauffolgend bauen wir diese Skripte aus, um komplexere Datenabfragen 
zu durchzuführen. Zuletzt werden neuere Methoden vorgestellt, die "text as data" 
([Grimmer & Stewart, 2013](https://www.cambridge.org/core/journals/political-analysis/article/text-as-data-the-promise-and-pitfalls-of-automatic-content-analysis-methods-for-political-texts/F7AAC8B2909441603FEB25C156448F20)) 
behandeln und es erlauben große Textkorpora zu bearbeiten. Während des Workshops 
soll die Möglichkeit bestehen eigene Projekte zu diskutieren, sodass das gewonnene
Wissen in den Projekten eingesetzt werden kann. 

**Organisation:**
BMBF-Förderschwerpunkt "Forschung zur Digitalisierung in der Kulturellen Bildung" ([DiKuBi](https://www.dikubi-meta.fau.de/))

**Ort/Zeit der Veranstaltung:**
Samstag, 28. September 2019, 9:15-13:15 Uhr, Kulturwerkstatt Auf AEG Nürnberg

**Dozent:**
Dr. Fabian Gülzau, HU Berlin ([Website](https://fguelzau.rbind.io/), [Twitter](https://twitter.com/FabFuchs))

**Folien:**
[Web Scraping mit R](https://fabianfox.github.io/Webscraping-FAU-Slides/Webscraping_FAU.html#1)

**Voraussetzungen:**
Die Kursvoraussetzungen werden mit den TeilnehmerInnen noch weiter abgestimmt. 
Wünschenswert sind Grundkenntnisse der Programmiersprache R. Gute Einführungen in
R sind kostenlos verfügbar:
- [R for Data Science](https://r4ds.had.co.nz/) (Wickham & Grolemund, 2017) [Kap. 1 & 4-6]
- Primers in der RStudio Cloud: [Working with data](https://rstudio.cloud/learn/primers/2)
- [swirl](https://swirlstats.com/): Learn R, in R.

Für die praktischen Beispiele ist ein Rechner mit den aktuellen Versionen von [R](https://www.r-project.org/) 
und [RStudio](https://www.rstudio.com/products/rstudio/download/) notwendig. Zudem sollten einige Pakete vorab installiert werden:

```
install.packages(pacman) # Installation nur einmal notwendig
library(pacman)
p_load(tidyverse, httr, robotstxt, qdap, janitor,
       devtools, lubridate, rzeit2)
```