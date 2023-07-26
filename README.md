# Terraform SaaS Gateway

A Proof of Concept for the API part of SaaS project.

```mermaid
graph LR
    A[Client] -->|Request| B[API Gateway]
    B -->|Authorization Request| C[Lambda Authorizer]
    C -->|Policy Document| B
    B -->|Valid Request| D[Backend]
    D -->|Response| B
    B -->|Response| A
```