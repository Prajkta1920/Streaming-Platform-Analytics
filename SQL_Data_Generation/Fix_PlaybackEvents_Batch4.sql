-- ================================================================
--  FIX: playback_events — Add missing 4th batch
--  Current:  3,000,000 rows (batches 1–3 used IDs 8500001–11500000)
--  Adding:   1,000,000 rows (IDs 12500001–13500000)
--  Target:   4,000,000 rows
--
--  Root cause of Error 1062:
--  Previous fix used 11500000+n which COLLIDES with batch 3 (10500000+n)
--  Safe fix: use 12500000+n (completely unused range)
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

-- Check current count before insert
SELECT CONCAT('Before: ', COUNT(*), ' rows in playback_events') AS status FROM playback_events;

-- ----------------------------------------------------------------
-- INSERT batch 4 using safe ID range: 12500001 to 13500000
-- (Batches 1-3 used: 8500001–9500000, 9500001–10500000, 10500001–11500000)
-- ----------------------------------------------------------------
INSERT INTO playback_events (
    playback_event_id, watch_id, user_id, event_datetime,
    event_type, buffering_seconds, video_quality,
    internet_speed_mbps, error_code
)
SELECT
    12500000 + n                                                             AS playback_event_id,
    9000001  + ((n+601) % 5000000)                                           AS watch_id,
    100001   + ((n+163) % 500000)                                            AS user_id,
    DATE_ADD('2023-07-01', INTERVAL (n%730) DAY) + INTERVAL (n%86400) SECOND AS event_datetime,
    ELT(1+((n+3)%6),'Buffering','Failure','Quality Drop','Resume','buffering','FAILURE')
                                                                             AS event_type,
    (n+11) % 121                                                             AS buffering_seconds,
    ELT(1+((n+4)%5),'480p','720p','1080p','4K','720p')                      AS video_quality,
    ROUND(0.5 + ((n+43) % 995) / 10.0, 2)                                   AS internet_speed_mbps,
    IF((n+6) % 7 = 0, NULL,
       ELT(1+((n+3)%6),'ERR_504','ERR_403','ERR_500','ERR_BUFFER','ERR_NET','ERR_DRM'))
                                                                             AS error_code
FROM numbers WHERE n BETWEEN 1 AND 1000000;
COMMIT;

SELECT CONCAT('✅ After: ', COUNT(*), ' rows in playback_events (target: 4,000,000)') AS status
FROM playback_events;

-- ----------------------------------------------------------------
-- RESTORE SETTINGS
-- ----------------------------------------------------------------
SET FOREIGN_KEY_CHECKS  = 1;
SET UNIQUE_CHECKS       = 1;
SET autocommit          = 1;

-- ----------------------------------------------------------------
-- FINAL CHECK — playback_event_id range should have no gaps/overlaps
-- ----------------------------------------------------------------
SELECT
    MIN(playback_event_id) AS min_id,
    MAX(playback_event_id) AS max_id,
    COUNT(*)               AS total_rows
FROM playback_events;

-- ================================================================
-- END — playback_events should now be exactly 4,000,000 rows
-- ================================================================
select count(*) from watch_history;
show tables;