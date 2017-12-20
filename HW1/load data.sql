LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW1/an_case.txt' INTO TABLE an_case 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW1/an_vitals.txt' INTO TABLE an_vitals 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW1/an_comorbid.txt' INTO TABLE an_comorbid 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW1/an_event.txt' INTO TABLE an_event 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW1/an_drug.txt' INTO TABLE an_drug 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/course/Rice/COMP533/HW1/an_drugCategory.txt' INTO TABLE an_drugCategory 
fields terminated by '\t' escaped by '\\' OPTIONALLY ENCLOSED BY '"' lines terminated by '\r\n'
IGNORE 1 LINES;