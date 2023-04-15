
from flask import Flask, flash, redirect, render_template, request, session, abort, url_for
import os
import sqlite3
# import MySQLdb.cursors
from flask_mysqldb import MySQL
import re
from urllib.parse import urlencode
from web3 import Web3
import json
from eth_utils import keccak
# from eth_abi import encode_abi
# Set up Web3.py to connect to the local network
w3 = Web3(Web3.HTTPProvider('http://localhost:8545'))


# Load the JobPlatform smart contract ABI
with open('./artifacts/contracts/JobPlatform.sol/JobPlatform.json') as f:

    contract_abi = json.load(f)['abi']

# Set the contract address
contract_address = '0x5FbDB2315678afecb367f032d93F642f64180aa3'

# Create a contract instance using the ABI and address
contract = w3.eth.contract(address=contract_address, abi=contract_abi)


def create_job_posting(title, description, salary):
    tx_hash = contract.functions.createJobPosting(
        title, description, int(salary)).transact()

    print(title, description, salary)

    tx_receipt = w3.eth.get_transaction_receipt(tx_hash)


def apply_to_jobposting(candidate, jobtitle):
    s = ""
    for item in candidate:
        s = s+str(item)
    # arr = [s]
    # hashed_value = w3.soliditySha3(['string'], arr).hex()
    # hashed_value_encoded = encode_abi(
    #    ['bytes32'], [bytes.fromhex(hashed_value)])
    hashed_value = keccak(text=s)
    print(candidate, hashed_value, jobtitle)

    hashed_encoded = w3.to_bytes(hexstr=hashed_value.hex())
    contract.functions.applyToJobPosting(
        hashed_value, jobtitle).transact()
    # tx_hash = contract.functions.applyToJobPosting(
    #     hashed_value, jobtitle).transact()

# Define a Flask route to get the total number of jobs on the platform


app = Flask(__name__)


def database_conn():
    conn = sqlite3.connect("query.db")

    c = conn.cursor()
    c.execute("DROP TABLE IF EXISTS accounts")
    print("Done")
    c.execute(''' CREATE TABLE IF NOT EXISTS accounts([name] varchar(50) NOT NULL, [username] varchar(50) NOT NULL PRIMARY KEY, [password] 
    varchar(255) NOT NULL, [email] varchar(100) NOT NULL, [area] varchar(100) NOT NULL, [describe] varchar(250) NOT NULL,
    [entity] varchar(20) NOT NULL, [url] varchar(20) NOT NULL)''')
    conn.commit()


database_conn()

app.secret_key = 'your secret key'

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'your password'
app.config['MYSQL_DB'] = 'query'

mysql = MySQL(app)


@app.route('/new_user', methods=['GET', 'POST'])
def register():
    msg = ''
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form:
        name = request.form["name"]
        username = request.form['username']
        password = request.form['password']
        email = request.form['email']
        entity = request.form["Entity"]
        if (entity == "Organisation"):
            area = request.form["area"]
        else:
            area = request.form["Area"]

        describe = request.form["describe"]
        repeat = request.form['repeat']
        url = request.form['url']
        conn = sqlite3.connect("query.db")
        cursor = conn.cursor()
        # cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        query = "SELECT * FROM accounts WHERE username = '{username}'".format(
            username=username)

        cursor.execute(query)

        account = cursor.fetchone()
        if account != None:
            msg = 'Account already exists !'

        elif not re.match(r'[^@]+@[^@]+\.[^@]+', email):
            msg = 'Invalid email address !'
        elif not re.match(r'[A-Za-z0-9]+', username):
            msg = 'Username must contain only characters and numbers !'
        elif not username or not password or not email:
            msg = 'Please fill out the form !'
        elif password != repeat:
            msg = "Passwords do not match!"
        else:
            cursor.execute('INSERT INTO accounts VALUES (?, ?, ?, ?, ?, ?, ?,?)',
                           (name, username, password, email, area, describe, entity, url))

            conn.commit()
            msg = 'You have successfully registered !'
    elif request.method == 'POST':
        msg = 'Please fill out the form !'
    return render_template('New_User.html', msg=msg)


index = 0


