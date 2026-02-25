import pymysql

# ================= 基础配置 =================
MYSQL_CONF = {
    "host": "gz-cdb-bh67xl30.sql.tencentcdb.com",
    "user": "root",
    "password": "jikp6OYL9iKBQ5Xb@",
    "port": 21656,
}

SOURCE_DB = "erp_data"
TARGET_DB = "test_erp_data"

# 大表判断规则
BIG_TABLE_MAX_ROWS = 200_000        # 行数阈值
BIG_TABLE_MAX_SIZE_MB = 100         # 表大小阈值（MB）
BIG_TABLE_SYNC_LIMIT = 50_000       # 大表同步条数

# ================== 配置区 ==================
MYSQL_HOST = "gz-cdb-bh67xl30.sql.tencentcdb.com"
MYSQL_PORT = 21656
MYSQL_USER = "root"
MYSQL_PASSWORD = "jikp6OYL9iKBQ5Xb@"

SOURCE_DB = "erp_data"
TARGET_DB = "test_erp_data"

BIG_TABLE_ROWS = 100000
BIG_TABLE_SYNC_LIMIT = 50000
# ===========================================


# 是否同步前清空目标表（强烈推荐 True）
CLEAN_BEFORE_SYNC = True
# ============================================


def get_conn():
    return pymysql.connect(
        **MYSQL_CONF,
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False
    )


def ensure_target_db(cursor):
    cursor.execute(
        f"CREATE DATABASE IF NOT EXISTS `{TARGET_DB}` "
        f"DEFAULT CHARACTER SET utf8mb4"
    )


def get_tables_meta(cursor):
    cursor.execute("""
        SELECT
            TABLE_NAME,
            TABLE_ROWS,
            (DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024 AS SIZE_MB
        FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = %s
          AND TABLE_TYPE = 'BASE TABLE'
    """, (SOURCE_DB,))
    return cursor.fetchall()


def create_table_if_not_exists(cursor, table):
    cursor.execute(f"SHOW CREATE TABLE `{SOURCE_DB}`.`{table}`")
    create_sql = cursor.fetchone()["Create Table"]
    create_sql = create_sql.replace(
        f"CREATE TABLE `{table}`",
        f"CREATE TABLE IF NOT EXISTS `{TARGET_DB}`.`{table}`"
    )
    cursor.execute(create_sql)


def truncate_if_needed(cursor, table):
    if CLEAN_BEFORE_SYNC:
        cursor.execute(f"TRUNCATE TABLE `{TARGET_DB}`.`{table}`")


def sync_small_table(cursor, table):
    print(f"[小表] {table} -> 全量同步")
    truncate_if_needed(cursor, table)
    cursor.execute(f"""
        INSERT INTO `{TARGET_DB}`.`{table}`
        SELECT * FROM `{SOURCE_DB}`.`{table}`
    """)


def sync_big_table(cursor, table):
    print(f"[大表] {table} -> 同步前 {BIG_TABLE_SYNC_LIMIT} 条")
    truncate_if_needed(cursor, table)
    cursor.execute(f"""
        INSERT INTO `{TARGET_DB}`.`{table}`
        SELECT * FROM `{SOURCE_DB}`.`{table}`
        ORDER BY 1
        LIMIT {BIG_TABLE_SYNC_LIMIT}
    """)


def main():
    conn = get_conn()
    try:
        with conn.cursor() as cursor:

            # ✅ 关键：兼容 0000-00-00 等非法日期
            cursor.execute("SET SESSION sql_mode = ''")

            ensure_target_db(cursor)

            tables = get_tables_meta(cursor)

            for t in tables:
                table = t["TABLE_NAME"]
                rows = t["TABLE_ROWS"] or 0
                size = t["SIZE_MB"] or 0

                print(f"处理表: {table}, rows={rows}, size={size:.2f}MB")

                create_table_if_not_exists(cursor, table)

                is_big = (
                    rows >= BIG_TABLE_MAX_ROWS
                    or size >= BIG_TABLE_MAX_SIZE_MB
                )

                if is_big:
                    sync_big_table(cursor, table)
                else:
                    sync_small_table(cursor, table)

        conn.commit()
        print("\n✅ 所有表同步完成")

    except Exception as e:
        conn.rollback()
        print("\n❌ 同步失败，已回滚")
        raise e
    finally:
        conn.close()


if __name__ == "__main__":
    main()
