
CREATE INDEX idx_customer_cust_nation 
ON system.customer (c_custkey, c_nationkey);
CREATE INDEX idx_customer_name_nation 
ON system.customer (c_name, c_nationkey);
CREATE INDEX idx_li_supp_part_order 
ON system.lineitem (l_suppkey, l_partkey, l_orderkey);
CREATE INDEX idx_li_supp_part ON system.lineitem(l_suppkey, l_partkey);
CREATE INDEX idx_nation_region ON system.nation(n_regionkey);
CREATE INDEX idx_li_part_supp ON system.lineitem(l_partkey, l_suppkey);
CREATE INDEX idx_ord_cust 
ON orders (o_orderkey, o_custkey);
CREATE INDEX idx_nation_region ON system.nation(n_regionkey);
CREATE BITMAP INDEX idx_cust_nation ON customer (c_nationkey);
CREATE BITMAP INDEX idx_supp_nation ON supplier (s_nationkey);
CREATE INDEX idx_li_supp_order
    ON system.lineitem (l_suppkey, l_orderkey);



--Q5
SELECT
    n_outer.n_name,
    SUM(li_outer.l_extendedprice * (1 - li_outer.l_discount)) AS revenue
FROM
    system.customer  c_outer,
    system.orders    o_outer,
    system.lineitem  li_outer,
    system.supplier  s_outer,
    system.nation    n_outer,
    system.region    r_outer
WHERE
        c_outer.c_custkey   = o_outer.o_custkey
    AND li_outer.l_orderkey = o_outer.o_orderkey
    AND li_outer.l_suppkey  = s_outer.s_suppkey
    AND c_outer.c_nationkey = s_outer.s_nationkey
    AND s_outer.s_nationkey = n_outer.n_nationkey
    AND n_outer.n_regionkey = r_outer.r_regionkey
    AND r_outer.r_name = 'ASIA'
    AND o_outer.o_orderdate >= DATE '1994-01-01'
    AND o_outer.o_orderdate <  DATE '1994-01-01' + INTERVAL '1' YEAR
    AND
    (
        (
            (
                SELECT COUNT(*)
                FROM system.lineitem li_inner
                JOIN system.orders   o_inner ON li_inner.l_orderkey = o_inner.o_orderkey
                JOIN system.customer c_inner ON o_inner.o_custkey   = c_inner.c_custkey
                JOIN system.nation   n_inner ON c_inner.c_nationkey = n_inner.n_nationkey
                JOIN system.region   r_inner ON n_inner.n_regionkey = r_inner.r_regionkey
                WHERE li_inner.l_suppkey = li_outer.l_suppkey
                  AND li_inner.l_partkey = li_outer.l_partkey
                  AND r_inner.r_regionkey = (
                        SELECT r2.r_regionkey
                        FROM system.customer me
                        JOIN system.nation  n2 ON me.c_nationkey = n2.n_nationkey
                        JOIN system.region r2 ON n2.n_regionkey = r2.r_regionkey
                        WHERE me.c_name = 'Customer#000001111'
                  )
            )
            >=
            0.20 *
            (
                SELECT COUNT(*)
                FROM system.lineitem li2
                WHERE li2.l_suppkey = li_outer.l_suppkey
                  AND li2.l_partkey = li_outer.l_partkey
            )
        )
        OR
        (
            li_outer.l_extendedprice * (1 - li_outer.l_discount)
            BETWEEN 20000 AND 200000
        )
    )
GROUP BY
    n_outer.n_name
ORDER BY
    revenue DESC;


--Q14
SELECT
    100.00 * SUM(
        CASE
            WHEN p.p_type LIKE 'PROMO%'
            THEN li_outer.l_extendedprice * (1 - li_outer.l_discount)
            ELSE 0
        END
    ) / SUM(li_outer.l_extendedprice * (1 - li_outer.l_discount)) AS promo_revenue
FROM
    system.lineitem li_outer,
    system.part p
WHERE
        li_outer.l_partkey = p.p_partkey
    AND li_outer.l_shipdate >= DATE '1995-09-01'
    AND li_outer.l_shipdate < DATE '1995-09-01' + INTERVAL '1' MONTH
    AND (
        (
            (
                SELECT COUNT(*)
                FROM system.lineitem li_inner
                JOIN system.orders o_inner ON li_inner.l_orderkey = o_inner.o_orderkey
                JOIN system.customer c_inner ON o_inner.o_custkey = c_inner.c_custkey
                JOIN system.nation n_inner ON c_inner.c_nationkey = n_inner.n_nationkey
                JOIN system.region r_inner ON n_inner.n_regionkey = r_inner.r_regionkey
                WHERE li_inner.l_suppkey = li_outer.l_suppkey
                  AND li_inner.l_partkey = li_outer.l_partkey
                  AND r_inner.r_regionkey = (
                        SELECT r2.r_regionkey
                        FROM system.customer me
                        JOIN system.nation n2 ON me.c_nationkey = n2.n_nationkey
                        JOIN system.region r2 ON n2.n_regionkey = r2.r_regionkey
                        WHERE me.c_name = 'Customer#000001111'
                  )
            ) >= 0.20 * (
                SELECT COUNT(*)
                FROM system.lineitem li2
                WHERE li2.l_suppkey = li_outer.l_suppkey
                  AND li2.l_partkey = li_outer.l_partkey
            )
        )
        OR
        (
            li_outer.l_extendedprice * (1 - li_outer.l_discount)
            BETWEEN 20000 AND 200000
        )
    );

--Q21
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
    AND (
        (
            (
                SELECT COUNT(*)
                FROM system.lineitem li_inner
                JOIN system.orders o_inner ON li_inner.l_orderkey = o_inner.o_orderkey
                JOIN system.customer c_inner ON o_inner.o_custkey = c_inner.c_custkey
                JOIN system.nation n_inner ON c_inner.c_nationkey = n_inner.n_nationkey
                JOIN system.region r_inner ON n_inner.n_regionkey = r_inner.r_regionkey
                WHERE li_inner.l_suppkey = l1.l_suppkey
                  AND li_inner.l_partkey = l1.l_partkey
                  AND r_inner.r_regionkey = (
                        SELECT r2.r_regionkey
                        FROM system.customer me
                        JOIN system.nation n2 ON me.c_nationkey = n2.n_nationkey
                        JOIN system.region r2 ON n2.n_regionkey = r2.r_regionkey
                        WHERE me.c_name = 'Customer#000001111'
                  )
            ) >= 0.20 * (
                SELECT COUNT(*)
                FROM system.lineitem li2
                WHERE li2.l_suppkey = l1.l_suppkey
                  AND li2.l_partkey = l1.l_partkey
            )
        )
        OR
        (
            l1.l_extendedprice * (1 - l1.l_discount)
            BETWEEN 20000 AND 200000
        )
    )
GROUP BY
    s.s_name
ORDER BY
    numwait DESC,
    s.s_name;

DROP INDEX idx_customer_cust_nation;
DROP INDEX idx_customer_name_nation;
DROP INDEX idx_li_supp_part_order;
DROP INDEX idx_li_supp_part;
DROP INDEX idx_nation_region;
DROP INDEX idx_li_part_supp;
DROP INDEX idx_ord_cust;
DROP INDEX idx_nation_region;
DROP INDEX idx_cust_nation; 
DROP INDEX idx_supp_nation; 
DROP INDEX idx_li_supp_order;
