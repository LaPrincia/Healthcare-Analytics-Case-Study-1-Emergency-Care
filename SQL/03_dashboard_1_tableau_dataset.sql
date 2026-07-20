/*
==============================================================
Project: Palmetto Regional Health System
Case Study: 1 – Emergency Care & Patient Experience
Dashboard: 1 – Emergency Department Operations
File: 03_dashboard_1_tableau_dataset.sql

Purpose:
Create the row-level Tableau dataset used to build the
Executive Emergency Department Operations Dashboard.

The dataset combines emergency visit and clinical operations
data and creates the calculated fields needed for Tableau.

Database: PalmettoRegionalHealthSystemDW
Author: La'Princia Mance
==============================================================
*/

USE PalmettoRegionalHealthSystemDW;
GO


/*==============================================================
1. Create or update the Tableau dataset view
==============================================================*/

CREATE OR ALTER VIEW dbo.PRHS_CaseStudy1_Master_Tableau_Dataset
AS

SELECT
    /*----------------------------------------------------------
    Visit identifiers
    ----------------------------------------------------------*/
    ed.Visit_ID,
    ed.Patient_ID,


    /*----------------------------------------------------------
    Visit date fields
    ----------------------------------------------------------*/
    ed.Visit_Date,

    YEAR(ed.Visit_Date) AS Visit_Year,

    MONTH(ed.Visit_Date) AS Visit_Month_Number,

    DATENAME(MONTH, ed.Visit_Date) AS Visit_Month,

    DATEFROMPARTS(
        YEAR(ed.Visit_Date),
        MONTH(ed.Visit_Date),
        1
    ) AS Visit_Month_Start,

    DATEPART(QUARTER, ed.Visit_Date) AS Visit_Quarter_Number,

    CONCAT(
        'Q',
        DATEPART(QUARTER, ed.Visit_Date)
    ) AS Visit_Quarter,

    DATENAME(WEEKDAY, ed.Visit_Date) AS Visit_Day_Name,

    DATEPART(WEEKDAY, ed.Visit_Date) AS Visit_Day_Number,


    /*----------------------------------------------------------
    Visit time fields
    ----------------------------------------------------------*/
    ed.Arrival_Time,
    ed.Triage_Time,
    ed.Provider_Time,
    ed.Discharge_Time,

    DATEPART(HOUR, ed.Arrival_Time) AS Arrival_Hour,

    CONCAT(
        CASE
            WHEN DATEPART(HOUR, ed.Arrival_Time) = 0
                THEN 12

            WHEN DATEPART(HOUR, ed.Arrival_Time) > 12
                THEN DATEPART(HOUR, ed.Arrival_Time) - 12

            ELSE DATEPART(HOUR, ed.Arrival_Time)
        END,
        ' ',
        CASE
            WHEN DATEPART(HOUR, ed.Arrival_Time) < 12
                THEN 'AM'
            ELSE 'PM'
        END
    ) AS Arrival_Hour_Label,


    /*----------------------------------------------------------
    Arrival period
    ----------------------------------------------------------*/
    CASE
        WHEN DATEPART(HOUR, ed.Arrival_Time) BETWEEN 5 AND 11
            THEN 'Morning'

        WHEN DATEPART(HOUR, ed.Arrival_Time) BETWEEN 12 AND 16
            THEN 'Afternoon'

        WHEN DATEPART(HOUR, ed.Arrival_Time) BETWEEN 17 AND 20
            THEN 'Evening'

        ELSE 'Overnight'
    END AS Arrival_Period,

    CASE
        WHEN DATEPART(HOUR, ed.Arrival_Time) BETWEEN 5 AND 11
            THEN 1

        WHEN DATEPART(HOUR, ed.Arrival_Time) BETWEEN 12 AND 16
            THEN 2

        WHEN DATEPART(HOUR, ed.Arrival_Time) BETWEEN 17 AND 20
            THEN 3

        ELSE 4
    END AS Arrival_Period_Sort_Order,


    /*----------------------------------------------------------
    Patient demographics
    ----------------------------------------------------------*/
    ed.Age,
    ed.Gender,
    ed.Race,
    ed.Insurance,

    CASE
        WHEN ed.Age < 18 THEN 'Under 18'
        WHEN ed.Age BETWEEN 18 AND 34 THEN '18–34'
        WHEN ed.Age BETWEEN 35 AND 49 THEN '35–49'
        WHEN ed.Age BETWEEN 50 AND 64 THEN '50–64'
        WHEN ed.Age >= 65 THEN '65+'
        ELSE 'Unknown'
    END AS Age_Group,

    CASE
        WHEN ed.Age < 18 THEN 1
        WHEN ed.Age BETWEEN 18 AND 34 THEN 2
        WHEN ed.Age BETWEEN 35 AND 49 THEN 3
        WHEN ed.Age BETWEEN 50 AND 64 THEN 4
        WHEN ed.Age >= 65 THEN 5
        ELSE 6
    END AS Age_Group_Sort_Order,


    /*----------------------------------------------------------
    Clinical visit details
    ----------------------------------------------------------*/
    ed.Chief_Complaint,
    ed.Diagnosis,
    ed.Diagnosis_Category,
    ed.Visit_Complexity,
    ed.ESI_Category_Label,
    ed.Disposition,
    ed.Provider_ID,
    ed.Department,
    ed.Eligible_For_Survey,


    /*----------------------------------------------------------
    ESI category sort order
    ----------------------------------------------------------*/
    CASE ed.ESI_Category_Label
        WHEN 'Resuscitation' THEN 1
        WHEN 'Emergent' THEN 2
        WHEN 'Urgent' THEN 3
        WHEN 'Less Urgent' THEN 4
        WHEN 'Non-Urgent' THEN 5
        ELSE 6
    END AS ESI_Sort_Order,


    /*----------------------------------------------------------
    Patient disposition sort order
    ----------------------------------------------------------*/
    CASE ed.Disposition
        WHEN 'Discharged' THEN 1
        WHEN 'Admitted' THEN 2
        WHEN 'Transferred' THEN 3
        WHEN 'LWBS' THEN 4
        ELSE 5
    END AS Disposition_Sort_Order,


    /*----------------------------------------------------------
    Door-to-provider time

    The additional 1,440 minutes accounts for encounters that
    cross midnight when the source columns are stored as times.
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
    Emergency department length of stay
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
    Tableau KPI flags
    ----------------------------------------------------------*/
    CASE
        WHEN ed.Disposition = 'LWBS' THEN 1
        ELSE 0
    END AS LWBS_Flag,

    CASE
        WHEN ed.Disposition = 'Discharged' THEN 1
        ELSE 0
    END AS Discharged_Flag,

    CASE
        WHEN ed.Disposition = 'Admitted' THEN 1
        ELSE 0
    END AS Admitted_Flag,

    CASE
        WHEN ed.Disposition = 'Transferred' THEN 1
        ELSE 0
    END AS Transferred_Flag,


    /*----------------------------------------------------------
    Clinical operations fields
    ----------------------------------------------------------*/
    co.Lab_Ordered,
    co.Lab_Turnaround_Min,

    co.Imaging_Ordered,
    co.Imaging_Turnaround_Min,

    co.Bed_Assigned,
    co.Boarding_Time_Min,

    co.Admission_Decision,
    co.Transport_Delay_Min,


    /*----------------------------------------------------------
    Clinical operations flags
    ----------------------------------------------------------*/
    CASE
        WHEN co.Lab_Ordered = 'Yes' THEN 1
        ELSE 0
    END AS Lab_Ordered_Flag,

    CASE
        WHEN co.Imaging_Ordered = 'Yes' THEN 1
        ELSE 0
    END AS Imaging_Ordered_Flag,

    CASE
        WHEN co.Bed_Assigned = 'Yes' THEN 1
        ELSE 0
    END AS Bed_Assigned_Flag,

    CASE
        WHEN co.Admission_Decision = 'Admit' THEN 1
        ELSE 0
    END AS Admission_Decision_Flag


