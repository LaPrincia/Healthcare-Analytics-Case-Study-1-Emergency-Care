/*
==============================================================
Project: Palmetto Regional Health System
Case Study: 1 – Emergency Care & Patient Experience
Dashboard: 2 – Patient Experience

File: 06_dashboard_2_tableau_dataset.sql

Purpose:
Create the final Tableau-ready dataset for the Patient
Experience dashboard.

The view combines patient satisfaction responses with ED
visit details and department information. It also creates
calculated dimensions, KPI flags, date fields, and operational
performance measures needed for Tableau.

Database: PalmettoRegionalHealthSystemDW
Author: La'Princia Mance
==============================================================
*/

USE PalmettoRegionalHealthSystemDW;
GO


/*==============================================================
1. Create the Patient Experience Tableau View
==============================================================*/

CREATE OR ALTER VIEW
    dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset
AS

SELECT

    /*----------------------------------------------------------
    Survey Record Identifier
    ----------------------------------------------------------*/

    ps.Visit_ID,


    /*----------------------------------------------------------
    Visit Date Fields
    ----------------------------------------------------------*/

    ed.Visit_Date,

    YEAR(ed.Visit_Date) AS Visit_Year,

    DATEPART(QUARTER, ed.Visit_Date) AS Visit_Quarter_Number,

    CONCAT(
        'Q',
        DATEPART(QUARTER, ed.Visit_Date)
    ) AS Visit_Quarter,

    MONTH(ed.Visit_Date) AS Month_Number,

    DATENAME(MONTH, ed.Visit_Date) AS Month_Name,

    LEFT(
        DATENAME(MONTH, ed.Visit_Date),
        3
    ) AS Month_Abbreviation,

    DATEFROMPARTS(
        YEAR(ed.Visit_Date),
        MONTH(ed.Visit_Date),
        1
    ) AS Month_Start_Date,

    DATEPART(WEEK, ed.Visit_Date) AS Week_Number,

    DATENAME(WEEKDAY, ed.Visit_Date) AS Day_Name,

    DATEPART(WEEKDAY, ed.Visit_Date) AS Day_Of_Week_Number,

    CASE
        WHEN DATENAME(WEEKDAY, ed.Visit_Date)
             IN ('Saturday', 'Sunday')
            THEN 'Weekend'

        ELSE 'Weekday'
    END AS Weekday_Weekend_Category,


    /*----------------------------------------------------------
    Arrival-Time Fields
    ----------------------------------------------------------*/

    ed.Arrival_Time,

    DATEPART(
        HOUR,
        ed.Arrival_Time
    ) AS Arrival_Hour,

    CASE
        WHEN DATEPART(HOUR, ed.Arrival_Time)
             BETWEEN 5 AND 11
            THEN 'Morning'

        WHEN DATEPART(HOUR, ed.Arrival_Time)
             BETWEEN 12 AND 16
            THEN 'Afternoon'

        WHEN DATEPART(HOUR, ed.Arrival_Time)
             BETWEEN 17 AND 20
            THEN 'Evening'

        ELSE 'Overnight'
    END AS Arrival_Period,

    CASE
        WHEN DATEPART(HOUR, ed.Arrival_Time)
             BETWEEN 5 AND 11
            THEN 1

        WHEN DATEPART(HOUR, ed.Arrival_Time)
             BETWEEN 12 AND 16
            THEN 2

        WHEN DATEPART(HOUR, ed.Arrival_Time)
             BETWEEN 17 AND 20
            THEN 3

        ELSE 4
    END AS Arrival_Period_Sort_Order,


    /*----------------------------------------------------------
    ED Visit Information
    ----------------------------------------------------------*/

    ed.Patient_ID,

    ed.Arrival_Mode,

    ed.Age,

    ed.Gender,

    ed.Race,

    ed.Insurance,

    ed.Acuity_Level,

    ed.ESI_Category_Label,

    CASE
        WHEN ed.ESI_Category_Label = 'Resuscitation'
            THEN 1

        WHEN ed.ESI_Category_Label = 'Emergent'
            THEN 2

        WHEN ed.ESI_Category_Label = 'Urgent'
            THEN 3

        WHEN ed.ESI_Category_Label = 'Less Urgent'
            THEN 4

        WHEN ed.ESI_Category_Label = 'Non-Urgent'
            THEN 5

        ELSE 6
    END AS ESI_Sort_Order,

    ed.Chief_Complaint,

    ed.Diagnosis,

    ed.Diagnosis_Category,

    ed.Visit_Complexity,

    ed.Disposition,

    ed.Referral_Source,

    ed.Provider_ID,

    ed.Department_ID,

    d.Department_Name AS Department,

    ed.Eligible_For_Survey,


    /*----------------------------------------------------------
    Age Group
    ----------------------------------------------------------*/

    CASE
        WHEN ed.Age IS NULL
            THEN 'Unknown'

        WHEN ed.Age <= 17
            THEN '0–17'

        WHEN ed.Age BETWEEN 18 AND 34
            THEN '18–34'

        WHEN ed.Age BETWEEN 35 AND 49
            THEN '35–49'

        WHEN ed.Age BETWEEN 50 AND 64
            THEN '50–64'

        ELSE '65+'
    END AS Age_Group,

    CASE
        WHEN ed.Age IS NULL
            THEN 6

        WHEN ed.Age <= 17
            THEN 1

        WHEN ed.Age BETWEEN 18 AND 34
            THEN 2

        WHEN ed.Age BETWEEN 35 AND 49
            THEN 3

        WHEN ed.Age BETWEEN 50 AND 64
            THEN 4

        ELSE 5
    END AS Age_Group_Sort_Order,


    /*----------------------------------------------------------
    Survey Response Fields
    ----------------------------------------------------------*/

    ps.Survey_Score,

    ps.Would_Recommend,

    ps.Staff_Courtesy,

    ps.Communication,

    ps.Wait_Time_Rating,


    /*----------------------------------------------------------
    Standardized Would-Recommend Fields
    ----------------------------------------------------------*/

    CASE
        WHEN UPPER(
                 LTRIM(
                     RTRIM(ps.Would_Recommend)
                 )
             ) IN ('YES', 'Y', 'TRUE', '1')
            THEN 'Yes'

        WHEN UPPER(
                 LTRIM(
                     RTRIM(ps.Would_Recommend)
                 )
             ) IN ('NO', 'N', 'FALSE', '0')
            THEN 'No'

        ELSE 'Unknown'
    END AS Would_Recommend_Category,

    CASE
        WHEN UPPER(
                 LTRIM(
                     RTRIM(ps.Would_Recommend)
                 )
             ) IN ('YES', 'Y', 'TRUE', '1')
            THEN 1

        WHEN UPPER(
                 LTRIM(
                     RTRIM(ps.Would_Recommend)
                 )
             ) IN ('NO', 'N', 'FALSE', '0')
            THEN 0

        ELSE NULL
    END AS Would_Recommend_Flag,


    /*----------------------------------------------------------
    Overall Survey Rating Category
    ----------------------------------------------------------*/

    CASE
        WHEN ps.Survey_Score IS NULL
            THEN 'Not Rated'

        WHEN ps.Survey_Score = 5
            THEN 'Excellent'

        WHEN ps.Survey_Score = 4
            THEN 'Good'

        WHEN ps.Survey_Score = 3
            THEN 'Average'

        WHEN ps.Survey_Score = 2
            THEN 'Poor'

        WHEN ps.Survey_Score = 1
            THEN 'Very Poor'

        ELSE 'Invalid Rating'
    END AS Survey_Rating_Category,

    CASE
        WHEN ps.Survey_Score = 5
            THEN 1

        WHEN ps.Survey_Score = 4
            THEN 2

        WHEN ps.Survey_Score = 3
            THEN 3

        WHEN ps.Survey_Score = 2
            THEN 4

        WHEN ps.Survey_Score = 1
            THEN 5

        ELSE 6
    END AS Survey_Rating_Sort_Order,


    /*----------------------------------------------------------
    Favorable Survey Flags

    Definition:
    A rating of 4 or 5 is considered favorable.
    ----------------------------------------------------------*/

    CASE
        WHEN ps.Survey_Score IS NULL
            THEN NULL

        WHEN ps.Survey_Score >= 4
            THEN 1

        ELSE 0
    END AS Overall_Satisfaction_Favorable_Flag,

    CASE
        WHEN ps.Staff_Courtesy IS NULL
            THEN NULL

        WHEN ps.Staff_Courtesy >= 4
            THEN 1

        ELSE 0
    END AS Staff_Courtesy_Favorable_Flag,

    CASE
        WHEN ps.Communication IS NULL
            THEN NULL

        WHEN ps.Communication >= 4
            THEN 1

        ELSE 0
    END AS Communication_Favorable_Flag,

    CASE
        WHEN ps.Wait_Time_Rating IS NULL
            THEN NULL

        WHEN ps.Wait_Time_Rating >= 4
            THEN 1

        ELSE 0
    END AS Wait_Time_Favorable_Flag,


    /*----------------------------------------------------------
    Composite Patient Experience Score

    The composite score is the average of:
    - Staff Courtesy
    - Communication
    - Wait-Time Rating
    ----------------------------------------------------------*/

    CASE
        WHEN ps.Staff_Courtesy IS NOT NULL
         AND ps.Communication IS NOT NULL
         AND ps.Wait_Time_Rating IS NOT NULL

            THEN CAST(
                (
                    CAST(
                        ps.Staff_Courtesy
                        AS DECIMAL(10,2)
                    )
                    +
                    CAST(
                        ps.Communication
                        AS DECIMAL(10,2)
                    )
                    +
                    CAST(
                        ps.Wait_Time_Rating
                        AS DECIMAL(10,2)
                    )
                ) / 3.0

                AS DECIMAL(10,2)
            )

        ELSE NULL
    END AS Composite_Experience_Score,


    /*----------------------------------------------------------
    Composite Experience Category
    ----------------------------------------------------------*/

    CASE
        WHEN ps.Staff_Courtesy IS NULL
          OR ps.Communication IS NULL
          OR ps.Wait_Time_Rating IS NULL
            THEN 'Incomplete'

        WHEN
            (
                CAST(ps.Staff_Courtesy AS DECIMAL(10,2))
                +
                CAST(ps.Communication AS DECIMAL(10,2))
                +
                CAST(ps.Wait_Time_Rating AS DECIMAL(10,2))
            ) / 3.0 >= 4.00
            THEN 'Favorable'

        WHEN
            (
                CAST(ps.Staff_Courtesy AS DECIMAL(10,2))
                +
                CAST(ps.Communication AS DECIMAL(10,2))
                +
                CAST(ps.Wait_Time_Rating AS DECIMAL(10,2))
            ) / 3.0 >= 3.00
            THEN 'Neutral'

        ELSE 'Unfavorable'
    END AS Composite_Experience_Category,


    /*----------------------------------------------------------
    Operational Time Fields
    ----------------------------------------------------------*/

    ed.Triage_Time,

    ed.Provider_Time,

    ed.Discharge_Time,


    /*----------------------------------------------------------
    Door-to-Provider Time

    Handles visits that cross midnight.
    ----------------------------------------------------------*/

    CASE
        WHEN ed.Arrival_Time IS NULL
          OR ed.Provider_Time IS NULL
            THEN NULL

        WHEN ed.Provider_Time >= ed.Arrival_Time
            THEN DATEDIFF(
                MINUTE,
                ed.Arrival_Time,
                ed.Provider_Time
            )

        ELSE DATEDIFF(
                MINUTE,
                ed.Arrival_Time,
                ed.Provider_Time
             ) + 1440
    END AS Door_To_Provider_Minutes,


    /*----------------------------------------------------------
    Arrival-to-Triage Time

    Handles visits that cross midnight.
    ----------------------------------------------------------*/

    CASE
        WHEN ed.Arrival_Time IS NULL
          OR ed.Triage_Time IS NULL
            THEN NULL

        WHEN ed.Triage_Time >= ed.Arrival_Time
            THEN DATEDIFF(
                MINUTE,
                ed.Arrival_Time,
                ed.Triage_Time
            )

        ELSE DATEDIFF(
                MINUTE,
                ed.Arrival_Time,
                ed.Triage_Time
             ) + 1440
    END AS Arrival_To_Triage_Minutes,


    /*----------------------------------------------------------
    ED Length of Stay

    Handles visits that cross midnight.
    ----------------------------------------------------------*/

    CASE
        WHEN ed.Arrival_Time IS NULL
          OR ed.Discharge_Time IS NULL
            THEN NULL

        WHEN ed.Discharge_Time >= ed.Arrival_Time
            THEN DATEDIFF(
                MINUTE,
                ed.Arrival_Time,
                ed.Discharge_Time
            )

        ELSE DATEDIFF(
                MINUTE,
                ed.Arrival_Time,
                ed.Discharge_Time
             ) + 1440
    END AS Length_Of_Stay_Minutes,


    /*----------------------------------------------------------
    Survey Record Flag

    Every row in this dataset represents one completed survey.
    ----------------------------------------------------------*/

    1 AS Survey_Response_Flag


