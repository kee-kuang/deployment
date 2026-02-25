import pymysql
import traceback
import time

# ================== 配置区 ==================
MYSQL_HOST = "gz-cdb-bh67xl30.sql.tencentcdb.com"
MYSQL_PORT = 21656
MYSQL_USER = "root"
MYSQL_PASSWORD = "jikp6OYL9iKBQ5Xb@"

SOURCE_DB = "sucai_other_cms"
TARGET_DB = "test_sucai_other_cms"

BIG_TABLE_ROWS = 100_000
BIG_TABLE_SYNC_LIMIT = 50_000
SMALL_TABLE_SAFE_LIMIT = 300_000
# ===========================================


def get_conn():
    return pymysql.connect(
        host=MYSQL_HOST,
        port=MYSQL_PORT,
        user=MYSQL_USER,
        password=MYSQL_PASSWORD,
        charset="utf8mb4",
        autocommit=False
    )


def get_tables(cursor):
    cursor.execute(f"SHOW TABLES FROM `{SOURCE_DB}`")
    return [row[0] for row in cursor.fetchall()]


def get_table_rows(cursor, table):
    cursor.execute("""
        SELECT TABLE_ROWS
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA=%s AND TABLE_NAME=%s
    """, (SOURCE_DB, table))
    return cursor.fetchone()[0] or 0


def get_writable_columns(cursor, table):
    cursor.execute("""
        SELECT COLUMN_NAME
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA=%s
          AND TABLE_NAME=%s
          AND EXTRA NOT LIKE '%%GENERATED%%'
        ORDER BY ORDINAL_POSITION
    """, (SOURCE_DB, table))
    return [r[0] for r in cursor.fetchall()]


def get_order_column(cursor, table):
    # 1️⃣ 自增主键
    cursor.execute("""
        SELECT COLUMN_NAME
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA=%s
          AND TABLE_NAME=%s
          AND COLUMN_KEY='PRI'
          AND EXTRA LIKE '%%auto_increment%%'
        LIMIT 1
    """, (SOURCE_DB, table))
    row = cursor.fetchone()
    if row:
        return row[0]

    # 2️⃣ 创建时间字段
    cursor.execute("""
        SELECT COLUMN_NAME
        FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA=%s
          AND TABLE_NAME=%s
          AND COLUMN_NAME IN ('create_time','created_at','gmt_create')
        LIMIT 1
    """, (SOURCE_DB, table))
    row = cursor.fetchone()
    return row[0] if row else None


def create_table_if_not_exists(cursor, table):
    cursor.execute(f"SHOW CREATE TABLE `{SOURCE_DB}`.`{table}`")
    create_sql = cursor.fetchone()[1]
    create_sql = create_sql.replace(
        f"CREATE TABLE `{table}`",
        f"CREATE TABLE IF NOT EXISTS `{TARGET_DB}`.`{table}`"
    )
    cursor.execute(create_sql)


def truncate_table(cursor, table):
    cursor.execute(f"TRUNCATE TABLE `{TARGET_DB}`.`{table}`")


def sync_table(cursor, table, rows):
    columns = get_writable_columns(cursor, table)
    if not columns:
        raise RuntimeError("无可写字段（全 GENERATED）")

    col_list = ",".join(f"`{c}`" for c in columns)

    if rows >= BIG_TABLE_ROWS:
        order_col = get_order_column(cursor, table)
        if not order_col:
            raise RuntimeError("大表但找不到排序字段")

        print(f"    使用排序字段: {order_col}")
        sql = f"""
            INSERT INTO `{TARGET_DB}`.`{table}` ({col_list})
            SELECT {col_list}
            FROM (
                SELECT {col_list}
                FROM `{SOURCE_DB}`.`{table}`
                ORDER BY `{order_col}` DESC
                LIMIT {BIG_TABLE_SYNC_LIMIT}
            ) t
            ORDER BY `{order_col}` ASC
        """
    else:
        sql = f"""
            INSERT INTO `{TARGET_DB}`.`{table}` ({col_list})
            SELECT {col_list}
            FROM `{SOURCE_DB}`.`{table}`
            LIMIT {SMALL_TABLE_SAFE_LIMIT}
        """

    cursor.execute(sql)
    return cursor.rowcount


def main():
    conn = get_conn()
    cursor = conn.cursor()

    # 关闭严格时间校验（仅 session）
    cursor.execute("""
        SET SESSION sql_mode =
        REPLACE(
          REPLACE(
            @@sql_mode,
            'NO_ZERO_DATE',
            ''
          ),
          'NO_ZERO_IN_DATE',
          ''
        )
    """)
    cursor.execute("SET FOREIGN_KEY_CHECKS=0")

    tables = get_tables(cursor)
    print(f"\n📦 共发现 {len(tables)} 张表\n")

    for table in tables:
        start = time.time()
        print(f"▶ 处理表: {table}")

        try:
            rows = get_table_rows(cursor, table)
            print(f"  行数估算: {rows}")

            create_table_if_not_exists(cursor, table)
            truncate_table(cursor, table)

            inserted = sync_table(cursor, table, rows)
            conn.commit()

            cost = round(time.time() - start, 2)
            print(f"  ✅ 完成，写入 {inserted} 行，耗时 {cost}s\n")

        except Exception as e:
            conn.rollback()
            print(f"  ❌ 表 {table} 失败，已跳过")
            print(f"     错误: {e}")
            traceback.print_exc()
            print()

    try:
        cursor.execute("SET FOREIGN_KEY_CHECKS=1")
    except:
        pass

    cursor.close()
    conn.close()
    print("🎉 所有表处理完成")


if __name__ == "__main__":
    main()
