## Name: LibStats_report_batch.R
## Created: June 2018 by Kristin Briney
## Purpose: This code takes StatBot data cleaned by LibStats_cleanup.R and automatically creates
##          reports for a list of library departments and people. Date range must be specified.


library(tidyverse)
library(rmarkdown)
library(stringr)
library(lubridate)

## CHANGE THESE PARAMETERS AS NECESSARY (KEEP DATE/TIME FORMATTING AS YYYY-MM-DD HH:MM:SS)

f_in <- "C:/Users/briney/Documents/LibStats/reports/data"
f_out <- "C:/Users/briney/Documents/LibStats/reports/reports"
period_Start <- "2018-01-01 00:00:00"
period_End <- "2018-12-31 23:59:59"


## Departments and individuals needing semesterly reports
## "deptName" is name as appears in the data, "deptFName" is file name friendly version

deptName <- tibble("AGSL", "Archives", "Curriculum Collection / Music Library", 
                   "Digital Humanities Lab", "Special Collections", "User Services")
deptFName <- tibble("AGSL", "Archives", "CurriculumMusic", 
                    "DHLab", "SpecialCollections", "UserServices")
persName <- tibble("briney", "ganski", "kabina", "kbowes", "kristinw", "lkopecky", 
                   "mathiasm", "nbungert", "skorolev", "thornto4", "wadecg",
                   "kj2", "aritter", "hanlon", "anye", "hanoszko", "srappel",
                   "ristic", "sqp", "acope", "bidney")



## Edit strings to add to output file name

startDate <- paste(substr(period_Start, 1,4),substr(period_Start, 6,7),substr(period_Start, 9,10),sep="")
endDate <- paste(substr(period_End, 1,4),substr(period_End, 6,7),substr(period_End, 9,10),sep="")

fname1 <- paste(f_out, "/", "Statbot_", sep="")
fname2 <- paste("_", startDate, "to", endDate, sep="")


## Create library report

render("LibStats_report_library.Rmd", params=list(
  fpath=f_in, periodStart=period_Start, periodEnd=period_End),
  output_file = paste(fname1, "GoldaMeir", fname2, ".pdf", sep=""))



## Create department reports

for (i in 1:dim(deptName)[2]) {
  render("LibStats_report_dept.Rmd", params=list(
    fpath=f_in, periodStart=period_Start, periodEnd=period_End, dept=as.character(deptName[i])),
    output_file = paste(fname1, deptFName[i], fname2, ".pdf", sep=""))
}


## Create AGSL collections spreadsheet

AGSLcol <- read_csv(paste(f_in, "AGSL.csv", sep="/"))
AGSL <- filter(AGSLcol, Date>=period_Start & 
                 Date<=period_End)
write_csv(AGSL, paste(fname1, "AGSL_collection", fname2, ".csv", sep=""))


# Create RHD and Welcome Desk reports

render("LibStats_report_RHD.Rmd", params=list(
  fpath=f_in, periodStart=period_Start, periodEnd=period_End),
  output_file = paste(fname1, "RHD", fname2, ".pdf", sep=""))

render("LibStats_report_welcome.Rmd", params=list(
  fpath=f_in, periodStart=period_Start, periodEnd=period_End),
  output_file = paste(fname1, "Welcome", fname2, ".pdf", sep=""))


## Create personal reports

for (i in 1:dim(persName)[2]) {
  render("LibStats_report_person.Rmd", params=list(
    fpath=f_in, periodStart=period_Start, periodEnd=period_End, person=as.character(persName[i])),
    output_file = paste(fname1, persName[i], fname2, ".pdf", sep=""))
}


## Create stories summary

render("LibStats_report_stories.Rmd", params=list(
  fpath=f_in, periodStart=period_Start, periodEnd=period_End),
  output_file = paste(fname1, "Stories", fname2, ".html", sep=""))






### Built raw data output files


## Load data

finput <- paste(f_in, "Cons.csv", sep="/")
Cons_raw <- read_csv(finput)
Cons_ <- filter(Cons_raw, Cons_raw$ConsDate>=period_Start & Cons_raw$ConsDate<=period_End)

finput <- paste(f_in, "Pres.csv", sep="/")
Pres_raw <- read_csv(finput)
Pres_ <- filter(Pres_raw, Pres_raw$PresDateTime>=period_Start & Pres_raw$PresDateTime<=period_End)

finput <- paste(f_in, "Trans.csv", sep="/")
Trans_raw <- read_csv(finput)
Trans_ <- filter(Trans_raw, Trans_raw$TransDateTime>=period_Start & 
                   Trans_raw$TransDateTime<=period_End)


## Write out filtered raw data files

## Departmental files

for (i in 1:dim(deptName)[2]) {
  Cons_temp <- filter(Cons_, Cons_$StaffDept == as.character(deptName[i]))
  Pres_temp <- filter(Pres_, Pres_$StaffDept == as.character(deptName[i]))
  Trans_temp <- filter(Trans_, Trans_$StaffDept == as.character(deptName[i]))
  
  foutput <- paste(fname1, deptFName[i], "_Cons", fname2, ".csv", sep="")
  write_csv(Cons_temp, foutput)
  
  foutput <- paste(fname1, deptFName[i], "_Pres", fname2, ".csv", sep="")
  write_csv(Pres_temp, foutput)
  
  foutput <- paste(fname1, deptFName[i], "_Trans", fname2, ".csv", sep="")
  write_csv(Trans_temp, foutput)
}

Trans_temp <- filter(Trans_, Trans_$StaffDept == "Research Help Desk")
foutput <- paste(fname1, "RHD", "_Trans", fname2, ".csv", sep="")
write_csv(Trans_temp, foutput)

## Personal files

for (i in 1:dim(persName)[2]) {
  Cons_temp <- filter(Cons_, Cons_$StaffName == as.character(persName[i]))
  Pres_temp <- filter(Pres_, Pres_$StaffName == as.character(persName[i]))
  Trans_temp <- filter(Trans_, Trans_$StaffName == as.character(persName[i]))
  
  foutput <- paste(fname1, persName[i], "_Cons", fname2, ".csv", sep="")
  write_csv(Cons_temp, foutput)
  
  foutput <- paste(fname1, persName[i], "_Pres", fname2, ".csv", sep="")
  write_csv(Pres_temp, foutput)
  
  foutput <- paste(fname1, persName[i], "_Trans", fname2, ".csv", sep="")
  write_csv(Trans_temp, foutput)
}

## Course file

finput <- paste(f_in, "Courses.csv", sep="/")
Courses_raw <- read_csv(finput)
Courses <- filter(Courses_raw, Courses_raw$DateTime>=period_Start & Courses_raw$DateTime<=period_End)
foutput <- paste(fname1, "Courses", fname2, ".csv", sep="")
write_csv(Courses, foutput)