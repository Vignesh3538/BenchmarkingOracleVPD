-- 1
select
    l_returnflag,
    l_linestatus,
    sum(l_quantity) as sum_qty,
    sum(l_extendedprice) as sum_base_price,
    sum(l_extendedprice*(1-l_discount)) as sum_disc_price,
    sum(l_extendedprice*(1-l_discount)*(1+l_tax)) as sum_charge,
    avg(l_quantity) as avg_qty,
    avg(l_extendedprice) as avg_price,
    avg(l_discount) as avg_disc,
    count(*) as count_order
from
    system.lineitem
where
    l_shipdate <= date '1998-12-01' - interval '90' day
group by
    l_returnflag,
    l_linestatus
order by
    l_returnflag,
    l_linestatus;

-- 2
SELECT
    s_acctbal,
    s_name,
    n_name,
    p_partkey,
    p_mfgr,
    s_address,
    s_phone,
    s_comment
FROM
    system.part,
    system.supplier,
    system.partsupp,
    system.nation,
    system.region
WHERE
        p_partkey = ps_partkey
    AND s_suppkey = ps_suppkey
    AND p_size = 15
    AND p_type LIKE '%BRASS'
    AND s_nationkey = n_nationkey
    AND n_regionkey = r_regionkey
    AND r_name = 'EUROPE'
    AND ps_supplycost = (
            SELECT MIN(ps_supplycost)
            FROM system.partsupp, system.supplier, system.nation, system.region
            WHERE
                    p_partkey = partsupp.ps_partkey
                AND supplier.s_suppkey = partsupp.ps_suppkey
                AND supplier.s_nationkey = nation.n_nationkey
                AND nation.n_regionkey = region.r_regionkey
                AND region.r_name = 'EUROPE'
    )
ORDER BY
    s_acctbal DESC,
    n_name,
    s_name,
    p_partkey;

-- 3
SELECT
    l_orderkey,
    SUM(l_extendedprice * (1 - l_discount)) AS revenue,
    o_orderdate,
    o_shippriority
FROM
    system.customer,
    system.orders,
    system.lineitem
WHERE
        c_mktsegment = 'BUILDING'
    AND c_custkey = o_custkey
    AND l_orderkey = o_orderkey
    AND o_orderdate < DATE '1995-03-15'
    AND l_shipdate > DATE '1995-03-15'
GROUP BY
    l_orderkey,
    o_orderdate,
    o_shippriority
ORDER BY
    revenue DESC,
    o_orderdate ;

-- 4
SELECT
    o_orderpriority,
    COUNT(*) AS order_count
FROM
    system.orders
WHERE
        o_orderdate >= DATE '1993-07-01'
    AND o_orderdate <  DATE '1993-07-01' + INTERVAL '3' MONTH
    AND EXISTS (
            SELECT 1
            FROM system.lineitem
            WHERE l_orderkey = o_orderkey
              AND l_commitdate < l_receiptdate
    )
GROUP BY
    o_orderpriority
ORDER BY
    o_orderpriority;

-- 5
SELECT
    n_name,
    SUM(l_extendedprice * (1 - l_discount)) AS revenue
FROM
    system.customer,
    system.orders,
    system.lineitem,
    system.supplier,
    system.nation,
    system.region
WHERE
        c_custkey = o_custkey
    AND l_orderkey = o_orderkey
    AND l_suppkey = s_suppkey
    AND c_nationkey = s_nationkey
    AND s_nationkey = n_nationkey
    AND n_regionkey = r_regionkey
    AND r_name = 'ASIA'
    AND o_orderdate >= DATE '1994-01-01'
    AND o_orderdate <  DATE '1994-01-01' + INTERVAL '1' YEAR
GROUP BY
    n_name
ORDER BY
    revenue DESC;

-- 6
SELECT
    SUM(l_extendedprice * l_discount) AS revenue
FROM
    system.lineitem
WHERE
        l_shipdate >= DATE '1994-01-01'
    AND l_shipdate <  DATE '1994-01-01' + INTERVAL '1' YEAR
    AND l_discount BETWEEN 0.06 - 0.01 AND 0.06 + 0.01
    AND l_quantity < 24;

-- 7
SELECT
    supp_nation,
    cust_nation,
    l_year,
    SUM(volume) AS revenue
