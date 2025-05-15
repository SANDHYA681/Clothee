```mermaid
classDiagram
    class AuthenticationFilter {
        +void init(FilterConfig filterConfig)
        +void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
        +void destroy()
    }
```
