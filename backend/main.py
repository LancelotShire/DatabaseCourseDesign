from fastapi import FastAPI
from pydantic import BaseModel
import mysql.connector
import datetime
import bcrypt

app = FastAPI()

def connect():
    conn = mysql.connector.connect(
        host = "localhost",
        user = "root",
        passwd = "20040403B",
        database = "library_managing_system"
    )
    return conn

@app.get("/")
def read_root():
    return {"message": "看到这条消息就代表前后端通讯已经成功了"}

@app.get("/search")
def search(param: str):
    conn = connect()
    cursor =conn.cursor()
    if param == "":
        cursor.execute("select * from books")
        rows = cursor.fetchall()
    else:
        param = "%"+param+"%"
        cursor.execute(f"select * from books where book_name like %s or author like %s or ISBN like %s or category like %s",(param,param,param,param))
        rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows

@app.get("/searchPeople")
def searchPeople(param: str):
    conn = connect()
    cursor = conn.cursor()
    if param == "":
        cursor.execute("select * from members")
        rows = cursor.fetchall()
    else:
        param = "%"+param+"%"
        cursor.execute(f"select * from members where name like %s or account like %s",(param,param))
        rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return rows


@app.get("/getAllBorrowedBook")
def getAllBorrowedBook():
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("select borrowing_id,name,members.account,book_name,books.ISBN,borrow_date,return_date from members,borrowings,books where members.account = borrowings.account and borrowings.ISBN = books.ISBN")
    rows = cursor.fetchall()
    cursor.close()
    conn.close
    return sorted(rows,key=lambda x: -x[0])


@app.get("/getBorrowedBook")
def getBorrowedBook(account: int):
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("select borrowing_id,name,members.account,book_name,books.ISBN,borrow_date,return_date from members,borrowings,books where members.account = borrowings.account and borrowings.ISBN = books.ISBN and members.account = %s",(account,))
    rows = cursor.fetchall()
    cursor.close()
    conn.close
    return sorted(rows,key=lambda x: x[0])

class AccountAndPassword(BaseModel):
    account: int
    password: str

@app.post("/login")
def login(accountAndPassword: AccountAndPassword):
    account = accountAndPassword.account
    password = accountAndPassword.password
    conn = connect()
    cursor =conn.cursor()
    cursor.execute(f"select * from members where account = {account}")
    row = cursor.fetchone()  
    cursor.close()
    conn.close()

    hashed = str(row[-1]).encode('utf-8')

    if row != None and bcrypt.checkpw(password.encode('utf-8'), hashed):
        return {"token": True, "userType": row[3] ,"userName": row[1], "message": "登陆成功！"}
    elif row != None and not bcrypt.checkpw(password.encode('utf-8'), hashed):
        return {"token": False, "userType": 0,"userName": " ", "message": "账号或密码错误！"}
    else:
        return {"token": False, "userType": 0,"userName": " ", "message": "账号未注册！请联系管理员注册账号！"}

@app.get("/find")
def find(account: int):
    conn = connect()
    cursor =conn.cursor()
    cursor.execute(f"select * from members where account = {account}")
    row = cursor.fetchone()  
    cursor.close()
    conn.close()
    data = {
        "name": row[1],
        "account": row[2],
        "userType": row[3],
        "maxBorrowedBook": row[4],
        "borrowedBook": row[5]
    }
    return data

class Name(BaseModel):
    account: int
    name: str

@app.put("/updatePersonalName")
def updatePersonalName(name: Name):
    try:
        conn = connect()
        cursor =conn.cursor()
        cursor.execute("update members set name = %s where account = %s",(name.name, name.account))
        conn.commit()
        return {'result': True, 'message': '更新昵称成功!'}
    except Exception as e:
         return {'result': False, 'message': str(e)}
    finally:
        if conn:
            cursor.close()
            conn.close()

class Password(BaseModel):
    account: int
    newPassword: str

@app.put("/updatePersonalPassword")
def updatePersonalName(password: Password):
    try:
        conn = connect()
        cursor = conn.cursor()
        hashed = bcrypt.hashpw(password.newPassword.encode('utf-8'),bcrypt.gensalt())
        cursor.execute("update members set password = %s where account = %s",(hashed, password.account))
        conn.commit()
        return {'result': True, 'message': '修改密码成功!'}
    except Exception as e:
         return {'result': False, 'message': str(e)}
    finally:
        if conn:
            cursor.close()
            conn.close()

class Member(BaseModel):
    name: str
    account: int
    userType: int
    maxBorrowedBook: int
    password: str

