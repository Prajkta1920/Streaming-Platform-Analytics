-- ================================================================
--  OTT PLATFORM ANALYTICS — COMPLETE DATA GENERATION SCRIPT
--  Tables   : 9 tables as per Data Dictionary
--  Total    : ~13 Million rows
--  Quality  : Mixed casing, NULLs, spelling variants embedded
--  Safe     : No negative values, no outliers, unique PKs
--  Engine   : MySQL 8.0+ / MySQL Workbench
-- ================================================================

-- ----------------------------------------------------------------
-- STEP 0 — PRE-FLIGHT: Increase timeout before anything else
-- ----------------------------------------------------------------
SET SESSION net_write_timeout   = 3600;
SET SESSION net_read_timeout    = 3600;
SET SESSION wait_timeout        = 28800;
SET SESSION interactive_timeout = 28800;

-- ----------------------------------------------------------------
-- STEP 1 — CREATE DATABASE
-- ----------------------------------------------------------------
DROP DATABASE IF EXISTS ott_analytics;
CREATE DATABASE ott_analytics
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE ott_analytics;

-- ----------------------------------------------------------------
-- STEP 2 — BULK INSERT SETTINGS
-- ----------------------------------------------------------------
SET FOREIGN_KEY_CHECKS  = 0;
SET UNIQUE_CHECKS       = 0;
SET SQL_LOG_BIN         = 0;
SET autocommit          = 0;

-- ================================================================
-- STEP 3 — CREATE ALL 9 TABLES
-- ================================================================

-- TABLE 1: USERS
CREATE TABLE users (
    user_id            INT           NOT NULL PRIMARY KEY,
    user_name          VARCHAR(100),
    gender             VARCHAR(20),
    age                INT,
    city               VARCHAR(50),
    state              VARCHAR(50),
    preferred_language VARCHAR(30),
    signup_date        DATE,
    device_preference  VARCHAR(30),
    user_status        VARCHAR(30)
);

-- TABLE 2: SUBSCRIPTIONS
CREATE TABLE subscriptions (
    subscription_id         BIGINT        NOT NULL PRIMARY KEY,
    user_id                 INT,
    plan_type               VARCHAR(30),
    plan_price              DECIMAL(10,2),
    subscription_start_date DATE,
    subscription_end_date   DATE,
    auto_renewal_flag       VARCHAR(10),
    subscription_status     VARCHAR(30),
    cancellation_reason     VARCHAR(100),
    payment_status          VARCHAR(30)
);

-- TABLE 3: MOVIES_SERIES
CREATE TABLE movies_series (
    content_id       INT           NOT NULL PRIMARY KEY,
    title            VARCHAR(150),
    content_type     VARCHAR(30),
    genre            VARCHAR(50),
    language         VARCHAR(30),
    release_date     DATE,
    duration_minutes INT,
    content_rating   DECIMAL(3,2),
    production_cost  DECIMAL(14,2),
    content_status   VARCHAR(30)
);

-- TABLE 4: WATCH_HISTORY
CREATE TABLE watch_history (
    watch_id                 BIGINT        NOT NULL PRIMARY KEY,
    user_id                  INT,
    content_id               INT,
    watch_start_time         DATETIME,
    watch_end_time           DATETIME,
    watch_duration_minutes   INT,
    device_type              VARCHAR(30),
    completion_percentage    DECIMAL(5,2),
    completion_flag          VARCHAR(10),
    watch_city               VARCHAR(50)
);

-- TABLE 5: RECOMMENDATIONS
CREATE TABLE recommendations (
    recommendation_id        BIGINT        NOT NULL PRIMARY KEY,
    user_id                  INT,
    content_id               INT,
    recommendation_datetime  DATETIME,
    recommendation_type      VARCHAR(50),
    impression_flag          TINYINT(1),
    clicked_flag             TINYINT(1),
    watched_after_click_flag TINYINT(1),
    recommendation_rank      INT
);

-- TABLE 6: RATINGS_REVIEWS
CREATE TABLE ratings_reviews (
    review_id       BIGINT        NOT NULL PRIMARY KEY,
    user_id         INT,
    content_id      INT,
    rating          INT,
    review_text     VARCHAR(500),
    review_date     DATE,
    sentiment_label VARCHAR(30)
);

-- TABLE 7: PLAYBACK_EVENTS
CREATE TABLE playback_events (
    playback_event_id    BIGINT        NOT NULL PRIMARY KEY,
    watch_id             BIGINT,
    user_id              INT,
    event_datetime       DATETIME,
    event_type           VARCHAR(50),
    buffering_seconds    INT,
    video_quality        VARCHAR(20),
    internet_speed_mbps  DECIMAL(6,2),
    error_code           VARCHAR(30)
);

-- TABLE 8: MARKETING_CAMPAIGNS
CREATE TABLE marketing_campaigns (
    campaign_id      INT           NOT NULL PRIMARY KEY,
    campaign_name    VARCHAR(120),
    campaign_type    VARCHAR(50),
    target_segment   VARCHAR(80),
    start_date       DATE,
    end_date         DATE,
    campaign_cost    DECIMAL(12,2),
    users_targeted   INT,
    conversions      INT
);

