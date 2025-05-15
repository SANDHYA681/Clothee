```mermaid
classDiagram
    class LoginServlet {
        -UserService userService
        -static final long serialVersionUID
        
        +void init()
        +void doGet(HttpServletRequest request, HttpServletResponse response)
        +void doPost(HttpServletRequest request, HttpServletResponse response)
        -void showLoginForm(HttpServletRequest request, HttpServletResponse response)
        -void login(HttpServletRequest request, HttpServletResponse response)
        -void logout(HttpServletRequest request, HttpServletResponse response)
    }
```