FROM dbo.ED_Visits AS ed

LEFT JOIN dbo.Clinical_Operations AS co
    ON ed.Visit_ID = co.Visit_ID;
GO


/*==============================================================
2. Confirm that the view was created successfully
==============================================================*/

SELECT TOP 20
    *
FROM dbo.PRHS_CaseStudy1_Master_Tableau_Dataset
ORDER BY
    Visit_Date,
    Arrival_Time;
GO


/*==============================================================
3. Validate final row count

Expected result:
1,200 rows
==============================================================*/

SELECT
    COUNT(*) AS Tableau_Dataset_Row_Count,
    COUNT(DISTINCT Visit_ID) AS Unique_Visit_Count
FROM dbo.PRHS_CaseStudy1_Master_Tableau_Dataset;
GO


/*==============================================================
4. Check for duplicate visits created by the join

Expected result:
No rows returned
==============================================================*/

SELECT
    Visit_ID,
    COUNT(*) AS Record_Count
FROM dbo.PRHS_CaseStudy1_Master_Tableau_Dataset
GROUP BY Visit_ID
HAVING COUNT(*) > 1;
GO


/*==============================================================
5. Confirm date range

Expected:
Calendar year 2025
==============================================================*/

SELECT
    MIN(Visit_Date) AS Earliest_Visit_Date,
    MAX(Visit_Date) AS Latest_Visit_Date
