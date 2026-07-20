/*
==============================================================
Project: Palmetto Regional Health System
Case Study: 1 – Emergency Care & Patient Experience
Dashboard: 1 – Emergency Department Operations
File: 01_dashboard_1_ed_operations_queries.sql

Purpose:
Calculate the operational KPIs and supporting analyses used
in the Executive Emergency Department Operations Dashboard.

Database: PalmettoRegionalHealthSystemDW
Author: La'Princia Mance
==============================================================
*/

USE PalmettoRegionalHealthSystemDW;
GO


/*==============================================================
1. Total Emergency Department Visits
Business Question:
How many ED visits occurred during the reporting period?

Expected Result:
1,200 total visits
==============================================================*/

SELECT
    COUNT(*) AS Total_ED_Visits
FROM dbo.ED_Visits;
GO


/*==============================================================
2. Average Door-to-Provider Time
Business Question:
On average, how many minutes elapsed between patient arrival
and the initial provider assessment?
==============================================================*/

SELECT
    CAST(
        AVG(
            CAST(
                DATEDIFF(
                    MINUTE,
                    Arrival_Time,
                    Provider_Time
                ) AS DECIMAL(10,2)
            )
        ) AS DECIMAL(10,1)
    ) AS Avg_Door_To_Provider_Minutes
FROM dbo.ED_Visits
WHERE Arrival_Time IS NOT NULL
  AND Provider_Time IS NOT NULL;
GO


/*==============================================================
3. Average Emergency Department Length of Stay
Business Question:
On average, how long did patients remain in the ED from
arrival through discharge?
==============================================================*/

SELECT
    CAST(
        AVG(
            CAST(
                DATEDIFF(
                    MINUTE,
                    Arrival_Time,
                    Discharge_Time
                ) AS DECIMAL(10,2)
            )
        ) AS DECIMAL(10,1)
    ) AS Avg_Length_Of_Stay_Minutes
FROM dbo.ED_Visits
WHERE Arrival_Time IS NOT NULL
  AND Discharge_Time IS NOT NULL;
GO


/*==============================================================
4. Left Without Being Seen Rate
Business Question:
What percentage of ED patients left before receiving care?

Expected Result:
30 LWBS visits
2.50% LWBS rate
==============================================================*/

SELECT
    COUNT(*) AS LWBS_Visits,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            (SELECT COUNT(*) FROM dbo.ED_Visits),
            0
        )
        AS DECIMAL(5,2)
    ) AS LWBS_Rate_Percent

FROM dbo.ED_Visits
WHERE Disposition = 'LWBS';
GO


/*==============================================================
5. Peak Arrival Hour
Business Question:
During which hour did the ED receive the highest number
of patient arrivals?

Expected Result:
7:00 AM with 64 visits
==============================================================*/

SELECT TOP 1
    DATEPART(HOUR, Arrival_Time) AS Arrival_Hour,

    CONCAT(
        CASE
            WHEN DATEPART(HOUR, Arrival_Time) = 0 THEN 12
            WHEN DATEPART(HOUR, Arrival_Time) > 12
                THEN DATEPART(HOUR, Arrival_Time) - 12
            ELSE DATEPART(HOUR, Arrival_Time)
        END,
        ' ',
        CASE
            WHEN DATEPART(HOUR, Arrival_Time) < 12
                THEN 'AM'
            ELSE 'PM'
        END
    ) AS Peak_Arrival_Time,

    COUNT(*) AS Total_Visits

FROM dbo.ED_Visits
WHERE Arrival_Time IS NOT NULL
GROUP BY DATEPART(HOUR, Arrival_Time)
ORDER BY
    COUNT(*) DESC,
    DATEPART(HOUR, Arrival_Time);
GO


/*==============================================================
6. Monthly Emergency Department Visit Trend
Business Question:
How did ED volume change by month during calendar year 2025?
==============================================================*/

