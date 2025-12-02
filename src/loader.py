import duckdb
import pandas as pd
import oracledb
from tqdm import tqdm

SCALE_FACTOR = 1              
DUCK_PATH = "tpch.duckdb"     
USER = "system"
PWD = ""
DSN = "localhost/FREEPDB1"    
BATCH_SIZE = 5000            

con = duckdb.connect(DUCK_PATH)
con.execute("INSTALL tpch; LOAD tpch;")
print(f"Generating TPC-H schema and data (scale = {SCALE_FACTOR})...")
con.execute(f"CALL dbgen(sf={SCALE_FACTOR});")

tables = [t[0] for t in con.execute("SHOW TABLES").fetchall()]
print("Generated tables:", tables)
load_order = [
    "region",
    "nation",
    "part",
    "supplier",
    "partsupp",
    "customer",
    "orders",
    "lineitem"
]
tables=load_order
for t in tqdm(tables, desc="Exporting from DuckDB"):
    con.execute(f"COPY {t} TO '{t}.parquet' (FORMAT PARQUET);")

con.close()

conn = oracledb.connect(user=USER, password=PWD, dsn=DSN)
cur = conn.cursor()

schema_statements = [

# REGION
"""
CREATE TABLE REGION (
    R_REGIONKEY NUMBER(10) NOT NULL,
    R_NAME      CHAR(25) NOT NULL,
    R_COMMENT   VARCHAR2(152),
    CONSTRAINT PK_REGION PRIMARY KEY (R_REGIONKEY)
)
""",

# NATION
"""
CREATE TABLE NATION (
    N_NATIONKEY NUMBER(10) NOT NULL,
    N_NAME      CHAR(25) NOT NULL,
    N_REGIONKEY NUMBER(10) NOT NULL,
    N_COMMENT   VARCHAR2(152),
    CONSTRAINT PK_NATION PRIMARY KEY (N_NATIONKEY),
    CONSTRAINT FK_NATION_REGION FOREIGN KEY (N_REGIONKEY) REFERENCES REGION(R_REGIONKEY)
)
""",

# PART
"""
CREATE TABLE PART (
    P_PARTKEY     NUMBER(10) NOT NULL,
    P_NAME        VARCHAR2(55) NOT NULL,
    P_MFGR        CHAR(25) NOT NULL,
    P_BRAND       CHAR(10) NOT NULL,
    P_TYPE        VARCHAR2(25) NOT NULL,
    P_SIZE        NUMBER(10) NOT NULL,
    P_CONTAINER   CHAR(10) NOT NULL,
    P_RETAILPRICE NUMBER(12,2) NOT NULL,
    P_COMMENT     VARCHAR2(23) NOT NULL,
    CONSTRAINT PK_PART PRIMARY KEY (P_PARTKEY)
)
""",

# SUPPLIER
"""
CREATE TABLE SUPPLIER (
    S_SUPPKEY   NUMBER(10) NOT NULL,
    S_NAME      CHAR(25) NOT NULL,
    S_ADDRESS   VARCHAR2(40) NOT NULL,
    S_NATIONKEY NUMBER(10) NOT NULL,
    S_PHONE     CHAR(15) NOT NULL,
    S_ACCTBAL   NUMBER(12,2) NOT NULL,
    S_COMMENT   VARCHAR2(101) NOT NULL,
    CONSTRAINT PK_SUPPLIER PRIMARY KEY (S_SUPPKEY),
    CONSTRAINT FK_SUPPLIER_NATION FOREIGN KEY (S_NATIONKEY) REFERENCES NATION(N_NATIONKEY)
)
""",

# PARTSUPP
"""
CREATE TABLE PARTSUPP (
    PS_PARTKEY   NUMBER(10) NOT NULL,
    PS_SUPPKEY   NUMBER(10) NOT NULL,
    PS_AVAILQTY  NUMBER(10) NOT NULL,
    PS_SUPPLYCOST NUMBER(12,2) NOT NULL,
    PS_COMMENT   VARCHAR2(199) NOT NULL,
    CONSTRAINT PK_PARTSUPP PRIMARY KEY (PS_PARTKEY, PS_SUPPKEY),
    CONSTRAINT FK_PARTSUPP_PART FOREIGN KEY (PS_PARTKEY) REFERENCES PART(P_PARTKEY),
    CONSTRAINT FK_PARTSUPP_SUPPLIER FOREIGN KEY (PS_SUPPKEY) REFERENCES SUPPLIER(S_SUPPKEY)
)
""",

# CUSTOMER
"""
CREATE TABLE CUSTOMER (
    C_CUSTKEY   NUMBER(10) NOT NULL,
    C_NAME      VARCHAR2(25) NOT NULL,
    C_ADDRESS   VARCHAR2(40) NOT NULL,
    C_NATIONKEY NUMBER(10) NOT NULL,
    C_PHONE     CHAR(15) NOT NULL,
    C_ACCTBAL   NUMBER(12,2) NOT NULL,
    C_MKTSEGMENT CHAR(10),
    C_COMMENT   VARCHAR2(117) NOT NULL,
    CONSTRAINT PK_CUSTOMER PRIMARY KEY (C_CUSTKEY),
    CONSTRAINT FK_CUSTOMER_NATION FOREIGN KEY (C_NATIONKEY) REFERENCES NATION(N_NATIONKEY)
)
""",

# ORDERS
"""
CREATE TABLE ORDERS (
    O_ORDERKEY      NUMBER(10) NOT NULL,
    O_CUSTKEY       NUMBER(10) NOT NULL,
    O_ORDERSTATUS   CHAR(1) NOT NULL,
    O_TOTALPRICE    NUMBER(12,2) NOT NULL,
    O_ORDERDATE     DATE NOT NULL,
    O_ORDERPRIORITY CHAR(15) NOT NULL,
    O_CLERK         CHAR(15) NOT NULL,
    O_SHIPPRIORITY  NUMBER(10) NOT NULL,
    O_COMMENT       VARCHAR2(79) NOT NULL,
    CONSTRAINT PK_ORDERS PRIMARY KEY (O_ORDERKEY),
    CONSTRAINT FK_ORDERS_CUSTOMER FOREIGN KEY (O_CUSTKEY) REFERENCES CUSTOMER(C_CUSTKEY)
)
""",

# LINEITEM
"""
CREATE TABLE LINEITEM (
    L_ORDERKEY    NUMBER(10) NOT NULL,
    L_PARTKEY     NUMBER(10) NOT NULL,
    L_SUPPKEY     NUMBER(10) NOT NULL,
    L_LINENUMBER  NUMBER(10) NOT NULL,
    L_QUANTITY    NUMBER(12,2) NOT NULL,
    L_EXTENDEDPRICE NUMBER(12,2) NOT NULL,
    L_DISCOUNT    NUMBER(12,2) NOT NULL,
    L_TAX         NUMBER(12,2) NOT NULL,
    L_RETURNFLAG  CHAR(1) NOT NULL,
    L_LINESTATUS  CHAR(1) NOT NULL,
    L_SHIPDATE    DATE NOT NULL,
    L_COMMITDATE  DATE NOT NULL,
    L_RECEIPTDATE DATE NOT NULL,
    L_SHIPINSTRUCT CHAR(25) NOT NULL,
    L_SHIPMODE    CHAR(10) NOT NULL,
    L_COMMENT     VARCHAR2(44) NOT NULL,
    CONSTRAINT PK_LINEITEM PRIMARY KEY (L_ORDERKEY, L_LINENUMBER),
    CONSTRAINT FK_LINEITEM_ORDERS FOREIGN KEY (L_ORDERKEY) REFERENCES ORDERS(O_ORDERKEY),
    CONSTRAINT FK_LINEITEM_PARTSUPP FOREIGN KEY (L_PARTKEY, L_SUPPKEY) REFERENCES PARTSUPP(PS_PARTKEY, PS_SUPPKEY)
)
"""
]

for stmt in schema_statements:
    try:
        cur.execute(stmt)
        print("Created table")
    except oracledb.DatabaseError as e:
        if "ORA-00955" in str(e):
            print("Table already exists")
        else:
            raise

for t in tables:
    df = pd.read_parquet(f"{t}.parquet")
    columns = df.columns.tolist()
    placeholders = ",".join([f":{i+1}" for i in range(len(columns))])
    insert_sql = f"INSERT INTO {t.upper()} VALUES ({placeholders})"
    rows = df.values.tolist()

    for i in tqdm(range(0, len(rows), BATCH_SIZE), desc=f"Loading {t}"):
        end = min(i + BATCH_SIZE, len(rows))
        cur.executemany(insert_sql, rows[i:end])
        conn.commit()


cur.close()
conn.close()
print("TPC-H 1 GB successfully loaded into Oracle with exact schema.")
