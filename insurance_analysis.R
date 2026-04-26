# Individuell inlämningsuppgift
# Försäkringskostnader - analys i R
# Filen är skriven för att kunna köras uppifrån och ner.

library(tidyverse)

# (1) Dataförståelse

insurance_raw <- read_csv("insurance_costs.csv")

glimpse(insurance_raw)
summary(insurance_raw)

# Storlek på datasetet
dim(insurance_raw)

# Saknade värden per variabel
colSums(is.na(insurance_raw))

# Kontroll av kategoriska variabler
insurance_raw %>% count(sex)
insurance_raw %>% count(region)
insurance_raw %>% count(smoker)
insurance_raw %>% count(chronic_condition)
insurance_raw %>% count(exercise_level)
insurance_raw %>% count(plan_type)

# (2)  Datastädning och förberedelse

insurance <- insurance_raw %>% 
  mutate(
    sex = str_trim(sex),
    sex = str_to_title(sex),
    
    region = str_trim(region),
    region = str_to_title(region),
    
    smoker = str_trim(smoker),
    smoker = str_to_title(smoker),
    
    chronic_condition = str_trim(chronic_condition),
    chronic_condition = str_to_title(chronic_condition),
    
    exercise_level = str_trim(exercise_level),
    exercise_level = str_to_title(exercise_level),
    
    plan_type = str_trim(plan_type),
    plan_type = str_to_title(plan_type),
    
    # Saknade numeriska värden ersätts med median.
    # Median påverkas mindre av extrema värden än medelvärde.
    bmi = if_else(
      is.na(bmi),
      median(bmi, na.rm = TRUE),
      bmi
    ),
    
    annual_checkups = if_else(
      is.na(annual_checkups),
      median(annual_checkups, na.rm = TRUE),
      annual_checkups
    ),
    
    # Saknad motionsnivå får en egen kategori.
    exercise_level = if_else(
      is.na(exercise_level),
      "Unknown",
      exercise_level
    ),
    
    sex = as.factor(sex),
    region = as.factor(region),
    smoker = as.factor(smoker),
    chronic_condition = as.factor(chronic_condition),
    exercise_level = as.factor(exercise_level),
    plan_type = as.factor(plan_type),
    
    # Nya variabler, BMI/Ålder delas upp i grupper för att enklare kunna tolka resultatet och göra det mer realistiskt.
    bmi_category = case_when(
      bmi < 18.5 ~ "Underweight",
      bmi < 25 ~ "Normal",
      bmi < 30 ~ "Overweight",
      bmi >= 30 ~ "Obese",
      TRUE ~ NA_character_
    ),
    
    age_group = case_when(
      age < 30 ~ "Under 30",
      age < 45 ~ "30-44",
      age < 60 ~ "45-59",
      age >= 60 ~ "60+",
      TRUE ~ NA_character_
    ),
    
    # Tidigare olyckor och claims slås ihop till ett enkelt historikmått.
    history_score = prior_accidents + prior_claims,
    
    # Risknivå skapas för att kunna analysera kunder i grupper.
    risk_level = case_when(
      smoker == "Yes" | chronic_condition == "Yes" | history_score >= 2 ~ "High",
      bmi >= 30 | history_score == 1 ~ "Medium",
      TRUE ~ "Low"
    ),
    
    bmi_category = as.factor(bmi_category),
    age_group = as.factor(age_group),
    risk_level = as.factor(risk_level)
  )

glimpse(insurance)
summary(insurance)
colSums(is.na(insurance))

# Kontroll efter städning
insurance %>% count(region)
insurance %>% count(smoker)
insurance %>% count(plan_type)
insurance %>% count(exercise_level)


# (3) Beskrivande analys 

# Tabell 1: Sammanfattning av försäkringskostnader
charges_summary <- insurance %>% 
  summarize(
    mean_charges = mean(charges, na.rm = TRUE),
    median_charges = median(charges, na.rm = TRUE),
    sd_charges = sd(charges, na.rm = TRUE),
    min_charges = min(charges, na.rm = TRUE),
    q1_charges = quantile(charges, 0.25, na.rm = TRUE),
    q3_charges = quantile(charges, 0.75, na.rm = TRUE),
    max_charges = max(charges, na.rm = TRUE)
  )

charges_summary

# Tolkning:
# Kostnaderna varierar tydligt mellan kunder. Medelvärdet är högre än medianen,
# vilket tyder på att några kunder har mycket höga kostnader.


# Figur 1: Fördelning av charges
ggplot(insurance, aes(x = charges)) +
  geom_histogram(bins = 30) +
  labs(
    title = "Fördelning av försäkringskostnader",
    x = "Charges",
    y = "Antal kunder"
  ) +
  theme_minimal()

# Tolkning:
# Figuren visar att de flesta kunder ligger på lägre eller medelhöga kostnader,
# men det finns även kunder med mycket höga kostnader.


