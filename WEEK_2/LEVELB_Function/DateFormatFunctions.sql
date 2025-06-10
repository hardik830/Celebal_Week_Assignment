
-- ========================================
--  Function 1: Format to MM/DD/YYYY
-- ========================================
CREATE FUNCTION dbo.FormatDate_MMDDYYYY (@InputDate DATETIME)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN RIGHT('0' + CAST(MONTH(@InputDate) AS VARCHAR), 2) + '/' +
           RIGHT('0' + CAST(DAY(@InputDate) AS VARCHAR), 2) + '/' +
           CAST(YEAR(@InputDate) AS VARCHAR);
END;
GO

-- ========================================
--  Function 2: Format to YYYYMMDD
-- ========================================
CREATE FUNCTION dbo.FormatDate_YYYYMMDD (@InputDate DATETIME)
RETURNS VARCHAR(8)
AS
BEGIN
    RETURN CAST(YEAR(@InputDate) AS VARCHAR) +
           RIGHT('0' + CAST(MONTH(@InputDate) AS VARCHAR), 2) +
           RIGHT('0' + CAST(DAY(@InputDate) AS VARCHAR), 2);
END;
GO
