
-- ============================================================
-- CARELOOP CLINICS - NO-SHOW GUARD
-- PART 2: SQL DATA ANALYSIS
-- Database: MySQL (XAMPP / phpMyAdmin)
-- ============================================================

-- PROJECT OBJECTIVE:
-- Analyze outpatient appointment no-shows across 8 clinics
-- using 990 cleaned appointment records.
--
-- Topics covered:
-- 1. Database creation and validation
-- 2. Clinic-level no-show analysis
-- 3. Booking lead-time analysis
-- 4. Monthly no-show trends
-- 5. City-wise clinic rankings
-- ============================================================


-- ============================================================
-- PART 2.1: DATABASE AND TABLE CREATION
-- ============================================================

-- Create the project database if it does not exist.
CREATE DATABASE IF NOT EXISTS noshowguard;

-- Select the database.
USE noshowguard;


-- Create the clinics table.
-- clinic_id is the PRIMARY KEY, ensuring unique clinic IDs.

CREATE TABLE IF NOT EXISTS clinics (
    clinic_id VARCHAR(10) PRIMARY KEY,
    clinic_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    tier VARCHAR(20),
    latitude DECIMAL(9,6),
    longitude DECIMAL(9,6)
);


-- Create the appointments table.
-- appointment_id is the PRIMARY KEY.
-- clinic_id is a FOREIGN KEY referencing clinics.

CREATE TABLE IF NOT EXISTS appointments (
    appointment_id VARCHAR(10) PRIMARY KEY,
    patient_id VARCHAR(10) NOT NULL,
    clinic_id VARCHAR(10) NOT NULL,
    booked_on DATE NOT NULL,
    appt_date DATE NOT NULL,
    age INT,
    gender VARCHAR(20),
    distance_km DECIMAL(6,1),
    fee_inr INT,
    booking_channel VARCHAR(20),
    visit_type VARCHAR(30),
    reminder_sent VARCHAR(10),
    prior_no_shows INT,
    status VARCHAR(20) NOT NULL,
    lead_days INT,
    no_show TINYINT,

    CONSTRAINT fk_appointment_clinic
        FOREIGN KEY (clinic_id)
        REFERENCES clinics(clinic_id)
);


-- DATA LOADING:
-- Execute load_data.sql after creating the tables.
-- The file contains 998 INSERT statements:
-- 8 clinic records and 990 appointment records.
--
-- Do not import load_data.sql twice because the
-- primary key constraints prevent duplicate IDs.


-- ------------------------------------------------------------
-- VERIFY IMPORTED DATA
-- ------------------------------------------------------------

-- Expected result: 8 clinics.
SELECT COUNT(*) AS total_clinics
FROM clinics;


-- Expected result: 990 appointments.
SELECT COUNT(*) AS total_appointments
FROM appointments;


-- Expected result: 218 missed appointments.
SELECT COUNT(*) AS total_no_shows
FROM appointments
WHERE no_show = 1;


-- ------------------------------------------------------------
-- PRIMARY KEY VALIDATION
-- ------------------------------------------------------------

-- The following test was executed separately in phpMyAdmin.
-- It attempts to insert an existing appointment ID.
--
-- INSERT INTO appointments
-- (appointment_id, patient_id, clinic_id,
--  booked_on, appt_date, status)
-- VALUES
-- ('A0001', 'TEST001', 'C01',
--  '2026-01-01', '2026-01-02', 'Attended');
--
-- EXPECTED RESULT:
-- Error 1062: Duplicate entry 'A0001' for key 'PRIMARY'.
--
-- CONCLUSION:
-- The primary key constraint successfully prevents
-- duplicate appointment IDs.


-- ============================================================
-- PART 2.2: CLINIC-LEVEL NO-SHOW ANALYSIS
-- ============================================================

-- OBJECTIVE:
-- Compare appointment volumes and no-show rates by clinic.
--
-- INNER JOIN combines appointment and clinic information.
-- GROUP BY aggregates records for each clinic.
-- HAVING filters clinics based on appointment volume.


-- QUERY 1: No-show rates for all 8 clinics.

SELECT
    c.clinic_name,
    c.city,
    COUNT(*) AS total_appointments,
    SUM(a.no_show) AS missed_appointments,
    ROUND(100.0 * AVG(a.no_show), 1) AS no_show_rate
FROM appointments a
INNER JOIN clinics c
    ON a.clinic_id = c.clinic_id
GROUP BY
    c.clinic_id,
    c.clinic_name,
    c.city
ORDER BY no_show_rate DESC;


-- QUERY 2: Clinics with at least 95 appointments.

SELECT
    c.clinic_name,
    c.city,
    COUNT(*) AS total_appointments,
    SUM(a.no_show) AS missed_appointments,
    ROUND(100.0 * AVG(a.no_show), 1) AS no_show_rate
FROM appointments a
INNER JOIN clinics c
    ON a.clinic_id = c.clinic_id
GROUP BY
    c.clinic_id,
    c.clinic_name,
    c.city
HAVING COUNT(*) >= 95
ORDER BY no_show_rate DESC;