# Tabell 2: Kostnader efter rökning
charges_by_smoker <- insurance %>% 
  group_by(smoker) %>% 
  summarize(
    mean_charges = mean(charges, na.rm = TRUE),
    median_charges = median(charges, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  )

charges_by_smoker

# Tolkning:
# Rökare har tydligt högre genomsnittliga kostnader än icke-rökare.


# Figur 2: Charges efter rökning
ggplot(insurance, aes(x = smoker, y = charges)) +
  geom_boxplot() +
  labs(
    title = "Försäkringskostnader efter rökning",
    x = "Rökare",
    y = "Charges"
  ) +
  theme_minimal()

# Tolkning:
# Boxplotten visar att rökare generellt har högre kostnader.


# Tabell 3: Kostnader efter BMI-kategori
charges_by_bmi_category <- insurance %>% 
  group_by(bmi_category) %>% 
  summarize(
    mean_charges = mean(charges, na.rm = TRUE),
    median_charges = median(charges, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>% 
  arrange(desc(mean_charges))

charges_by_bmi_category

# Tolkning:
# Kunder med fetma har högre genomsnittlig kostnad än kunder med normal BMI.


# Figur 3: BMI och charges
ggplot(insurance, aes(x = bmi, y = charges)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title = "Samband mellan BMI och försäkringskostnad",
    x = "BMI",
    y = "Charges"
  ) +
  theme_minimal()

# Tolkning:
# Det finns ett positivt samband mellan BMI och kostnader, men dock ska man anmärka på att spridningen är stor.


# Tabell 4: Kostnader efter risknivå
charges_by_risk_level <- insurance %>% 
  group_by(risk_level) %>% 
  summarize(
    mean_charges = mean(charges, na.rm = TRUE),
    median_charges = median(charges, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>% 
  arrange(desc(mean_charges))

charges_by_risk_level

# Tolkning:
# Gruppen med hög risknivå har högst genomsnittlig kostnad.


# Figur 4: Charges efter risknivå
ggplot(insurance, aes(x = risk_level, y = charges)) +
  geom_boxplot() +
  labs(
    title = "Försäkringskostnader efter risknivå",
    x = "Risknivå",
    y = "Charges"
  ) +
  theme_minimal()

# Tolkning:
# Figuren visar att den konstruerade risknivån fångar tydliga skillnader i kostnader.


# Figur 5: Ålder och charges
ggplot(insurance, aes(x = age, y = charges)) +
  geom_point(alpha = 0.5) +
  geom_smooth(method = "lm", se = TRUE) +
  labs(
    title = "Samband mellan ålder och försäkringskostnad",
    x = "Ålder",
    y = "Charges"
  ) +
  theme_minimal()

# Tolkning:
# Kostnaderna tenderar att öka med ålder, men även här finns stor variation.


# (4) Regressionsanalys 

# Modell 1: enkel modell med endast numeriska grundvariabler
model_1 <- lm(
  charges ~ age + bmi + children,
  data = insurance
)

summary(model_1)

# Modell 2: lägger till viktiga riskfaktorer
model_2 <- lm(
  charges ~ age + bmi + children + smoker + chronic_condition + history_score,
  data = insurance
)

summary(model_2)

# Modell 3: mer fullständig modell med fler kategoriska variabler
model_3 <- lm(
  charges ~ age + bmi + children + smoker + chronic_condition +
    history_score + exercise_level + plan_type + region + sex,
  data = insurance
)

summary(model_3)

# Modelljämförelse
model_comparison <- tibble(
  model = c(
    "Model 1: age + bmi + children",
    "Model 2: + smoker + chronic_condition + history_score",
    "Model 3: + exercise_level + plan_type + region + sex"
  ),
  r_squared = c(
    summary(model_1)$r.squared,
    summary(model_2)$r.squared,
    summary(model_3)$r.squared
  ),
  adjusted_r_squared = c(
    summary(model_1)$adj.r.squared,
    summary(model_2)$adj.r.squared,
    summary(model_3)$adj.r.squared
  ),
  residual_se = c(
    summary(model_1)$sigma,
    summary(model_2)$sigma,
    summary(model_3)$sigma
  )
)

model_comparison

# Tolkning:
# Modell 2 förbättras mycket jämfört med modell 1. Det visar att rökning,
# kronisk sjukdom och tidigare historik är viktiga för att förklara charges.
# Modell 3 förbättras ytterligare något, men skillnaden är mindre än mellan
# modell 1 och modell 2.


# Diagnostik för vald modell 

model_3_diagnostics <- insurance %>% 
  mutate(
    fitted_value = fitted(model_3),
    residual = resid(model_3)
  )

model_3_diagnostics %>% 
  select(charges, fitted_value, residual) %>% 
  slice_head(n = 10)

# Residualer mot predikterade värden
ggplot(model_3_diagnostics, aes(x = fitted_value, y = residual)) +
  geom_point(alpha = 0.5) +
  geom_hline(yintercept = 0) +
  labs(
    title = "Residualer mot predikterade värden",
    x = "Predikterade värden",
    y = "Residualer"
  ) +
  theme_minimal()

# Tolkning:
# Residualerna är inte helt perfekta, men figuren ger en rimlig kontroll av
# om modellen gör systematiska fel.


# Histogram över residualer
ggplot(model_3_diagnostics, aes(x = residual)) +
  geom_histogram(bins = 30) +
  labs(
    title = "Fördelning av residualer",
    x = "Residual",
    y = "Antal"
  ) +
  theme_minimal()

# Tolkning:
# Residualerna är relativt samlade kring 0, men det finns sonliga större fel.



# (5) Tolkning och slutsatser

# De tydligaste faktorerna i analysen är rökning, kronisk sjukdom,
# tidigare historik, ålder och BMI. Modellen fungerar som ett stöd för att
# förstå vilka faktorer som hänger ihop med högre försäkringskostnader.
# Samtidigt är modellen förenklad. Den visar samband, men den bevisar inte
# orsakssamband. Den fångar inte heller alla individuella skillnader mellan
# kunder.
