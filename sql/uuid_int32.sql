SET timezone TO 'Zulu';
\x

-- I/O
SELECT 'edb4d8f0-1a80-11e8-98d9-e03f49f7f8f3'::uuid_int32 AS ext;
SELECT 'EDB4D8F0-1A80-11E8-98D9-E03F49F7F8F3'::uuid_int32 AS ext_upper;
SELECT '{edb4d8f0-1a80-11e8-98d9-e03f49f7f8f3}'::uuid_int32 AS ext_braces;
SELECT 'edb4d8f01a8011e898d9e03f49f7f8f3'::uuid_int32 AS ext_nosep;
SELECT '{edb4d8f01a8011e898d9e03f49f7f8f3}'::uuid_int32 AS ext_nosep_braces;

-- ...don't accept garbage...
SELECT 'edb4d8f0-1a80-11e8-98d9-e03_49f7f8f3'::uuid_int32 AS fail;

-- ...also accept different versions...
SELECT '87c771ce-bc95-3114-ae59-c0e26acf8e81'::uuid_int32 AS ver_3;
SELECT '22859369-3a4f-49ef-8264-1aaf0a953299'::uuid_int32 AS ver_4;
SELECT 'c9aec822-6992-5c93-b34a-33cc0e952b5e'::uuid_int32 AS ver_5;
SELECT '00000000-0000-0000-0000-000000000000'::uuid_int32 AS nil;

-- ...also accept different variants...
SELECT 'edb4d8f0-1a80-11e8-78d9-e03f49f7f8f3'::uuid_int32 AS var_ncs;
SELECT 'edb4d8f0-1a80-11e8-d8d9-e03f49f7f8f3'::uuid_int32 AS var_ms;
SELECT 'edb4d8f0-1a80-11e8-f8d9-e03f49f7f8f3'::uuid_int32 AS var_future;

-- conversion
SELECT from_std, pg_typeof(from_std) AS from_std
FROM uuid_int32_convert('edb4d8f0-1a80-11e8-98d9-e03f49f7f8f3'::uuid) AS from_std;
SELECT to_std, pg_typeof(to_std)
FROM uuid_int32_convert('edb4d8f0-1a80-11e8-98d9-e03f49f7f8f3'::uuid_int32) AS to_std;

-- cast
SELECT 'edb4d8f0-1a80-11e8-98d9-e03f49f7f8f3'::uuid_int32::uuid AS cast_to_uuid;
SELECT 'edb4d8f0-1a80-11e8-98d9-e03f49f7f8f3'::uuid::uuid_int32 AS cast_from_uuid;

-- basic comparison method
SELECT
    uuid_int32_cmp('8385ded2-8dbb-11e9-ae2b-db6f0f573554', '8385ded2-8dbb-11e9-ae2b-db6f0f573554') AS eq,
    uuid_int32_cmp('8385ded2-8dbb-11e9-ae2b-db6f0f573554', '8385ded3-8dbb-11e9-ae2b-db6f0f573554') AS lt,
    uuid_int32_cmp('8385ded3-8dbb-11e9-ae2b-db6f0f573554', '8385ded2-8dbb-11e9-ae2b-db6f0f573554') AS gt,
    uuid_int32_cmp('8385ded2-8dbb-11e9-ae2b-db6f0f573554', '8385ded2-8dbb-11e9-ae2c-db6f0f573554') AS lt_clock,
    uuid_int32_cmp('8385ded2-8dbb-11e9-ae2c-db6f0f573554', '8385ded2-8dbb-11e9-ae2b-db6f0f573554') AS gt_clock,
    uuid_int32_cmp('8385ded2-8dbb-11e9-ae2b-db6f0f573554', '8385ded2-8dbb-11e9-ae2b-db6f0f573555') AS lt_node,
    uuid_int32_cmp('8385ded2-8dbb-11e9-ae2b-db6f0f573555', '8385ded2-8dbb-11e9-ae2b-db6f0f573554') AS gt_node
;

-- timestamp extraction...
SELECT extract(epoch from ts), to_char(ts, 'YYYY-MM-DD HH24:MI:SS.US')
FROM uuid_int32_timestamp('edb4d8f0-1a80-11e8-98d9-e03f49f7f8f3') AS ts;

SELECT extract(epoch from ts), to_char(ts, 'YYYY-MM-DD HH24:MI:SS.US')
FROM uuid_int32_timestamp('4938f30e-8449-11e9-ae2b-e03f49467033') AS ts;