@app.put("/addMember")
def addMember(member: Member):
    name = member.name
    account = member.account
    userType = member.userType
    maxBorrowedBook = member.maxBorrowedBook
    password = bcrypt.hashpw(member.password.encode('utf-8'),bcrypt.gensalt())

    conn = connect()
    cursor =conn.cursor()
    cursor.execute("select * from members where account = %s",(account,))
    row = cursor.fetchone()
    if row != None:
        return {'result': False, 'message': '账号已注册!'}
    else:
        cursor.execute("INSERT INTO members(name, account, user_type, max_borrowed_book, borrowed_book, deleted, password) VALUES(%s, %s, %s, %s, 0, 0, %s)",(name,account,userType,maxBorrowedBook,password))
        conn.commit()
        cursor.close()
        conn.close()
        return {'result': True, 'message': '成功添加了新用户!'}

class Book(BaseModel):
    bookName: str
    author: str
    ISBN: str
    category: str
    count: int

@app.put("/addBook")
def addBook(book: Book):
    bookName = book.bookName
    author = book.author
    ISBN = book.ISBN
    category = book.category
    count = book.count

    conn = connect()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM books where ISBN = %s",(ISBN,))
    row = cursor.fetchone()
    if row != None:
        return {'result': False, 'message': '书籍已存在!'}
    else:
        cursor.execute("INSERT INTO books(book_name, author, ISBN, category, count, deleted) VALUES(%s, %s, %s, %s, %s, 0)",(bookName, author, ISBN, category, count))
        conn.commit()
        cursor.close()
        conn.close()
        return {'result': True, 'message': '成功添加了新书籍!'}

@app.get("/isBookBorrowable")
def isBookBorrowable(ISBN: str):
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM books WHERE ISBN = %s",(ISBN,))
    row = cursor.fetchone()
    cursor.close()
    conn.close()
    if row == None:
        return {'result': False, 'message': '书籍已不存在!'}
    elif row[5] == 0:
        return {'result': False, 'message': '书籍数量为0,无法借阅!'}
    else:
        return {'result': True, 'message': '图书状态正确,可以借阅!'}

@app.get("/isAccountAllowedToBorrow")
def isAccountAllowedToBorrow(account: int):
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM members WHERE account = %s",(account,))
    row = cursor.fetchone()
    cursor.close()
    conn.close()
    if row == None:
        return {'result': False, 'message': '账户已不存在!'}
    elif (row[4] - row[5]) <= 0:
        return {'result': False, 'message': '已经达到最大借阅上限!'}
    else:
        return {'result': True, 'message': '账户验证通过,可以借阅!'}

class Borrow(BaseModel):
    account: int
    ISBN: str

@app.post("/borrow")
def borrowABook(borrow: Borrow):
    account = borrow.account
    ISBN = borrow.ISBN
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM borrowings WHERE account = %s and ISBN = %s and return_date IS NULL",(account,ISBN))
    row = cursor.fetchone()
    if row != None:
        return {'result': False, 'message': '当前已借阅本书,在归还前不可重复借阅!'}
    local_time = datetime.datetime.now()
    borrow_date = local_time.strftime("%Y-%m-%d")
    cursor.execute("UPDATE members SET borrowed_book = borrowed_book+1 WHERE account = %s",(account,))
    cursor.execute("UPDATE books SET count = count-1 WHERE ISBN = %s",(ISBN,))
    cursor.execute("INSERT INTO borrowings(account, ISBN, borrow_date) VALUES(%s, %s, %s)",(account, ISBN, borrow_date))
    conn.commit()
    cursor.close()
    conn.close()
    return {'result': True, 'message': '借阅成功!请注意及时归还!'}

@app.get("/getTime")
def getTime():
    return datetime.datetime.now().strftime("%Y-%m-%d")

@app.get("/isNotReturned")
def isNotReturned(borrowingId: int):
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM borrowings WHERE borrowing_id = %s",(borrowingId,))
    row = cursor.fetchone()
    if row[-1] != None:
        return {'result': False, 'message': '已经归还!'}
    else:
        return {'result': True, 'message': '可以归还!'}

@app.get("/getBorrowDays")
def getBorrowDays():
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM parameters WHERE param_name = \"borrow_days\"")
    row = cursor.fetchone()
    data = row[1]
    cursor.close()
    conn.close()
    return data

@app.get("/getRecentlyReturn")
def getRecentlyReturn(account: int):
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("select book_name,borrow_date from books,borrowings where books.isbn = borrowings.isbn and return_date is null and account = %s",(account,))
    rows = cursor.fetchall()
    rows = sorted(rows,key=lambda x:x[1])
    cursor.close()
    conn.close()
    return rows

@app.get("/getMostPopular")
def getMostPopular():
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("select book_name,count(distinct account) from books,borrowings where books.isbn = borrowings.isbn group by book_name")
    rows = cursor.fetchall()
    rows = sorted(rows,key=lambda x:-x[1])
    cursor.close()
    conn.close()
    return rows