FROM (
    SELECT
        n1.n_name AS supp_nation,
        n2.n_name AS cust_nation,
        EXTRACT(YEAR FROM l_shipdate) AS l_year,
        l_extendedprice * (1 - l_discount) AS volume
    FROM
        system.supplier,
        system.lineitem,
        system.orders,
        system.customer,
        system.nation n1,
        system.nation n2
    WHERE
            s_suppkey = l_suppkey
        AND o_orderkey = l_orderkey
        AND c_custkey = o_custkey
        AND s_nationkey = n1.n_nationkey
        AND c_nationkey = n2.n_nationkey
        AND (
                (n1.n_name = 'FRANCE'  AND n2.n_name = 'GERMANY')
             OR (n1.n_name = 'GERMANY' AND n2.n_name = 'FRANCE')
            )
        AND l_shipdate BETWEEN DATE '1995-01-01'
                           AND DATE '1996-12-31'
) shipping
GROUP BY
    supp_nation,
    cust_nation,
    l_year
ORDER BY
    supp_nation,
    cust_nation,
    l_year;

-- 8
SELECT
    o_year,
    SUM(CASE
            WHEN nation = 'BRAZIL'
            THEN volume
            ELSE 0
        END) / SUM(volume) AS mkt_share
FROM (
    SELECT
        EXTRACT(YEAR FROM o_orderdate) AS o_year,
        l_extendedprice * (1 - l_discount) AS volume,
        n2.n_name AS nation
    FROM
        system.part,
        system.supplier,
        system.lineitem,
        system.orders,
        system.customer,
        system.nation n1,
        system.nation n2,
        system.region
    WHERE
            p_partkey = l_partkey
        AND s_suppkey = l_suppkey
        AND l_orderkey = o_orderkey
        AND o_custkey = c_custkey
        AND c_nationkey = n1.n_nationkey
        AND n1.n_regionkey = r_regionkey
        AND r_name = 'AMERICA'
        AND s_nationkey = n2.n_nationkey
        AND o_orderdate BETWEEN DATE '1995-01-01'
                            AND DATE '1996-12-31'
        AND p_type = 'ECONOMY ANODIZED STEEL'
) all_nations
GROUP BY
    o_year
ORDER BY
    o_year;

-- 9
SELECT
    nation,
    o_year,
    SUM(amount) AS sum_profit
FROM (
    SELECT
        n_name AS nation,
        EXTRACT(YEAR FROM o_orderdate) AS o_year,
        (l_extendedprice * (1 - l_discount) - ps_supplycost * l_quantity) AS amount
    FROM
        system.part,
        system.supplier,
        system.lineitem,
        system.partsupp,
        system.orders,
        system.nation
    WHERE
            s_suppkey   = l_suppkey
        AND ps_suppkey  = l_suppkey
        AND ps_partkey  = l_partkey
        AND p_partkey   = l_partkey
        AND o_orderkey  = l_orderkey
        AND s_nationkey = n_nationkey
        AND p_name LIKE '%green%'
) profit
GROUP BY
    nation,
    o_year
ORDER BY
    nation,
    o_year DESC;

-- 10
SELECT
    c.c_custkey,
    c.c_name,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue,
    c.c_acctbal,
    n.n_name,
    c.c_address,
    c.c_phone,
    c.c_comment
FROM
    system.customer c,
    system.orders o,
    system.lineitem l,
    system.nation n
WHERE
        c.c_custkey = o.o_custkey
    AND l.l_orderkey = o.o_orderkey
    AND o.o_orderdate >= DATE '1993-10-01'
    AND o.o_orderdate <  DATE '1993-10-01' + INTERVAL '3' MONTH
    AND l.l_returnflag = 'R'
    AND c.c_nationkey = n.n_nationkey
GROUP BY
    c.c_custkey,
    c.c_name,
    c.c_acctbal,
    c.c_phone,
    n.n_name,
    c.c_address,
    c.c_comment
ORDER BY
    revenue DESC;

-- 11
SELECT
    ps.ps_partkey,
    SUM(ps.ps_supplycost * ps.ps_availqty) AS value
FROM
    system.partsupp ps,
    system.supplier s,
    system.nation n
WHERE
        ps.ps_suppkey = s.s_suppkey
    AND s.s_nationkey = n.n_nationkey
    AND n.n_name = 'GERMANY'
GROUP BY
    ps.ps_partkey
HAVING
    SUM(ps.ps_supplycost * ps.ps_availqty) > (
        SELECT
            SUM(ps2.ps_supplycost * ps2.ps_availqty) * 0.0001
        FROM
            system.partsupp ps2,
            system.supplier s2,
            system.nation n2
        WHERE
                ps2.ps_suppkey = s2.s_suppkey
            AND s2.s_nationkey = n2.n_nationkey
            AND n2.n_name = 'GERMANY'
    )
ORDER BY
    value DESC;

-- 12
SELECT
    l_shipmode,
    SUM(CASE
            WHEN o_orderpriority = '1-URGENT'
              OR o_orderpriority = '2-HIGH'
            THEN 1
            ELSE 0
        END) AS high_line_count,
    SUM(CASE
            WHEN o_orderpriority <> '1-URGENT'
              AND o_orderpriority <> '2-HIGH'
            THEN 1
            ELSE 0
        END) AS low_line_count