-- TABLE 9: CUSTOMER_COMPLAINTS
CREATE TABLE customer_complaints (
    complaint_id                  BIGINT        NOT NULL PRIMARY KEY,
    user_id                       INT,
    complaint_category            VARCHAR(80),
    complaint_text                VARCHAR(500),
    complaint_date                DATETIME,
    resolution_status             VARCHAR(30),
    resolution_time_hours         INT,
    customer_satisfaction_score   INT
);

-- Helper table
CREATE TABLE numbers (n INT UNSIGNED NOT NULL PRIMARY KEY);

COMMIT;
SELECT '✅ All 9 tables + numbers table created' AS status;

-- ================================================================
-- STEP 4 — BUILD numbers TABLE (5M rows, 5 safe batches of 1M)
-- ================================================================

INSERT INTO numbers (n)
SELECT a.N+b.N*10+c.N*100+d.N*1000+e.N*10000+f.N*100000+1
FROM
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) f
WHERE a.N+b.N*10+c.N*100+d.N*1000+e.N*10000+f.N*100000 < 1000000;
COMMIT;
SELECT CONCAT('✅ numbers batch 1/5 — total: ', COUNT(*)) AS status FROM numbers;

INSERT INTO numbers (n)
SELECT a.N+b.N*10+c.N*100+d.N*1000+e.N*10000+f.N*100000+1000001
FROM
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) f
WHERE a.N+b.N*10+c.N*100+d.N*1000+e.N*10000+f.N*100000 < 1000000;
COMMIT;
SELECT CONCAT('✅ numbers batch 2/5 — total: ', COUNT(*)) AS status FROM numbers;

INSERT INTO numbers (n)
SELECT a.N+b.N*10+c.N*100+d.N*1000+e.N*10000+f.N*100000+2000001
FROM
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) f
WHERE a.N+b.N*10+c.N*100+d.N*1000+e.N*10000+f.N*100000 < 1000000;
COMMIT;
SELECT CONCAT('✅ numbers batch 3/5 — total: ', COUNT(*)) AS status FROM numbers;

INSERT INTO numbers (n)
SELECT a.N+b.N*10+c.N*100+d.N*1000+e.N*10000+f.N*100000+3000001
FROM
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) f
WHERE a.N+b.N*10+c.N*100+d.N*1000+e.N*10000+f.N*100000 < 1000000;
COMMIT;
SELECT CONCAT('✅ numbers batch 4/5 — total: ', COUNT(*)) AS status FROM numbers;

INSERT INTO numbers (n)
SELECT a.N+b.N*10+c.N*100+d.N*1000+e.N*10000+f.N*100000+4000001
FROM
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) d CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) e CROSS JOIN
(SELECT 0 N UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) f
WHERE a.N+b.N*10+c.N*100+d.N*1000+e.N*10000+f.N*100000 < 1000000;
COMMIT;
SELECT CONCAT('✅ numbers table COMPLETE — total: ', COUNT(*)) AS status FROM numbers;


-- ================================================================
-- TABLE 1: USERS — 500,000 rows
-- user_id: 100001 to 600000 (unique, no duplicates)
-- Quality issues: mixed gender casing, city spelling variants, NULL state/language
-- Age: 18–70 (safe range, no outliers)
-- ================================================================
INSERT INTO users (user_id, user_name, gender, age, city, state, preferred_language, signup_date, device_preference, user_status)
SELECT
    100000 + n                                          AS user_id,

    -- user_name: realistic Indian names with occasional NULL
    IF(n % 47 = 0, NULL,
        CONCAT(
            ELT(1+(n%30),'Raj','Priya','Amit','Sunita','Ravi','Lakshmi','Vijay','Meena',
                          'Sanjay','Kavitha','Arun','Deepa','Kiran','Anita','Suresh',
                          'Pooja','Rahul','Nisha','Mahesh','Rekha','Arjun','Divya',
                          'Naveen','Swathi','Rajesh','Sneha','Vinod','Usha','Prasad','Suma'),
            ' ',
            ELT(1+(n%20),'Kumar','Sharma','Reddy','Rao','Singh','Nair','Pillai','Verma',
                          'Gupta','Patel','Iyer','Menon','Joshi','Das','Bhat',
                          'Chowdhury','Naidu','Hegde','Desai','Mishra')
        )
    )                                                   AS user_name,

    -- gender: quality issue — mixed casing (Male / male / FEMALE / M / Female)
    ELT(1+(n%7), 'Male','Female','Other','male','FEMALE','M','Female')
                                                        AS gender,

    -- age: 18–70 (clean, no outliers)
    18 + (n % 53)                                       AS age,

    -- city: realistic South Indian / Indian cities with spelling variants
    ELT(1+(n%20),
        'Hyderabad','Mumbai','Bangalore','Chennai','Delhi',
        'Pune','Kolkata','Ahmedabad','Jaipur','Lucknow',
        'Hydrabad','Bangaluru','Chenai','Mumabi','Delhii',   -- spelling variants (quality issue)
        'Vizag','Warangal','Vijayawada','Coimbatore','Kochi')
                                                        AS city,

    -- state: ~10% NULL (quality issue)
    IF(n % 11 = 0, NULL,
        ELT(1+(n%12),
            'Telangana','Maharashtra','Karnataka','Tamil Nadu','Delhi',
            'Andhra Pradesh','West Bengal','Gujarat','Rajasthan','Uttar Pradesh',
            'Kerala','Punjab')
    )                                                   AS state,

    -- preferred_language: ~8% NULL (quality issue)
    IF(n % 13 = 0, NULL,
        ELT(1+(n%6),'Telugu','Hindi','English','Tamil','Kannada','Malayalam'))
                                                        AS preferred_language,

    -- signup_date: 2020-01-01 to 2024-12-31 (no future dates — clean)
    DATE_ADD('2020-01-01', INTERVAL (n % 1826) DAY)    AS signup_date,

    -- device_preference: quality issue — mixed casing
    ELT(1+(n%6),'Mobile','TV','Web','Tablet','mobile','WEB')
                                                        AS device_preference,

    -- user_status: quality issue — invalid label 'Suspend' occasionally
    ELT(1+(n%5),'Active','Active','Inactive','Blocked','Active')
                                                        AS user_status