-- EXPECTED RESULT:
-- 6 clinics meet the minimum appointment threshold.
--
-- KEY FINDING:
-- Hadapsar Care Centre has the highest no-show rate
-- among eligible clinics: 27.3%.
--
-- Gomti Nagar Care Point has a higher rate (33.3%)
-- but is excluded because it has only 90 appointments.


-- ============================================================
-- PART 2.3: BOOKING LEAD-TIME ANALYSIS
-- ============================================================

-- OBJECTIVE:
-- Investigate whether booking lead time is associated
-- with appointment no-show rates.
--
-- CASE divides appointments into four lead-time bands.
-- BETWEEN includes both endpoints.


SELECT
    CASE
        WHEN lead_days BETWEEN 1 AND 7 THEN '1-7'
        WHEN lead_days BETWEEN 8 AND 14 THEN '8-14'
        WHEN lead_days BETWEEN 15 AND 30 THEN '15-30'
        ELSE '31+'
    END AS lead_band,

    COUNT(*) AS total_appointments,
    SUM(no_show) AS missed_appointments,
    ROUND(100.0 * AVG(no_show), 1) AS no_show_rate

FROM appointments

GROUP BY lead_band

ORDER BY MIN(lead_days);


-- EXPECTED RESULTS:
--
-- Lead band | Appointments | No-shows | Rate
-- 1-7       | 390          | 63       | 16.2%
-- 8-14      | 304          | 53       | 17.4%
-- 15-30     | 253          | 76       | 30.0%
-- 31+       | 43           | 26       | 60.5%
--
-- KEY FINDING:
-- Appointments booked 31+ days ahead have a 60.5%
-- no-show rate, compared with 16.2% for 1-7 days.
--
-- This is an observed association, not proof
-- that booking earlier causes no-shows.


-- ============================================================
-- PART 2.4: MONTHLY NO-SHOW TRENDS
-- ============================================================

-- OBJECTIVE:
-- Calculate monthly appointment counts, no-show rates,
-- and month-over-month changes.
--
-- WITH creates a Common Table Expression (CTE).
-- LAG() retrieves the previous month's rate.
-- OVER (ORDER BY month) defines chronological order.


WITH monthly_stats AS (
    SELECT
        DATE_FORMAT(appt_date, '%Y-%m') AS month,
        COUNT(*) AS total_appointments,
        SUM(no_show) AS missed_appointments,
        ROUND(100.0 * AVG(no_show), 1) AS no_show_rate
    FROM appointments
    GROUP BY DATE_FORMAT(appt_date, '%Y-%m')
)

SELECT
    month,
    total_appointments,
    missed_appointments,
    no_show_rate,

    ROUND(
        no_show_rate -
        LAG(no_show_rate) OVER (ORDER BY month),
        1
    ) AS monthly_change

FROM monthly_stats
ORDER BY month;


-- EXPECTED RESULTS:
-- 6 monthly rows, January through June.
--
-- January has NULL monthly_change because
-- there is no preceding month.
--
-- February's no-show rate is 20.5%, compared with
-- January's 24.8%, a decrease of 4.3 percentage points.
--
-- NOTE:
-- monthly_change is measured in percentage points,
-- not percentage growth.


-- ============================================================
-- PART 2.5: CITY-WISE RANKING AND OVERALL COMPARISON
-- ============================================================

-- OBJECTIVE:
-- Rank clinics within their respective cities
-- and compare each clinic's no-show rate with
-- the overall no-show rate.
--
-- RANK() assigns rankings within each city.
-- PARTITION BY restarts rankings for each city.
-- CROSS JOIN attaches the overall rate to every clinic.


WITH clinic_stats AS (
    SELECT
        c.clinic_id,
        c.clinic_name,
        c.city,
        COUNT(*) AS total_appointments,
        SUM(a.no_show) AS missed_appointments,
        ROUND(100.0 * AVG(a.no_show), 1) AS no_show_rate
    FROM appointments a
    JOIN clinics c
        ON a.clinic_id = c.clinic_id
    GROUP BY
        c.clinic_id,
        c.clinic_name,
        c.city
),

overall_stats AS (
    SELECT
        ROUND(100.0 * AVG(no_show), 2) AS overall_rate
    FROM appointments
)

SELECT
    cs.clinic_name,
    cs.city,
    cs.total_appointments,
    cs.no_show_rate,

    RANK() OVER (
        PARTITION BY cs.city
        ORDER BY cs.no_show_rate DESC
    ) AS city_rank,

    os.overall_rate,

    ROUND(
        cs.no_show_rate - os.overall_rate,
        1
    ) AS vs_overall

FROM clinic_stats cs
CROSS JOIN overall_stats os

ORDER BY cs.city, city_rank;


-- EXPECTED RESULTS:
-- 8 clinic rows.
-- Overall no-show rate: approximately 22.02%.
--
-- KEY FINDING:
-- Hadapsar Care Centre has a 27.3% no-show rate,
-- approximately 5.3 percentage points above
-- the overall rate.
--
-- Positive vs_overall:
-- Clinic performs worse than the overall average.
--
-- Negative vs_overall:
-- Clinic has a lower no-show rate than average.


-- ============================================================
-- END OF PART 2: SQL DATA ANALYSIS
-- ============================================================
