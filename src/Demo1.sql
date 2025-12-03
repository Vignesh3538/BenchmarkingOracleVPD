-- Enable P11 to P20 and run queries and disable them one by one
-- Create indices

CREATE BITMAP INDEX idx_cust_nation ON customer (c_nationkey);
CREATE INDEX idx_cust_ord
ON orders (o_custkey, o_orderkey);
CREATE INDEX idx_li_order_supp
    ON system.lineitem (l_orderkey, l_suppkey);
CREATE INDEX idx_ps_suppkey_partkey
    ON SYSTEM.PARTSUPP(ps_suppkey, ps_partkey);
CREATE INDEX idx_ps_partkey_supplycost
    ON SYSTEM.PARTSUPP(ps_partkey, ps_supplycost);
CREATE INDEX idx_ps_partkey ON SYSTEM.PARTSUPP(ps_partkey);
CREATE INDEX idx_o_custkey
    ON system.orders (o_custkey);

-- Enable P11 to P20 and run queries and disable them one by one
-- Drop indices
DROP INDEX idx_cust_nation;
DROP INDEX idx_cust_ord;
DROP INDEX idx_li_order_supp;
DROP INDEX idx_ps_suppkey_partkey;
DROP INDEX idx_ps_partkey_supplycost;
DROP INDEX idx_ps_partkey;
DROP INDEX idx_o_custkey;
