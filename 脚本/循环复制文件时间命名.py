import os
import shutil
from datetime import datetime, timedelta

def copy_and_rename_files(source_folder, destination_folder, start_date, end_date):
    current_date = start_date
    while current_date <= end_date:
        for filename in os.listdir(source_folder):
            if filename.endswith(".xlsx"):
                source_path = os.path.join(source_folder, filename)
                new_filename = current_date.strftime("%m-%d") + ".xlsx"
                destination_path = os.path.join(destination_folder, new_filename)

                shutil.copy(source_path, destination_path)
                print(f"复制 {source_path} 到 {destination_path}")

        current_date += timedelta(days=1)

if __name__ == "__main__":
    source_folder = r"C:\Users\kuang\Desktop\report"
    destination_folder = r"C:\Users\kuang\Desktop\reportt"  
    start_date = datetime.strptime("04-01", "%m-%d")
    end_date = datetime.strptime("11-22", "%m-%d")
    copy_and_rename_files(source_folder, destination_folder, start_date, end_date)
    print("完成。")