FROM
    system.orders o,
    system.lineitem l
WHERE
        o.o_orderkey = l.l_orderkey
    AND l.l_shipmode IN ('MAIL', 'SHIP')
    AND l.l_commitdate < l.l_receiptdate
    AND l.l_shipdate < l.l_commitdate
    AND l.l_receiptdate >= DATE '1994-01-01'
    AND l.l_receiptdate < DATE '1994-01-01' + INTERVAL '1' YEAR
GROUP BY
    l_shipmode
ORDER BY
    l_shipmode;

-- 13
SELECT
    c_count,
    COUNT(*) AS custdist
FROM (
    SELECT
        c.c_custkey,
        COUNT(o.o_orderkey) AS c_count
    FROM
        system.customer c
        LEFT OUTER JOIN system.orders o
            ON c.c_custkey = o.o_custkey
           AND o.o_comment NOT LIKE '%special%requests%'
    GROUP BY
        c.c_custkey
) c_orders
GROUP BY
    c_count
ORDER BY
    custdist DESC,
    c_count DESC;

-- 14
SELECT
    100.00 * SUM(
        CASE
            WHEN p.p_type LIKE 'PROMO%'
            THEN l.l_extendedprice * (1 - l.l_discount)
            ELSE 0
        END
    ) / SUM(l.l_extendedprice * (1 - l.l_discount)) AS promo_revenue
FROM
    system.lineitem l,
    system.part p
WHERE
        l.l_partkey = p.p_partkey
    AND l.l_shipdate >= DATE '1995-09-01'
    AND l.l_shipdate < DATE '1995-09-01' + INTERVAL '1' MONTH;

-- 15
CREATE OR REPLACE VIEW revenue_stream AS
SELECT
    l.l_suppkey AS supplier_no,
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS total_revenue
FROM
    system.lineitem l
WHERE
        l.l_shipdate >= DATE '1996-01-01'
    AND l.l_shipdate < DATE '1996-01-01' + INTERVAL '3' MONTH
GROUP BY
    l.l_suppkey;

SELECT
    s.s_suppkey,
    s.s_name,
    s.s_address,
    s.s_phone,
    r.total_revenue
FROM
    system.supplier s,
    revenue_stream r
WHERE
        s.s_suppkey = r.supplier_no
    AND r.total_revenue = (
        SELECT MAX(total_revenue)
        FROM revenue_stream
    )
ORDER BY
    s.s_suppkey;

DROP VIEW revenue_stream;

-- 16
SELECT
    p.p_brand,
    p.p_type,
    p.p_size,
    COUNT(DISTINCT ps.ps_suppkey) AS supplier_cnt
FROM
    system.partsupp ps,
    system.part p
WHERE
        p.p_partkey = ps.ps_partkey
    AND p.p_brand <> 'Brand#45'
    AND p.p_type NOT LIKE 'MEDIUM POLISHED%'
    AND p.p_size IN (49, 14, 23, 45, 19, 3, 36, 9)
    AND ps.ps_suppkey NOT IN (
        SELECT s.s_suppkey
        FROM system.supplier s
        WHERE s.s_comment LIKE '%Customer%Complaints%'
    )
GROUP BY
    p.p_brand,
    p.p_type,
    p.p_size
ORDER BY
    supplier_cnt DESC,
    p.p_brand,
    p.p_type,
    p.p_size;

-- 17
SELECT
    SUM(l.l_extendedprice) / 7.0 AS avg_yearly
FROM
    system.lineitem l,
    system.part p
WHERE
        p.p_partkey = l.l_partkey
    AND p.p_brand = 'Brand#23'
    AND p.p_container = 'MED BOX'
    AND l.l_quantity < (
        SELECT
            0.2 * AVG(l2.l_quantity)
        FROM
            system.lineitem l2
        WHERE
            l2.l_partkey = p.p_partkey
    );

-- 18
SELECT
    c.c_name,
    c.c_custkey,
    o.o_orderkey,
    o.o_orderdate,
    o.o_totalprice,
    SUM(l.l_quantity) AS sum_qty
FROM
    system.customer c,
    system.orders o,
    system.lineitem l
WHERE
        o.o_orderkey IN (
            SELECT l2.l_orderkey
            FROM system.lineitem l2
            GROUP BY l2.l_orderkey
            HAVING SUM(l2.l_quantity) > 300
        )
    AND c.c_custkey = o.o_custkey
    AND o.o_orderkey = l.l_orderkey
GROUP BY
    c.c_name,
    c.c_custkey,
    o.o_orderkey,
    o.o_orderdate,
    o.o_totalprice