FROM dbo.PRHS_CaseStudy1_Master_Tableau_Dataset;
GO


/*==============================================================
6. Confirm the primary dashboard KPIs
==============================================================*/

SELECT
    COUNT(*) AS Total_ED_Visits,

    CAST(
        AVG(
            CAST(
                Door_To_Provider_Minutes
                AS DECIMAL(10,2)
            )
        )
        AS DECIMAL(10,1)
    ) AS Avg_Door_To_Provider_Minutes,

    CAST(
        AVG(
            CAST(
                Length_Of_Stay_Minutes
                AS DECIMAL(10,2)
            )
        )
        AS DECIMAL(10,1)
    ) AS Avg_Length_Of_Stay_Minutes,

    SUM(LWBS_Flag) AS LWBS_Visits,

    CAST(
        AVG(
            CAST(LWBS_Flag AS DECIMAL(10,4))
        ) * 100
        AS DECIMAL(5,2)
    ) AS LWBS_Rate_Percent

FROM dbo.PRHS_CaseStudy1_Master_Tableau_Dataset;
GO


/*==============================================================
7. Confirm monthly volume

Expected:
January   108
February   88
March     107
April      94
May        82
June       96
July      101
August    107
September  97
October    98
November  101
December  121
==============================================================*/

SELECT
    Visit_Year,
    Visit_Month_Number,
    Visit_Month,
    COUNT(*) AS Total_ED_Visits
FROM dbo.PRHS_CaseStudy1_Master_Tableau_Dataset
GROUP BY
    Visit_Year,
    Visit_Month_Number,
    Visit_Month
ORDER BY
    Visit_Year,
    Visit_Month_Number;
GO


/*==============================================================
8. Confirm peak arrival hour

Expected:
7 AM with 64 visits
==============================================================*/

SELECT TOP 1
    Arrival_Hour,
    Arrival_Hour_Label,
    COUNT(*) AS Total_ED_Visits
FROM dbo.PRHS_CaseStudy1_Master_Tableau_Dataset
GROUP BY
    Arrival_Hour,
    Arrival_Hour_Label
ORDER BY
    COUNT(*) DESC,
    Arrival_Hour;
GO


/*==============================================================
9. Confirm disposition distribution

Expected:
Discharged   576
Admitted     306
Transferred  288
LWBS          30
==============================================================*/

SELECT
    Disposition,
    COUNT(*) AS Total_ED_Visits
FROM dbo.PRHS_CaseStudy1_Master_Tableau_Dataset
GROUP BY Disposition
ORDER BY Total_ED_Visits DESC;
GO


/*==============================================================
10. Tableau dataset creation complete
==============================================================*/

PRINT 'Dashboard 1 Tableau dataset created and validated successfully.';
GO