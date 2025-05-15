```mermaid
classDiagram
    class Message {
        -int id
        -int userId
        -String name
        -String email
        -String subject
        -String message
        -Timestamp createdAt
        -int parentId
        -transient boolean replied
        
        +Message()
        +Message(int id, int userId, String name, String email, String subject, String message, Timestamp createdAt, int parentId)
        +Message(int id, int userId, String name, String email, String subject, String message, Timestamp createdAt)
        +int getId()
        +void setId(int id)
        +int getUserId()
        +void setUserId(int userId)
        +String getName()
        +void setName(String name)
        +String getEmail()
        +void setEmail(String email)
        +String getSubject()
        +void setSubject(String subject)
        +String getMessage()
        +void setMessage(String message)
        +Timestamp getCreatedAt()
        +void setCreatedAt(Timestamp createdAt)
        +int getParentId()
        +void setParentId(int parentId)
        +boolean isReply()
        +boolean isReplied()
        +void setReplied(boolean replied)
        +boolean isRead()
        +String getFormattedDate()
        +String getShortMessage()
        +String toString()
    }
```