SELECT
    coalesce(to_char(uuid_int32_timestamp('87c771ce-bc95-3114-ae59-c0e26acf8e81'), 'YYYY-MM-DD HH24:MI:SS.US'), '<null>') AS ver_3,
    coalesce(to_char(uuid_int32_timestamp('22859369-3a4f-49ef-8264-1aaf0a953299'), 'YYYY-MM-DD HH24:MI:SS.US'), '<null>') AS ver_4,
    coalesce(to_char(uuid_int32_timestamp('c9aec822-6992-5c93-b34a-33cc0e952b5e'), 'YYYY-MM-DD HH24:MI:SS.US'), '<null>') AS ver_5,
    coalesce(to_char(uuid_int32_timestamp('00000000-0000-0000-0000-000000000000'), 'YYYY-MM-DD HH24:MI:SS.US'), '<null>') AS nil
;

-- simple data tests
CREATE TABLE uuid_int32_test (id uuid_int32 PRIMARY KEY);

INSERT INTO uuid_int32_test (id) VALUES
('1004cd50-4241-11e9-b3ab-db6f0f573554'), -- 2019-03-09 07:58:02.056840
('05602550-8a8c-11e9-b3ab-db6f0f573554'), -- 2019-06-09 07:56:00.175240
('8385ded2-8dbb-11e9-ae2b-db6f0f573554'), -- 2019-06-13 09:13:31.650017
('00000000-0000-0000-0000-000000000000'), -- nil
('ffc449f0-8c2f-11e9-aba7-e03f497ffcbf'), -- 2019-06-11 10:02:19.391640
('ffc449f0-8c2f-11e9-96b4-e03f49d7f7bb'), -- 2019-06-11 10:02:19.391640
('ffc449f0-8c2f-11e9-9bb8-e03f4977f7b7'), -- 2019-06-11 10:02:19.391640
('ffc449f0-8c2f-11e9-8f34-e03f49c7763b'), -- 2019-06-11 10:02:19.391640
('c9aec822-6992-5c93-b34a-33cc0e952b5e'), -- version 5
('ffced5f0-8c2f-11e9-aba7-e03f497ffcbf'), -- 2019-06-11 10:02:19.460760
('22859369-3a4f-49ef-8264-1aaf0a953299'), -- version 4
('ffd961f0-8c2f-11e9-96b4-e03f49d7f7bb'), -- 2019-06-11 10:02:19.529880
('ffe3edf0-8c2f-11e9-9bb8-e03f4977f7b7'), -- 2019-06-11 10:02:19.599000
('ffee79f0-8c2f-11e9-aba7-e03f497ffcbf'), -- 2019-06-11 10:02:19.668120
('fff905f0-8c2f-11e9-96b4-e03f49d7f7bb'), -- 2019-06-11 10:02:19.737240
('87c771ce-bc95-3114-ae59-c0e26acf8e81'), -- version 3
('000391f0-8c30-11e9-aba7-e03f497ffcbf'), -- 2019-06-11 10:02:19.806360
('000e1df0-8c30-11e9-9bb8-e03f4977f7b7'), -- 2019-06-11 10:02:19.875480
('0018a9f0-8c30-11e9-96b4-e03f49d7f7bb'), -- 2019-06-11 10:02:19.944600
('002335f0-8c30-11e9-9bb8-e03f4977f7b7'), -- 2019-06-11 10:02:20.013720
('002dc1f0-8c30-11e9-aba7-e03f497ffcbf'), -- 2019-06-11 10:02:20.082840
('00384df0-8c30-11e9-96b4-e03f49d7f7bb'), -- 2019-06-11 10:02:20.151960
('0042d9f0-8c30-11e9-aba7-e03f497ffcbf'), -- 2019-06-11 10:02:20.221080
('004d65f0-8c30-11e9-9bb8-e03f4977f7b7')  -- 2019-06-11 10:02:20.290200
;

ANALYZE uuid_int32_test;

SELECT
    count(*) FILTER (WHERE id < '002335f0-8c30-11e9-9bb8-e03f4977f7b7') AS count_lt,
    count(*) FILTER (WHERE id <= '002335f0-8c30-11e9-9bb8-e03f4977f7b7') AS count_le,
    count(*) FILTER (WHERE id > '002335f0-8c30-11e9-9bb8-e03f4977f7b7') AS count_gt,
    count(*) FILTER (WHERE id >= '002335f0-8c30-11e9-9bb8-e03f4977f7b7') AS count_ge
FROM uuid_int32_test;


-- verify use of sort-support
SET enable_seqscan TO off;
\x
SET timezone TO 'Asia/Tokyo';

SELECT id FROM uuid_int32_test WHERE id <= '002335f0-8c30-11e9-9bb8-e03f4977f7b7';

EXPLAIN (ANALYZE, TIMING OFF, SUMMARY OFF, COSTS OFF)
SELECT * FROM uuid_int32_test WHERE id = '000e1df0-8c30-11e9-9bb8-e03f4977f7b7';

EXPLAIN (ANALYZE, TIMING OFF, SUMMARY OFF, COSTS OFF)
SELECT id FROM uuid_int32_test WHERE id > 'ffc449f0-8c2f-11e9-96b4-e03f49d7f7bb' ORDER BY id DESC LIMIT 3 OFFSET 1;
