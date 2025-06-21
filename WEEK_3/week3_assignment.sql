-- Drop tables if they already exist
DROP TABLE IF EXISTS Projects;
DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Friends;
DROP TABLE IF EXISTS Packages;

-- =====================
-- Task 1: Projects Table
-- =====================
CREATE TABLE Projects (
    Task_ID INT,
    Start_Date DATE,
    End_Date DATE
);

INSERT INTO Projects (Task_ID, Start_Date, End_Date) VALUES
(1, '2015-10-01', '2015-10-02'),
(2, '2015-10-02', '2015-10-03'),
(3, '2015-10-03', '2015-10-04'),
(4, '2015-10-13', '2015-10-14'),
(5, '2015-10-14', '2015-10-15'),
(6, '2015-10-28', '2015-10-29'),
(7, '2015-10-30', '2015-10-31');

-- =====================
-- Task 2: Students, Friends, Packages Tables
-- =====================
CREATE TABLE Students (
    ID INT PRIMARY KEY,
    Name VARCHAR(100)
);

CREATE TABLE Friends (
    ID INT,
    Friend_ID INT
);

CREATE TABLE Packages (
    ID INT,
    Salary FLOAT
);

INSERT INTO Students (ID, Name) VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

INSERT INTO Friends (ID, Friend_ID) VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 1);

INSERT INTO Packages (ID, Salary) VALUES
(1, 15.20),
(2, 10.06),
(3, 11.55),
(4, 12.12);

-- =====================
-- Query for Task 1
-- =====================
-- Find start and end dates of projects
WITH ProjectsRanked AS (
    SELECT 
        Task_ID,
        Start_Date,
        End_Date,
        DATE_SUB(Start_Date, INTERVAL ROW_NUMBER() OVER (ORDER BY Start_Date) DAY) AS grp
    FROM Projects
),
GroupedProjects AS (
    SELECT 
        MIN(Start_Date) AS Project_Start,
        MAX(End_Date) AS Project_End,
        DATEDIFF(MAX(End_Date), MIN(Start_Date)) + 1 AS Duration
    FROM ProjectsRanked
    GROUP BY grp
)
SELECT 
    Project_Start,
    Project_End
FROM GroupedProjects
ORDER BY 
    Duration ASC,
    Project_Start ASC;

-- =====================
-- Query for Task 2
-- =====================
-- Find students whose best friend got a higher salary
SELECT 
    s.Name
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages p1 ON s.ID = p1.ID
JOIN Packages p2 ON f.Friend_ID = p2.ID
WHERE p2.Salary > p1.Salary
ORDER BY p2.Salary;

-- ============================================
-- TASK 3: Symmetric Pairs
-- ============================================

DROP TABLE IF EXISTS Functions;

CREATE TABLE Functions (
    x INT,
    y INT
);

INSERT INTO Functions VALUES
(20, 20),
(20, 20),
(20, 21),
(23, 22),
(22, 23),
(21, 20);

-- Symmetric pairs query
SELECT DISTINCT f1.x, f1.y
FROM Functions f1
JOIN Functions f2
  ON f1.x = f2.y AND f1.y = f2.x
WHERE f1.x <= f1.y
ORDER BY f1.x;


-- ============================================
-- TASK 4: Contest Aggregation
-- ============================================

DROP TABLE IF EXISTS Contests;
DROP TABLE IF EXISTS Colleges;
DROP TABLE IF EXISTS Challenges;
DROP TABLE IF EXISTS View_Stats;
DROP TABLE IF EXISTS Submission_Stats;

CREATE TABLE Contests (
    contest_id INT,
    hacker_id INT,
    name VARCHAR(100)
);

CREATE TABLE Colleges (
    college_id INT,
    contest_id INT
);

CREATE TABLE Challenges (
    challenge_id INT,
    college_id INT
);

CREATE TABLE View_Stats (
    challenge_id INT,
    total_views INT,
    total_unique_views INT
);

CREATE TABLE Submission_Stats (
    challenge_id INT,
    total_submissions INT,
    total_accepted_submissions INT
);

-- Insert sample data
INSERT INTO Contests VALUES
(66406, 17973, 'Rose'),
(66556, 79153, 'Angela'),
(94828, 80275, 'Frank');