FROM dbo.Patient_Satisfaction AS ps

INNER JOIN dbo.ED_Visits AS ed
    ON ps.Visit_ID = ed.Visit_ID

INNER JOIN dbo.Departments AS d
    ON ed.Department_ID = d.Department_ID;
GO


/*==============================================================
2. Preview the Tableau Dataset
==============================================================*/

SELECT TOP 20
    *
FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset
ORDER BY Visit_Date, Visit_ID;
GO


/*==============================================================
3. Dataset Row Count
==============================================================*/

SELECT
    COUNT(*) AS Tableau_Dataset_Rows
FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset;
GO


/*==============================================================
4. Source-to-View Row Reconciliation

Expected result:
Patient_Satisfaction rows and Tableau view rows should match.
==============================================================*/

SELECT
    (
        SELECT COUNT(*)
        FROM dbo.Patient_Satisfaction
    ) AS Source_Survey_Rows,

    (
        SELECT COUNT(*)
        FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset
    ) AS Tableau_View_Rows,

    (
        SELECT COUNT(*)
        FROM dbo.Patient_Satisfaction
    )
    -
    (
        SELECT COUNT(*)
        FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset
    ) AS Row_Count_Difference;
GO


/*==============================================================
5. Duplicate Visit ID Validation

Expected result:
No rows should be returned.
==============================================================*/