@app.route('/')
@app.route('/login', methods=['GET', 'POST'])
def login():
    global index
    msg = ''
    if request.method == 'POST' and 'username' in request.form and 'password' in request.form:
        username = request.form['username']
        password = request.form['password']

        conn = sqlite3.connect("query.db")
        cursor = conn.cursor()
        cursor.execute(
            'SELECT * FROM accounts WHERE username = ? AND password = ?', (username, password, ))
        account = cursor.fetchone()
        if account:
            session['loggedin'] = True
            session["name"] = account[0]
            session['username'] = account[1]
            session['email'] = account[3]
            session['area'] = account[4]
            session["describe"] = account[-3]
            session["entity"] = account[-2]
            session['url'] = account[-1]
            msg = 'Logged in successfully !'
            conn = sqlite3.connect("query.db")
            cursor = conn.cursor()
            if (session['entity'] == "Organisation"):

                query = "SELECT * from job_openings where username='{username}' ".format(
                    username=session['username'])
            else:
                query = "SELECT * from job_applications where applicant='{username}' ".format(
                    username=session['username'])
            cursor.execute(query)
            data = cursor.fetchall()
            print(data)
            if data == []:
                return render_template("abc.html", msg=msg, data=[])
            arr = []
            for item in data:
                arr.append(list(item))
            return render_template("abc.html", msg=msg, data=arr)

            # return render_template('abc.html', msg = msg)
        else:
            msg = 'Incorrect username / password !'
    return render_template('login.html', msg=msg)


@app.route("/logout")
def logout():
    session.pop('loggedin', None)

    session.pop('username', None)

    return redirect(url_for('login'))


conn = sqlite3.connect("query.db")
cursor = conn.cursor()

print("Done")
cursor.execute("DROP TABLE IF EXISTS job_openings")
cursor.execute(''' CREATE TABLE IF NOT EXISTS job_openings([job_id] varchar(50) NOT NULL PRIMARY KEY, [name] varchar(50) NOT NULL, 
[email] varchar(100) NOT NULL, [area] varchar(100) NOT NULL, [describe] varchar(250) NOT NULL,
 [for_type] varchar(20) NOT NULL, [url] varchar(20) NOT NULL, [salary] int, [job_location] varchar(20) NOT NULL,
 [username] varchar(20) NOT NULL)''')
conn.commit()


counter = 0


@app.route("/Create_job_opening", methods=['GET', 'POST'])
def create_job_opening():

    global cursor
    global counter

    msg = ''
    if request.method == 'POST' and 'Job location' in request.form and 'Salary' in request.form and 'for_type' in request.form and 'describe' in request.form:
        name = session["name"]

        email = session['email']

        area = session["area"]
        Job_location = request.form["Job location"]
        salary = request.form["Salary"]
        for_type = request.form['for_type']
        describe = request.form["describe"]

        url = session['url']
        conn = sqlite3.connect("query.db")
        cursor = conn.cursor()
        # cursor = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
        query = "SELECT * FROM job_openings WHERE username = '{username}' AND for_type='{for_type}'".format(
            username=session['username'], for_type=for_type)

        cursor.execute(query)
        account = cursor.fetchone()
        query = "SELECT * FROM job_openings WHERE username='{username}'".format(
            username=session['username'])
        cursor.execute(query)

        count = len(cursor.fetchall())
        print(count)
        if account != None:
            msg = 'Job posting already exists!'

        elif not re.match(r'[^@]+@[^@]+\.[^@]+', email):
            msg = 'Invalid email address !'

        elif not email:
            msg = 'Please fill out the form !'
        elif count == 10:
            msg = "Limit reached!"
        else:
            cursor.execute('INSERT INTO job_openings VALUES (?, ?, ?, ?, ?,?,?,?, ?,?)', (str(
                counter), name, email, area, describe, for_type, url, salary, Job_location, session['username']))
            counter = counter+1
            conn.commit()
            msg = 'Job posting created!'
            create_job_posting(
                title=for_type, description=email, salary=salary)
            query = "SELECT * from job_openings where username='{username}'".format(
                username=session['username'])
            cursor.execute(query)
            data = cursor.fetchall()
            query_string = urlencode({'data': data, "msg": msg}, doseq=True)
            return redirect("/page?{}".format(query_string))
            # return updated_page(msg=msg,data=data)
    elif request.method == 'POST':
        msg = 'Please fill out the form !'
    return render_template('Job_Posting.html', msg=msg)


@app.route("/page", methods=['GET', 'POST'])
def updated_page():
    # msg=request.args.get('msg')
    # data=request.args.get("data")
    # arr=msg.split("$")
    # msg=arr[0]
    # data=eval(arr[1])
    msg = request.args.get("msg")
    mylist = request.args.getlist("data")

    if mylist == []:
        return render_template("abc.html", msg=msg, data=[])
    arr = []
    for item in mylist:
        arr.append(list(eval(item)))
    return render_template("abc.html", msg=msg, data=arr)