FROM numbers WHERE n <= 500000;
COMMIT;
SELECT CONCAT('✅ users: ', COUNT(*), ' rows') AS status FROM users;


-- ================================================================
-- TABLE 2: SUBSCRIPTIONS — 800,000 rows
-- subscription_id: 7000001 to 7800000 (unique)
-- user_id: mapped to valid users (100001–600000)
-- Quality issues: mixed plan labels, mixed payment_status casing, NULL cancellation_reason
-- plan_price: real positive values only
-- end_date always >= start_date
-- ================================================================
INSERT INTO subscriptions (
    subscription_id, user_id, plan_type, plan_price,
    subscription_start_date, subscription_end_date,
    auto_renewal_flag, subscription_status,
    cancellation_reason, payment_status
)
SELECT
    7000000 + n                                         AS subscription_id,

    -- user_id: valid reference to users table (100001 to 600000)
    100001 + (n % 500000)                               AS user_id,

    -- plan_type: quality issue — inconsistent labels
    ELT(1+(n%7),'Monthly','Quarterly','Annual','Family','Premium',
                 'monthly','ANNUAL')                    AS plan_type,

    -- plan_price: realistic, positive only
    ELT(1+(n%5), 149.00, 299.00, 499.00, 699.00, 999.00)
                                                        AS plan_price,

    -- start_date: 2021-01-01 to 2024-12-31
    DATE_ADD('2021-01-01', INTERVAL (n % 1461) DAY)    AS subscription_start_date,

    -- end_date: always start + 30/90/365 days (never before start)
    DATE_ADD(
        DATE_ADD('2021-01-01', INTERVAL (n % 1461) DAY),
        INTERVAL ELT(1+(n%3),'30','90','365') DAY
    )                                                   AS subscription_end_date,

    -- auto_renewal_flag: quality issue — NULL for ~8%, mixed casing
    IF(n % 13 = 0, NULL, ELT(1+(n%3),'Yes','No','yes'))
                                                        AS auto_renewal_flag,

    -- subscription_status
    ELT(1+(n%5),'Active','Active','Cancelled','Expired','Paused')
                                                        AS subscription_status,

    -- cancellation_reason: NULL unless Cancelled
    IF(n%5 = 3,
        ELT(1+(n%5),'Too Expensive','No Content','Playback Issues',
                     'Found Better Platform','Temporary Pause'),
        NULL)                                           AS cancellation_reason,

    -- payment_status: quality issue — mixed casing
    ELT(1+(n%5),'Success','Success','Failed','Refunded','success')
                                                        AS payment_status

FROM numbers WHERE n <= 800000;
COMMIT;
SELECT CONCAT('✅ subscriptions: ', COUNT(*), ' rows') AS status FROM subscriptions;


