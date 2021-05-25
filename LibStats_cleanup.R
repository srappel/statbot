## Name: LibStats_cleanup.R
## Created: June 2018 by Kristin Briney
## Purpose: This code takes the output of UWM Libraries' StatBot data, cleans it, and separates
##          it into several smaller and condensed spreadsheets


#install.packages("tidyverse")
library(tidyverse)
library(stringr)
library(lubridate)


## READ IN LIBSTATS CSV FILE

  ## Set file path and input file name -- CHANGE AS NEEDED (direction of slashes matters)**
  fpath <- "C:/Users/briney/Documents/LibStats/reports/data"
  fname <- "rawData.csv"
  
  
  
  finput <- paste(fpath, fname, sep="/")

  ## Define variable names
  libStats_variables <- c("StartDate", "EndDate", "ResponseType", "IPAddress", "Progress", "Duration", "Finished",
                        "RecordedDate", "EventID", "RecipientLastName", "RecipientFirstName", "RecipientEmail",
                        "ExternalDataReference", "LocationLatitude", "LocationLongitude", "DistributionChannel",
                        "UserLanguage", "StaffName", "StaffDept", "ServiceType", "WDUserStatus", "WDType", "WDLoc",
                        "WDFormat", "WDDate_old", "WDDate", "WDTime", "WDStory", "WDNotes", "TransUserStatus", "TransType",
                        "TransDept", "TransCourse_old", "TransFac_old", "TransCourse", "TransFac", "TransLoc", "TransLocOther",
                        "TransFormat", "TransFormatOther", "TransDate_old", "TransDate", "TransTime", "AGSLTransColl",
                        "TransStory", "TransNotes", "ConsUserStatus", "ConsDept", "ConsCourse_old", "ConsFac_old",
                        "ConsCourse", "ConsFac", "ConsUserDept", "ConsFormat", "ConsFormatOther", "ConsDate", "ConsLength",
                        "ConsCountIs1", "ConsCountOver1", "AGSLConsColl", "ConsStory", "ConsNotes", "PresUserStatus",
                        "PresType", "PresTitle", "PresDept", "PresCourse_old", "PresSect_old", "PresFac_old", "PresCourse",
                        "PresSect", "PresFac", "PresLoc", "PresLocOther", "PresPartner", "PresPartnerName", "PresFormat",
                        "PresDate", "PresTime", "PresLength", "PresCount", "PresStory", "PresNotes", "Q22_old", "Q42_old")

  ## Read in raw file (change file path as necessary)
  libStats_unfiltered <- read_csv(finput, col_names=libStats_variables, skip=3,
    col_types=cols("TransCourse" = col_character(), "TransFac" = col_character(),
                   "TransStory" = col_character(), "TransNotes" = col_character(),
                   "ConsCourse" = col_character(), "ConsFac" = col_character(),
                   "ConsStory"= col_character(), "ConsNotes"= col_character(),
                   "ConsFormatOther" = col_character(),
                   "PresCourse" = col_character(), "PresSect" = col_character(), "PresFac" = col_character(),
                   "PresStory"= col_character(), "PresNotes"= col_character(),
                   "WDStory" = col_logical(), "WDNotes" = col_logical()))


  ## Filter out incomplete and test entries
  libStats <- filter(libStats_unfiltered, ResponseType=="IP Address" & StaffName!="test")

  
  
  

## BUILD SUBTABLES

## Build Events table
#  Events <- tibble(EventID=libStats$EventID, EntryDate=libStats$StartDate, StaffName=str_to_lower(libStats$StaffName), 
#                 StaffDept=libStats$StaffDept, ServiceType=libStats$ServiceType)
  
#  ## Write out Events
#  foutput <- paste(fpath, "Events.csv", sep="/")
#  write_csv(Events, foutput)

  

## Clean and build Cons table
  libCons <- filter(libStats, ServiceType=="consultation")

  ## Fix ConsCount, ConsFormat, ConsCourse, ConsFac, ConsDate
  libCons$ConsCountIs1 <- str_replace(libCons$ConsCountIs1, "No", "1")
  libCons$ConsCountIs1 <- str_replace(libCons$ConsCountIs1, "Yes, and this is how many people were in the group:", "0")

  for (i in 1:dim(libCons)[1]) {
    if(!is.na(libCons$ConsCountIs1[i]) & (libCons$ConsCountIs1[i] == 0)) libCons$ConsCountIs1[i] <- libCons$ConsCountOver1[i]
  
    if(!is.na(libCons$ConsFormat[i]) & libCons$ConsFormat[i] == "other") libCons$ConsFormat[i] <- libCons$ConsFormatOther[i]
  
    if(!is.na(libCons$ConsCourse_old[i])) libCons$ConsCourse[i] <- libCons$ConsCourse_old[i]
    
    if(!is.na(libCons$ConsFac_old[i])) libCons$ConsFac[i] <- libCons$ConsFac_old[i]
    
    if(!is.na(libCons$ConsDate[i])) libCons$ConsDate[i] <- as.character(mdy(libCons$ConsDate[i]))
  }

  ## Built Cons
  Cons <- tibble(EventID=libCons$EventID, StaffName=str_to_lower(libCons$StaffName), StaffDept=libCons$StaffDept, 
                 UserStatus=libCons$ConsUserStatus, UserDept=libCons$ConsUserDept,
                 Department=libCons$ConsDept, Course=libCons$ConsCourse, Faculty=libCons$ConsFac,
                 Format=libCons$ConsFormat, ConsDate=libCons$ConsDate, Length=libCons$ConsLength,
                 Count=as.numeric(libCons$ConsCountIs1), Story=libCons$ConsStory, Notes=libCons$ConsNotes)

  ## Write out Cons
  foutput <- paste(fpath, "Cons.csv", sep="/")
  write_csv(Cons, foutput)


  
  
