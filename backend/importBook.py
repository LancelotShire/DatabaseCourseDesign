import csv
import mysql.connector

def connect():
    conn = mysql.connector.connect(
        host = "localhost",
        user = "root",
        passwd = "20040403B",
        database = "library_managing_system"
    )
    return conn

conn = connect()
cursor = conn.cursor()
with open('C:/DatabaseCourseDesign/JavaCourseDesign/backend/books.csv', newline='', encoding='utf-8') as csvfile:
    reader = csv.reader(csvfile)
    count = 1
    for row in reader:
        cursor.execute('INSERT INTO books(book_name, author, ISBN, category, count, deleted) VALUES(%s, %s, %s, %s, %s, 0)',(row[1], row[2], str(count), row[4], int(row[5])))
        count += 1
conn.commit()
cursor.close()
conn.close()

