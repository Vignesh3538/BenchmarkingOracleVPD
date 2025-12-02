CREATE INDEX idx_li_order ON system.lineitem(l_orderkey);
CREATE INDEX idx_orders_cust_date ON system.orders(o_custkey, o_orderdate);
CREATE INDEX idx_orders_cust_status ON system.orders(o_custkey, o_orderstatus);
CREATE INDEX idx_ps_part ON system.partsupp(ps_partkey);
CREATE INDEX idx_ps_supp ON system.partsupp(ps_suppkey);
CREATE INDEX idx_supplier_nation ON system.supplier(s_nationkey);


BEGIN
    -- ORDERS POLICY_FN1
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'ORDERS',
        policy_name     => 'ORDERS_POLICY_M1',
        function_schema => 'SYSTEM',
        policy_function => 'ORDERS_POLICY_FN1',
        statement_types => 'SELECT',
        update_check    => FALSE,
        enable          => TRUE,
        static_policy   => FALSE,
        long_predicate  => FALSE
    );

    -- CUSTOMER POLICY_FN2
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'CUSTOMER',
        policy_name     => 'CUSTOMER_POLICY_M1',
        function_schema => 'SYSTEM',
        policy_function => 'CUSTOMER_POLICY_FN2',
        statement_types => 'SELECT',
        update_check    => FALSE,
        enable          => TRUE,
        static_policy   => FALSE,
        long_predicate  => FALSE
    );

    -- CUSTOMER POLICY_FN3
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'CUSTOMER',
        policy_name     => 'CUSTOMER_POLICY_M2',
        function_schema => 'SYSTEM',
        policy_function => 'CUSTOMER_POLICY_FN3',
        statement_types => 'SELECT',
        update_check    => FALSE,
        enable          => TRUE,
        static_policy   => FALSE,
        long_predicate  => FALSE
    );

    -- PART POLICY_FN1
    DBMS_RLS.ADD_POLICY(
        object_schema   => 'SYSTEM',
        object_name     => 'PART',
        policy_name     => 'PART_POLICY_M1',
        function_schema => 'SYSTEM',
        policy_function => 'PART_POLICY_FN1',
        statement_types => 'SELECT',
        update_check    => FALSE,
        enable          => TRUE,
        static_policy   => FALSE,
        long_predicate  => FALSE
    );
END;
/

BEGIN
        DBMS_RLS.DROP_POLICY(
            object_schema => 'SYSTEM',
            object_name   => 'ORDERS',
            policy_name   => 'ORDERS_POLICY_M1'
        );
    EXCEPTION WHEN OTHERS THEN NULL; END;
/
  
    BEGIN
        DBMS_RLS.DROP_POLICY(
            object_schema => 'SYSTEM',
            object_name   => 'CUSTOMER',
            policy_name   => 'CUSTOMER_POLICY_M2'
        );
    EXCEPTION WHEN OTHERS THEN NULL; END;
/
   
    BEGIN
        DBMS_RLS.DROP_POLICY(
            object_schema => 'SYSTEM',
            object_name   => 'PART',
            policy_name   => 'PART_POLICY_M1'
        );
    EXCEPTION WHEN OTHERS THEN NULL; END;
/

BEGIN
        DBMS_RLS.DROP_POLICY(
            object_schema => 'SYSTEM',
            object_name   => 'CUSTOMER',
            policy_name   => 'CUSTOMER_POLICY_M1'
        );
    EXCEPTION WHEN OTHERS THEN NULL; END;
/



DROP INDEX idx_li_order ;
DROP INDEX idx_orders_cust_date ;
DROP INDEX idx_orders_cust_status ;
DROP INDEX idx_ps_part ;
DROP INDEX idx_ps_supp;
DROP INDEX idx_supplier_nation;