## Clean and build Pres table
  libPres <- filter(libStats, ServiceType=="presentation")
  
  ## Fix Undergraduates, Graduates, FacultyStaff, Children, HighSchool, NonUWM,
  ##     Course, Section, Faculty, Location, Date variables
  Undergraduates <- tibble(U=libPres$PresUserStatus)
  Graduates <- tibble(G=libPres$PresUserStatus)
  FacultyStaff <- tibble(FS=libPres$PresUserStatus)
  Children <- tibble(C=libPres$PresUserStatus)
  HighSchool <- tibble(HS=libPres$PresUserStatus)
  NonUWM <- tibble(N=libPres$PresUserStatus)
  DateTime <- tibble(DT=libPres$PresDate)
  
  for (i in 1:dim(libPres)[1]) {
    if(!is.na(Undergraduates$U[i]) & str_detect(Undergraduates$U[i], "UWM undergraduates"))
      Undergraduates$U[i] <- TRUE else Undergraduates$U[i] <- FALSE
  
    if(!is.na(Graduates$G[i]) & str_detect(Graduates$G[i], "UWM graduate students"))
      Graduates$G[i] <- TRUE else Graduates$G[i] <- FALSE
  
    if(!is.na(FacultyStaff$FS[i]) & str_detect(FacultyStaff$FS[i], "UWM faculty or staff"))
      FacultyStaff$FS[i] <- TRUE else FacultyStaff$FS[i] <- FALSE
    
    if(!is.na(Children$C[i]) & str_detect(Children$C[i], "children"))
      Children$C[i] <- TRUE else Children$C[i] <- FALSE
      
    if(!is.na(HighSchool$HS[i]) & str_detect(HighSchool$HS[i], "high school students"))
      HighSchool$HS[i] <- TRUE else HighSchool$HS <- FALSE
      
    if(!is.na(NonUWM$N[i]) & str_detect(NonUWM$N[i], "non-UWM adults"))
      NonUWM$N[i] <- TRUE else NonUWM$N[i] <- FALSE
    
    if(!is.na(libPres$PresCourse_old[i])) libPres$PresCourse[i] <- libPres$PresCourse_old[i]
  
    if(!is.na(libPres$PresSect_old[i])) libPres$PresSect[i] <- libPres$PresSect_old[i]
  
    if(!is.na(libPres$PresFac_old[i])) libPres$PresFac[i] <- libPres$PresFac_old[i]
    
    if(!is.na(libPres$PresLoc[i]) & str_detect(libPres$PresLoc[i],"Somewhere else")) 
      libPres$PresLoc[i] <- str_replace(libPres$PresLoc[i], "Somewhere else", libPres$PresLocOther[i])
    
    if(is.na(libPres$PresTime[i]) | !str_detect(libPres$PresTime[i], ":")) libPres$PresTime[i] <- "12:00 AM"
    
    DateTime$DT[i] <- as.character(mdy_hm(paste(libPres$PresDate[i], libPres$PresTime[i], sep=" ")))
  }

  ## Build Pres
  Pres <- tibble(EventID=libPres$EventID, StaffName=str_to_lower(libPres$StaffName), StaffDept=libPres$StaffDept,
                 Undergraduates=Undergraduates$U, Graduates=Graduates$G,
                 FacultyStaff=FacultyStaff$FS, Children=Children$C, HighSchool=HighSchool$HS,
                 NonUWM=NonUWM$N, PresType=libPres$PresType, Title=libPres$PresTitle, Department=libPres$PresDept, Course=libPres$PresCourse,
                 Section=libPres$PresSect, Faculty=libPres$PresFac, Location=libPres$PresLoc, Partner=libPres$PresPartner,
                 PartnerName=libPres$PresPartnerName, Format=libPres$PresFormat, PresDateTime=DateTime$DT,
                 Length=libPres$PresLength, Count=libPres$PresCount, Story=libPres$PresStory, Notes=libPres$PresNotes)
  
  ## Write out Pres
  foutput <- paste(fpath, "Pres.csv", sep="/")
  write_csv(Pres, foutput)
  

  

