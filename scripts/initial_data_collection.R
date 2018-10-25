# collecting different data sources

if(!require(pacman)){install.packages("pacman"); library(pacman)}
p_load(tidyverse, tidycensus)

download.file("https://enfxfr.dol.gov/data_catalog/WHD/whd_whisard_20180814.csv.zip", destfile = "data/whd.zip", 
              mmethod = "wget")

download.file("https://www.census.gov/eos/www/naics/2012NAICS/2-digit_2012_Codes.xls", 
              destfile = "data/naics_xwalk.xls", method = "wget")

# download working age populations for counties
fips <- tidycensus::fips_codes

fips$full_county <- paste0(fips$state_code, fips$county_code)

acs_table <- tidycensus::load_variables(2016, "acs5", cache = TRUE)

sex_by_age <- grep("B01001_", acs_table$name, value = TRUE) 

age_by_sex <- get_acs(geography = "county", variables = sex_by_age, output = "wide")
working_age <- age_by_sex %>% 
  select(1:3, 13:39, 61:87)

working_age <- working_age %>% 
  select(ends_with("E"),  GEOID)

working_age$working_age <- rowSums(working_age[3:30], na.rm = TRUE)
working_age <- working_age %>% mutate(working_per = working_age/B01001_001E)
working_age <- working_age %>% 
  select(NAME, GEOID, working_age, working_per)

saveRDS(working_age, "data/Raw/working_age_county2016.RDS")

#moved the whd csv and the crosswalk to a raw folder using terminal

