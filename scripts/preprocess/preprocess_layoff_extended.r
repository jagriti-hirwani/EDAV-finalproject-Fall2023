library(dplyr)
library(tidyr)
library(readxl)
library(lubridate)
library(stringr)

layoff_data <- read_excel("data/Clean/layoff_cleaned.xlsx")

temp_layoff_types <- layoff_data |> filter(str_detect(`Layoff/Closure\n Type`, "temp|Temp|TEMP"))
temp_covid_layoff_types <- temp_layoff_types |> filter(str_detect(`Layoff/Closure\n Type`, "COVID|Covid|covid"))
temp_non_covid_layoff_types <- temp_layoff_types |> filter(!str_detect(`Layoff/Closure\n Type`, "COVID|Covid|covid"))
temp_covid_layoff_types <- unique(temp_covid_layoff_types$`Layoff/Closure\n Type`)
temp_non_covid_layoff_types <- unique(temp_non_covid_layoff_types$`Layoff/Closure\n Type`)

perm_layoff_types <- layoff_data |> filter(str_detect(`Layoff/Closure\n Type`, "perm|Perm|PERM"))
perm_covid_layoff_types <- perm_layoff_types |> filter(str_detect(`Layoff/Closure\n Type`, "COVID|Covid|covid"))
perm_non_covid_layoff_types <- perm_layoff_types |> filter(!str_detect(`Layoff/Closure\n Type`, "COVID|Covid|covid"))
perm_covid_layoff_types <- unique(perm_covid_layoff_types$`Layoff/Closure\n Type`)
perm_non_covid_layoff_types <- unique(perm_non_covid_layoff_types$`Layoff/Closure\n Type`)

closure_layoff_types <- layoff_data |> filter(str_detect(`Layoff/Closure\n Type`, "Clos|clos|CLOS"))
closure_layoff_types <- unique(closure_layoff_types$`Layoff/Closure\n Type`)

covid_layoff_types <- layoff_data |> filter(str_detect(`Layoff/Closure\n Type`, "Covid|covid|COVID"))
covid_layoff_types <- unique(covid_layoff_types$`Layoff/Closure\n Type`)

mass_layoff_types <- layoff_data |> filter(str_detect(`Layoff/Closure\n Type`, "Mass|mass|MASS"))
mass_layoff_types <- unique(mass_layoff_types$`Layoff/Closure\n Type`)

restructure_layoff_types <- layoff_data |> filter(str_detect(`Layoff/Closure\n Type`, "Restruct|restruct|RESTRUCT"))
restructure_layoff_types <- unique(restructure_layoff_types$`Layoff/Closure\n Type`)

contract_layoff_types <- layoff_data |> filter(str_detect(`Layoff/Closure\n Type`, "Contract|contract|CONTRACT"))
contract_layoff_types <- unique(contract_layoff_types$`Layoff/Closure\n Type`)

work_reduc_layoff_types <- layoff_data |> filter(str_detect(`Layoff/Closure\n Type`, "reduc|Reduc|REDUC"))
work_reduc_hour_layoff_types <- work_reduc_layoff_types |> filter(str_detect(`Layoff/Closure\n Type`, "hour|Hour|HOUR"))
work_reduc_total_layoff_types <- work_reduc_layoff_types |> filter(!str_detect(`Layoff/Closure\n Type`, "hour|Hour|HOUR"))
work_reduc_hour_layoff_types <- unique(work_reduc_hour_layoff_types$`Layoff/Closure\n Type`)
work_reduc_total_layoff_types <- unique(work_reduc_total_layoff_types$`Layoff/Closure\n Type`)

other_reason_layoff <- layoff_data |>
    drop_na(`Layoff/Closure\n Type`) |>
    group_by(`Layoff/Closure\n Type`) |>
    summarize(total_layoffs = sum(`Number of Workers`, na.rm = TRUE)) |>
    filter(total_layoffs < 100)

other_reason_layoff <- unique(other_reason_layoff$`Layoff/Closure\n Type`)

# Create a new column with mapped values
layoff_data <- layoff_data %>%
    mutate(layoff_type_cleaned = case_when(
        `Layoff/Closure\n Type` %in% temp_covid_layoff_types ~ "COVID - Temporary",
        `Layoff/Closure\n Type` %in% temp_non_covid_layoff_types ~ "Temporary",
        `Layoff/Closure\n Type` %in% perm_covid_layoff_types ~ "COVID - Permanent",
        `Layoff/Closure\n Type` %in% perm_non_covid_layoff_types ~ "Permanent",
        `Layoff/Closure\n Type` %in% closure_layoff_types ~ "Closure",
        `Layoff/Closure\n Type` %in% covid_layoff_types ~ "COVID",
        `Layoff/Closure\n Type` %in% mass_layoff_types ~ "Mass Layoff",
        `Layoff/Closure\n Type` %in% restructure_layoff_types ~ "Restructuring",
        `Layoff/Closure\n Type` %in% work_reduc_hour_layoff_types ~ "Hour Reduction",
        `Layoff/Closure\n Type` %in% work_reduc_total_layoff_types ~ "Workforce Reduction",
        `Layoff/Closure\n Type` %in% contract_layoff_types ~ "Loss of Contract",
        `Layoff/Closure\n Type` %in% c("Layiff", "Layoff", "Layofff", "Layoffs") ~ "Layoffs",
        `Layoff/Closure\n Type` %in% c("Mass Layoff", "Mayss Layoff") ~ "Mass Layoffs",
        `Layoff/Closure\n Type` %in% other_reason_layoff ~ "Other",
        TRUE ~ `Layoff/Closure\n Type`
    ))

write.csv(layoff_data, "./data/Clean/layoff_cleaned_2.csv", row.names = FALSE)
