SET TIMING ON;
SET LINESIZE 200
SET PAGESIZE 100
SET TRIMOUT ON
SET TRIMSPOOL ON
SET TAB OFF
ALTER SESSION SET statistics_level = ALL;

-- To view proposed plan by optimizer (can change if adaptive)
EXPLAIN PLAN SET STATEMENT_ID = 'M1' FOR
-- SQL query;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'M1'));

--To view actual plan with actual rows, time per each operation first run SQL query and do
SELECT * 
FROM TABLE(
    DBMS_XPLAN.DISPLAY_CURSOR(
        NULL, 
        NULL, 
        'ALLSTATS LAST'
    )
);
