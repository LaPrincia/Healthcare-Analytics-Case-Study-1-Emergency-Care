/*
==============================================================
Project: Palmetto Regional Health System
Case Study: 1 – Emergency Care & Patient Experience
Dashboard: 2 – Patient Experience

File: 05_dashboard_2_patient_experience_validation.sql

Purpose:
Validate the Patient Satisfaction dataset and verify that
all dashboard KPIs reconcile correctly before publishing
to Tableau.

Database: PalmettoRegionalHealthSystemDW
Author: La'Princia Mance
==============================================================
*/

USE PalmettoRegionalHealthSystemDW;
GO

/*==============================================================
1. Patient Satisfaction Row Count
==============================================================*/

SELECT
    COUNT(*) AS Total_Survey_Records
FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
2. Distinct Visit IDs
==============================================================*/

SELECT
    COUNT(DISTINCT Visit_ID) AS Distinct_Visit_IDs
FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
3. Duplicate Visit IDs
==============================================================*/

SELECT
    Visit_ID,
    COUNT(*) AS Duplicate_Count
FROM dbo.Patient_Satisfaction
GROUP BY Visit_ID
HAVING COUNT(*) > 1;
GO


/*==============================================================
4. Missing Visit IDs
==============================================================*/

SELECT *
FROM dbo.Patient_Satisfaction
WHERE Visit_ID IS NULL;
GO


/*==============================================================
5. Join Validation
==============================================================*/

SELECT
    COUNT(*) AS Successfully_Joined_Records
FROM dbo.Patient_Satisfaction ps
INNER JOIN dbo.ED_Visits ed
    ON ps.Visit_ID = ed.Visit_ID;
GO


/*==============================================================
6. Survey Records Missing an ED Visit
==============================================================*/

SELECT
    ps.Visit_ID
FROM dbo.Patient_Satisfaction ps
LEFT JOIN dbo.ED_Visits ed
    ON ps.Visit_ID = ed.Visit_ID
WHERE ed.Visit_ID IS NULL;
GO


/*==============================================================
7. Eligible Survey Validation
==============================================================*/

SELECT
    COUNT(*) AS Eligible_Survey_Records
FROM dbo.Patient_Satisfaction ps
INNER JOIN dbo.ED_Visits ed
    ON ps.Visit_ID = ed.Visit_ID
WHERE ed.Eligible_For_Survey = 1;
GO


/*==============================================================
8. Survey Score Validation
==============================================================*/

SELECT
    MIN(Survey_Score) AS Minimum_Score,
    MAX(Survey_Score) AS Maximum_Score
FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
9. Invalid Survey Scores
==============================================================*/

SELECT *
FROM dbo.Patient_Satisfaction
WHERE Survey_Score NOT BETWEEN 1 AND 5;
GO


/*==============================================================
10. Staff Courtesy Validation
==============================================================*/

SELECT
    MIN(Staff_Courtesy) AS Minimum_Rating,
    MAX(Staff_Courtesy) AS Maximum_Rating
FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
11. Communication Validation
==============================================================*/

SELECT
    MIN(Communication) AS Minimum_Rating,
    MAX(Communication) AS Maximum_Rating
FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
12. Wait Time Rating Validation
==============================================================*/

SELECT
    MIN(Wait_Time_Rating) AS Minimum_Rating,
    MAX(Wait_Time_Rating) AS Maximum_Rating
FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
13. Would Recommend Values
==============================================================*/

SELECT
    Would_Recommend,
    COUNT(*) AS Responses
FROM dbo.Patient_Satisfaction
GROUP BY Would_Recommend
ORDER BY Responses DESC;
GO


/*==============================================================
14. Missing Values
==============================================================*/

SELECT

SUM(CASE WHEN Survey_Score IS NULL THEN 1 ELSE 0 END) AS Missing_Survey_Score,

SUM(CASE WHEN Would_Recommend IS NULL THEN 1 ELSE 0 END) AS Missing_Would_Recommend,

SUM(CASE WHEN Staff_Courtesy IS NULL THEN 1 ELSE 0 END) AS Missing_Staff_Courtesy,

SUM(CASE WHEN Communication IS NULL THEN 1 ELSE 0 END) AS Missing_Communication,

SUM(CASE WHEN Wait_Time_Rating IS NULL THEN 1 ELSE 0 END) AS Missing_Wait_Time_Rating

FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
15. Department Join Validation
==============================================================*/

SELECT
    d.Department_Name,
    COUNT(*) AS Survey_Responses
FROM dbo.Patient_Satisfaction ps
INNER JOIN dbo.ED_Visits ed
    ON ps.Visit_ID = ed.Visit_ID
INNER JOIN dbo.Departments d
    ON ed.Department_ID = d.Department_ID
GROUP BY d.Department_Name
ORDER BY Survey_Responses DESC;
GO


/*==============================================================
16. Monthly Survey Validation
==============================================================*/

SELECT

YEAR(ed.Visit_Date) AS Visit_Year,

MONTH(ed.Visit_Date) AS Month_Number,

DATENAME(MONTH,ed.Visit_Date) AS Month_Name,

COUNT(*) AS Survey_Responses

FROM dbo.Patient_Satisfaction ps

INNER JOIN dbo.ED_Visits ed
ON ps.Visit_ID = ed.Visit_ID

GROUP BY

YEAR(ed.Visit_Date),

MONTH(ed.Visit_Date),

DATENAME(MONTH,ed.Visit_Date)

ORDER BY
Visit_Year,
Month_Number;
GO


/*==============================================================
17. KPI Validation
==============================================================*/

SELECT

COUNT(*) AS Survey_Responses,

CAST(AVG(CAST(Survey_Score AS DECIMAL(10,2))) AS DECIMAL(10,2))
AS Average_Survey_Score,

CAST(

SUM(
CASE
WHEN Survey_Score >=4 THEN 1
ELSE 0
END
)*100.0
/
COUNT(*)

AS DECIMAL(6,2))

AS Favorable_Satisfaction_Percent

FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
18. Validation Complete
==============================================================*/

PRINT 'Dashboard 2 validation completed successfully.';
GO