INSERT INTO Colleges VALUES
(11219, 66406),
(32473, 66556),
(56685, 94828);

INSERT INTO Challenges VALUES
(47127, 11219),
(18765, 11219),
(60292, 32473),
(72974, 56685),
(75516, 32473);

INSERT INTO View_Stats VALUES
(47127, 26, 19),
(47127, 15, 14),
(18765, 43, 10),
(18765, 72, 13),
(75516, 35, 17),
(60292, 11, 10),
(72974, 41, 15),
(75516, 75, 11);

INSERT INTO Submission_Stats VALUES
(75516, 34, 12),
(47127, 27, 10),
(47127, 56, 18),
(75516, 74, 12),
(75516, 83, 8),
(72974, 68, 24),
(72974, 82, 14),
(47127, 28, 11);

-- Task 4 Query
SELECT 
    c.contest_id,
    c.hacker_id,
    c.name,
    COALESCE(SUM(ss.total_submissions), 0) AS total_submissions,
    COALESCE(SUM(ss.total_accepted_submissions), 0) AS total_accepted_submissions,
    COALESCE(SUM(vs.total_views), 0) AS total_views,
    COALESCE(SUM(vs.total_unique_views), 0) AS total_unique_views
FROM Contests c
JOIN Colleges col ON c.contest_id = col.contest_id
JOIN Challenges ch ON ch.college_id = col.college_id
LEFT JOIN View_Stats vs ON ch.challenge_id = vs.challenge_id
LEFT JOIN Submission_Stats ss ON ch.challenge_id = ss.challenge_id
GROUP BY c.contest_id, c.hacker_id, c.name
HAVING COALESCE(SUM(ss.total_submissions), 0) +
       COALESCE(SUM(ss.total_accepted_submissions), 0) +
       COALESCE(SUM(vs.total_views), 0) +
       COALESCE(SUM(vs.total_unique_views), 0) > 0
ORDER BY c.contest_id;


-- ============================================
-- TASK 5: Daily Unique Hackers & Top Submissions
-- ============================================

DROP TABLE IF EXISTS Hackers;
DROP TABLE IF EXISTS Submissions;

CREATE TABLE Hackers (
    hacker_id INT,
    name VARCHAR(100)
);

CREATE TABLE Submissions (
    submission_date DATE,
    submission_id INT,
    hacker_id INT,
    score INT
);

-- Sample Data
INSERT INTO Hackers VALUES
(15758, 'Rose'),
(20703, 'Angela'),
(36396, 'Frank'),
(38289, 'Patrick'),
(44065, 'Lisa'),
(53473, 'Kimberly'),
(62529, 'Bonnie'),
(79722, 'Michael');

INSERT INTO Submissions VALUES
('2016-03-01', 8494, 20703, 0),
('2016-03-01', 22403, 53473, 15),
('2016-03-01', 23965, 79722, 60),
('2016-03-01', 30173, 36396, 70),
('2016-03-02', 34928, 20703, 10),
('2016-03-02', 38740, 15758, 60),
('2016-03-02', 42769, 79722, 25),
('2016-03-02', 44364, 79722, 60),
('2016-03-03', 45440, 20703, 0),
('2016-03-03', 49050, 36396, 70),
('2016-03-03', 50273, 79722, 5),
('2016-03-04', 50344, 20703, 10),
('2016-03-04', 51360, 44065, 90),
('2016-03-04', 54404, 53473, 65),
('2016-03-04', 61533, 79722, 45),
('2016-03-05', 72852, 20703, 0),
('2016-03-05', 74546, 38289, 0),
('2016-03-05', 76487, 62529, 0),
('2016-03-05', 82439, 36396, 10),
('2016-03-05', 90006, 36396, 40),
('2016-03-06', 90404, 20703, 0);

-- Task 5 Query
SELECT
    s.submission_date,
    COUNT(DISTINCT s.hacker_id) AS total_hackers,
    hs.hacker_id,
    h.name
