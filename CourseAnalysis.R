#install.packages("tidyverse")
library(tidyverse)
library(stringr)
library(lubridate)


## READ IN LIBSTATS CSV FILE

## Set file path and input file name -- CHANGE AS NEEDED (direction of slashes matters)**
fpath <- "C:/Users/briney/Documents/LibStats/reports/data"
fname <- "Courses.csv"

period_Start <- "2017-09-01 00:00:00"
period_End <- "2019-12-31 23:59:59"

finput <- paste(fpath, fname, sep="/")
Courses_unfiltered <- read_csv(finput)

Courses_filtered <- filter(Courses_unfiltered, ServiceType == "presentation" & 
                             DateTime>=period_Start & 
                             DateTime<=period_End)

AFR <- filter(Courses_filtered, Department == "Africology (AFRICOL)") %>% arrange(Course)
ART <- filter(Courses_filtered, Department == "Art and Design (ART)") %>% arrange(Course)
NUR <- filter(Courses_filtered, Department == "Nursing (NURS)") %>% arrange(Course)
PUB <- filter(Courses_filtered, Department == "Public Health (PH)") %>% arrange(Course)
SOC <- filter(Courses_filtered, Department == "Social Work (SOC WRK)") %>% arrange(Course)

Courses_selDept <- bind_rows(AFR, ART, NUR, PUB, SOC)

foutput <- paste(fpath, "Courses_Select.csv", sep="/")
write_csv(Courses_selDept, foutput)