SELECT
    YEAR(Visit_Date) AS Visit_Year,
    MONTH(Visit_Date) AS Month_Number,
    DATENAME(MONTH, Visit_Date) AS Month_Name,
    COUNT(*) AS Total_ED_Visits

FROM dbo.ED_Visits
WHERE Visit_Date IS NOT NULL

GROUP BY
    YEAR(Visit_Date),
    MONTH(Visit_Date),
    DATENAME(MONTH, Visit_Date)

ORDER BY
    Visit_Year,
    Month_Number;
GO


/*==============================================================
7. Average Monthly ED Visit Volume
Business Question:
What was the average number of ED visits per month?
==============================================================*/

WITH Monthly_Visits AS
(
    SELECT
        YEAR(Visit_Date) AS Visit_Year,
        MONTH(Visit_Date) AS Month_Number,
        COUNT(*) AS Total_ED_Visits

    FROM dbo.ED_Visits
    WHERE Visit_Date IS NOT NULL

    GROUP BY
        YEAR(Visit_Date),
        MONTH(Visit_Date)
)

SELECT
    CAST(
        AVG(
            CAST(Total_ED_Visits AS DECIMAL(10,2))
        ) AS DECIMAL(10,1)
    ) AS Average_Monthly_ED_Visits

FROM Monthly_Visits;
GO


/*==============================================================
8. Hourly Emergency Department Visit Volume
Business Question:
At what times of day did the ED experience the greatest
patient-arrival volume?
==============================================================*/

SELECT
    DATEPART(HOUR, Arrival_Time) AS Arrival_Hour,

    CONCAT(
        CASE
            WHEN DATEPART(HOUR, Arrival_Time) = 0 THEN 12
            WHEN DATEPART(HOUR, Arrival_Time) > 12
                THEN DATEPART(HOUR, Arrival_Time) - 12
            ELSE DATEPART(HOUR, Arrival_Time)
        END,
        ' ',
        CASE
            WHEN DATEPART(HOUR, Arrival_Time) < 12
                THEN 'AM'
            ELSE 'PM'
        END
    ) AS Arrival_Hour_Label,

    COUNT(*) AS Total_ED_Visits

FROM dbo.ED_Visits
WHERE Arrival_Time IS NOT NULL

GROUP BY DATEPART(HOUR, Arrival_Time)

ORDER BY Arrival_Hour;
GO


/*==============================================================
9. Arrival Period Distribution
Business Question:
How was ED volume distributed across major periods of the day?
==============================================================*/

SELECT
    CASE
        WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 5 AND 11
            THEN 'Morning'

        WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 12 AND 16
            THEN 'Afternoon'

        WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 17 AND 20
            THEN 'Evening'

        ELSE 'Overnight'
    END AS Arrival_Period,

    COUNT(*) AS Total_ED_Visits,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            (SELECT COUNT(*) FROM dbo.ED_Visits),
            0
        )
        AS DECIMAL(5,2)
    ) AS Percent_Of_Visits

FROM dbo.ED_Visits
WHERE Arrival_Time IS NOT NULL

GROUP BY
    CASE
        WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 5 AND 11
            THEN 'Morning'

        WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 12 AND 16
            THEN 'Afternoon'

        WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 17 AND 20
            THEN 'Evening'

        ELSE 'Overnight'
    END

ORDER BY
    CASE
        WHEN
            CASE
                WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 5 AND 11
                    THEN 'Morning'
                WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 12 AND 16
                    THEN 'Afternoon'
                WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 17 AND 20
                    THEN 'Evening'
                ELSE 'Overnight'
            END = 'Morning'
            THEN 1

        WHEN
            CASE
                WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 5 AND 11
                    THEN 'Morning'
                WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 12 AND 16
                    THEN 'Afternoon'
                WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 17 AND 20
                    THEN 'Evening'
                ELSE 'Overnight'
            END = 'Afternoon'
            THEN 2

        WHEN
            CASE
                WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 5 AND 11
                    THEN 'Morning'
                WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 12 AND 16
                    THEN 'Afternoon'
                WHEN DATEPART(HOUR, Arrival_Time) BETWEEN 17 AND 20
                    THEN 'Evening'
                ELSE 'Overnight'
            END = 'Evening'
            THEN 3

        ELSE 4
    END;
