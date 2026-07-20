/*
==============================================================
Project: Palmetto Regional Health System
Case Study: 1 – Emergency Care & Patient Experience
Dashboard: 1 – Emergency Department Operations
File: 02_dashboard_1_ed_operations_validation.sql
Purpose: Validate all metrics used in the Executive ED Dashboard
Database: PalmettoRegionalHealthSystemDW
Author: La'Princia Mance
==============================================================
*/

USE PalmettoRegionalHealthSystemDW;
GO

/*==============================================================
1. Total ED Visits
Expected: 1,200
==============================================================*/
SELECT
    COUNT(*) AS Total_ED_Visits
FROM ED_Visits;
GO


/*==============================================================
2. Monthly ED Visit Trend
Expected: 12 Months
==============================================================*/
SELECT
    DATENAME(MONTH, Visit_Date) AS Month_Name,
    MONTH(Visit_Date) AS Month_Number,
    COUNT(*) AS Total_Visits
FROM ED_Visits
GROUP BY
    DATENAME(MONTH, Visit_Date),
    MONTH(Visit_Date)
ORDER BY Month_Number;
GO


/*==============================================================
3. Hourly ED Visit Volume
==============================================================*/
SELECT
    DATEPART(HOUR, Arrival_Time) AS Arrival_Hour,
    COUNT(*) AS Total_Visits
FROM ED_Visits
GROUP BY DATEPART(HOUR, Arrival_Time)
ORDER BY Arrival_Hour;
GO


/*==============================================================
4. Emergency Severity Index Distribution
==============================================================*/
SELECT
    ESI_Category_Label,
    COUNT(*) AS Total_Visits
FROM ED_Visits
GROUP BY ESI_Category_Label
ORDER BY Total_Visits DESC;
GO


/*==============================================================
5. Chief Complaint Distribution
==============================================================*/
SELECT
    Chief_Complaint,
    COUNT(*) AS Total_Visits
FROM ED_Visits
GROUP BY Chief_Complaint
ORDER BY Total_Visits DESC;
GO


/*==============================================================
6. Patient Disposition
==============================================================*/
SELECT
    Disposition,
    COUNT(*) AS Total_Visits
FROM ED_Visits
GROUP BY Disposition
ORDER BY Total_Visits DESC;
GO


/*==============================================================
7. Average Door-to-Provider Time
==============================================================*/
SELECT
    AVG(DATEDIFF(MINUTE, Arrival_Time, Provider_Time))
        AS Avg_Door_To_Provider_Minutes
FROM ED_Visits;
GO


/*==============================================================
8. Average Length of Stay
==============================================================*/
SELECT
    AVG(DATEDIFF(MINUTE, Arrival_Time, Discharge_Time))
        AS Avg_Length_of_Stay_Minutes
FROM ED_Visits;
GO


/*==============================================================
9. Left Without Being Seen (LWBS)
==============================================================*/
SELECT
    COUNT(*) AS LWBS_Count,
    CAST(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM ED_Visits)
        AS DECIMAL(5,2)
    ) AS LWBS_Percentage
FROM ED_Visits
WHERE Disposition = 'Left Without Being Seen';
GO


/*==============================================================
10. Laboratory Utilization
==============================================================*/
SELECT
    COUNT(*) AS Lab_Orders,
    CAST(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM Clinical_Operations)
        AS DECIMAL(5,2)
    ) AS Lab_Order_Rate
FROM Clinical_Operations
WHERE Lab_Ordered = 'Yes';
GO


/*==============================================================
11. Imaging Utilization
==============================================================*/
SELECT
    COUNT(*) AS Imaging_Orders,
    CAST(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM Clinical_Operations)
        AS DECIMAL(5,2)
    ) AS Imaging_Order_Rate
FROM Clinical_Operations
WHERE Imaging_Ordered = 'Yes';
GO


/*==============================================================
12. Admission Rate
==============================================================*/
SELECT
    COUNT(*) AS Admissions,
    CAST(
        COUNT(*) * 100.0 /
        (SELECT COUNT(*) FROM Clinical_Operations)
        AS DECIMAL(5,2)
    ) AS Admission_Rate
FROM Clinical_Operations
WHERE Admission_Decision = 'Admit';
GO


/*==============================================================
13. Dashboard Validation Complete
==============================================================*/
PRINT 'Dashboard 1 validation complete.';
GO