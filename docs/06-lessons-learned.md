# 学びとAWS比較

## 初期設計比較

| 観点 | AWS編 | Azure編 |
| --- | --- | --- |
| L7負荷分散 | Application Load Balancer | Application Gateway Standard_v2 |
| Network | VPC + Public/Private Subnet | VNet + App Gateway専用/Backend Subnet |
| Backend outbound | S3 Gateway Endpoint中心 | 明示的NAT Gateway |
| State locking | S3 native lockfile | Azure Blob lease |
| CI Identity | IAM Role | User-assigned Managed Identity |
| Federation | IAM OIDC Provider/Trust Policy | Entra Federated Identity Credential |
| 権限 | IAM Policy | Azure RBAC |
| ログ | ALB access log to S3 | Application Gateway access log to Log Analytics |

AzureではResource Groupをcleanup境界にできる。一方、Application Gateway専用Subnet、2026年以降の明示的outbound、Entra IdentityとAzure RBACの分離が追加の設計要素となる。