FROM Submissions s
JOIN (
    SELECT
        submission_date,
        hacker_id,
        COUNT(*) AS total_subs
    FROM Submissions
    GROUP BY submission_date, hacker_id
) AS daily_subs
ON s.submission_date = daily_subs.submission_date
JOIN (
    SELECT
        submission_date,
        hacker_id
    FROM (
        SELECT
            submission_date,
            hacker_id,
            COUNT(*) AS sub_count,
            RANK() OVER (PARTITION BY submission_date ORDER BY COUNT(*) DESC, hacker_id ASC) AS rnk
        FROM Submissions
        GROUP BY submission_date, hacker_id
    ) ranked
    WHERE rnk = 1
) hs
ON s.submission_date = hs.submission_date AND s.hacker_id = hs.hacker_id
JOIN Hackers h ON hs.hacker_id = h.hacker_id
GROUP BY s.submission_date, hs.hacker_id, h.name
ORDER BY s.submission_date;


-- ============================================
-- TASK 6: Manhattan Distance
-- ============================================

DROP TABLE IF EXISTS STATION;

CREATE TABLE STATION (
    ID INT,
    CITY VARCHAR(21),
    STATE VARCHAR(2),
    LAT_N FLOAT,
    LONG_W FLOAT
);

-- Example Data (add more as needed)
INSERT INTO STATION VALUES (1, 'Delhi', 'DL', 18.5, 70.6);
INSERT INTO STATION VALUES (2, 'Mumbai', 'MH', 10.2, 70.6);
INSERT INTO STATION VALUES (3, 'Chennai', 'TN', 18.5, 60.2);
INSERT INTO STATION VALUES (4, 'Kolkata', 'WB', 15.5, 60.2);

-- Manhattan Distance
SELECT
    ROUND(
        ABS(MAX(LAT_N) - MIN(LAT_N)) +
        ABS(MAX(LONG_W) - MIN(LONG_W)),
        4
    ) AS Manhattan_Distance
FROM STATION;

-- TASK 7: Generate prime numbers <= 1000 in a single line separated by '&'

WITH RECURSIVE numbers AS (
    SELECT 2 AS n
    UNION ALL
    SELECT n + 1 FROM numbers WHERE n < 1000
),
primes AS (
    SELECT n FROM numbers
    WHERE NOT EXISTS (
        SELECT 1 FROM numbers AS divs
        WHERE divs.n < numbers.n AND numbers.n % divs.n = 0 AND divs.n > 1
    )
)
SELECT GROUP_CONCAT(n SEPARATOR '&') AS prime_list
FROM primes;

-- TASK 8: Pivot names under each occupation

DROP TABLE IF EXISTS OCCUPATIONS;

CREATE TABLE OCCUPATIONS (
    Name VARCHAR(100),
    Occupation VARCHAR(20)
);

INSERT INTO OCCUPATIONS VALUES
('Samantha', 'Doctor'),
('Julia', 'Actor'),
('Maria', 'Actor'),
('Meera', 'Singer'),
('Ashely', 'Professor'),
('Ketty', 'Professor'),
('Christeen', 'Professor'),
('Jane', 'Actor'),
('Jenny', 'Doctor'),
('Priya', 'Singer');

-- Pivot query
SELECT
    MAX(CASE WHEN Occupation = 'Doctor' THEN Name END) AS Doctor,
    MAX(CASE WHEN Occupation = 'Professor' THEN Name END) AS Professor,
    MAX(CASE WHEN Occupation = 'Singer' THEN Name END) AS Singer,
    MAX(CASE WHEN Occupation = 'Actor' THEN Name END) AS Actor
FROM (
    SELECT Name, Occupation,
           ROW_NUMBER() OVER (PARTITION BY Occupation ORDER BY Name) AS rn
    FROM OCCUPATIONS
) AS sub
GROUP BY rn;

-- TASK 9: Classify nodes as Root, Leaf, or Inner

DROP TABLE IF EXISTS BST;

CREATE TABLE BST (
    N INT,
    P INT
);

INSERT INTO BST VALUES
(1, 2),
(3, 2),
(6, 8),
(9, 8),
(2, 3),
(8, 5),
(5, NULL);