@app.get("/getMostPopularCategory")
def getMostPopularCategory():
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("select category,count(distinct account) from books,borrowings where books.isbn = borrowings.isbn group by category")
    rows = cursor.fetchall()
    rows = sorted(rows,key=lambda x:-x[1])
    cursor.close()
    conn.close()
    return rows

@app.get("/getBookCount")
def getBookCount():
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("select category,sum(count) from books group by category")
    rows = cursor.fetchall()
    rows = sorted(rows,key=lambda x:-x[1])
    cursor.close()
    conn.close()
    return rows

class Return(BaseModel):
    borrowingId: int

@app.post("/returnABook")
def returnABook(re: Return):
    borrowingId = re.borrowingId
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM borrowings WHERE borrowing_id = %s",(borrowingId,))
    row = cursor.fetchone()
    account = row[1]
    ISBN = row[2]
    borrowed = row[3]
    returned = datetime.datetime.now().date()
    return_date = returned.strftime("%Y-%m-%d")
    cursor.execute("UPDATE borrowings SET return_date = %s WHERE borrowing_id = %s",(return_date, borrowingId))
    cursor.execute("UPDATE books SET count = count+1 WHERE ISBN = %s",(ISBN,))
    cursor.execute("UPDATE members SET borrowed_book = borrowed_book-1 WHERE account = %s",(account,))
    conn.commit()
    cursor.close()
    conn.close()
    if (returned-borrowed).days > getBorrowDays():
        return {'result': True, 'message': '归还成功,本次结束借书时间超过了规定期限,请联系管理员处理违约'}
    else:
        return {'result': True, 'message': '归还成功!'}

class Days(BaseModel):
    borrowDays: int

@app.post("/updateBorrowDays")
def updateBorrowDays(d: Days):
    borrowDays = d.borrowDays
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("UPDATE parameters SET param_value = %s WHERE param_name = \"borrow_days\"",(borrowDays,))
    conn.commit()
    cursor.close()
    conn.close()
    return {'result': True, 'message': '更改成功!'}

class Count(BaseModel):
    ISBN : str
    count: int

@app.put("/updateCount")
def updateCount(c: Count):
    count = c.count
    ISBN = c.ISBN
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("UPDATE books SET count = %s WHERE ISBN = %s",(count,ISBN))
    conn.commit()
    cursor.close()
    conn.close()
    return {'result': True, 'message': '更改成功!'}

class MaxBorrowedBook(BaseModel):
    account: int
    maxBorrowedBook: int

@app.put("/updateMaxBorrowedBook")
def updateMaxBorrowedBook(m: MaxBorrowedBook):
    account = m.account
    maxBorrowedBook = m.maxBorrowedBook
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("UPDATE members SET max_borrowed_book = %s WHERE account = %s",(maxBorrowedBook,account))
    conn.commit()
    cursor.close()
    conn.close()
    return {'result': True, 'message': '更改成功!'}

class Account(BaseModel):
    account: int
    userType: int

@app.put("/ban")
def ban(a: Account):
    account = a.account
    userType = a.userType
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("UPDATE members SET user_type = %s WHERE account = %s",(userType,account))
    conn.commit()
    cursor.close()
    conn.close()
    return {'result': True, 'message': '操作成功!'}


@app.put("/deleteBook")
def deleteBook(ISBN: str):
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM borrowings WHERE ISBN = %s and return_date IS NULL",(ISBN,))
    row = cursor.fetchone()
    if row != None:
        return {'result': False, 'message': '有人尚未归还此书,暂不可删除! 待全部归还后即可删除此书'}
    else:
        cursor.execute("DELETE FROM borrowings WHERE ISBN = %s",(ISBN,))
        cursor.execute("DELETE FROM books WHERE ISBN = %s",(ISBN,))
        print(ISBN, type(ISBN))
        conn.commit()
        cursor.close()
        conn.close()
        return {'result': True, 'message': '成功删除了此书与此书的借阅记录!'}

@app.put("/deleteMember")
def deleteMember(account: int):
    conn = connect()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM borrowings WHERE account = %s and return_date IS NULL",(account,))
    row = cursor.fetchone()
    if row != None:
        return {'result': False, 'message': '此用户尚未归还全部书籍,暂不可删除! 待全部归还后即可删除此用户'}
    else:
        cursor.execute("DELETE FROM borrowings WHERE account = %s",(account,))
        cursor.execute("DELETE FROM members WHERE account = %s",(account,))
        conn.commit()
        cursor.close()
        conn.close()
        return {'result': True, 'message': '成功删除了此用户与此用户的借阅记录!'}

@app.get("/getCategoryCounts")
def getCategoryCounts():
    conn = connect()
    cursor = conn.cursor()
    result = {}
    cursor.execute("SELECT category, count(category) FROM books GROUP BY category")
    rows = cursor.fetchall()
    for elem in rows:
        result[elem[0]] = elem[1]
    cursor.close()
    conn.close()
    return result

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app,host="127.0.0.1",port=8000)





