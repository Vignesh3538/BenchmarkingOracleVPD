SET TIMING ON;
SET LINESIZE 200
SET PAGESIZE 100
SET TRIMOUT ON
SET TRIMSPOOL ON
SET TAB OFF
EXPLAIN PLAN SET STATEMENT_ID = 'M1' FOR
SELECT COUNT(*) FROM SYSTEM.CUSTOMER;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'M1'));

EXPLAIN PLAN SET STATEMENT_ID = 'M1' FOR
select count(*) from lineitem where ( SELECT
      (
        (SELECT COUNT(*)
         FROM SYSTEM.lineitem all_li
           JOIN SYSTEM.orders   all_o ON all_li.l_orderkey = all_o.o_orderkey
           JOIN SYSTEM.customer all_c ON all_o.o_custkey   = all_c.c_custkey
           JOIN SYSTEM.nation   all_n ON all_c.c_nationkey = all_n.n_nationkey
           JOIN SYSTEM.region   all_r ON all_n.n_regionkey = all_r.r_regionkey
         WHERE all_li.l_suppkey = lineitem.l_suppkey
           AND all_li.l_partkey  = lineitem.l_partkey
           AND all_r.r_regionkey = (
             SELECT r2.r_regionkey
             FROM SYSTEM.customer me
               JOIN SYSTEM.nation n2 ON me.c_nationkey = n2.n_nationkey
               JOIN SYSTEM.region r2 ON n2.n_regionkey = r2.r_regionkey
             WHERE me.c_name = 'Customer#000001111'
           )
        ) /
        (SELECT COUNT(*)
         FROM SYSTEM.lineitem all2
         WHERE all2.l_suppkey = lineitem.l_suppkey
           AND all2.l_partkey  = lineitem.l_partkey
        )
      )
    FROM dual
  ) >= 1;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY(NULL, 'M1'));