-- Query to classify node type
SELECT
    N,
    CASE
        WHEN P IS NULL THEN 'Root'
        WHEN N NOT IN (SELECT DISTINCT P FROM BST WHERE P IS NOT NULL) THEN 'Leaf'
        ELSE 'Inner'
    END AS Node_Type
FROM BST
ORDER BY N;

-- TASK 10: Count hierarchy levels per company

DROP TABLE IF EXISTS Company;
DROP TABLE IF EXISTS Lead_Manager;
DROP TABLE IF EXISTS Senior_Manager;
DROP TABLE IF EXISTS Manager;
DROP TABLE IF EXISTS Employee;

CREATE TABLE Company (
    company_code VARCHAR(10),
    founder VARCHAR(100)
);

CREATE TABLE Lead_Manager (
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

CREATE TABLE Senior_Manager (
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

CREATE TABLE Manager (
    manager_code VARCHAR(10),
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

CREATE TABLE Employee (
    employee_code VARCHAR(10),
    manager_code VARCHAR(10),
    senior_manager_code VARCHAR(10),
    lead_manager_code VARCHAR(10),
    company_code VARCHAR(10)
);

-- Sample data
INSERT INTO Company VALUES
('C1', 'Monika'),
('C2', 'Samantha');

INSERT INTO Lead_Manager VALUES
('LM1', 'C1'),
('LM2', 'C2');

INSERT INTO Senior_Manager VALUES
('SM1', 'LM1', 'C1'),
('SM2', 'LM1', 'C1'),
('SM3', 'LM2', 'C2');

INSERT INTO Manager VALUES
('M1', 'SM1', 'LM1', 'C1'),
('M2', 'SM3', 'LM2', 'C2'),
('M3', 'SM3', 'LM2', 'C2');

INSERT INTO Employee VALUES
('E1', 'M1', 'SM1', 'LM1', 'C1'),
('E2', 'M1', 'SM1', 'LM1', 'C1'),
('E3', 'M2', 'SM3', 'LM2', 'C2'),
('E4', 'M3', 'SM3', 'LM2', 'C2');

-- Final output
SELECT
    c.company_code,
    c.founder,
    COUNT(DISTINCT lm.lead_manager_code) AS lead_manager_count,
    COUNT(DISTINCT sm.senior_manager_code) AS senior_manager_count,
    COUNT(DISTINCT m.manager_code) AS manager_count,
    COUNT(DISTINCT e.employee_code) AS employee_count
FROM Company c
LEFT JOIN Lead_Manager lm ON c.company_code = lm.company_code
LEFT JOIN Senior_Manager sm ON c.company_code = sm.company_code
LEFT JOIN Manager m ON c.company_code = m.company_code
LEFT JOIN Employee e ON c.company_code = e.company_code
GROUP BY c.company_code, c.founder
ORDER BY c.company_code;

-- TASK 11: Students whose best friends have better salaries

DROP TABLE IF EXISTS Students;
DROP TABLE IF EXISTS Friends;
DROP TABLE IF EXISTS Packages;

CREATE TABLE Students (
    ID INT,
    Name VARCHAR(100)
);

CREATE TABLE Friends (
    ID INT,
    Friend_ID INT
);

CREATE TABLE Packages (
    ID INT,
    Salary FLOAT
);

-- Sample Data
INSERT INTO Students VALUES
(1, 'Ashley'),
(2, 'Samantha'),
(3, 'Julia'),
(4, 'Scarlet');

INSERT INTO Friends VALUES
(1, 2),
(2, 3),
(3, 4),
(4, 7);

INSERT INTO Packages VALUES
(1, 7.25),
(2, 10.06),
(3, 11.55),
(4, 12.12),
(7, 15.20);

-- Final Query
SELECT s.Name
FROM Students s
JOIN Friends f ON s.ID = f.ID
JOIN Packages p1 ON s.ID = p1.ID
JOIN Packages p2 ON f.Friend_ID = p2.ID
WHERE p2.Salary > p1.Salary
ORDER BY p2.Salary;

-- Task 15: Top 5 salaries without using ORDER BY (using DENSE_RANK instead)

DROP TABLE IF EXISTS Employees;

CREATE TABLE Employees (
    emp_id INT,
    emp_name VARCHAR(100),
    salary INT
);

INSERT INTO Employees VALUES
(1, 'Alice', 8000),
(2, 'Bob', 9500),
(3, 'Charlie', 12000),
(4, 'David', 11000),
(5, 'Eva', 7000),
(6, 'Frank', 9800),
(7, 'Grace', 13000);

-- Using a subquery with RANK or DENSE_RANK to avoid ORDER BY in outer query
SELECT emp_id, emp_name, salary
FROM (
    SELECT *, DENSE_RANK() OVER (PARTITION BY 1 ORDER BY salary DESC) AS rnk
    FROM Employees
) AS ranked
WHERE rnk <= 5;

-- Task 16: Swap two columns (e.g., A and B) in a table without a third variable

DROP TABLE IF EXISTS SwapTest;

CREATE TABLE SwapTest (
    id INT,
    A INT,
    B INT
);

INSERT INTO SwapTest VALUES
(1, 10, 20),
(2, 30, 40);

-- Swap A and B without third variable
UPDATE SwapTest
SET A = A + B,
    B = A - B,
    A = A - B;

-- View the result
SELECT * FROM SwapTest;

-- Task 17: Create a login, user, and assign db_owner role (SQL Server)

-- Create login at the server level
CREATE LOGIN user_samantha WITH PASSWORD = 'StrongPassword123';

-- Create user for the current database
CREATE USER user_samantha FOR LOGIN user_samantha;

-- Grant db_owner permissions
EXEC sp_addrolemember 'db_owner', 'user_samantha';

-- Task 18: Weighted Average Cost per BU per Month

DROP TABLE IF EXISTS Employee_Costs;

CREATE TABLE Employee_Costs (
    emp_id INT,
    bu VARCHAR(10),
    month_year DATE,
    cost DECIMAL(10,2),
    headcount INT
);

INSERT INTO Employee_Costs VALUES
(1, 'BU1', '2024-01-01', 10000, 1),
(2, 'BU1', '2024-01-01', 20000, 1),
(3, 'BU2', '2024-01-01', 15000, 1),
(4, 'BU1', '2024-02-01', 12000, 1),
(5, 'BU1', '2024-02-01', 18000, 1);

-- Weighted Avg = SUM(Cost * Headcount) / SUM(Headcount)
SELECT
    bu,
    MONTH(month_year) AS month,
    YEAR(month_year) AS year,
    ROUND(SUM(cost * headcount) / SUM(headcount), 2) AS weighted_avg_cost
FROM Employee_Costs
GROUP BY bu, month_year;

-- Task 19: Find error in average caused by removing 0s from salary

DROP TABLE IF EXISTS EMPLOYEES;

CREATE TABLE EMPLOYEES (
    emp_id INT,
    salary INT
);

INSERT INTO EMPLOYEES VALUES
(1, 10000),
(2, 24000),
(3, 30050),
(4, 70000);

-- Actual Average
WITH actual AS (
    SELECT AVG(salary) AS actual_avg FROM EMPLOYEES
),
-- Miscalculated Average: removing '0' from salary before converting to int
miscalculated AS (
    SELECT AVG(CAST(REPLACE(salary, '0', '') AS UNSIGNED)) AS wrong_avg FROM EMPLOYEES
)
SELECT CEIL(actual.actual_avg - miscalculated.wrong_avg) AS error
FROM actual, miscalculated;

-- Task 20: Copy only new records from one table to another (no indicator)

DROP TABLE IF EXISTS SourceTable;
DROP TABLE IF EXISTS TargetTable;

CREATE TABLE SourceTable (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE TargetTable (
    id INT PRIMARY KEY,
    name VARCHAR(100)
);

-- Initial Data
INSERT INTO SourceTable VALUES (1, 'Alice'), (2, 'Bob'), (3, 'Charlie');
INSERT INTO TargetTable VALUES (1, 'Alice');

-- Copy new records based on primary key NOT EXISTS
INSERT INTO TargetTable (id, name)
SELECT s.id, s.name
FROM SourceTable s
LEFT JOIN TargetTable t ON s.id = t.id
WHERE t.id IS NULL;

-- View result
SELECT * FROM TargetTable;
