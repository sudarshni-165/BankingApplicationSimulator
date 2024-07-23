package org.banking.servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.banking.database.jdbc;
import org.banking.models.User;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet(name="AdministrationrServlet", value="/administration-Servlet")
public class administrationServlet extends HttpServlet {

    public void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        jdbc db = new jdbc();
        String action = request.getParameter("action");
        System.out.println(action);

        switch (action) {
            case "register":
                try {
                    db.insertUser(new User(request));
                    response.getWriter().println("Successfully registered");
                } catch (SQLException | InterruptedException e) {
                    response.getWriter().println(e.getMessage());
                    throw new RuntimeException(e);
                } finally {
                    db.close();
                }
                break;

            case "modify-fetch":
                break;

            case "modify-post":
                break;

            case "delete":

                try {
                    int id = Integer.parseInt(request.getParameter("account-no"));
                    String declaration = request.getParameter("declaration");

                    if (declaration.equals("delete/" + id) && db.fetchBalance(id) == 0) {
                        db.deleteUser(id);
                        response.getWriter().println("Successfully deleted");
                    } else {
                        response.getWriter().println("Deletion failed");
                    }

                } catch (SQLException e) {
                    response.getWriter().println(e.getMessage());
                    throw new RuntimeException(e);
                } finally {
                    db.close();
                }
                break;

        }


    }
}