SELECT
    Visit_ID,
    COUNT(*) AS Record_Count
FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset
GROUP BY Visit_ID
HAVING COUNT(*) > 1;
GO


/*==============================================================
6. Missing Department Validation

Expected result:
Missing department count should be zero.
==============================================================*/

SELECT
    COUNT(*) AS Missing_Department_Records
FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset
WHERE Department IS NULL;
GO


/*==============================================================
7. Visit-Date Range
==============================================================*/

SELECT
    MIN(Visit_Date) AS Earliest_Visit_Date,
    MAX(Visit_Date) AS Latest_Visit_Date
FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset;
GO


/*==============================================================
8. Patient Experience KPI Validation
==============================================================*/

SELECT
    COUNT(*) AS Total_Survey_Responses,

    CAST(
        AVG(
            CAST(Survey_Score AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Survey_Score,

    CAST(
        AVG(
            CAST(Composite_Experience_Score AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Composite_Experience_Score,

    CAST(
        AVG(
            CAST(
                Overall_Satisfaction_Favorable_Flag
                AS DECIMAL(10,4)
            )
        ) * 100.0
        AS DECIMAL(6,2)
    ) AS Overall_Favorable_Rate_Percent,

    CAST(
        AVG(
            CAST(
                Would_Recommend_Flag
                AS DECIMAL(10,4)
            )
        ) * 100.0
        AS DECIMAL(6,2)
    ) AS Would_Recommend_Rate_Percent,

    CAST(
        AVG(
            CAST(Staff_Courtesy AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Staff_Courtesy,

    CAST(
        AVG(
            CAST(Communication AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Communication,

    CAST(
        AVG(
            CAST(Wait_Time_Rating AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Wait_Time_Rating

FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset;
GO


/*==============================================================
9. Would-Recommend Validation

Expected result:
Yes = 574
No  = 115
Total = 689
==============================================================*/

SELECT
    Would_Recommend_Category,

    COUNT(*) AS Total_Responses,

    CAST(
        COUNT(*) * 100.0
        /
        NULLIF(
            (
                SELECT COUNT(*)
                FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset
            ),
            0
        )
        AS DECIMAL(6,2)
    ) AS Percent_Of_Responses

FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset

GROUP BY Would_Recommend_Category

ORDER BY Total_Responses DESC;
GO


/*==============================================================
10. Survey Score Distribution
==============================================================*/

SELECT
    Survey_Score,

    Survey_Rating_Category,

    COUNT(*) AS Total_Responses

FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset

GROUP BY
    Survey_Score,
    Survey_Rating_Category

ORDER BY Survey_Score;
GO


/*==============================================================
11. Monthly KPI Validation
==============================================================*/

SELECT
    Visit_Year,

    Month_Number,

    Month_Name,

    COUNT(*) AS Survey_Responses,

    CAST(
        AVG(
            CAST(Survey_Score AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Survey_Score,

    CAST(
        AVG(
            CAST(
                Overall_Satisfaction_Favorable_Flag
                AS DECIMAL(10,4)
            )
        ) * 100.0
        AS DECIMAL(6,2)
    ) AS Favorable_Satisfaction_Rate_Percent,

    CAST(
        AVG(
            CAST(
                Would_Recommend_Flag
                AS DECIMAL(10,4)
            )
        ) * 100.0
        AS DECIMAL(6,2)
    ) AS Would_Recommend_Rate_Percent

FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset

GROUP BY
    Visit_Year,
    Month_Number,
    Month_Name

ORDER BY
    Visit_Year,
    Month_Number;
GO


/*==============================================================
12. Department KPI Validation
==============================================================*/

SELECT
    Department,

    COUNT(*) AS Survey_Responses,

    CAST(
        AVG(
            CAST(Survey_Score AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Survey_Score,

    CAST(
        AVG(
            CAST(
                Overall_Satisfaction_Favorable_Flag
                AS DECIMAL(10,4)
            )
        ) * 100.0
        AS DECIMAL(6,2)
    ) AS Favorable_Satisfaction_Rate_Percent,

    CAST(
        AVG(
            CAST(
                Would_Recommend_Flag
                AS DECIMAL(10,4)
            )
        ) * 100.0
        AS DECIMAL(6,2)
    ) AS Would_Recommend_Rate_Percent

FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset

GROUP BY Department

ORDER BY Average_Survey_Score DESC;
GO


/*==============================================================
13. Arrival-Period Validation
==============================================================*/

SELECT
    Arrival_Period,

    Arrival_Period_Sort_Order,

    COUNT(*) AS Survey_Responses,

    CAST(
        AVG(
            CAST(Survey_Score AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Survey_Score

FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset

GROUP BY
    Arrival_Period,
    Arrival_Period_Sort_Order

ORDER BY Arrival_Period_Sort_Order;
GO


/*==============================================================
14. Operational Metric Validation
==============================================================*/

SELECT
    CAST(
        AVG(
            CAST(
                Door_To_Provider_Minutes
                AS DECIMAL(10,2)
            )
        )
        AS DECIMAL(10,2)
    ) AS Average_Door_To_Provider_Minutes,

    CAST(
        AVG(
            CAST(
                Arrival_To_Triage_Minutes
                AS DECIMAL(10,2)
            )
        )
        AS DECIMAL(10,2)
    ) AS Average_Arrival_To_Triage_Minutes,

    CAST(
        AVG(
            CAST(
                Length_Of_Stay_Minutes
                AS DECIMAL(10,2)
            )
        )
        AS DECIMAL(10,2)
    ) AS Average_Length_Of_Stay_Minutes

FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset;
GO


/*==============================================================
15. Tableau Filter-Value Validation
==============================================================*/

SELECT DISTINCT
    Department
FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset
ORDER BY Department;
GO

SELECT DISTINCT
    ESI_Category_Label,
    ESI_Sort_Order
FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset
ORDER BY ESI_Sort_Order;
GO

SELECT DISTINCT
    Arrival_Period,
    Arrival_Period_Sort_Order
FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset
ORDER BY Arrival_Period_Sort_Order;
GO

SELECT DISTINCT
    Age_Group,
    Age_Group_Sort_Order
FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset
ORDER BY Age_Group_Sort_Order;
GO

SELECT DISTINCT
    Visit_Year,
    Month_Number,
    Month_Name
FROM dbo.PRHS_CaseStudy1_Patient_Experience_Tableau_Dataset
ORDER BY Visit_Year, Month_Number;
GO


/*==============================================================
16. Dataset Creation Complete
==============================================================*/

PRINT 'Dashboard 2 Tableau dataset created and validated successfully.';
GO