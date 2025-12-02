CREATE INDEX idx_li_order_supp ON system.lineitem(l_orderkey, l_suppkey);
CREATE INDEX idx_o_custkey ON system.orders(o_custkey);
CREATE INDEX idx_customer_cust_nation ON system.customer(c_custkey, c_nationkey);
CREATE BITMAP INDEX idx_cust_nation ON system.customer(c_nationkey);
CREATE INDEX idx_ps_suppkey_partkey ON system.partsupp(ps_suppkey, ps_partkey);
CREATE INDEX idx_ps_partkey_supplycost ON system.partsupp(ps_partkey, ps_supplycost);
CREATE INDEX idx_part_type_upper ON system.part(UPPER(p_type));

-- LINEITEM P11
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'LINEITEM',
        policy_name     => 'LINEITEM_POLICY_K',
        function_schema => 'SYSTEM',
        policy_function => 'LINEITEM_POLICY_FN11',
        statement_types => 'SELECT',
        update_check    => FALSE,
        enable          => TRUE,
        static_policy   => FALSE,
        long_predicate  => FALSE 
    );
END;
/

-- ORDERS P13
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'ORDERS',
        policy_name     => 'ORDERS_POLICY_K',
        function_schema => 'SYSTEM',
        policy_function => 'ORDERS_POLICY_FN2',
        statement_types => 'SELECT',
        update_check    => FALSE,
        enable          => TRUE,
        static_policy   => FALSE,
        long_predicate  => FALSE
    );
END;
/

-- CUSTOMER P14
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'CUSTOMER',
        policy_name     => 'CUSTOMER_POLICY_K',
        function_schema => 'SYSTEM',
        policy_function => 'CUSTOMER_POLICY_FN1',
        statement_types => 'SELECT',
        update_check    => FALSE,
        enable          => TRUE,
        static_policy   => FALSE,
        long_predicate  => FALSE
    );
END;
/

-- SUPPLIER P18
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'SUPPLIER',
        policy_name     => 'SUPPLIER_POLICY_K',
        function_schema => 'SYSTEM',
        policy_function => 'SUPPLIER_POLICY_FN1',
        statement_types => 'SELECT',
        update_check    => FALSE,
        enable          => TRUE,
        static_policy   => FALSE,
        long_predicate  => FALSE
    );
END;
/

-- PART P20
BEGIN
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'PART',
        policy_name     => 'PART_POLICY_K',
        function_schema => 'SYSTEM',
        policy_function => 'PART_POLICY_FN2',
        statement_types => 'SELECT',
        update_check    => FALSE,
        enable          => TRUE,
        static_policy   => FALSE,
        long_predicate  => FALSE
    );
END;
/

BEGIN
    -- LINEITEM
    BEGIN
        DBMS_RLS.DROP_POLICY(
            object_schema => 'SYSTEM',
            object_name   => 'LINEITEM',
            policy_name   => 'LINEITEM_POLICY_K'
        );
    EXCEPTION WHEN OTHERS THEN NULL; END;

    -- ORDERS
    BEGIN
        DBMS_RLS.DROP_POLICY(
            object_schema => 'SYSTEM',
            object_name   => 'ORDERS',
            policy_name   => 'ORDERS_POLICY_K'
        );
    EXCEPTION WHEN OTHERS THEN NULL; END;

    -- CUSTOMER
    BEGIN
        DBMS_RLS.DROP_POLICY(
            object_schema => 'SYSTEM',
            object_name   => 'CUSTOMER',
            policy_name   => 'CUSTOMER_POLICY_K'
        );
    EXCEPTION WHEN OTHERS THEN NULL; END;

    -- SUPPLIER
    BEGIN
        DBMS_RLS.DROP_POLICY(
            object_schema => 'SYSTEM',
            object_name   => 'SUPPLIER',
            policy_name   => 'SUPPLIER_POLICY_K'
        );
    EXCEPTION WHEN OTHERS THEN NULL; END;

    -- PART
    BEGIN
        DBMS_RLS.DROP_POLICY(
            object_schema => 'SYSTEM',
            object_name   => 'PART',
            policy_name   => 'PART_POLICY_K'
        );
    EXCEPTION WHEN OTHERS THEN NULL; END;
END;
/

DROP INDEX idx_li_order_supp;
DROP INDEX idx_o_custkey;
DROP INDEX idx_customer_cust_nation;
DROP INDEX idx_cust_nation;
DROP INDEX idx_ps_suppkey_partkey;
DROP INDEX idx_ps_partkey_supplycost;
DROP INDEX idx_part_type_upper;