/*
==============================================================
Project: Palmetto Regional Health System
Case Study: 1 – Emergency Care & Patient Experience
Dashboard: 2 – Patient Experience

File: 04_dashboard_2_patient_experience_queries.sql

Purpose:
Calculate the patient-experience KPIs and supporting analyses
used in the Patient Experience Tableau dashboard.

Database: PalmettoRegionalHealthSystemDW
Author: La'Princia Mance
==============================================================
*/

USE PalmettoRegionalHealthSystemDW;
GO


/*==============================================================
1. Total Patient Satisfaction Survey Responses

Business Question:
How many patient-experience surveys were completed?
==============================================================*/

SELECT
    COUNT(*) AS Total_Survey_Responses
FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
2. Unique Surveyed Visits

Business Question:
How many individual ED visits received a completed
patient-experience survey?
==============================================================*/

SELECT
    COUNT(DISTINCT Visit_ID) AS Unique_Surveyed_Visits
FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
3. Survey Response Rate

Business Question:
What percentage of survey-eligible ED visits generated a
completed patient-satisfaction survey?

Note:
Eligible_For_Survey is stored as a bit field:
1 = eligible
0 = not eligible
==============================================================*/

SELECT
    COUNT(DISTINCT ps.Visit_ID) AS Surveyed_Visits,

    COUNT(
        DISTINCT CASE
            WHEN ed.Eligible_For_Survey = 1
                THEN ed.Visit_ID
        END
    ) AS Eligible_ED_Visits,

    CAST(
        COUNT(DISTINCT ps.Visit_ID) * 100.0
        /
        NULLIF(
            COUNT(
                DISTINCT CASE
                    WHEN ed.Eligible_For_Survey = 1
                        THEN ed.Visit_ID
                END
            ),
            0
        )
        AS DECIMAL(6,2)
    ) AS Survey_Response_Rate_Percent

FROM dbo.ED_Visits AS ed

LEFT JOIN dbo.Patient_Satisfaction AS ps
    ON ed.Visit_ID = ps.Visit_ID;
GO


/*==============================================================
4. Average Overall Survey Score

Business Question:
What was the average overall patient survey score?
==============================================================*/