## Clean and build Trans table
  libTrans <- filter(libStats, ServiceType=="transaction")
  
  ## Fix Directional, Informational, Referral, Reference, Format,
  ## Course, Faculty, TransDate, and TransTime variables
  Directional <- tibble(D=libTrans$TransType)
  Informational <- tibble(I=libTrans$TransType)
  Referral <- tibble(E=libTrans$TransType)
  Reference <- tibble(R=libTrans$TransType)
  DateTime <- tibble(DT=libTrans$TransDate)
  
  for (i in 1:dim(libTrans)[1]) {
    if(!is.na(Directional$D[i]) & str_detect(Directional$D[i], "directional"))
      Directional$D[i] <- TRUE else Directional$D[i] <- FALSE
      
    if(!is.na(Informational$I[i]) & str_detect(Informational$I[i], "informational"))
      Informational$I[i] <- TRUE else Informational$I[i] <- FALSE  
    
    if(!is.na(Referral$E[i]) & str_detect(Referral$E[i], "referral"))
      Referral$E[i] <- TRUE else Referral$E[i] <- FALSE  
    
    if(!is.na(Reference$R[i]) & str_detect(Reference$R[i], "reference"))
      Reference$R[i] <- TRUE else Reference$R[i] <- FALSE
        
    if(!is.na(libTrans$TransFormat[i]) & libTrans$TransFormat[i] == "other") libTrans$TransFormat[i] <- libTrans$TransFormatOther[i]
    
    if(!is.na(libTrans$TransCourse_old[i])) libTrans$TransCourse[i] <- libTrans$TransCourse_old[i]
    
    if(!is.na(libTrans$TransFac_old[i])) libTrans$TransFac[i] <- libTrans$TransFac_old[i]
    
    if(!is.na(libTrans$TransDate_old[i]) & str_detect(libTrans$TransDate_old[i], "Just now")) {
      #libTrans$TransDate[i] <- str_sub(libTrans$StartDate[i],1,10)
      #libTrans$TransTime[i] <- str_sub(libTrans$StartDate[i],12,19)
      DateTime$DT[i] <- as.character(libTrans$StartDate[i])
    } 
    else {
      if(!is.na(libTrans$TransTime[i]) & !str_detect(libTrans$TransTime[i], ":")) libTrans$TransTime[i] <- "12:00 AM"
      DateTime$DT[i] <- as.character(mdy_hm(paste(libTrans$TransDate[i], libTrans$TransTime[i], sep=" ")))
    }
    
    if(!is.na(libTrans$TransLoc[i]) & str_detect(libTrans$TransLoc[i], "Research Help Desk")) libTrans$StaffDept[i] <- "Research Help Desk"
  }
  
  ## Build Trans
  Trans <- tibble(EventID=libTrans$EventID, StaffName=str_to_lower(libTrans$StaffName), StaffDept=libTrans$StaffDept,
                  UserStatus=libTrans$TransUserStatus,
                  Directional=Directional$D, Informational=Informational$I, Referral=Referral$E, Reference=Reference$R,
                  Department=libTrans$TransDept, Course=libTrans$TransCourse, Faculty=libTrans$TransFac,
                  Location=libTrans$TransLoc, Format=libTrans$TransFormat, TransDateTime=DateTime$DT,
                  Story=libTrans$TransStory, Notes=libTrans$TransNotes)
    
  
  ## Write out Trans
  foutput <- paste(fpath, "Trans.csv", sep="/")
  write_csv(Trans, foutput)

  
  
  
