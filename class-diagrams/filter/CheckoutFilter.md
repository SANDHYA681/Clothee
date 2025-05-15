```mermaid
classDiagram
    class CheckoutFilter {
        -CartService cartService
        
        +void init(FilterConfig filterConfig)
        +void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
        +void destroy()
    }
```
