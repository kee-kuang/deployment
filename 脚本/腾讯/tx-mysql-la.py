import pymysql
import traceback
import time

# ================== 配置区 ==================
MYSQL_HOST = "gz-cdb-bh67xl30.sql.tencentcdb.com"
MYSQL_PORT = 21656
MYSQL_USER = "root"
MYSQL_PASSWORD = "jikp6OYL9iKBQ5Xb@"

SOURCE_DBS = [
    "big_admin",
    "cid_data",
    "cid_data_hour",
    "crm_data",
    "erp_data",
    "sucai_cms",
    "sucai_hw_cms",
    "sucai_oss",
    "sucai_other_cms",
]

TARGET_PREFIX = "test_"

BIG_TABLE_ROWS = 100_000
BIG_TABLE_SYNC_LIMIT = 50_000
SMALL_TABLE_SAFE_LIMIT = 1_000_000
# ===========================================


def get_target_db(source_db):
    if source_db.startswith(TARGET_PREFIX):
        raise RuntimeError(f"SOURCE_DB 非法（已是 test 库）: {source_db}")
    return f"{TARGET_PREFIX}{source_db}"


def get_conn():
    return pymysql.connect(
        host=MYSQL_HOST,
        port=MYSQL_PORT,
        user=MYSQL_USER,
        password=MYSQL_PASSWORD,
        charset="utf8mb4",
        autocommit=False,
        read_timeout=120,
        write_timeout=120,
    )


def get_tables(cursor, db):
    cursor.execute(f"SHOW TABLES FROM `{db}`")
    return [row[0] for row in cursor.fetchall()]


def get_table_rows(cursor, db, table):
    cursor.execute("""
        SELECT TABLE_ROWS
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA=%s AND TABLE_NAME=%s
    """, (db, table))
    r = cursor.fetchone()
    return r[0] if r and r[0] else 0


def get_writable_columns(cursor, db, table):
    cursor.execute("""
        SELECT COLUMN_NAME
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA=%s
          AND TABLE_NAME=%s
          AND EXTRA NOT LIKE '%%GENERATED%%'
        ORDER BY ORDINAL_POSITION
    """, (db, table))
    return [r[0] for r in cursor.fetchall()]


def create_table_if_not_exists(cursor, source_db, target_db, table):
    print(f"    ⏳ SHOW CREATE TABLE {table}")
    cursor.execute(f"SHOW CREATE TABLE `{source_db}`.`{table}`")
    create_sql = cursor.fetchone()[1]
    create_sql = create_sql.replace(
        f"CREATE TABLE `{table}`",
        f"CREATE TABLE IF NOT EXISTS `{target_db}`.`{table}`"
    )
    cursor.execute(create_sql)


def truncate_table(cursor, target_db, table):
    cursor.execute(f"TRUNCATE TABLE `{target_db}`.`{table}`")


def get_order_by_clause(cursor, db, table):
    """
    优先级：
    1. AUTO_INCREMENT
    2. PRIMARY KEY
    3. 无 ORDER BY（退化）
    """
    cursor.execute("""
        SELECT COLUMN_NAME, EXTRA
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA=%s AND TABLE_NAME=%s
        ORDER BY ORDINAL_POSITION
    """, (db, table))

    auto_inc = None
    pk = None

    for col, extra in cursor.fetchall():
        if "auto_increment" in extra:
            auto_inc = col
            break

    if auto_inc:
        return f"ORDER BY `{auto_inc}` DESC"

    cursor.execute("""
        SELECT COLUMN_NAME
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA=%s AND TABLE_NAME=%s AND CONSTRAINT_NAME='PRIMARY'
        ORDER BY ORDINAL_POSITION
        LIMIT 1
    """, (db, table))

    r = cursor.fetchone()
    if r:
        return f"ORDER BY `{r[0]}` DESC"

    return ""


def sync_table(cursor, source_db, target_db, table, rows):
    cols = get_writable_columns(cursor, source_db, table)
    if not cols:
        print(f"    ⚠️ 无可写字段，跳过")
        return

    col_list = ",".join(f"`{c}`" for c in cols)
    order_by = get_order_by_clause(cursor, source_db, table)

    if rows >= BIG_TABLE_ROWS:
        limit = BIG_TABLE_SYNC_LIMIT
        print(f"    📦 大表：同步最后 {limit} 条")
    else:
        limit = SMALL_TABLE_SAFE_LIMIT
        print(f"    📦 小表：全量同步（上限 {limit}）")

    sql = f"""
        INSERT INTO `{target_db}`.`{table}` ({col_list})
        SELECT {col_list}
        FROM `{source_db}`.`{table}`
        {order_by}
        LIMIT {limit}
    """
    cursor.execute(sql)


def sync_database(source_db):
    target_db = get_target_db(source_db)

    conn = get_conn()
    cursor = conn.cursor()

    try:
        print(f"\n📦 同步数据库 {source_db} → {target_db}")

        cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{target_db}`")

        cursor.execute("""
            SET SESSION sql_mode =
            REPLACE(
              REPLACE(@@sql_mode, 'NO_ZERO_DATE', ''),
              'NO_ZERO_IN_DATE', ''
            )
        """)
        cursor.execute("SET FOREIGN_KEY_CHECKS=0")

        tables = get_tables(cursor, source_db)
        print(f"  📊 共 {len(tables)} 张表")

        for table in tables:
            print(f"  ▶ 表: {table}")
            try:
                rows = get_table_rows(cursor, source_db, table)
                print(f"    行数估算: {rows}")

                create_table_if_not_exists(cursor, source_db, target_db, table)
                truncate_table(cursor, target_db, table)
                sync_table(cursor, source_db, target_db, table, rows)

                conn.commit()
                print(f"    ✅ 表完成")

            except Exception as e:
                conn.rollback()
                print(f"    ❌ 表失败，已跳过: {e}")
                traceback.print_exc()

    finally:
        try:
            cursor.execute("SET FOREIGN_KEY_CHECKS=1")
        except:
            pass
        cursor.close()
        conn.close()


def main():
    start = time.time()

    for source_db in SOURCE_DBS:
        try:
            sync_database(source_db)
        except Exception as e:
            print(f"\n❌ 数据库失败，已跳过: {source_db}")
            traceback.print_exc()

    print(f"\n🎉 全部完成，用时 {int(time.time() - start)} 秒")


if __name__ == "__main__":
    main()