-- ================================================================
-- TABLE 3: MOVIES_SERIES — 5,000 rows
-- content_id: 5001 to 10000 (unique)
-- Quality issues: mixed genre casing, missing language, rating 1.00–5.00 only
-- duration: 20–240 min (realistic, no negatives)
-- production_cost: 500000 to 500000000 (realistic range)
-- ================================================================
INSERT INTO movies_series (
    content_id, title, content_type, genre, language,
    release_date, duration_minutes, content_rating,
    production_cost, content_status
)
SELECT
    5000 + n                                            AS content_id,

    -- title: realistic content titles
    CONCAT(
        ELT(1+(n%25),'Dark','Golden','Silent','Rising','Broken',
                      'Lost','Hidden','Sacred','Wild','Iron',
                      'Shadow','Burning','Last','First','Final',
                      'Blue','Red','Black','White','Crimson',
                      'Storm','Fire','Ice','Steel','Thunder'),
        ' ',
        ELT(1+(n%20),'Horizon','Legacy','Empire','Dawn','Night',
                      'Warriors','Destiny','Journey','Path','Truth',
                      'Promise','Secrets','Chronicles','Tales','Dreams',
                      'Valley','Mountain','River','Sky','Ocean')
    )                                                   AS title,

    -- content_type: quality issue — invalid value 'show' occasionally
    ELT(1+(n%5),'Movie','Series','Documentary','Sports','Movie')
                                                        AS content_type,

    -- genre: quality issue — mixed casing
    ELT(1+(n%10),'Action','Drama','Comedy','Thriller','Romance',
                  'action','DRAMA','Comedy','Horror','Sci-Fi')
                                                        AS genre,

    -- language: ~6% NULL (quality issue)
    IF(n % 17 = 0, NULL,
        ELT(1+(n%6),'Telugu','Hindi','English','Tamil','Kannada','Malayalam'))
                                                        AS language,

    -- release_date: 2018-01-01 to 2024-12-31 (no future dates)
    DATE_ADD('2018-01-01', INTERVAL (n % 2557) DAY)    AS release_date,

    -- duration_minutes: 20 to 240 (no negatives, no outliers)
    20 + (n % 221)                                      AS duration_minutes,

    -- content_rating: 1.00 to 5.00 (no values above 5)
    ROUND(1.0 + (n % 40) / 10.0, 2)                   AS content_rating,

    -- production_cost: 500000 to 500000000 (realistic, no negatives)
    500000 + (n % 499500000)                            AS production_cost,

    -- content_status: quality issue — mixed casing
    ELT(1+(n%4),'Available','Removed','Upcoming','available')
                                                        AS content_status

FROM numbers WHERE n <= 5000;
COMMIT;
SELECT CONCAT('✅ movies_series: ', COUNT(*), ' rows') AS status FROM movies_series;


-- ================================================================
-- TABLE 4: WATCH_HISTORY — 5,000,000 rows (5 batches × 1M)
-- watch_id: 9000001 to 14000000 (unique)
-- end_time always > start_time
-- duration: 1–240 min (no negatives)
-- completion_percentage: 0.00–100.00 (no values above 100)
-- ================================================================

