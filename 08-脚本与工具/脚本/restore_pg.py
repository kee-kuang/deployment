#!/usr/bin/python


import os
import sys

COLUMNS_STRUCTURE_FILE_NAME = "column_structure.sql"
CONSTRAINT_STRUCTURE_FILE_NAME = "constraint_structure.sql"
INDEX_STRUCTURE_FILE_NAME = "index_structure.sql"
INHERIT_STRUCTURE_FILE_NAME = "inherit_structure.sql"
STRUCTURE_FILE_NAME = "structure.sql"

DATA_PATH_PREFIX = "data"


def create_database(db_host, db_port, db_user, db_pass, db_name, create_stmt_file):
    if db_name == "postgres":
        return
    cmd = "PGPASSWORD=" + db_pass + " psql -h" + db_host + " -p" + db_port + " -U" + db_user + " -d" + "postgres" + " <" + create_stmt_file
    if os.system(cmd) != 0:
        print("[ERROR]: execute SQL failed. command: " + cmd)
        exit(1)


def create_schema(db_host, db_port, db_user, db_pass, db_name, create_stmt_file):
    cmd = "PGPASSWORD=" + db_pass + " psql -h" + db_host + " -p" + db_port + " -U" + db_user + " -d" + db_name + " <" + create_stmt_file
    if os.system(cmd) != 0:
        print("[ERROR]: execute SQL failed. command: " + cmd)
        exit(1)


def import_file_csv(db_host, db_port, db_user, db_pass, csv_file, db_name, db_schema, table):
    load_cmd = " -c \"\copy " + "\"" + db_schema + "\".\"" + table + "\" " + " from '" + csv_file + "' delimiter ',' csv\""
    cmd = "PGPASSWORD=" + db_pass + " psql -h" + db_host + " -p" + db_port + " -U" + db_user + " -d" + db_name + load_cmd
    print("[INFO]: trying to exec: " + cmd)
    if os.system(cmd) != 0:
        print("[ERROR]: execute SQL failed. command: " + cmd)
        exit(1)


def import_file_sql(db_host, db_port, db_user, db_pass, db_name, sql_file):
    cmd = "PGPASSWORD=" + db_pass + " psql -h" + db_host + " -p" + db_port + " -U" + db_user + " -d" + db_name + " <" + sql_file
    print("[INFO]: trying to exec: " + cmd)
    if os.system(cmd) != 0:
        print("[ERROR]: execute SQL failed. command: " + cmd)
        exit(1)


def print_usage():
    print(
        "Usage: python ./restore_mysql.py [backupset_directory] [database_host] [database_port] [database_username] [database_password]")


if __name__ == '__main__':
    if len(sys.argv) != 6:
        print_usage()
        exit()

    root_dir = os.path.abspath(sys.argv[1])
    db_host = sys.argv[2]
    db_port = sys.argv[3]
    db_user = sys.argv[4]
    db_pass = sys.argv[5]
    print("[INFO]: restore data from " + root_dir + " to " + db_host + ":" + db_port)

    db_dirs = os.listdir(root_dir)
    for db_dir in db_dirs:
        db_dir_path = os.path.join(root_dir, db_dir)
        if not os.path.isdir(db_dir_path):
            continue
        db_structure_file = os.path.join(db_dir_path, STRUCTURE_FILE_NAME)
        create_database(db_host, db_port, db_user, db_pass, db_dir, db_structure_file)
        print("[INFO]: restore structure database: " + db_dir + " ends")

        constraint_ddl_file_list = []
        index_ddl_file_list = []
        inherit_ddl_file_list = []

        schema_dirs = os.listdir(db_dir_path)
        for schema_dir in schema_dirs:
            schema_dir_path = os.path.join(db_dir_path, schema_dir)
            if not os.path.isdir(schema_dir_path):
                continue
            db_structure_file = os.path.join(schema_dir_path, STRUCTURE_FILE_NAME)
            create_schema(db_host, db_port, db_user, db_pass, db_dir, db_structure_file)
            print("[INFO]: restore structure schema: " + schema_dir + " ends")

            table_dirs = os.listdir(schema_dir_path)
            for table_dir in table_dirs:
                table_dir_path = os.path.join(schema_dir_path, table_dir)
                if not os.path.isdir(table_dir_path):
                    continue
                column_ddl_file = os.path.join(table_dir_path, COLUMNS_STRUCTURE_FILE_NAME)
                constraint_ddl_file = os.path.join(table_dir_path, CONSTRAINT_STRUCTURE_FILE_NAME)
                index_ddl_file = os.path.join(table_dir_path, INDEX_STRUCTURE_FILE_NAME)
                inherit_ddl_file = os.path.join(table_dir_path, INHERIT_STRUCTURE_FILE_NAME)
                if os.path.exists(constraint_ddl_file): constraint_ddl_file_list.append(constraint_ddl_file)
                if os.path.exists(index_ddl_file): index_ddl_file_list.append(index_ddl_file)
                if os.path.exists(inherit_ddl_file): inherit_ddl_file_list.append(inherit_ddl_file)

                import_file_sql(db_host, db_port, db_user, db_pass, db_dir, column_ddl_file)
                print("[INFO]: restoring structure table: " + table_dir)
                table_data_dir_path = os.path.join(table_dir_path, DATA_PATH_PREFIX)
                if not os.path.isdir(table_data_dir_path):
                    continue
                files_format = os.listdir(table_data_dir_path)[0].split(".")[-1]
                if files_format == "csv":
                    csv_files = os.listdir(table_data_dir_path)
                    csv_count = 0
                    for csv_file in csv_files:
                        csv_file_path = os.path.join(table_data_dir_path, csv_file)
                        file_size = os.path.getsize(csv_file_path)
                        if file_size > 0:
                            import_file_csv(db_host, db_port, db_user, db_pass, csv_file_path, db_dir, schema_dir,
                                            table_dir)
                            csv_count = csv_count + 1
                            print("[INFO]: restore data [" + str(csv_count) + "/" + str(
                                len(csv_files)) + "] of table " + db_dir + ": " + schema_dir + "." + table_dir)
                elif files_format == "sql":
                    sql_files = os.listdir(table_data_dir_path)
                    sql_count = 0
                    for sql_file in sql_files:
                        sql_file_path = os.path.join(table_data_dir_path, sql_file)
                        file_size = os.path.getsize(sql_file_path)
                        if file_size > 0:
                            import_file_sql(db_host, db_port, db_user, db_pass, db_dir, sql_file_path)
                            sql_count = sql_count + 1
                            print("[INFO]: restore data [" + str(sql_count) + "/" + str(
                                len(sql_files)) + "] of table " + db_dir + ": " + schema_dir + "." + table_dir)

        for file in constraint_ddl_file_list:
            import_file_sql(db_host, db_port, db_user, db_pass, db_dir, file)
        for file in index_ddl_file_list:
            import_file_sql(db_host, db_port, db_user, db_pass, db_dir, file)
        for file in inherit_ddl_file_list:
            import_file_sql(db_host, db_port, db_user, db_pass, db_dir, file)