@app.route("/delete_jobposting/<job_id>", methods=['GET', "POST"])
def delete_jobposting(job_id):

    print(job_id)
    conn = sqlite3.connect("query.db")
    cursor = conn.cursor()

    query = "SELECT * from job_openings where job_id='{job_id}' ".format(
        job_id=job_id)
    cursor.execute(query)
    data = cursor.fetchall()
    print(data)
    username = data[0][-1]
    query = "SELECT * from job_openings where username='{username}' ".format(
        username=username)
    cursor.execute(query)
    data = cursor.fetchall()
    print(data)
    query = '''DELETE FROM job_openings WHERE job_id='{job_id}' '''.format(
        job_id=job_id)

    cursor.execute(query)

    conn.commit()
    if (len(data) != 1):
        query = "SELECT * from job_openings where username='{username}'".format(
            username=username)
        cursor.execute(query)
        data = cursor.fetchall()
    else:
        data = []
    msg = "Job posting deleted"
    query_string = urlencode({'data': data, "msg": msg}, doseq=True)
    return redirect("/page?{}".format(query_string))

    # return redirect(url_for('updated_page',msg="Job Posting deleted",data=data))


@app.route("/delete_user")
def delete_user():
    conn = sqlite3.connect("query.db")
    cursor = conn.cursor()
    session.pop('loggedin', None)

    conn.execute("DELETE FROM accounts WHERE username='{username}'".format(
        username=session['username']))
    session.pop('username', None)
    conn.commit()
    return redirect("/login")


@app.route("/apply_job")
def apply_to_job():
    conn = sqlite3.connect("query.db")
    cursor = conn.cursor()

    query = "SELECT * from job_openings"
    cursor.execute(query)
    data = cursor.fetchall()

    # data=[]
    msg = ""

    return render_template("apply_to_job.html", data=data)


cursor.execute("DROP TABLE IF EXISTS job_applications")
cursor.execute(''' CREATE TABLE IF NOT EXISTS job_applications([jobid] varchar(50), [name] varchar(50) NOT NULL,
[for_type] varchar(50), [salary] int, [job_location] varchar(20) NOT NULL,[applicant] varchar(50) NOT NULL,[companyid] varchar(50)
 NOT NULL)''')
conn.commit()


@app.route("/applying/<id>")
def applying_to_job(id):
    print(id)
    conn = sqlite3.connect("query.db")
    cursor = conn.cursor()
    query = "SELECT * from job_openings WHERE job_id='{id}'".format(id=id)
    cursor.execute(query)
    data = cursor.fetchone()
    # str(counter),name, email, area, describe, for_type,url,salary,Job_location,session['username']

    companyid = data[-1]
    name = data[1]
    email = data[2]
    for_type = data[-5]
    salary = data[-3]
    job_location = data[-2]
    query = "SELECT * from job_applications WHERE companyid='{company_id}' AND applicant='{username}'".format(
        company_id=companyid, username=session['username'])
    cursor.execute(query)
    application = cursor.fetchone()
    query = "SELECT * from job_applications WHERE applicant='{username}'".format(
        username=session['username'])
    cursor.execute(query)
    data = cursor.fetchall()
    query = "SELECT DISTINCT username from job_openings"
    cursor.execute(query)
    data2 = cursor.fetchall()
    if (application):
        msg = "Cannot apply to same company twice"

    else:
        if (len(data) == 10):
            msg = "You Cannot apply to more than 10 companies"
        else:
            if (len(data) == len(data2)-1 and len(data2) >= 2):
                msg = "You Cannot apply to all the companies"
            else:
                msg = 'Job applied'
                cursor.execute('INSERT INTO job_applications VALUES ( ?, ?, ?, ?, ?, ?, ?)', (
                    id, name, for_type, salary, job_location, session['username'], companyid))

                conn.commit()
                apply_to_jobposting(
                    (id, name, for_type, salary, job_location, session['username'], companyid), for_type)

    query = "SELECT * from job_applications WHERE applicant='{username}'".format(
        username=session['username'])
    cursor.execute(query)
    data = cursor.fetchall()

    query_string = urlencode({'data': data, "msg": msg}, doseq=True)
    return redirect("/page?{}".format(query_string))


@app.route("/withdraw/<job_id>", methods=['GET', 'POST'])
def withdraw(job_id):

    print(job_id)
    conn = sqlite3.connect("query.db")
    cursor = conn.cursor()

    query = "SELECT * from job_applications where jobid='{job_id}' ".format(
        job_id=job_id)
    cursor.execute(query)
    data = cursor.fetchall()
    print(data)
    name = data[0][1]
    query = '''DELETE FROM job_applications WHERE jobid='{job_id}' AND applicant='{username}' '''.format(
        job_id=job_id, username=session['username'])

    cursor.execute(query)

    conn.commit()

    query = "SELECT * from job_applications where applicant='{username}'".format(
        username=session['username'])
    cursor.execute(query)
    data = cursor.fetchall()

    msg = "Job application withdrawn"
    query_string = urlencode({'data': data, "msg": msg}, doseq=True)
    return redirect("/page?{}".format(query_string))


app.run(debug=True)


# str(counter),name, email, area, describe, url, for_type,salary,Job_location
