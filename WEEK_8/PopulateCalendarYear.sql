
-- Create the CalendarDimension table
CREATE TABLE dbo.CalendarDimension (
  DateKey INT PRIMARY KEY,
  CalendarDate DATE NOT NULL,
  CalendarDay TINYINT, 
  CalendarMonth TINYINT, 
  CalendarQuarter TINYINT, 
  CalendarYear INT,
  DayNameLong VARCHAR(20), 
  DayNameShort CHAR(3),
  DayNumberOfWeek TINYINT, 
  DayNumberOfYear SMALLINT, 
  DaySuffix VARCHAR(2),
  FiscalWeek SMALLINT, 
  FiscalPeriod TINYINT, 
  FiscalQuarter TINYINT, 
  FiscalYear INT,
  FiscalYearPeriod VARCHAR(10)
);
GO

-- Stored procedure to populate the CalendarDimension table for a full year
CREATE OR ALTER PROC dbo.PopulateCalendarYear
  @InputDate       DATE
AS
BEGIN
  SET NOCOUNT ON;
  SET DATEFIRST 1;  -- Monday as the first day of the week

  DECLARE @YearStart DATE = DATEFROMPARTS(YEAR(@InputDate), 1, 1);
  DECLARE @YearEnd   DATE = DATEFROMPARTS(YEAR(@InputDate), 12, 31);

  WITH DateSeq AS (
    SELECT DATEADD(DAY, v.number, @YearStart) AS CalendarDate
    FROM master..spt_values AS v
    WHERE v.type = 'P'
      AND v.number BETWEEN 0 AND DATEDIFF(DAY, @YearStart, @YearEnd)
  )
  INSERT INTO dbo.CalendarDimension (
    DateKey, CalendarDate,
    CalendarDay, CalendarMonth, CalendarQuarter, CalendarYear,
    DayNameLong, DayNameShort,
    DayNumberOfWeek, DayNumberOfYear, DaySuffix,
    FiscalWeek, FiscalPeriod, FiscalQuarter, FiscalYear, FiscalYearPeriod
  )
  SELECT
    CAST(CONVERT(CHAR(8), CalendarDate, 112) AS INT) AS DateKey,
    CalendarDate,
    DAY(CalendarDate),
    MONTH(CalendarDate),
    DATEPART(QUARTER, CalendarDate),
    YEAR(CalendarDate),
    DATENAME(WEEKDAY, CalendarDate),
    LEFT(DATENAME(WEEKDAY, CalendarDate), 3),
    DATEPART(WEEKDAY, CalendarDate),
    DATEPART(DAYOFYEAR, CalendarDate),
    CASE
      WHEN DAY(CalendarDate) IN (1, 21, 31) THEN 'st'
      WHEN DAY(CalendarDate) IN (2, 22) THEN 'nd'
      WHEN DAY(CalendarDate) IN (3, 23) THEN 'rd'
      ELSE 'th'
    END,
    DATEPART(ISO_WEEK, CalendarDate),
    MONTH(CalendarDate),
    DATEPART(QUARTER, CalendarDate),
    YEAR(CalendarDate),
    CONCAT(YEAR(CalendarDate), RIGHT('0' + CAST(MONTH(CalendarDate) AS VARCHAR(2)), 2))
  FROM DateSeq
  OPTION (MAXRECURSION 0);
END;
GO
