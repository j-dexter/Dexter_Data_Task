## Thank you for the opportunity to participate in the Data Task Exercise :smiley:

### This ReadMe file will guide you through my solution and orient you to the GitHub repository.

---

**PART ONE:** Description of each file in Repository (view them in this order to follow my workflow):
1. **python_code_initial_QA.ipynb** (code used for Data Quality Assurance and cleaning SAT data)
2. **SAT_clean.txt** (output from QA python code and input for MySQL SAT table Load)
3. **mysql_code_Data_Task.sql** (MySQL script used for Database Loads and parts of Data Transformation)
4. **SAT_wide_format.txt** (output from MySQL (w/ID column) and input for python code that reshapes data to long-format)
5. **python_code_Transform.ipynb** (takes wide SAT data and reshapes to the requested normalized structure)
6. **SAT_long_format.txt** (reshaped SAT data ready for Load into MySQL and final QA) 

**BONUS FILE/Code:** automated_QA_Report_Example.ipynb 
- Produces example of a table with targed list of records that have Data Integrity issues and that analyst could follow up on.

---

**PART TWO:** How I approached the problem and got started:
1. I wanted to follow closely to ETL: Clean/QA -> Normalize/Transform Data -> Load -> Final QA
    -  And at the same time, think of a way to automate the QA/Cleaning process for scaling to larger datasets.
2. My general workflow for getting started on the Data Task
    - Read instructions to get the general idea of what I needed to do.
    - Because these were small datasets, I opened them in Excel to quickly get familiar with the data.
    - While SAT.txt and enrollment.txt were opened, I determined a few methods to use for the QA/cleaing process.
        - This was simply by doing custom sorts, calculating new totals for comparison, etc.
    - I also started to get a sense of what would be needed to join the two tables.
    - Once that was completed, I used Jupyter Notebooks and MySQL Workbench to work my way through the Data Task(s).

--- 

**PART THREE:** Description of My Process and Findings during the QA Data Task:
1. As mentioned before, for time's sake I did my initial inspection in Microsoft Excel.
    - This allowed me to quickly get oriented with the data and identify ways to run my QA/cleaning of the SAT data.
2. These are the **Data Integrity issues identified:**
    - Six duplicated entries were found and dropped.
    - Four null values were found and dropped.
    - Three Data Entry Errors related to Test Scores and Total columns were identified and dropped.
    - Seven entries were found to have Test Score values outside of the range 200-800 and were dropped.
3. This brought the inititial 400 SAT records down to 380 and those were then loaded into MySQL for next steps.

**Note:** See code file (**python_code_initial_QA.ipynb**) for more details regarding QA process and findings.

**PART FOUR:** Noted irregularities in the resulting PERC_TAKING_SAT column created during Data Transformation task:
1. After calculating the Percentage of Students taking the SAT at each school I noticed 3 records with values over 100%:
    - ID: 34300050 (146.7 %)
    - ID: 31370040 (118.3 %)
    - ID: 31760050 (116.3 %)
2. Obviously, there can't be over 100 % of students taking SAT tests at a school and so these are errors and need further investigation.
    - If I were to Automate QA process, I'd add this as another component.

**Note:** See code file (**mysql_code_Data_Task.sql**) for more details.
