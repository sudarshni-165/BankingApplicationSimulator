package org.banking.database;

import org.banking.models.Credential;
import org.banking.models.Transaction;
import org.banking.models.User;
import org.banking.models.Hashing;

import java.sql.*;

public class jdbc {

    private Connection conn;
    private Statement statement;

    public jdbc() {
        try {
            String username = "root";
            String password = "chico";
            String url = "jdbc:mysql://localhost:3306/banking";
            conn = DriverManager.getConnection(url, username, password);
            statement = conn.createStatement();

        } catch (SQLException e) {
            System.out.println("SQL Exception : "+ e.getMessage());
            System.out.println("Vendor Error : "+ e.getErrorCode());
        }
    }


    public Credential checkPassword(int account_no, String password) throws SQLException {
        ResultSet resultSet = statement.executeQuery(
                "SELECT username, password, is_admin FROM credintials WHERE account_no = " + account_no
        );
        resultSet.next();

        try {
            if (Hashing.verifyPassword(resultSet.getString("password"), password)) {
                System.out.println("Password Matched" + password);
                return new Credential(resultSet.getString("username"),
                        resultSet.getBoolean("is_admin"),
                        true,
                        account_no);
            }
        } catch (SQLException e) {
            throw new SQLException("Credential Not Found");
        }

        throw new SQLException("Password Not Matched");
    }

    public ResultSet fetchUsers() throws SQLException {
        String columns = " account_no, username, mobile, email, date_of_birth ";
        return statement.executeQuery(
                "SELECT" + columns + "FROM details;"
        );
    }

    public ResultSet fetchTransaction(int account_no) throws SQLException {
        String columns = " date_time, description, change_in_amount, balance_after ";
        return statement.executeQuery(
                "select  * from (SELECT" + columns + "FROM transactions WHERE account_no = " +
                        account_no + " Order By date_time desc limit 10) as datas order by date_time;"
        );
    }

    public void insertUser(User user) throws SQLException {
        ResultSet resultSet;
        do {
            resultSet = statement.executeQuery(
                    "SELECT 1 FROM details WHERE account_no = " + user.get_account_number() + ";"
            );
        } while (resultSet.next());

        PreparedStatement insertStatement = conn.prepareStatement(
                "INSERT INTO details (account_no, username, mobile, email, date_of_birth, account_type, id_proof, Address) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?);"
        );

        try {
            insertStatement.setInt(1, user.get_account_number());
            insertStatement.setString(2, user.get_full_name());
            insertStatement.setString(3, user.get_mobile());
            insertStatement.setString(4, user.get_email());
            insertStatement.setString(5, user.get_date_of_birth());
            insertStatement.setString(6, user.get_account_type());
            insertStatement.setString(7, user.get_id_proof());
            insertStatement.setString(8, user.get_address());

            insertStatement.executeUpdate();
        } catch (SQLException e) {
            System.out.println(user.get_account_number() + " " + e.getMessage());
        }

        PreparedStatement updateStatement = conn.prepareStatement("UPDATE credintials SET password = ? WHERE account_no = ?");

        try {
            updateStatement.setInt(2, user.get_account_number());
            updateStatement.setString(1, Hashing.hashPassword(user.get_password()));

            updateStatement.executeUpdate();
        } catch (SQLException e) {
            throw new SQLException(e.getMessage());
        }

        System.out.println(user.get_account_number() + " " + user.get_password());
    }

    public double fetchBalance(int account_no) throws SQLException {
        ResultSet rs = statement.executeQuery(
                "SELECT balance from customers where account_no = " + account_no + ";"
        );
        rs.next();
        return rs.getInt("balance");
    }

    public void updateBalance(int account_no, double balance) throws SQLException {
        PreparedStatement ps = conn.prepareStatement(
            "UPDATE customers SET balance = ? WHERE account_no = ?;"
        );

        ps.setDouble(1, balance);
        ps.setInt(2, account_no);
        ps.executeUpdate();

        ps = conn.prepareStatement(
                "INSERT INTO transactions (account_no, description, balance_before, change_in_amount, balance_after) values (?, ?, ?, ?, ?);"
        );
        ps.setInt(1, account_no);
        ps.setString(2, Transaction.message);
        ps.setDouble(3, Transaction.balance);
        ps.setDouble(4, Transaction.balance - balance);
        ps.setDouble(5, balance);
        ps.executeUpdate();

        System.out.println(account_no + " " + balance);
    }

    public void deleteUser(int account_no) throws SQLException {
        statement.executeUpdate("delete from customers where account_no = " + account_no);
        statement.executeUpdate("delete from credintials where account_no = " + account_no);
        statement.executeUpdate("delete from details where account_no = " + account_no);

        System.out.println("Successfully Deleted User " + account_no);
    }

    public void close() {
        try {
            if (statement != null) {
                statement.close();
            }
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException e) {
            System.out.println("SQL Exception during close: " + e.getMessage());
        }
    }

    public static void main(String[] args) {

        jdbc jdbc = new jdbc();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.out.println("ClassNotFoundException : " + e.getMessage());
            return;
        }

        try {
            jdbc.checkPassword(12345, "1543");
        } catch (SQLException e) {
            System.out.println("SQL Exception : "+ e.getMessage());
            System.out.println("Vendor Error : "+ e.getErrorCode());
        }
    }
}
