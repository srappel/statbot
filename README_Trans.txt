"Trans.xlsx" Data Dictionary

EventID - unique ID for each event, created by Qualtrics survey tool

StaffName - Panther ID of staff member who provided the transaction

StaffDept - department that the staff member providing transaction is associated with

UserStatus - status of patron receiving the transaction; values may be either "UWM undergraduate student", "UWM graduate student", "UWM faculty or staff", "non-UWM person", or "don't know"

Directional - value is "TRUE" if transaction was of directional type, otherwise "FALSE"; transactions may have multiple types

Informational - value is "TRUE" if transaction was of informational type, otherwise "FALSE"; transactions may have multiple types

Referral - value is "TRUE" if transaction was of referral type, otherwise "FALSE"; transactions may have multiple types

Reference - value is "TRUE" if transaction was of reference type, otherwise "FALSE"; transactions may have multiple types

Department - if course-related, the department of the course this transaction was about; unknown/no course represented as "NA"

Course - if course-related, the number of course this transaction was about; unknown/no course represented as "NA"

Faculty - if course-related, the faculty member for the course this transaction was about; unknown/no course represented as "NA"

Location - location of the transaction

Format - format of the transaction; values may be "in person/face to face", "on the phone", "over e-mail", "over snail mail", or a combination of these options

TransDateTime - date and time of the transaction; format is YYYY-MM-DDThh:mm:ssZ

Story - a touching story about this transaction; if no story is given, the field is marked "NA"

Notes - personal notes about the transaction; if no notes are input, this field is marked "NA"
