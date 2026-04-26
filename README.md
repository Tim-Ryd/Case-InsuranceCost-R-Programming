# Försäkringskostnader – Dataanalys i R

## Syfte

Syftet med projektet är att analysera vilka faktorer som påverkar försäkringskostnader och undersöka om en regressionsmodell kan användas som stöd för prissättning.

---

## Innehåll

Projektet består av följande filer:

* `insurance_analysis.R` – kod för hela analysen
* `insurance_costs.csv` – dataset
* `rapport_av_Analys.md` – sammanfattande rapport

---

## Använda paket

Följande R-paket används i analysen:

```r
library(tidyverse)
```

---

## Hur man kör projektet

1. Öppna projektet i RStudio
2. Se till att filen `insurance_costs.csv` ligger i samma mapp som koden
3. Installera paket om det behövs:

```r
install.packages("tidyverse")
```

4. Kör hela skriptet:

```r
source("insurance_analysis.R")
```

eller kör rad för rad i RStudio.

---

## Analysens innehåll

Analysen består av följande steg:

### 1. Dataförståelse

* Inläsning av data
* Kontroll av struktur och saknade värden

### 2. Datastädning

* Hantering av saknade värden
* Städning av kategoriska variabler
* Skapande av nya variabler (t.ex. BMI-kategori, åldersgrupp)

### 3. Beskrivande analys

* Statistiska sammanfattningar
* Visualiseringar (histogram, boxplots, scatterplots)

### 4. Regressionsanalys och  Modelljämförelse

* Uppbyggnad av multipel regressionsmodell
* Tolkning av koefficienter
* Identifiering av viktiga variabler
* Jämförelse mellan flera modeller
* Utvärdering med R² och residualer

### 5. Kort tolkning och slutsat
* Tolkning och slutsats
---

## Viktiga resultat

* Rökning har starkast samband med kostnader
* Kronisk sjukdom och tidigare historik påverkar också tydligt
* Modellen förklarar cirka 75% av variationen i kostnader

---

## Begränsningar

* Modellen fångar inte alla faktorer (t.ex. livsstil, genetik)
* Resultaten visar samband, inte orsak
* Datakvalitet kan påverka analysen

---

## Slutsats

Analysen visar att flera faktorer har tydliga samband med försäkringskostnader. Regressionsmodellen kan användas som ett stöd vid prissättning, men bör kompletteras med ytterligare information för bättre precision.

---

## Författare

Tim Rydén