GO


/*==============================================================
10. Emergency Severity Index Distribution
Business Question:
What was the distribution of patient acuity levels?
==============================================================*/

SELECT
    ESI_Category_Label,
    COUNT(*) AS Total_ED_Visits,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            (SELECT COUNT(*) FROM dbo.ED_Visits),
            0
        )
        AS DECIMAL(5,2)
    ) AS Percent_Of_Visits

FROM dbo.ED_Visits

GROUP BY ESI_Category_Label

ORDER BY
    CASE ESI_Category_Label
        WHEN 'Resuscitation' THEN 1
        WHEN 'Emergent' THEN 2
        WHEN 'Urgent' THEN 3
        WHEN 'Less Urgent' THEN 4
        WHEN 'Non-Urgent' THEN 5
        ELSE 6
    END;
GO


/*==============================================================
11. Chief Complaint Analysis
Business Question:
What were the most common reasons patients visited the ED?
==============================================================*/

SELECT
    Chief_Complaint,
    COUNT(*) AS Total_ED_Visits,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            (SELECT COUNT(*) FROM dbo.ED_Visits),
            0
        )
        AS DECIMAL(5,2)
    ) AS Percent_Of_Visits

FROM dbo.ED_Visits

GROUP BY Chief_Complaint

ORDER BY
    Total_ED_Visits DESC,
    Chief_Complaint;
GO


/*==============================================================
12. Top Five Chief Complaints
Business Question:
Which five chief complaints accounted for the highest
ED visit volume?
==============================================================*/

SELECT TOP 5
    Chief_Complaint,
    COUNT(*) AS Total_ED_Visits,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            (SELECT COUNT(*) FROM dbo.ED_Visits),
            0
        )
        AS DECIMAL(5,2)
    ) AS Percent_Of_Visits

FROM dbo.ED_Visits

GROUP BY Chief_Complaint

ORDER BY
    Total_ED_Visits DESC,
    Chief_Complaint;
GO


/*==============================================================
13. Patient Disposition Distribution
Business Question:
What were the final outcomes of ED encounters?

Expected Results:
Discharged: 576
Admitted: 306
Transferred: 288
LWBS: 30
==============================================================*/

SELECT
    Disposition,
    COUNT(*) AS Total_ED_Visits,

    CAST(
        COUNT(*) * 100.0 /
        NULLIF(
            (SELECT COUNT(*) FROM dbo.ED_Visits),
            0
        )
        AS DECIMAL(5,2)
    ) AS Percent_Of_Visits

FROM dbo.ED_Visits

GROUP BY Disposition

ORDER BY Total_ED_Visits DESC;
GO


/*==============================================================
14. Department-Level ED Performance
Business Question:
How did patient volume and operational performance vary
by department?
==============================================================*/

