<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.banking.database.jdbc" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="org.banking.models.Credential" %>

<%
    Credential login = (Credential) session.getAttribute("login");

    if (login == null || !login.is_admin) {
        response.sendRedirect("login.jsp");
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
            background-color: #f4f4f4;
        }
        .tabs {
            display: flex;
            justify-content: center;
            margin-bottom: 20px;
        }
        .tab {
            display: inline-block;
            padding: 15px 25px;
            cursor: pointer;
            background-color: #f1f1f1;
            border: 1px solid #ccc;
            border-bottom: none;
            margin-right: 2px;
            font-weight: bold;
        }
        .tab.active {
            background-color: #fff;
            border-bottom: 1px solid #fff;
        }
        .tab-content {
            display: none;
            padding: 20px;
            border: 1px solid #ccc;
            border-top: none;
            background-color: #fff;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .tab-content.active {
            display: block;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        table, th, td {
            border: 1px solid #ccc;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #f1f1f1;
        }
        tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        .container {
            background-color: #fff;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            max-width: 500px;
            width: 100%;
            margin: 0 auto;
        }
        h2 {
            margin-bottom: 20px;
            color: #333;
            text-align: center;
        }
        label {
            display: block;
            margin-bottom: 10px;
            color: #555;
        }
        input[type="text"],
        input[type="email"],
        input[type="number"],
        input[type="password"],
        input[type="date"],
        select {
            width: 100%;
            padding: 10px;
            margin-bottom: 20px;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
        }
        .submit-button, .delete-button {
            width: 100%;
            padding: 15px;
            background-color: #5cb85c;
            color: #fff;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
        }
        .delete-button {
            background-color: #d9534f;
        }
        .submit-button:hover, .delete-button:hover {
            background-color: #4cae4c;
        }
        .delete-button:hover {
            background-color: #c9302c;
        }
        .logout-button {
            position: absolute;
            top: 25px;
            right: 30px;
            padding: 10px 20px;
            background-color: #d9534f;
            color: #fff;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s ease;
            text-align: center;
            text-decoration: none;
            font-size: 16px;
        }
        .logout-button:hover {
            background-color: #c9302c;
        }
    </style>
</head>
<body>

<div class="tabs">
    <div class="tab active" onclick="showTabContent(event, 'tab1')">USER DETAILS</div>
    <div class="tab" onclick="showTabContent(event, 'tab2')">REGISTER USER</div>
    <div class="tab" onclick="showTabContent(event, 'tab3')">MODIFY USER</div>
    <div class="tab" onclick="showTabContent(event, 'tab4')">DELETE USER</div>
</div>

<div id="tab1" class="tab-content active">
    <h2>User Details</h2>
    <table>
        <tr>
            <th>Account No</th>
            <th>Name</th>
            <th>Mobile</th>
            <th>Email</th>
            <th>DOB</th>
        </tr>

        <%
            jdbc db = new jdbc();
            try {
                ResultSet rs = db.fetchUsers();
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getInt("account_no") %></td>
            <td><%= rs.getString("username") %></td>
            <td><%= rs.getString("mobile") %></td>
            <td><%= rs.getString("email") %></td>
            <td><%= rs.getDate("date_of_birth") %></td>
        </tr>
        <%
                }
            } catch (SQLException e) {
                throw new RuntimeException(e);
            } finally {
                db.close();
            }
        %>
    </table>
</div>

<div id="tab2" class="tab-content">
    <h2>Register User</h2>
    <div class="container">
        <form action="administration-Servlet" method="post">
            <input type="hidden" name="action" value="register">

            <label for="full_name">Full Name:</label>
            <input type="text" id="Full_Name" name="full_name" required>

            <label for="address">Address:</label>
            <input type="text" id="address" name="address" required>

            <label for="Mobile_No">Mobile No:</label>
            <input type="text" id="Mobile_No" name="mobile" required>

            <label for="register-email">Email:</label>
            <input type="email" id="register-email" name="email" required>

            <label for="account_type">Account Type:</label>
            <select id="account_type" name="account_type" required>
                <option value="Savings">Savings</option>
                <option value="Current">Current</option>
                <option value="Admin">Admin</option>
            </select>

            <label for="date_of_birth">Date Of Birth:</label>
            <input type="date" id="date_of_birth" name="date_of_birth" required>

            <label for="ID_Proof">ID Proof:</label>
            <select id="ID_Proof" name="ID_Proof" required>
                <option value="" disabled selected>--select--</option>
                <option value="Aadhar Card">Aadhar Card</option>
                <option value="Driving License">Driving License</option>
                <option value="Passport">Passport</option>
                <option value="Pan Card">Pan Card</option>
            </select>

            <input type="submit" class="submit-button" value="Register">
        </form>
    </div>
</div>


<div id="tab3" class="tab-content">
    <div class="container">
        <h2>Modify User</h2>
        <form action="administration-Servlet" method="post">
            <input type="hidden" name="action" value="modify-fetch">

            <label for="modify-account-no">Account No</label>
            <input type="text" id="modify-account-no" name="account-no" required>

            <button type="submit" class="submit-button">Fetch User</button>
        </form>
        <form action="administration-Servlet" method="post">

            <input type="hidden" name="action" value="modify-post">

            <label for="modify-username">Username</label>
            <input type="text" id="modify-username" name="username">

            <label for="modify-email">Email</label>
            <input type="email" id="modify-email" name="email">

            <label for="modify-mobile">Mobile</label>
            <input type="text" id="modify-mobile" name="mobile">

            <label for="address">Address</label>
            <input type="text" id="modify-address" name="address">

            <label for="modify-date-of-birth">Date of Birth</label>
            <input type="date" id="modify-date-of-birth" name="date_of_birth">

            <button type="submit" class="submit-button">Modify User</button>
        </form>
    </div>
</div>

<div id="tab4" class="tab-content">
    <div class="container">
        <h2>Delete User</h2>
        <form action="administration-Servlet" method="post">
            <input type="hidden" name="action" value="delete">

            <label for="delete-account-no">Account No</label>
            <input type="text" id="delete-account-no" name="

            account-no" required>

            <label for="delete-declaration">Enter "delete/`account no`" to delete</label>
            <input type="text" id="delete-declaration" name="declaration" required>

            <button type="submit" class="delete-button">Delete User</button>
        </form>
    </div>
</div>

<a href="removeAttribute" class="logout-button">Logout</a>

<script>
    function showTabContent(event, tabId) {

        const tabContents = document.querySelectorAll('.tab-content');
        tabContents.forEach(content => content.classList.remove('active'));

        const tabs = document.querySelectorAll('.tab');
        tabs.forEach(tab => tab.classList.remove('active'));

        document.getElementById(tabId).classList.add('active');

        event.currentTarget.classList.add('active');
    }

    let timeout;
    const maxIdleTime = 5 * 60 * 1000;

    function logout() {
        window.location.href = 'removeAttribute';
    }

    function resetTimer() {
        clearTimeout(timeout);
        timeout = setTimeout(logout, maxIdleTime);
    }

    window.onload = function() {
        document.onmousemove = resetTimer;
        document.onscroll = resetTimer;
        resetTimer();
    };
</script>

</body>
</html>
