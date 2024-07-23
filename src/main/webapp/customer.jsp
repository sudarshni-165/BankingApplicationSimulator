<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="org.banking.database.jdbc" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="org.banking.models.Credential" %>

<%
    Credential login = (Credential) session.getAttribute("login");
    if (login == null || login.is_admin) {
        response.sendRedirect("login.jsp");
    }
    else {
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Banking Tabs</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .tabs-container {
            position: relative;
            background-color: #fff;
            width: 80%;
            max-width: 800px;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.1);
            border-radius: 10px;
            overflow: hidden;
        }
        .welcome-text {
            text-align: center;
            padding: 20px;
            font-size: 1.5em;
            background-color: #f4f4f4;
            color: #333;
        }
        .tabs {
            display: flex;
            justify-content: space-around;
            background-color: #007bff;
        }
        .tabs button {
            flex: 1;
            padding: 20px 0;
            font-size: 1.2em;
            color: #fff;
            background-color: #007bff;
            border: none;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .tabs button:hover {
            background-color: #0056b3;
        }
        .tabs button.active {
            background-color: #0056b3;
        }
        .tab-content {
            padding: 20px;
            display: none;
        }
        .tab-content.active {
            display: block;
        }
        input[type="number"], input[type="text"], input[type="date"], button, input[type="submit"] {
            width: 100%;
            padding: 15px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 5px;
            box-sizing: border-box;
            font-size: 1em;
        }
        input[type="submit"], button {
            background-color: #007bff;
            color: white;
            border: none;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        input[type="submit"]:hover, button:hover {
            background-color: #0056b3;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #f2f2f2;
            color: #333;
        }
        tr:hover {
            background-color: #f9f9f9;
        }
        .logout-button {
            position: absolute;
            top: 10px;
            right: 10px;
            padding: 10px 20px;
            background-color: #dc3545;
            color: white;
            border: none;
            border-radius: 5px;
            width: 100px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        .logout-button:hover {
            background-color: #c82333;
        }
        #welcome-text {
            position: relative;
            display: flex;
            justify-content: center;
            align-content: center;
        }

    </style>
</head>
<body>
    <div class="tabs-container">
        <%
            jdbc db = new jdbc();
            double balance;

            try {
                balance = db.fetchBalance(login.accountNumber);
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
        %>
        <div id="welcome-text"><h4>Hello <%=login.name%>, Your balance ₹<%=balance%></h4></div>
        <a href="removeAttribute"><button class="logout-button">Logout</button></a>

        <div class="tabs">
            <button class="tab-button active" data-tab="deposit">Deposit</button>
            <button class="tab-button" data-tab="withdrawal">Withdrawal</button>
            <button class="tab-button" data-tab="fund-transfer">Fund Transfer</button>
            <button class="tab-button" data-tab="mini-statement">Mini Statement</button>
        </div>
        <div id="deposit" class="tab-content active">
            <form action="transaction" method="post">
            <h2>Deposit</h2>
            <input type="hidden" name="source" value="deposit">
            <input type="number" id="deposit-amount" name="deposit" required><br>
            <input type="submit" value="Deposit">
            </form>
        </div>
        <div id="withdrawal" class="tab-content">
            <form action="transaction" method="post">
            <h2>Withdrawal</h2>
            <input type="hidden" name="source" value="withdraw">
            <label for="withdrawal-amount">Enter Amount to Withdraw:</label>
            <input type="number" id="withdrawal-amount" name="withdraw" required><br>
            <input type="submit" value="Withdraw">
            </form>
        </div>
        <div id="fund-transfer" class="tab-content">
            <form action="transaction" method="post">
            <h2>Fund Transfer</h2>
            <input type="hidden" name="source" value="transfer">
            <label for="transfer-account-number">Enter the Account Number:</label>
            <input type="text" id="transfer-account-number" name="transfer-account-number" required><br>
            <label for="transfer-amount">Enter the Amount:</label>
            <input type="number" id="transfer-amount" name="transfer" required><br>
            <input type="submit" value="Transfer">
            </form>
        </div>
        <div id="mini-statement" class="tab-content">
            <h2>Mini Statement</h2>
            <table id="statement-table">

                    <tr>
                        <th>Date</th>
                        <th>Description</th>
                        <th>Amount</th>
                        <th>Balance</th>
                    </tr>

                    <%;
                        try {
                            ResultSet rs = db.fetchTransaction(login.accountNumber);
                            while (rs.next()) {
                    %>
                    <tr>
                        <td><%= rs.getDate("date_time") %></td>
                        <td><%= rs.getString("description") %></td>
                        <td><%= rs.getInt("change_in_amount") %></td>
                        <td><%= rs.getInt("balance_after") %></td>
                    </tr>
                    <%
                            }
                        } catch (SQLException e) {
                            %><%="Error Occured"%><%
                            System.out.println(e.getMessage());
                        } finally {
                            db.close();
                        }
                    %>

            </table>    
        </div>
    </div>

    <script>
        const tabButtons = document.querySelectorAll('.tab-button');
        const tabContents = document.querySelectorAll('.tab-content');

        tabButtons.forEach(button => {
            button.addEventListener('click', () => {
                const tab = button.getAttribute('data-tab');

                tabButtons.forEach(btn => btn.classList.remove('active'));
                tabContents.forEach(content => content.classList.remove('active'));

                button.classList.add('active');
                document.getElementById(tab).classList.add('active');
            });
        });

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

<%
    }
%>