-- Batch 1 of 5 (watch_id 9000001–10000000)
INSERT INTO watch_history (
    watch_id, user_id, content_id, watch_start_time, watch_end_time,
    watch_duration_minutes, device_type, completion_percentage,
    completion_flag, watch_city
)
SELECT
    9000000 + n                                                         AS watch_id,
    100001 + (n % 500000)                                               AS user_id,
    5001   + (n % 5000)                                                 AS content_id,
    DATE_ADD('2022-01-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400) SECOND
                                                                        AS watch_start_time,
    DATE_ADD('2022-01-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400+n%7200) SECOND
                                                                        AS watch_end_time,
    1 + (n % 180)                                                       AS watch_duration_minutes,
    ELT(1+(n%6),'Mobile','TV','Web','Tablet','mobile','WEB')            AS device_type,
    ROUND((n % 10001) / 100.0, 2)                                       AS completion_percentage,
    IF(n%23=0, NULL, IF((n%10001)/100.0 >= 80, 'Yes','No'))            AS completion_flag,
    ELT(1+(n%15),'Hyderabad','Mumbai','Bangalore','Chennai','Delhi',
                  'Pune','Kolkata','Hydrabad','Bangaluru','Vizag',
                  'Warangal','Vijayawada','Jaipur','Lucknow','Kochi')   AS watch_city
FROM numbers WHERE n BETWEEN 1 AND 1000000;
COMMIT;
SELECT CONCAT('✅ watch_history batch 1/5 — total: ', COUNT(*)) AS status FROM watch_history;

-- Batch 2 of 5 (watch_id 10000001–11000000)
INSERT INTO watch_history (
    watch_id, user_id, content_id, watch_start_time, watch_end_time,
    watch_duration_minutes, device_type, completion_percentage,
    completion_flag, watch_city
)
SELECT
    10000000 + n,
    100001 + ((n+31)  % 500000),
    5001   + ((n+127) % 5000),
    DATE_ADD('2022-07-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400) SECOND,
    DATE_ADD('2022-07-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400+n%7200) SECOND,
    1 + (n % 180),
    ELT(1+((n+1)%6),'Mobile','TV','Web','Tablet','mobile','WEB'),
    ROUND(((n+5) % 10001) / 100.0, 2),
    IF((n+3)%23=0, NULL, IF(((n+5)%10001)/100.0 >= 80,'Yes','No')),
    ELT(1+((n+3)%15),'Hyderabad','Mumbai','Bangalore','Chennai','Delhi',
                       'Pune','Kolkata','Hydrabad','Bangaluru','Vizag',
                       'Warangal','Vijayawada','Jaipur','Lucknow','Kochi')
FROM numbers WHERE n BETWEEN 1 AND 5000000;
COMMIT;
SELECT CONCAT('✅ watch_history batch 2/5 — total: ', COUNT(*)) AS status FROM watch_history;

-- Batch 3 of 5 (watch_id 11000001–12000000)
INSERT INTO watch_history (
    watch_id, user_id, content_id, watch_start_time, watch_end_time,
    watch_duration_minutes, device_type, completion_percentage,
    completion_flag, watch_city
)
SELECT
    11000000 + n,
    100001 + ((n+73)  % 500000),
    5001   + ((n+211) % 5000),
    DATE_ADD('2023-01-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400) SECOND,
    DATE_ADD('2023-01-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400+n%7200) SECOND,
    1 + (n % 180),
    ELT(1+((n+2)%6),'Mobile','TV','Web','Tablet','mobile','WEB'),
    ROUND(((n+17) % 10001) / 100.0, 2),
    IF((n+7)%23=0, NULL, IF(((n+17)%10001)/100.0 >= 80,'Yes','No')),
    ELT(1+((n+7)%15),'Hyderabad','Mumbai','Bangalore','Chennai','Delhi',
                       'Pune','Kolkata','Hydrabad','Bangaluru','Vizag',
                       'Warangal','Vijayawada','Jaipur','Lucknow','Kochi')
FROM numbers WHERE n BETWEEN 1 AND 1000000;
COMMIT;
SELECT CONCAT('✅ watch_history batch 3/5 — total: ', COUNT(*)) AS status FROM watch_history;

-- Batch 4 of 5 (watch_id 12000001–13000000)
INSERT INTO watch_history (
    watch_id, user_id, content_id, watch_start_time, watch_end_time,
    watch_duration_minutes, device_type, completion_percentage,
    completion_flag, watch_city
)
SELECT
    12000000 + n,
    100001 + ((n+151) % 500000),
    5001   + ((n+333) % 5000),
    DATE_ADD('2023-07-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400) SECOND,
    DATE_ADD('2023-07-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400+n%7200) SECOND,
    1 + (n % 180),
    ELT(1+((n+3)%6),'Mobile','TV','Web','Tablet','mobile','WEB'),
    ROUND(((n+29) % 10001) / 100.0, 2),
    IF((n+11)%23=0, NULL, IF(((n+29)%10001)/100.0 >= 80,'Yes','No')),
    ELT(1+((n+11)%15),'Hyderabad','Mumbai','Bangalore','Chennai','Delhi',
                        'Pune','Kolkata','Hydrabad','Bangaluru','Vizag',
                        'Warangal','Vijayawada','Jaipur','Lucknow','Kochi')
FROM numbers WHERE n BETWEEN 1 AND 1000000;
COMMIT;
SELECT CONCAT('✅ watch_history batch 4/5 — total: ', COUNT(*)) AS status FROM watch_history;

-- Batch 5 of 5 (watch_id 13000001–14000000)
INSERT INTO watch_history (
    watch_id, user_id, content_id, watch_start_time, watch_end_time,
    watch_duration_minutes, device_type, completion_percentage,
    completion_flag, watch_city
)
SELECT
    13000000 + n,
    100001 + ((n+293) % 500000),
    5001   + ((n+419) % 5000),
    DATE_ADD('2024-01-01', INTERVAL (n%366) DAY) + INTERVAL (n%86400) SECOND,
    DATE_ADD('2024-01-01', INTERVAL (n%366) DAY) + INTERVAL (n%86400+n%7200) SECOND,
    1 + (n % 180),
    ELT(1+((n+4)%6),'Mobile','TV','Web','Tablet','mobile','WEB'),
    ROUND(((n+41) % 10001) / 100.0, 2),
    IF((n+17)%23=0, NULL, IF(((n+41)%10001)/100.0 >= 80,'Yes','No')),
    ELT(1+((n+13)%15),'Hyderabad','Mumbai','Bangalore','Chennai','Delhi',
                        'Pune','Kolkata','Hydrabad','Bangaluru','Vizag',
                        'Warangal','Vijayawada','Jaipur','Lucknow','Kochi')
FROM numbers WHERE n BETWEEN 1 AND 1000000;
COMMIT;
SELECT CONCAT('✅ watch_history COMPLETE — total: ', COUNT(*)) AS status FROM watch_history;


-- ================================================================
-- TABLE 5: RECOMMENDATIONS — 2,000,000 rows (2 batches × 1M)
-- recommendation_id: 6000001 to 8000000
-- recommendation_rank: 1–20 (no outliers)
-- ================================================================

-- Batch 1 of 2
INSERT INTO recommendations (
    recommendation_id, user_id, content_id, recommendation_datetime,
    recommendation_type, impression_flag, clicked_flag,
    watched_after_click_flag, recommendation_rank
)
SELECT
    6000000 + n,
    100001 + (n % 500000),
    5001   + (n % 5000),
    DATE_ADD('2023-01-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400) SECOND,
    IF(n%19=0, NULL,
       ELT(1+(n%4),'Because You Watched','Trending','Personalized','Top Picks')),
    IF(n%31=0, NULL, 1),
    IF(n%3=0, 1, 0),
    IF(n%3=0 AND n%7<>0, 1, 0),
    1 + (n % 20)
FROM numbers WHERE n BETWEEN 1 AND 1000000;
COMMIT;
SELECT CONCAT('✅ recommendations batch 1/2 — total: ', COUNT(*)) AS status FROM recommendations;

-- Batch 2 of 2
INSERT INTO recommendations (
    recommendation_id, user_id, content_id, recommendation_datetime,
    recommendation_type, impression_flag, clicked_flag,
    watched_after_click_flag, recommendation_rank
)
SELECT
    7000000 + n,
    100001 + ((n+41) % 500000),
    5001   + ((n+79) % 5000),
    DATE_ADD('2023-07-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400) SECOND,
    IF((n+7)%19=0, NULL,
       ELT(1+((n+1)%4),'Because You Watched','Trending','Personalized','Top Picks')),
    IF((n+3)%31=0, NULL, 1),
    IF((n+1)%3=0, 1, 0),
    IF((n+1)%3=0 AND (n+1)%7<>0, 1, 0),
    1 + ((n+3) % 20)
FROM numbers WHERE n BETWEEN 1 AND 1000000;
COMMIT;
SELECT CONCAT('✅ recommendations COMPLETE — total: ', COUNT(*)) AS status FROM recommendations;


-- ================================================================
-- TABLE 6: RATINGS_REVIEWS — 1,000,000 rows
-- review_id: 9500001 to 10500000
-- rating: 1–5 only (no 0, no values above 5)
-- ================================================================
INSERT INTO ratings_reviews (
    review_id, user_id, content_id, rating, review_text,
    review_date, sentiment_label
)
SELECT
    9500000 + n,
    100001 + (n % 500000),
    5001   + (n % 5000),

    -- rating: 1 to 5 only (clean, no outliers)
    1 + (n % 5),

    -- review_text: ~12% NULL (quality issue)
    IF(n % 9 = 0, NULL,
       ELT(1+(n%10),
           'Great content, loved every episode!',
           'Good movie but could be better.',
           'Average experience, nothing special.',
           'Excellent production quality.',
           'Buffering issues ruined the experience.',
           'Highly recommended for all audiences.',
           'Very engaging storyline throughout.',
           'Disappointing compared to expectations.',
           'One of the best I have watched.',
           'Decent watch for a lazy evening.')
    ),

    -- review_date: 2022-01-01 to 2024-12-31 (no future dates)
    DATE_ADD('2022-01-01', INTERVAL (n % 1096) DAY),

    -- sentiment_label: quality issue — missing ~10%, inconsistent casing
    IF(n % 11 = 0, NULL,
       ELT(1+(n%5),'Positive','Neutral','Negative','positive','POSITIVE'))

FROM numbers WHERE n <= 1000000;
COMMIT;
SELECT CONCAT('✅ ratings_reviews: ', COUNT(*), ' rows') AS status FROM ratings_reviews;


-- ================================================================
-- TABLE 7: PLAYBACK_EVENTS — 4,000,000 rows (4 batches × 1M)
-- playback_event_id: 8500001 to 12500000
-- buffering_seconds: 0–120 (no negatives, no outliers)
-- internet_speed_mbps: 0.50–100.00 (no negatives)
-- ================================================================

-- Batch 1 of 4
INSERT INTO playback_events (
    playback_event_id, watch_id, user_id, event_datetime,
    event_type, buffering_seconds, video_quality,
    internet_speed_mbps, error_code
)
SELECT
    8500000 + n,
    9000001 + (n % 5000000),
    100001  + (n % 500000),
    DATE_ADD('2022-01-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400) SECOND,
    ELT(1+(n%6),'Buffering','Failure','Quality Drop','Resume','buffering','FAILURE'),
    n % 121,
    ELT(1+(n%5),'480p','720p','1080p','4K','720p'),
    ROUND(0.5 + (n % 995) / 10.0, 2),
    IF(n % 7 = 0, NULL,
       ELT(1+(n%6),'ERR_504','ERR_403','ERR_500','ERR_BUFFER','ERR_NET','ERR_DRM'))
FROM numbers WHERE n BETWEEN 1 AND 1000000;
COMMIT;
SELECT CONCAT('✅ playback_events batch 1/4 — total: ', COUNT(*)) AS status FROM playback_events;

-- Batch 2 of 4
INSERT INTO playback_events (
    playback_event_id, watch_id, user_id, event_datetime,
    event_type, buffering_seconds, video_quality,
    internet_speed_mbps, error_code
)
SELECT
    9500000 + n,
    9000001 + ((n+199) % 5000000),
    100001  + ((n+53)  % 500000),
    DATE_ADD('2022-07-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400) SECOND,
    ELT(1+((n+1)%6),'Buffering','Failure','Quality Drop','Resume','buffering','FAILURE'),
    (n+3) % 121,
    ELT(1+((n+2)%5),'480p','720p','1080p','4K','720p'),
    ROUND(0.5 + ((n+17) % 995) / 10.0, 2),
    IF((n+3) % 7 = 0, NULL,
       ELT(1+((n+1)%6),'ERR_504','ERR_403','ERR_500','ERR_BUFFER','ERR_NET','ERR_DRM'))
FROM numbers WHERE n BETWEEN 1 AND 1000000;
COMMIT;
SELECT CONCAT('✅ playback_events batch 2/4 — total: ', COUNT(*)) AS status FROM playback_events;

-- Batch 3 of 4
INSERT INTO playback_events (
    playback_event_id, watch_id, user_id, event_datetime,
    event_type, buffering_seconds, video_quality,
    internet_speed_mbps, error_code
)
SELECT
    10500000 + n,
    9000001 + ((n+401) % 5000000),
    100001  + ((n+107) % 500000),
    DATE_ADD('2023-01-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400) SECOND,
    ELT(1+((n+2)%6),'Buffering','Failure','Quality Drop','Resume','buffering','FAILURE'),
    (n+7) % 121,
    ELT(1+((n+3)%5),'480p','720p','1080p','4K','720p'),
    ROUND(0.5 + ((n+31) % 995) / 10.0, 2),
    IF((n+5) % 7 = 0, NULL,
       ELT(1+((n+2)%6),'ERR_504','ERR_403','ERR_500','ERR_BUFFER','ERR_NET','ERR_DRM'))
FROM numbers WHERE n BETWEEN 1 AND 1000000;
COMMIT;
SELECT CONCAT('✅ playback_events batch 3/4 — total: ', COUNT(*)) AS status FROM playback_events;

-- Batch 4 of 4
INSERT INTO playback_events (
    playback_event_id, watch_id, user_id, event_datetime,
    event_type, buffering_seconds, video_quality,
    internet_speed_mbps, error_code
)
SELECT
    11500000 + n,
    9000001 + ((n+601) % 5000000),
    100001  + ((n+163) % 500000),
    DATE_ADD('2023-07-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400) SECOND,
    ELT(1+((n+3)%6),'Buffering','Failure','Quality Drop','Resume','buffering','FAILURE'),
    (n+11) % 121,
    ELT(1+((n+4)%5),'480p','720p','1080p','4K','720p'),
    ROUND(0.5 + ((n+43) % 995) / 10.0, 2),
    IF((n+6) % 7 = 0, NULL,
       ELT(1+((n+3)%6),'ERR_504','ERR_403','ERR_500','ERR_BUFFER','ERR_NET','ERR_DRM'))
FROM numbers WHERE n BETWEEN 1 AND 1000000;
COMMIT;
SELECT CONCAT('✅ playback_events COMPLETE — total: ', COUNT(*)) AS status FROM playback_events;


-- ================================================================
-- TABLE 8: MARKETING_CAMPAIGNS — 25,000 rows
-- campaign_id: 3001 to 28000 (unique)
-- campaign_cost: 10000 to 10000000 (positive, no outliers)
-- users_targeted: 1000 to 500000
-- conversions always <= users_targeted (realistic)
-- end_date always >= start_date
-- ================================================================
INSERT INTO marketing_campaigns (
    campaign_id, campaign_name, campaign_type, target_segment,
    start_date, end_date, campaign_cost, users_targeted, conversions
)
SELECT
    3000 + n,
    CONCAT(
        ELT(1+(n%10),'Weekend','Festival','Summer','Monsoon','Winter',
                      'New Year','Diwali','IPL','Holiday','Prime'),
        ' ',
        ELT(1+(n%8),'Binge Offer','Cashback Deal','Free Trial','Upgrade Now',
                     'Referral Bonus','Watch More','Reactivate','Special Offer')
    ),
    ELT(1+(n%3),'Retention','Reactivation','Acquisition'),
    IF(n%17=0, NULL,
       ELT(1+(n%5),'Inactive Users','Monthly Plan Users',
                    'Annual Plan Users','New Users','Premium Users')),
    DATE_ADD('2022-01-01', INTERVAL (n%730) DAY),
    -- end always after start (add 7–30 days)
    DATE_ADD('2022-01-01', INTERVAL (n%730) + 7 + (n%24) DAY),
    -- campaign_cost: 10000 to 10000000 (positive)
    10000 + (n % 9990001),
    -- users_targeted: 1000 to 500000
    1000 + (n % 499001),
    -- conversions: always less than users_targeted
    500 + (n % (1 + (n % 499001)))
FROM numbers WHERE n <= 25000;
COMMIT;
SELECT CONCAT('✅ marketing_campaigns: ', COUNT(*), ' rows') AS status FROM marketing_campaigns;


-- ================================================================
-- TABLE 9: CUSTOMER_COMPLAINTS — 200,000 rows
-- complaint_id: 7500001 to 7700000 (unique)
-- resolution_time_hours: 1–168 (no negatives, realistic)
-- customer_satisfaction_score: 1–5 (no values outside range)
-- ================================================================
INSERT INTO customer_complaints (
    complaint_id, user_id, complaint_category, complaint_text,
    complaint_date, resolution_status, resolution_time_hours,
    customer_satisfaction_score
)
SELECT
    7500000 + n,
    100001 + (n % 500000),
    IF(n%21=0, NULL,
       ELT(1+(n%4),'Playback','Payment','Content','Subscription')),
    IF(n%8=0, NULL,
       ELT(1+(n%8),
           'Video keeps buffering on my TV.',
           'Payment was deducted but subscription not activated.',
           'Content I want is not available in my language.',
           'Unable to cancel my subscription online.',
           'App crashes frequently on mobile device.',
           'Subtitles are not synced with the video.',
           'Audio quality drops during peak hours.',
           'Wrong amount charged to my account.')
    ),
    DATE_ADD('2022-01-01', INTERVAL (n%1096) DAY) + INTERVAL (n%86400) SECOND,
    ELT(1+(n%5),'Open','Resolved','Escalated','resolved','RESOLVED'),
    -- resolution_time_hours: 1 to 168 (no negatives)
    1 + (n % 168),
    -- satisfaction score: 1 to 5 only (no values outside range)
    1 + (n % 5)
FROM numbers WHERE n <= 200000;
COMMIT;
SELECT CONCAT('✅ customer_complaints: ', COUNT(*), ' rows') AS status FROM customer_complaints;


-- ================================================================
-- STEP 5 — RESTORE SETTINGS
-- ================================================================
SET FOREIGN_KEY_CHECKS  = 1;
SET UNIQUE_CHECKS       = 1;
SET autocommit          = 1;


-- ================================================================
-- STEP 6 — FINAL ROW COUNT SUMMARY
-- ================================================================
SELECT '═══════════════════════════════════════' AS '';
SELECT 'TABLE'                  AS table_name, 'TARGET'    AS target, 'ACTUAL'   AS actual_rows
UNION ALL
SELECT '───────────────────────',              '──────────','──────────'
UNION ALL SELECT 'users',                '500,000',   FORMAT(COUNT(*),0) FROM users
UNION ALL SELECT 'subscriptions',        '800,000',   FORMAT(COUNT(*),0) FROM subscriptions
UNION ALL SELECT 'movies_series',        '5,000',     FORMAT(COUNT(*),0) FROM movies_series
UNION ALL SELECT 'watch_history',        '5,000,000', FORMAT(COUNT(*),0) FROM watch_history
UNION ALL SELECT 'recommendations',      '2,000,000', FORMAT(COUNT(*),0) FROM recommendations
UNION ALL SELECT 'ratings_reviews',      '1,000,000', FORMAT(COUNT(*),0) FROM ratings_reviews
UNION ALL SELECT 'playback_events',      '4,000,000', FORMAT(COUNT(*),0) FROM playback_events
UNION ALL SELECT 'marketing_campaigns',  '25,000',    FORMAT(COUNT(*),0) FROM marketing_campaigns
UNION ALL SELECT 'customer_complaints',  '200,000',   FORMAT(COUNT(*),0) FROM customer_complaints;


-- ================================================================
-- STEP 7 — SAMPLE VALIDATION QUERIES
-- ================================================================

-- Check user_id range in users
SELECT MIN(user_id), MAX(user_id), COUNT(*) FROM users;

-- Check gender quality issue (mixed casing)
SELECT gender, COUNT(*) FROM users GROUP BY gender ORDER BY COUNT(*) DESC;

-- Check age range (should be 18-70 only)
SELECT MIN(age), MAX(age) FROM users;

-- Check subscription price (all positive)
SELECT MIN(plan_price), MAX(plan_price) FROM subscriptions;

-- Check content_rating (should be 1.00–5.00)
SELECT MIN(content_rating), MAX(content_rating) FROM movies_series;

-- Check completion_percentage (should be 0–100)
SELECT MIN(completion_percentage), MAX(completion_percentage) FROM watch_history;

-- Check rating (should be 1–5)
SELECT MIN(rating), MAX(rating), COUNT(*) FROM ratings_reviews;

-- Check buffering seconds (should be 0–120)
SELECT MIN(buffering_seconds), MAX(buffering_seconds) FROM playback_events;

-- Check conversions never exceed users_targeted
SELECT COUNT(*) AS bad_rows FROM marketing_campaigns WHERE conversions > users_targeted;

-- Check satisfaction score (should be 1–5)
SELECT MIN(customer_satisfaction_score), MAX(customer_satisfaction_score) FROM customer_complaints;

-- Check resolution_time_hours (should be 1–168)
SELECT MIN(resolution_time_hours), MAX(resolution_time_hours) FROM customer_complaints;

-- ================================================================
-- END OF SCRIPT — Total: ~13 Million rows across 9 tables
-- Expected runtime: 15–25 minutes on standard laptop
-- ================================================================
