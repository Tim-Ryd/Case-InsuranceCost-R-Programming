# Rapport: Försäkringskostnader

## Syfte

Syftet med analysen är att undersöka vilka faktorer som verkar hänga ihop med försäkringskostnader (`charges`). Analysen bygger på ett dataset med 1100 kunder och har variabler som ålder, kön, region, BMI, antal barn, rökning, kronisk sjukdom, motionsnivå, försäkringsplan, tidigare olyckor, tidigare claims, hälsokontroller och försäkringskostnad.

## Metod

Arbetet gjordes i R med paketet `tidyverse`. Först lästes datasetet in och kontrollerades med `glimpse()`, `summary()`, `dim()` och `colSums(is.na())`. Därefter städades de kategoriska variabler med `str_trim()` och `str_to_title()` eftersom vissa värden hade olika skrivsätt, till exempel `Yes`, `no`, `North` och `South`.

Saknade värden i de numeriska variablerna som `bmi` och `annual_checkups` ersattes med medianvärden. Saknad `exercise_level` fick kategorin `Unknown`. Jag skapade också nya variabler:

-   `bmi_category`, för att kunna jämföra kunder med olika BMI-nivåer.
-   `age_group`, för att kunna analysera ålder i grupper.
-   `history_score`, som summerar tidigare olyckor och tidigare claims.
-   `risk_level`, som delar in kunder i låg, medium och hög risk baserat på rökning, kronisk sjukdom, historik och BMI.

Därefter gjordes en beskrivande analys med tabeller och figurer. Slutligen byggdes tre regressionsmodeller med `charges` som målvariabel.

## Resultat 

Försäkringskostnaderna varierar tydligt mellan kunder. Genomsnittlig kostnad är ungefär 10 060 och medianen är ungefär 9 124. Att medelvärdet är högre än medianen kan tolkas som att det finnas vissa kunder med särskilt höga kostnader.

Rökning är en av de tydligaste skillnaderna i datat. Icke-rökare har en genomsnittlig kostnad på ungefär 8 586, medan rökare har en genomsnittlig kostnad på ungefär 16 537. Detta är en stor skillnad och gör rökning till en viktig variabel att ta med i regressionsmodellen.

BMI verkar också spela roll. Kunder med fetma har en genomsnittlig kostnad på ungefär 10 910, medan kunder med normal BMI har en genomsnittlig kostnad på ungefär 9 218. Skillnaden är inte lika stor som för rökning, men sambandet är ändå relevant.

Den skapade variabeln `risk_level` visade också tydliga skillnader. Kunder med hög risknivå hade en genomsnittlig kostnad på ungefär 13 673, medan låg risknivå låg på ungefär 6 855. Detta visar att risknivån fångar flera viktiga riskfaktorer på ett enkelt sätt.

## Regressionsanalys

Tre modeller jämfördes:

1.  Modell 1: `age + bmi + children`
2.  Modell 2: Modell 1 plus `smoker`, `chronic_condition` och `history_score`
3.  Modell 3: Modell 2 plus `exercise_level`, `plan_type`, `region` och `sex`

Modelljämförelsen visade följande:

| Modell   |    R² | Justerad R² | Residual standard error |
|----------|------:|------------:|------------------------:|
| Modell 1 | 0.086 |       0.084 |                    4379 |
| Modell 2 | 0.720 |       0.718 |                    2428 |
| Modell 3 | 0.748 |       0.744 |                    2313 |

Modell 1 förklarar bara en liten del av variationen i kostnader. När rökning, kronisk sjukdom och historik läggs till i modell 2 förbättras modellen mycket. Modell 3 förbättrar modellen ytterligare, men förbättringen är mindre än mellan modell 1 och modell 2.

I den mest fullständiga modellen var de tydligaste faktorerna:

-   Rökning: rökare hade mycket högre kostnader, ungefär 7 425 högre än icke-rökare när övriga variabler hålls konstanta.
-   Kronisk sjukdom: kunder med kronisk sjukdom hade ungefär 3 814 högre kostnader.
-   Tidigare historik: varje extra historikpoäng var kopplad till ungefär 968 högre kostnad.
-   Ålder: varje extra år var kopplat till ungefär 69 högre kostnad.
-   BMI: varje extra BMI-enhet var kopplad till ungefär 157 högre kostnad.
-   Låg motionsnivå var också kopplad till högre kostnader jämfört med hög motionsnivå.
-   Premiumplan hade högre kostnader än basicplan.

Region och kön hade däremot inte lika tydliga samband i modellen.

## Slutsatser

Analysen visar att rökning, kronisk sjukdom, tidigare olyckor/claims, ålder och BMI är de faktorer som verkar ha tydligast samband med försäkringskostnader. Rökning är den starkaste enskilda faktorn i modellen.

Regressionsmodellen kan användas som ett beslutsstöd för att förstå vilka faktorer som hänger ihop med högre kostnader. Den mest fullständiga modellen förklarar ungefär 75 procent av variationen i kostnader, vilket är relativt starkt för en enkel linjär modell.

## Begränsningar

Modellen visar samband men bevisar inte orsakssamband. Det kan också finnas viktiga faktorer som inte finns med i datasetet, till exempel inkomst, yrke, mer detaljerad sjukdomshistorik eller vårdkostnader över tid. En annan begränsning är att linjär regression antar ungefär linjära samband, men verkliga försäkringskostnader kan vara mer komplexa.

Det finns också några saknade värden och mindre inkonsekvenser i datat. Dessa hanterades på ett rimligt sätt, men beroende på vilka val som görs vid datastädning så kan det påverka resultatet.

## Möjliga förbättringar

Analysen hade kunnat förbättras genom att testa fler modeller, till exempel modeller med interaktioner mellan rökning och BMI eller rökning och kronisk sjukdom. Man hade också kunnat dela upp datat i träningsdata och testdata för att undersöka hur bra modellen fungerar på nya kunder.

## Självreflektion

Jag tycker att arbetet som gjordes är strukturerat. Där jag först undersökte datan, sedan städade det, skapade relevanta nya variabler, gjorde tabeller och figurer och till sist byggde flera regressionsmodeller. Det svåraste var att välja vilka variabler som skulle ingå i modellen och att tolka skillnaden mellan modellerna på ett rimligt sätt.

Jag tycker att inlämningen motsvarar VG eftersom den inte bara innehåller en regressionsmodell utan även jämför flera modellvarianter. Den diskuterar också modellval, styrkor, svagheter och möjliga förbättringar.
