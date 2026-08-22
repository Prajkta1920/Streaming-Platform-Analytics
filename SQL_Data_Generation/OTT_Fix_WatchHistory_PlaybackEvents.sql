-- ================================================================
--  FIX SCRIPT: watch_history (5,000,000) + playback_events (4,000,000)
--  Run this ONLY after your main OTT_Analytics_Complete.sql is done
--  This script: DELETES extra rows & ADDS missing rows correctly
-- ================================================================

USE ott_analytics;

SET FOREIGN_KEY_CHECKS  = 0;
SET UNIQUE_CHECKS       = 0;
SET SQL_LOG_BIN         = 0;
SET autocommit          = 0;
SET net_write_timeout   = 3600;
SET net_read_timeout    = 3600;
SET wait_timeout        = 28800;
SET interactive_timeout = 28800;

-- ================================================================
-- BEFORE: Check current counts
-- ================================================================
SELECT 'BEFORE FIX' AS check_point,
       (SELECT COUNT(*) FROM watch_history)    AS watch_history_current,
       (SELECT COUNT(*) FROM playback_events)  AS playback_events_current;

-- ================================================================
-- FIX 1: watch_history — currently 6,000,000, need 5,000,000
--         DELETE the extra 1,000,000 rows (batch 6 = watch_id 14000001–15000000)
-- ================================================================
DELETE FROM watch_history
WHERE watch_id BETWEEN 14000001 AND 15000000;
COMMIT;
SELECT CONCAT('✅ watch_history after delete: ', COUNT(*), ' rows (target: 5,000,000)') AS status
FROM watch_history;

-- ================================================================
-- FIX 2: playback_events — currently 3,000,000, need 4,000,000
--         ADD the missing 4th batch (playback_event_id 11500001–12500000)
-- ================================================================
INSERT INTO playback_events (
    playback_event_id, watch_id, user_id, event_datetime,
    event_type, buffering_seconds, video_quality,
    internet_speed_mbps, error_code
)
SELECT
    11500000 + n                                                            AS playback_event_id,
    9000001  + ((n+601) % 5000000)                                          AS watch_id,
    100001   + ((n+163) % 500000)                                           AS user_id,
    DATE_ADD('2023-07-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400) SECOND
                                                                            AS event_datetime,
    ELT(1+((n+3)%6),'Buffering','Failure','Quality Drop','Resume','buffering','FAILURE')
                                                                            AS event_type,
    (n+11) % 121                                                            AS buffering_seconds,
    ELT(1+((n+4)%5),'480p','720p','1080p','4K','720p')                     AS video_quality,
    ROUND(0.5 + ((n+43) % 995) / 10.0, 2)                                  AS internet_speed_mbps,
    IF((n+6) % 7 = 0, NULL,
       ELT(1+((n+3)%6),'ERR_504','ERR_403','ERR_500','ERR_BUFFER','ERR_NET','ERR_DRM'))
                                                                            AS error_code
FROM numbers WHERE n BETWEEN 1 AND 1000000;
COMMIT;
SELECT CONCAT('✅ playback_events after insert: ', COUNT(*), ' rows (target: 4,000,000)') AS status
FROM playback_events;

-- ================================================================
-- RESTORE SETTINGS
-- ================================================================
SET FOREIGN_KEY_CHECKS  = 1;
SET UNIQUE_CHECKS       = 1;
SET autocommit          = 1;

-- ================================================================
-- FINAL VERIFICATION — All 9 tables
-- ================================================================
SELECT table_name, target, actual_rows,
       IF(actual_rows = target, '✅ CORRECT', '❌ MISMATCH') AS result
FROM (
    SELECT 'users'               AS table_name, '500,000'   AS target, FORMAT(COUNT(*),0) AS actual_rows FROM users
    UNION ALL
    SELECT 'subscriptions',       '800,000',   FORMAT(COUNT(*),0) FROM subscriptions
    UNION ALL
    SELECT 'movies_series',       '5,000',     FORMAT(COUNT(*),0) FROM movies_series
    UNION ALL
    SELECT 'watch_history',       '5,000,000', FORMAT(COUNT(*),0) FROM watch_history
    UNION ALL
    SELECT 'recommendations',     '2,000,000', FORMAT(COUNT(*),0) FROM recommendations
    UNION ALL
    SELECT 'ratings_reviews',     '1,000,000', FORMAT(COUNT(*),0) FROM ratings_reviews
    UNION ALL
    SELECT 'playback_events',     '4,000,000', FORMAT(COUNT(*),0) FROM playback_events
    UNION ALL
    SELECT 'marketing_campaigns', '25,000',    FORMAT(COUNT(*),0) FROM marketing_campaigns
    UNION ALL
    SELECT 'customer_complaints', '200,000',   FORMAT(COUNT(*),0) FROM customer_complaints
) AS summary;
