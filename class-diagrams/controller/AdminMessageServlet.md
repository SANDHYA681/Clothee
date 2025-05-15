```mermaid
classDiagram
    class AdminMessageServlet {
        -MessageDAO messageDAO
        -MessageService messageService
        -static final long serialVersionUID
        
        +AdminMessageServlet()
        +void doGet(HttpServletRequest request, HttpServletResponse response)
        +void doPost(HttpServletRequest request, HttpServletResponse response)
        -void listMessages(HttpServletRequest request, HttpServletResponse response)
        -void viewMessage(HttpServletRequest request, HttpServletResponse response)
        -void deleteMessage(HttpServletRequest request, HttpServletResponse response)
        -void editReply(HttpServletRequest request, HttpServletResponse response)
    }
```