SELECT
    CAST(
        AVG(
            CAST(Survey_Score AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Survey_Score

FROM dbo.Patient_Satisfaction

WHERE Survey_Score IS NOT NULL;
GO


/*==============================================================
5. Overall Favorable Satisfaction Rate

Definition:
Survey scores of 4 or 5 are considered favorable.

Business Question:
What percentage of respondents reported a favorable overall
patient experience?
==============================================================*/

SELECT
    SUM(
        CASE
            WHEN Survey_Score >= 4 THEN 1
            ELSE 0
        END
    ) AS Favorable_Responses,

    COUNT(Survey_Score) AS Rated_Responses,

    CAST(
        SUM(
            CASE
                WHEN Survey_Score >= 4 THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(COUNT(Survey_Score), 0)
        AS DECIMAL(6,2)
    ) AS Overall_Favorable_Rate_Percent

FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
6. Would Recommend Rate

Business Question:
What percentage of surveyed patients indicated that they
would recommend the organization?
==============================================================*/

SELECT
    SUM(
        CASE
            WHEN UPPER(LTRIM(RTRIM(Would_Recommend)))
                 IN ('YES', 'Y', 'TRUE', '1')
                THEN 1
            ELSE 0
        END
    ) AS Would_Recommend_Responses,

    COUNT(Would_Recommend) AS Total_Recommendation_Responses,

    CAST(
        SUM(
            CASE
                WHEN UPPER(LTRIM(RTRIM(Would_Recommend)))
                     IN ('YES', 'Y', 'TRUE', '1')
                    THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(COUNT(Would_Recommend), 0)
        AS DECIMAL(6,2)
    ) AS Would_Recommend_Rate_Percent

FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
7. Average Staff Courtesy Rating

Business Question:
How did patients rate the courtesy and respect demonstrated
by staff?
==============================================================*/

SELECT
    CAST(
        AVG(
            CAST(Staff_Courtesy AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Staff_Courtesy_Rating

FROM dbo.Patient_Satisfaction

WHERE Staff_Courtesy IS NOT NULL;
GO


/*==============================================================
8. Staff Courtesy Favorable Rate

Definition:
Ratings of 4 or 5 are considered favorable.
==============================================================*/

SELECT
    SUM(
        CASE
            WHEN Staff_Courtesy >= 4 THEN 1
            ELSE 0
        END
    ) AS Favorable_Staff_Courtesy_Responses,

    COUNT(Staff_Courtesy) AS Rated_Responses,

    CAST(
        SUM(
            CASE
                WHEN Staff_Courtesy >= 4 THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(COUNT(Staff_Courtesy), 0)
        AS DECIMAL(6,2)
    ) AS Staff_Courtesy_Favorable_Rate_Percent

FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
9. Average Communication Rating

Business Question:
How did patients rate communication from clinical and
operational staff?
==============================================================*/

SELECT
    CAST(
        AVG(
            CAST(Communication AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Communication_Rating

FROM dbo.Patient_Satisfaction

WHERE Communication IS NOT NULL;
GO


/*==============================================================
10. Communication Favorable Rate

Definition:
Ratings of 4 or 5 are considered favorable.
==============================================================*/

SELECT
    SUM(
        CASE
            WHEN Communication >= 4 THEN 1
            ELSE 0
        END
    ) AS Favorable_Communication_Responses,

    COUNT(Communication) AS Rated_Responses,

    CAST(
        SUM(
            CASE
                WHEN Communication >= 4 THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(COUNT(Communication), 0)
        AS DECIMAL(6,2)
    ) AS Communication_Favorable_Rate_Percent

FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
11. Average Wait-Time Rating

Business Question:
How did patients rate their experience with ED wait times?
==============================================================*/

SELECT
    CAST(
        AVG(
            CAST(Wait_Time_Rating AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Wait_Time_Rating

FROM dbo.Patient_Satisfaction

WHERE Wait_Time_Rating IS NOT NULL;
GO


/*==============================================================
12. Wait-Time Favorable Rate

Definition:
Ratings of 4 or 5 are considered favorable.
==============================================================*/

SELECT
    SUM(
        CASE
            WHEN Wait_Time_Rating >= 4 THEN 1
            ELSE 0
        END
    ) AS Favorable_Wait_Time_Responses,

    COUNT(Wait_Time_Rating) AS Rated_Responses,

    CAST(
        SUM(
            CASE
                WHEN Wait_Time_Rating >= 4 THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(COUNT(Wait_Time_Rating), 0)
        AS DECIMAL(6,2)
    ) AS Wait_Time_Favorable_Rate_Percent

FROM dbo.Patient_Satisfaction;
GO


/*==============================================================
13. Composite Patient Experience Score

Definition:
Average of Staff Courtesy, Communication, and Wait-Time
ratings for each completed survey.

Business Question:
What was the overall average patient-experience score across
the three component measures?
==============================================================*/

WITH Patient_Experience AS
(
    SELECT
        Visit_ID,

        (
            CAST(Staff_Courtesy AS DECIMAL(10,2))
            + CAST(Communication AS DECIMAL(10,2))
            + CAST(Wait_Time_Rating AS DECIMAL(10,2))
        ) / 3.0 AS Composite_Experience_Score

    FROM dbo.Patient_Satisfaction

    WHERE Staff_Courtesy IS NOT NULL
      AND Communication IS NOT NULL
      AND Wait_Time_Rating IS NOT NULL
)

SELECT
    CAST(
        AVG(Composite_Experience_Score)
        AS DECIMAL(10,2)
    ) AS Average_Composite_Experience_Score

FROM Patient_Experience;
GO


/*==============================================================
14. Survey Score Distribution

Business Question:
How were overall survey ratings distributed?
==============================================================*/

SELECT
    Survey_Score,

    COUNT(*) AS Total_Responses,

    CAST(
        COUNT(*) * 100.0
        /
        NULLIF(
            (
                SELECT COUNT(*)
                FROM dbo.Patient_Satisfaction
                WHERE Survey_Score IS NOT NULL
            ),
            0
        )
        AS DECIMAL(6,2)
    ) AS Percent_Of_Responses

FROM dbo.Patient_Satisfaction

WHERE Survey_Score IS NOT NULL

GROUP BY Survey_Score

ORDER BY Survey_Score;
GO


/*==============================================================
15. Would Recommend Distribution
==============================================================*/

SELECT
    CASE
        WHEN UPPER(LTRIM(RTRIM(Would_Recommend)))
             IN ('YES', 'Y', 'TRUE', '1')
            THEN 'Yes'

        WHEN UPPER(LTRIM(RTRIM(Would_Recommend)))
             IN ('NO', 'N', 'FALSE', '0')
            THEN 'No'

        ELSE 'Other / Unknown'
    END AS Recommendation_Response,

    COUNT(*) AS Total_Responses

FROM dbo.Patient_Satisfaction

GROUP BY
    CASE
        WHEN UPPER(LTRIM(RTRIM(Would_Recommend)))
             IN ('YES', 'Y', 'TRUE', '1')
            THEN 'Yes'

        WHEN UPPER(LTRIM(RTRIM(Would_Recommend)))
             IN ('NO', 'N', 'FALSE', '0')
            THEN 'No'

        ELSE 'Other / Unknown'
    END

ORDER BY Total_Responses DESC;
GO


/*==============================================================
16. Monthly Patient Experience Trend

Business Question:
How did patient-experience performance change throughout
the year?
==============================================================*/

SELECT
    YEAR(ed.Visit_Date) AS Visit_Year,

    MONTH(ed.Visit_Date) AS Month_Number,

    DATENAME(MONTH, ed.Visit_Date) AS Month_Name,

    COUNT(*) AS Survey_Responses,

    CAST(
        AVG(
            CAST(ps.Survey_Score AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Survey_Score,

    CAST(
        SUM(
            CASE
                WHEN ps.Survey_Score >= 4 THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(COUNT(ps.Survey_Score), 0)
        AS DECIMAL(6,2)
    ) AS Favorable_Satisfaction_Rate_Percent,

    CAST(
        SUM(
            CASE
                WHEN UPPER(LTRIM(RTRIM(ps.Would_Recommend)))
                     IN ('YES', 'Y', 'TRUE', '1')
                    THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(COUNT(ps.Would_Recommend), 0)
        AS DECIMAL(6,2)
    ) AS Would_Recommend_Rate_Percent

FROM dbo.Patient_Satisfaction AS ps

INNER JOIN dbo.ED_Visits AS ed
    ON ps.Visit_ID = ed.Visit_ID

WHERE ed.Visit_Date IS NOT NULL

GROUP BY
    YEAR(ed.Visit_Date),
    MONTH(ed.Visit_Date),
    DATENAME(MONTH, ed.Visit_Date)

ORDER BY
    Visit_Year,
    Month_Number;
GO


/*==============================================================
17. Patient Experience by Department

Business Question:
Which departments received the strongest and weakest
patient-experience ratings?
==============================================================*/

SELECT
    d.Department_Name AS Department,

    COUNT(*) AS Survey_Responses,

    CAST(
        AVG(
            CAST(ps.Survey_Score AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Survey_Score,

    CAST(
        AVG(
            CAST(ps.Staff_Courtesy AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Staff_Courtesy,

    CAST(
        AVG(
            CAST(ps.Communication AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Communication,

    CAST(
        AVG(
            CAST(ps.Wait_Time_Rating AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Wait_Time_Rating,

    CAST(
        SUM(
            CASE
                WHEN UPPER(LTRIM(RTRIM(ps.Would_Recommend)))
                     IN ('YES', 'Y', 'TRUE', '1')
                    THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(COUNT(ps.Would_Recommend), 0)
        AS DECIMAL(6,2)
    ) AS Would_Recommend_Rate_Percent

FROM dbo.Patient_Satisfaction AS ps

INNER JOIN dbo.ED_Visits AS ed
    ON ps.Visit_ID = ed.Visit_ID

INNER JOIN dbo.Departments AS d
    ON ed.Department_ID = d.Department_ID

GROUP BY d.Department_Name

ORDER BY Average_Survey_Score DESC;
GO


/*==============================================================
18. Patient Experience by Emergency Severity Level

Business Question:
How did patient experience vary by clinical acuity?
==============================================================*/

SELECT
    ed.ESI_Category_Label,

    COUNT(*) AS Survey_Responses,

    CAST(
        AVG(
            CAST(ps.Survey_Score AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Survey_Score,

    CAST(
        SUM(
            CASE
                WHEN ps.Survey_Score >= 4 THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(COUNT(ps.Survey_Score), 0)
        AS DECIMAL(6,2)
    ) AS Favorable_Satisfaction_Rate_Percent

FROM dbo.Patient_Satisfaction AS ps

INNER JOIN dbo.ED_Visits AS ed
    ON ps.Visit_ID = ed.Visit_ID

GROUP BY ed.ESI_Category_Label

ORDER BY
    CASE ed.ESI_Category_Label
        WHEN 'Resuscitation' THEN 1
        WHEN 'Emergent' THEN 2
        WHEN 'Urgent' THEN 3
        WHEN 'Less Urgent' THEN 4
        WHEN 'Non-Urgent' THEN 5
        ELSE 6
    END;
GO


/*==============================================================
19. Patient Experience by Arrival Period

Business Question:
Did patient experience vary based on the time of day that
patients arrived?
==============================================================*/

SELECT
    CASE
        WHEN DATEPART(HOUR, ed.Arrival_Time) BETWEEN 5 AND 11
            THEN 'Morning'

        WHEN DATEPART(HOUR, ed.Arrival_Time) BETWEEN 12 AND 16
            THEN 'Afternoon'

        WHEN DATEPART(HOUR, ed.Arrival_Time) BETWEEN 17 AND 20
            THEN 'Evening'

        ELSE 'Overnight'
    END AS Arrival_Period,

    COUNT(*) AS Survey_Responses,

    CAST(
        AVG(
            CAST(ps.Survey_Score AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Survey_Score,

    CAST(
        SUM(
            CASE
                WHEN ps.Survey_Score >= 4 THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(COUNT(ps.Survey_Score), 0)
        AS DECIMAL(6,2)
    ) AS Favorable_Satisfaction_Rate_Percent

FROM dbo.Patient_Satisfaction AS ps

INNER JOIN dbo.ED_Visits AS ed
    ON ps.Visit_ID = ed.Visit_ID

GROUP BY
    CASE
        WHEN DATEPART(HOUR, ed.Arrival_Time) BETWEEN 5 AND 11
            THEN 'Morning'

        WHEN DATEPART(HOUR, ed.Arrival_Time) BETWEEN 12 AND 16
            THEN 'Afternoon'

        WHEN DATEPART(HOUR, ed.Arrival_Time) BETWEEN 17 AND 20
            THEN 'Evening'

        ELSE 'Overnight'
    END

ORDER BY
    CASE
        WHEN
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
            END = 'Morning'
            THEN 1

        WHEN
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
            END = 'Afternoon'
            THEN 2

        WHEN
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
            END = 'Evening'
            THEN 3

        ELSE 4
    END;
GO


/*==============================================================
20. Patient Experience by Disposition

Business Question:
How did patient-experience performance vary by final ED
disposition?
==============================================================*/

SELECT
    ed.Disposition,

    COUNT(*) AS Survey_Responses,

    CAST(
        AVG(
            CAST(ps.Survey_Score AS DECIMAL(10,2))
        )
        AS DECIMAL(10,2)
    ) AS Average_Survey_Score,

    CAST(
        SUM(
            CASE
                WHEN UPPER(LTRIM(RTRIM(ps.Would_Recommend)))
                     IN ('YES', 'Y', 'TRUE', '1')
                    THEN 1
                ELSE 0
            END
        ) * 100.0
        /
        NULLIF(COUNT(ps.Would_Recommend), 0)
        AS DECIMAL(6,2)
    ) AS Would_Recommend_Rate_Percent

FROM dbo.Patient_Satisfaction AS ps

INNER JOIN dbo.ED_Visits AS ed
    ON ps.Visit_ID = ed.Visit_ID

GROUP BY ed.Disposition

ORDER BY Survey_Responses DESC;
GO


/*==============================================================
21. Patient Experience Analysis Complete
==============================================================*/

PRINT 'Dashboard 2 patient experience analysis queries completed successfully.';
GO