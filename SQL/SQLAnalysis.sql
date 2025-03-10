USE [Manufacturing Downtime] EXEC sp_changedbowner 'sa'

--Reading the tables to confirm Uploading of the cleaned and pre processed data by Python

select* from line_productivity
select* from downtime_factors
select* from line_downtime
select* from products

--Rephrasing some coulmns names  to be more clear and indicative.

EXEC SP_RENAME 'line_productivity.Efficiency', 'BatchOverallEfficiency', 'COLUMN';
EXEC SP_RENAME 'line_productivity.LinelaggingEfficiency', 'LinelaggingPercentage', 'COLUMN';
EXEC SP_RENAME 'line_productivity.LinelaggingPercentage', 'LineEfficiency', 'COLUMN';
EXEC SP_RENAME 'line_productivity.OpreatorlaggingEfficiency', 'OperatorlaggingPercentage', 'COLUMN';
EXEC SP_RENAME 'line_productivity.OperatorlaggingPercentage', 'OperatorEfficiency', 'COLUMN';
EXEC SP_RENAME 'line_productivity.TotalDowntimewithHumanErrors', 'TotalHumanErrorRelatedDowntime', 'COLUMN';
EXEC SP_RENAME 'line_productivity.TotalDowntimewithoutHumanErrors', 'TotalNonHumanErrorRelatedDowntime', 'COLUMN';

--checking the down times and efficiencies for differnt operators
SELECT 
    Operator,
	SUM(Duration) AS TotalBatchDuration,
    SUM(TotalDowntime) AS TotalDowntime,
    AVG(OperatorEfficiency) AS AvgOperatorEfficiency,
    SUM(TotalHumanErrorRelatedDowntime) AS HumanErrorRelatedDownTime,
    SUM(TotalNonHumanErrorRelatedDowntime) AS NonHumanErrorRelatedDowntime
FROM line_productivity
GROUP BY Operator

--checking the down times and efficiencies for differnt shifts

SELECT 
    Shift,
    SUM(TotalDowntime) AS TotalDowntime,
	Sum (TotalHumanErrorRelatedDowntime) AS TotalHumanErrorRelatedDowntime, 
	Sum (TotalNonHumanErrorRelatedDowntime) AS TotalNonHumanErrorRelatedDowntime,
	Avg (OperatorEfficiency) AS AverageOperatorEfficiency,
	Avg (LineEfficiency) AS AverageLineEfficiency,
	AVG (BatchOverallEfficiency)   AS AverageBatchOverallEfficiency
FROM line_productivity
GROUP BY Shift
order by TotalDowntime desc;

-- Ranking the batches for ech product based on total down time

SELECT 
    Product,
    Batch,
    TotalDowntime,
    RANK() OVER (PARTITION BY Product ORDER BY TotalDowntime DESC) AS DowntimeRank
FROM line_productivity;


--Copmaring the overall effecincyies for different operator for different batches to check for improvements
SELECT 
    Operator,
    Batch,
    BatchOverallEfficiency,
    LEAD(BatchOverallEfficiency, 1) OVER (PARTITION BY operator ORDER BY Batch) AS NextBatcOveralleffeciency
FROM line_productivity;

--checking the down times and efficiencies for differnt Products and different batches using rolling up quey to get sub totatals for different products

SELECT 
    Product, 
    Batch,
    SUM(TotalDowntime) AS TotalDowntime,
    SUM(TotalHumanErrorRelatedDowntime) AS TotalHumanErrorRelatedDowntime, 
    SUM(TotalNonHumanErrorRelatedDowntime) AS TotalNonHumanErrorRelatedDowntime,
    AVG(OperatorEfficiency) AS AverageOperatorEfficiency,
    AVG(LineEfficiency) AS AverageLineEfficiency,
    AVG(BatchOverallEfficiency) AS AverageBatchOverallEfficiency
FROM line_productivity
GROUP BY ROLLUP(Product, Batch)
ORDER BY Product DESC, Batch;


-- the foloowing code is targeting Spliting downtime factors and error types from comma-separated strings into individual rows.
-- Associates each downtime factor with its corresponding error type (Yes or No).
-- Calculates downtime based on whether the downtime is related to human errors or not, showing the correct downtime for each condition.
-- Presents a clear, structured output that shows:
--- The batch number (Batch).
--- The individual downtime factor (DowntimeFactor).
--- Whether the downtime is associated with human errors (HumanError).
--- The total downtime based on the presence of human errors (Total Downtime with Human or without Human)


WITH DowntimeDetails AS (
    SELECT 
        Batch,
        HumanErrors,
        DowntimeFactorsDescriptions,
        TotalDowntime, 
        TotalDowntimewithHumanErrors,
        TotalDowntimewithoutHumanErrors
    FROM 
        line_downtime
),
ParsedFactors AS (
    SELECT 
        Batch,
        HumanErrors,
        TotalDowntime,
        TotalDowntimewithHumanErrors,
        TotalDowntimewithoutHumanErrors,
        ROW_NUMBER() OVER (PARTITION BY Batch ORDER BY (SELECT NULL)) AS RowNum,
        TRIM(value) AS DowntimeFactor
    FROM DowntimeDetails
    CROSS APPLY STRING_SPLIT(DowntimeFactorsDescriptions, ',') 
),
ParsedErrors AS (
    SELECT 
        Batch,
        TRIM(value) AS ErrorType,
        ROW_NUMBER() OVER (PARTITION BY Batch ORDER BY (SELECT NULL)) AS RowNumError
    FROM DowntimeDetails
    CROSS APPLY STRING_SPLIT(HumanErrors, ',') 
)
SELECT 
    p.Batch,
    p.DowntimeFactor,
    CASE 
        WHEN pe.ErrorType = 'Yes' THEN 'Yes'
        ELSE 'No'
    END AS HumanError,
    CASE 
        WHEN pe.ErrorType = 'Yes' THEN p.TotalDowntimewithHumanErrors  
        WHEN pe.ErrorType = 'No' THEN p.TotalDowntimewithoutHumanErrors  
    END AS [Total Downtime with Human or without Human]
FROM ParsedFactors p
JOIN ParsedErrors pe 
    ON p.Batch = pe.Batch 
    AND p.RowNum = pe.RowNumError  
ORDER BY p.Batch, p.RowNum;
--