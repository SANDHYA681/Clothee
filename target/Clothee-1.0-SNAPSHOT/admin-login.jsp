<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBConnection" %>
<%@ page import="util.PasswordHasher" %>
<%@ page import="model.User" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Admin Login</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 0;
        }
        .container {
            max-width: 400px;
            margin: 100px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h2 {
            text-align: center;
            margin-bottom: 20px;
            color: #333;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="email"], input[type="password"] {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        button {
            background-color: #4a6bdf;
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
        }
        button:hover {
            background-color: #3a5bcf;
        }
        .alert {
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 4px;
        }
        .alert-danger {
            background-color: #f8d7da;
            color: #721c24;
        }
        .alert-success {
            background-color: #d4edda;
            color: #155724;
        }
        .home-link {
            text-align: center;
            margin-top: 15px;
        }
        .home-link a {
            color: #4a6bdf;
            text-decoration: none;
        }
        .home-link a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>Admin Login</h2>

        <%
        // Process form submission
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String email = request.getParameter("email");
            String password = request.getParameter("password");

            // Validate input
            if (email == null || password == null || email.isEmpty() || password.isEmpty()) {
                %><div class="alert alert-danger">Email and password are required</div><%
            } else {
                Connection conn = null;
                PreparedStatement stmt = null;
                ResultSet rs = null;

                try {
                    conn = DBConnection.getConnection();
                    String query = "SELECT * FROM users WHERE email = ? AND role = 'admin'";
                    stmt = conn.prepareStatement(query);
                    stmt.setString(1, email);
                    rs = stmt.executeQuery();

                    if (rs.next()) {
                        String storedPassword = rs.getString("password");

                        // Check password
                        if (PasswordHasher.checkPassword(password, storedPassword)) {
                            // Create user object
                            User user = new User();
                            user.setId(rs.getInt("id"));
                            user.setFirstName(rs.getString("first_name"));
                            user.setLastName(rs.getString("last_name"));
                            user.setEmail(rs.getString("email"));
                            user.setRole(rs.getString("role"));

                            // Create session
                            HttpSession userSession = request.getSession(true);
                            userSession.setAttribute("userId", user.getId());
                            userSession.setAttribute("userEmail", user.getEmail());
                            userSession.setAttribute("userName", user.getFirstName() + " " + user.getLastName());
                            userSession.setAttribute("userRole", user.getRole());
                            userSession.setAttribute("user", user);

                            // Redirect to admin dashboard
                            response.sendRedirect("admin/dashboard.jsp");
                            return;
                        } else {
                            %><div class="alert alert-danger">Invalid password</div><%
                        }
                    } else {
                        %><div class="alert alert-danger">Admin account not found</div><%
                    }
                } catch (SQLException e) {
                    %><div class="alert alert-danger">Database error: <%= e.getMessage() %></div><%
                } finally {
                    try {
                        if (rs != null) rs.close();
                        if (stmt != null) stmt.close();
                        if (conn != null) conn.close();
                    } catch (SQLException e) {
                        // Ignore
                    }
                }
            }
        }
        %>

        <form method="post" action="<%= request.getContextPath() %>/LoginServlet">
            <input type="hidden" name="userType" value="admin">
            <div class="form-group">
                <label for="email">Email Address</label>
                <input type="email" id="email" name="email" required>
            </div>

            <div class="form-group">
                <label for="password">Password</label>
                <input type="password" id="password" name="password" required>
            </div>

            <div class="form-group">
                <button type="submit">Login</button>
            </div>

            <div class="home-link">
                <a href="index.jsp">Back to Home</a>
            </div>
        </form>
    </div>
</body>
</html>