ORDER BY
    c.c_name,
    c.c_custkey,
    o.o_orderkey,
    o.o_orderdate,
    o.o_totalprice DESC,
    o.o_orderdate;

-- 19
SELECT
    SUM(l.l_extendedprice * (1 - l.l_discount)) AS revenue
FROM
    system.lineitem l,
    system.part p
WHERE
        (
            p.p_partkey = l.l_partkey
            AND p.p_brand = 'Brand#12'
            AND p.p_container IN ('SM CASE', 'SM BOX', 'SM PACK', 'SM PKG')
            AND l.l_quantity BETWEEN 1 AND 11
            AND p.p_size BETWEEN 1 AND 5
            AND l.l_shipmode IN ('AIR', 'AIR REG')
            AND l.l_shipinstruct = 'DELIVER IN PERSON'
        )
    OR
        (
            p.p_partkey = l.l_partkey
            AND p.p_brand = 'Brand#23'
            AND p.p_container IN ('MED BAG', 'MED BOX', 'MED PKG', 'MED PACK')
            AND l.l_quantity BETWEEN 10 AND 20
            AND p.p_size BETWEEN 1 AND 10
            AND l.l_shipmode IN ('AIR', 'AIR REG')
            AND l.l_shipinstruct = 'DELIVER IN PERSON'
        )
    OR
        (
            p.p_partkey = l.l_partkey
            AND p.p_brand = 'Brand#34'
            AND p.p_container IN ('LG CASE', 'LG BOX', 'LG PACK', 'LG PKG')
            AND l.l_quantity BETWEEN 20 AND 30
            AND p.p_size BETWEEN 1 AND 15
            AND l.l_shipmode IN ('AIR', 'AIR REG')
            AND l.l_shipinstruct = 'DELIVER IN PERSON'
        );

-- 20
SELECT
    s.s_name,
    s.s_address
FROM
    system.supplier s,
    system.nation n
WHERE
        s.s_suppkey IN (
            SELECT
                ps.ps_suppkey
            FROM
                system.partsupp ps
            WHERE
                    ps.ps_partkey IN (
                        SELECT p.p_partkey
                        FROM system.part p
                        WHERE p.p_name LIKE 'forest%'
                    )
                AND ps.ps_availqty > (
                    SELECT
                        0.5 * SUM(l.l_quantity)
                    FROM
                        system.lineitem l
                    WHERE
                            l.l_partkey = ps.ps_partkey
                        AND l.l_suppkey = ps.ps_suppkey
                        AND l.l_shipdate >= DATE '1994-01-01'
                        AND l.l_shipdate < DATE '1994-01-01' + INTERVAL '1' YEAR
                )
        )
    AND s.s_nationkey = n.n_nationkey
    AND n.n_name = 'CANADA'
ORDER BY
    s.s_name,
    s.s_address;

-- 21
SELECT
    s.s_name,
    COUNT(*) AS numwait
FROM
    system.supplier s,
    system.lineitem l1,
    system.orders o,
    system.nation n
WHERE
        s.s_suppkey = l1.l_suppkey
    AND o.o_orderkey = l1.l_orderkey
    AND o.o_orderstatus = 'F'
    AND l1.l_receiptdate > l1.l_commitdate
    AND EXISTS (
        SELECT *
        FROM system.lineitem l2
        WHERE l2.l_orderkey = l1.l_orderkey
          AND l2.l_suppkey <> l1.l_suppkey
    )
    AND NOT EXISTS (
        SELECT *
        FROM system.lineitem l3
        WHERE l3.l_orderkey = l1.l_orderkey
          AND l3.l_suppkey <> l1.l_suppkey
          AND l3.l_receiptdate > l3.l_commitdate
    )
    AND s.s_nationkey = n.n_nationkey
    AND n.n_name = 'SAUDI ARABIA'
GROUP BY
    s.s_name
ORDER BY
    numwait DESC,
    s.s_name;

-- 22
SELECT
    cntrycode,
    COUNT(*) AS numcust,
    SUM(c_acctbal) AS totacctbal
FROM (
    SELECT
        SUBSTR(c.c_phone, 1, 2) AS cntrycode,
        c.c_acctbal
    FROM
        system.customer c
    WHERE
            SUBSTR(c.c_phone, 1, 2) IN ('13','31','23','29','30','18','17')
        AND c.c_acctbal > (
            SELECT AVG(c2.c_acctbal)
            FROM system.customer c2
            WHERE c2.c_acctbal > 0.00
              AND SUBSTR(c2.c_phone,1,2) IN ('13','31','23','29','30','18','17')
        )
        AND NOT EXISTS (
            SELECT *
            FROM system.orders o
            WHERE o.o_custkey = c.c_custkey
        )
) custsale
GROUP BY
    cntrycode
ORDER BY
    cntrycode;