## Build WD table
  libWD <- filter(libStats, StaffDept=="Welcome Desk")
  libWD$WDTime <- as.character(libWD$WDTime)
  
  ## Fix Directional, Informational, Referral, Reference, WDDate, and WDTime variables
  Directional <- tibble(D=libWD$WDType)
  Informational <- tibble(I=libWD$WDType)
  Referral <- tibble(E=libWD$WDType)
  Reference <- tibble(R=libWD$WDType)

  for (i in 1:dim(libWD)[1]) {
    if(!is.na(Directional$D[i]) & str_detect(Directional$D[i], "Directional"))
      Directional$D[i] <- TRUE else Directional$D[i] <- FALSE
      
    if(!is.na(Informational$I[i]) & str_detect(Informational$I[i], "Informational"))
        Informational$I[i] <- TRUE else Informational$I[i] <- FALSE  
        
    if(!is.na(Referral$E[i]) & str_detect(Referral$E[i], "Referral"))
          Referral$E[i] <- TRUE else Referral$E[i] <- FALSE  
          
    if(!is.na(Reference$R[i]) & str_detect(Reference$R[i], "Reference"))
            Reference$R[i] <- TRUE else Reference$R[i] <- FALSE
            
    if(!is.na(libWD$WDDate_old[i]) & str_detect(libWD$WDDate_old[i], "Just now")) {
        libWD$WDDate[i] <- str_sub(libWD$StartDate[i],1,10)
        libWD$WDTime[i] <- str_sub(libWD$StartDate[i],12,19)
    } else libWD$WDDate[i] <- as.character(mdy(libWD$WDDate[i]))
  }
  
  WD <- tibble(EventID=libWD$EventID, StaffName=str_to_lower(libWD$StaffName), StaffDept=libWD$StaffDept, UserStatus=libWD$WDUserStatus,
                Directional=Directional$D, Informational=Informational$I, Referral=Referral$E, Reference=Reference$R,
                Format=libWD$WDFormat, WDDate=libWD$WDDate, WDTime=libWD$WDTime,
                Story=libWD$WDStory, Notes=libWD$WDNotes) %>%
        unite(WDDateTime,WDDate,WDTime,sep=" ")
  
  ## Write out WD
  foutput <- paste(fpath, "WD.csv", sep="/")
  write_csv(WD, foutput)
  
  
  

 ## Build AGSL table
  AGSL_Cons <- tibble(Date=libStats$ConsDate, StaffName=libStats$StaffName, ServiceType="consultation", Collection=libStats$AGSLConsColl)
  AGSL_Cons <- filter(AGSL_Cons, Collection != "")

  for(i in 1:dim(AGSL_Cons)[1]) {
    if(!is.na(AGSL_Cons$Date[i])) AGSL_Cons$Date[i] <- as.character(mdy(AGSL_Cons$Date[i]))
  }

  
  AGSL_Trans <- tibble(Date=libStats$TransDate, Date_old=libStats$TransDate_old,  Date_start=libStats$StartDate, Time=libStats$TransTime,
                       StaffName=libStats$StaffName, ServiceType="transaction", Collection=libStats$AGSLTransColl)
  AGSL_Trans <- filter(AGSL_Trans, Collection != "")
  
  for(i in 1:dim(AGSL_Trans)[1]) {
    if(!is.na(AGSL_Trans$Date_old[i]) & str_detect(AGSL_Trans$Date_old[i], "Just now")) {
      AGSL_Trans$Date[i] <- as.character(AGSL_Trans$Date_start[i])
    } 
    else {
      if(!is.na(AGSL_Trans$Time[i]) & !str_detect(AGSL_Trans$Time[i], ":")) AGSL_Trans$Time[i] <- "12:00 AM"
      AGSL_Trans$Date[i] <- as.character(mdy_hm(paste(AGSL_Trans$Date[i], AGSL_Trans$Time[i], sep=" ")))
    }
  }
  
  AGSL_Trans <- select(AGSL_Trans, Date, StaffName, ServiceType, Collection)
  AGSL <- bind_rows(AGSL_Cons, AGSL_Trans) %>% arrange(Date)
  
  ## Write out AGSL
  foutput <- paste(fpath, "AGSL.csv", sep="/")
  write_csv(AGSL, foutput)  
  
  
  
  
## Build Dept table of course information
  Dept_Cons <- tibble(EventID=Cons$EventID, DateTime=Cons$ConsDate, StaffDept=Cons$StaffDept, StaffName=Cons$StaffName,
                      ServiceType="consultation", Format=Cons$Format,
                      Department=Cons$Department, Course=Cons$Course, Section="", Faculty=Cons$Faculty,
                      Count=as.character(Cons$Count), Length=as.character(Cons$Length))
  Dept_Pres <- tibble(EventID=Pres$EventID, DateTime= Pres$PresDateTime, StaffDept=Pres$StaffDept, StaffName=Pres$StaffName, 
                      ServiceType="presentation", Format=Pres$Format,
                      Department=Pres$Department, Course=Pres$Course, Section=Pres$Section, Faculty=Pres$Faculty,
                      Count=as.character(Pres$Count), Length=as.character(Pres$Length))
  Dept_Trans <- tibble(EventID=Trans$EventID, DateTime=Trans$TransDateTime, StaffDept=Trans$StaffDept, StaffName=Trans$StaffName,
                      ServiceType="transaction", Format=Trans$Format,
                      Department=Trans$Department, Course=Trans$Course, Section="", Faculty=Trans$Faculty,
                      Count="", Length="")

  Dept_unfiltered <- bind_rows(Dept_Cons, Dept_Pres, Dept_Trans)
  
  Dept <- filter(Dept_unfiltered, Department != "" & Department != "Don't know/no answer")
  

  ## Write out Dept
  foutput <- paste(fpath, "Courses.csv", sep="/")
  write_csv(Dept, foutput)