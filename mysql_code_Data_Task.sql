/* This MySQL script has these SECTIONS
1. Create Database and setup table Schemas: SAT, enrollment, and SAT_normalized
2. Load raw datasets 'SAT.txt' and 'enrollment.txt'
3. Perform steps 1-3 in the Data Task section two: Data Transformation
Note: The final transformation of the SAT data is done in Python
4. Load normalized (long-fromat) tab-delimeted text file: 'SAT_normalized.txt'
5. Perform final QA using simple MySQL queries to check final count and for Null values.
*/

### SECTION 1) Create Database and Setup Database Table Schemas for Loading tab-delimited text files ###

# Create new Database for Data Task
CREATE DATABASE SCHOOL_PERFORMANCE;

# Activate Database for USE
USE SCHOOL_PERFORMANCE;

# Create enrollment table schema
CREATE TABLE enrollment(
   state_id INT UNSIGNED NOT NULL,  
   enrollment SMALLINT UNSIGNED NOT NULL
);

# Create SAT table schema (This is for loading the output from QA Python Code: 'SAT_clean.txt') 
/* This table schema pads leading zeros where necessary to ensure proper joins later in script.
The padded zeros ensure the concatenated CODE values will match the pattern in the 'state_id" column 
in the enrollment dataset. */
CREATE TABLE SAT(
	CO_CODE INT(2), # Constrain to 2 integers (no leading zero necessary)
	DIST_CODE INT(4) ZEROFILL, # Constrain to 4 integers and pad with leading zeros
	SCH_CODE INT(3) ZEROFILL, # Constrain to 3 integers and pad with leading zeros
	TOTAL SMALLINT UNSIGNED NOT NULL,
	MATHEMATICS SMALLINT UNSIGNED NOT NULL,
	CRITICAL_READING SMALLINT UNSIGNED NOT NULL,
	WRITING SMALLINT UNSIGNED NOT NULL,
	SAT_1550 FLOAT NOT NULL,
	N_STUDENTS_SCORED SMALLINT UNSIGNED NOT NULL
);

# Create table schema for the normalized SAT data (For Loading the output from python code: 'SAT_normalized.txt')
CREATE TABLE SAT_normalized(
	ID INT UNSIGNED NOT NULL, 
	DATA_TYPE VARCHAR(20) NOT NULL,
   VALUE SMALLINT NOT NULL
);

### SECTION 2)Load tab-delimited data files for SAT (raw) and enrollment (raw) into database schemas 

# Load enrollment data into table
LOAD DATA LOCAL INFILE '/Users/jdexter/Desktop/dexter_data_task/enrollment.txt' # raw data
	INTO TABLE enrollment
   IGNORE 1 LINES;

SELECT * FROM enrollment;

### LOAD CLEANED SAT DATA ###
   
# Load SAT data into table (USES THE CLEANED 'SAT_clean.txt' file for LOAD)
LOAD DATA LOCAL INFILE '/Users/jdexter/Desktop/dexter_data_task/SAT_clean.txt' # CLEANED DATA
	INTO TABLE SAT
   IGNORE 1 LINES;
   
# Check number of records (to ensure it is 389 for enrollment and 380 for SAT)
SELECT COUNT(*) FROM enrollment;
SELECT COUNT(*) FROM SAT;

# View SAT data table to be sure all looks good
SELECT * FROM SAT;

### SECTION 3) Perform steps 1-3 in the Data Task section Data Transformation.

/* In this section I'm performing the concatenation of the CODE columns,
Joining the datasets to create the OVERALL_ENROL column, and then 
calculating the Percentage of Students taking the SAT at each school.
This join is in preparation for the final transformation done in Python.*/

### 1. Concatenate the three code columns to create a single ID column. ###

# Add column ID in preparation for concatenating the three code columns.
ALTER TABLE SAT ADD COLUMN ID INT UNSIGNED NULL UNIQUE;

# Concatenate the three code columns to create single ID columns
UPDATE SAT SET ID = CONCAT(`CO_CODE`, `DIST_CODE`, `SCH_CODE`); 

# Query SAT table to ensure CODES were concatenated and added to ID column properly
SELECT * FROM SAT ORDER BY CO_CODE, DIST_CODE; # View in sorted order that mirrors sorted state_id column

### THE NEXT QUERY COMBINES 2 & 3 IN THE DATA TRANSFORMATION SECTION ###
# 2. Create new column OVERALL_ENROL by joining the SAT.txt and supplied enrollment.txt file. 
# 3. Calculate the percentage of students taking the SAT at each school. 
	# Store that value in a separate column, PERC_TAKING_SAT, noting any irregularities in the result.
SELECT S.ID, S.TOTAL, S.MATHEMATICS, S.CRITICAL_READING, S.WRITING, S.SAT_1550, 
S.N_STUDENTS_SCORED, e.enrollment AS OVERALL_ENROLL, 
(N_STUDENTS_SCORED / enrollment) * 100 AS PERC_TAKING_SAT # S.CO_CODE, S.DIST_CODE, S.SCH_CODE,
FROM SAT S LEFT JOIN enrollment e ON S.ID = e.state_id
ORDER BY PERC_TAKING_SAT DESC;

# Export Wide-Format SAT table to a tab-lemited text file for transformation in Python
SELECT * FROM SAT
INTO OUTFILE 'SAT_wide.txt';

### SECTION 4) Load normalized (long-fromat) tab-delimeted text file: 'SAT_long_format.txt'
LOAD DATA LOCAL INFILE '/Users/jdexter/Desktop/dexter_data_task/SAT_long_format.txt' # cleaned data
	INTO TABLE SAT_normalized
   IGNORE 1 LINES;

# View normalized data
SELECT * FROM SAT_normalized;

### SECTION 5) Perform final QA using simple MySQL queries to check table counts and null values.
# be sure SAT_normalized is good to go and ready to present metrics on the web-platform

# Count records to be sure it equals 1900
SELECT COUNT(*) FROM SAT_normalized;  # Count is 1900 (sanity check: (5 data types) * (380 records for each) = 1900)

# Do a quick check to be sure there are no Null values
SELECT * FROM SAT_normalized 
WHERE ID IS NULL; # None

SELECT * FROM SAT_normalized
WHERE DATA_TYPE IS NULL; # None

SELECT * FROM SAT_normalized
WHERE VALUE IS NULL; # None