SELECT
    Department,
    COUNT(*) AS Total_ED_Visits,

    CAST(
        AVG(
            CAST(
                DATEDIFF(
                    MINUTE,
                    Arrival_Time,
                    Provider_Time
                ) AS DECIMAL(10,2)
            )
        ) AS DECIMAL(10,1)
    ) AS Avg_Door_To_Provider_Minutes,

    CAST(
        AVG(
            CAST(
                DATEDIFF(
                    MINUTE,
                    Arrival_Time,
                    Discharge_Time
                ) AS DECIMAL(10,2)
            )
        ) AS DECIMAL(10,1)
    ) AS Avg_Length_Of_Stay_Minutes,

    SUM(
        CASE
            WHEN Disposition = 'LWBS' THEN 1
            ELSE 0
        END
    ) AS LWBS_Visits,

    CAST(
        SUM(
            CASE
                WHEN Disposition = 'LWBS' THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS LWBS_Rate_Percent

FROM dbo.ED_Visits

GROUP BY Department

ORDER BY Total_ED_Visits DESC;
GO


/*==============================================================
15. Laboratory Utilization
Business Question:
What percentage of ED visits included a laboratory order?

Expected Result:
Approximately 64.42%
==============================================================*/

SELECT
    SUM(
        CASE
            WHEN Lab_Ordered = 'Yes' THEN 1
            ELSE 0
        END
    ) AS Visits_With_Lab_Order,

    COUNT(*) AS Total_Clinical_Operations_Records,

    CAST(
        SUM(
            CASE
                WHEN Lab_Ordered = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS Lab_Utilization_Rate

FROM dbo.Clinical_Operations;
GO


/*==============================================================
16. Imaging Utilization
Business Question:
What percentage of ED visits included an imaging order?

Expected Result:
Approximately 50.42%
==============================================================*/

SELECT
    SUM(
        CASE
            WHEN Imaging_Ordered = 'Yes' THEN 1
            ELSE 0
        END
    ) AS Visits_With_Imaging_Order,

    COUNT(*) AS Total_Clinical_Operations_Records,

    CAST(
        SUM(
            CASE
                WHEN Imaging_Ordered = 'Yes' THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS Imaging_Utilization_Rate

FROM dbo.Clinical_Operations;
GO


/*==============================================================
17. Admission Decision Rate
Business Question:
What percentage of clinical-operation records included
an admission decision?

Expected Result:
Approximately 39.75%
==============================================================*/

SELECT
    SUM(
        CASE
            WHEN Admission_Decision = 'Admit' THEN 1
            ELSE 0
        END
    ) AS Admission_Decisions,

    COUNT(*) AS Total_Clinical_Operations_Records,

    CAST(
        SUM(
            CASE
                WHEN Admission_Decision = 'Admit' THEN 1
                ELSE 0
            END
        ) * 100.0 /
        NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS Admission_Decision_Rate

FROM dbo.Clinical_Operations;
GO


/*==============================================================
18. Clinical Operations Turnaround Times
Business Question:
What were the average turnaround and delay times for
laboratory, imaging, boarding, and transport activities?
==============================================================*/

SELECT
    CAST(
        AVG(
            CAST(Lab_Turnaround_Min AS DECIMAL(10,2))
        ) AS DECIMAL(10,1)
    ) AS Avg_Lab_Turnaround_Minutes,

    CAST(
        AVG(
            CAST(Imaging_Turnaround_Min AS DECIMAL(10,2))
        ) AS DECIMAL(10,1)
    ) AS Avg_Imaging_Turnaround_Minutes,

    CAST(
        AVG(
            CAST(Boarding_Time_Min AS DECIMAL(10,2))
        ) AS DECIMAL(10,1)
    ) AS Avg_Boarding_Time_Minutes,

    CAST(
        AVG(
            CAST(Transport_Delay_Min AS DECIMAL(10,2))
        ) AS DECIMAL(10,1)
    ) AS Avg_Transport_Delay_Minutes

FROM dbo.Clinical_Operations;
GO


/*==============================================================
19. Dashboard Filter Reference Values
Purpose:
Review all valid filter values used in Tableau.
==============================================================*/

SELECT DISTINCT
    Department
FROM dbo.ED_Visits
ORDER BY Department;
GO

SELECT DISTINCT
    ESI_Category_Label
FROM dbo.ED_Visits
ORDER BY ESI_Category_Label;
GO

SELECT DISTINCT
    DATENAME(MONTH, Visit_Date) AS Month_Name,
    MONTH(Visit_Date) AS Month_Number
FROM dbo.ED_Visits
ORDER BY Month_Number;
GO

SELECT DISTINCT
    DATEPART(HOUR, Arrival_Time) AS Arrival_Hour
FROM dbo.ED_Visits
WHERE Arrival_Time IS NOT NULL
ORDER BY Arrival_Hour;
GO


/*==============================================================
20. Dashboard 1 Analysis Complete
==============================================================*/

PRINT 'Dashboard 1 ED operations analysis queries completed successfully.';
GO