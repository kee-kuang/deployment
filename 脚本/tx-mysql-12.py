import pymysql
import time
import traceback
from datetime import datetime


# ================== 配置区 ==================
MYSQL_HOST = "gz-cdb-bh67xl30.sql.tencentcdb.com"
MYSQL_PORT = 21656
MYSQL_USER = "root"
MYSQL_PASSWORD = "jikp6OYL9iKBQ5Xb@"

SOURCE_DB = "sucai_hw_cms"
TARGET_DB = "test_sucai_hw_cms"

BIG_TABLE_ROWS = 100_000
BIG_TABLE_SYNC_LIMIT = 50_000
SMALL_TABLE_SAFE_LIMIT = 200_000
# ===========================================


def now():
    return datetime.now().strftime("%H:%M:%S.%f")[:-3]


def log(msg):
    print(f"[{now()}] {msg}", flush=True)


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
    return [row[0] for row in cursor.fetchall()]


def create_table_if_not_exists(cursor, table):
    log(f"{table} | 建表开始")
    cursor.execute(f"SHOW CREATE TABLE `{SOURCE_DB}`.`{table}`")
    create_sql = cursor.fetchone()[1]
    create_sql = create_sql.replace(
        f"CREATE TABLE `{table}`",
        f"CREATE TABLE IF NOT EXISTS `{TARGET_DB}`.`{table}`"
    )
    cursor.execute(create_sql)
    log(f"{table} | 建表完成")


def truncate_table(cursor, table):
    log(f"{table} | TRUNCATE 开始")
    cursor.execute(f"TRUNCATE TABLE `{TARGET_DB}`.`{table}`")
    log(f"{table} | TRUNCATE 完成")


def sync_table(cursor, table, limit):
    columns = get_writable_columns(cursor, table)
    if not columns:
        raise RuntimeError("无可写字段")

    col_list = ",".join(f"`{c}`" for c in columns)

    sql = f"""
        INSERT INTO `{TARGET_DB}`.`{table}` ({col_list})
        SELECT {col_list}
        FROM `{SOURCE_DB}`.`{table}`
        LIMIT {limit}
    """

    log(f"{table} | INSERT 开始（limit={limit}）")
    start = time.time()
    cursor.execute(sql)
    cost = time.time() - start

    cursor.execute("SELECT ROW_COUNT()")
    rows = cursor.fetchone()[0]

    log(f"{table} | INSERT 完成，插入 {rows} 行，用时 {cost:.2f}s")


def main():
    conn = get_conn()
    cursor = conn.cursor()

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
    log(f"发现 {len(tables)} 张表")

    for table in tables:
        log(f"====== 处理表 {table} ======")

        try:
            rows = get_table_rows(cursor, table)
            log(f"{table} | TABLE_ROWS={rows}")

            create_table_if_not_exists(cursor, table)
            truncate_table(cursor, table)

            if rows >= BIG_TABLE_ROWS:
                sync_table(cursor, table, BIG_TABLE_SYNC_LIMIT)
            else:
                sync_table(cursor, table, SMALL_TABLE_SAFE_LIMIT)

            conn.commit()
            log(f"{table} | 提交完成\n")

        except Exception as e:
            conn.rollback()
            log(f"{table} | ❌ 失败，已回滚")
            log(str(e))
            traceback.print_exc()
            print()

    cursor.execute("SET FOREIGN_KEY_CHECKS=1")
    cursor.close()
    conn.close()
    log("全部表处理完成")


if __name__ == "__main__":
    main()
