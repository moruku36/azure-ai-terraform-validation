# Monitoring

## 採用予定

- Azure Monitor platform metrics
- Application Gateway `HealthyHostCount` / `UnhealthyHostCount`
- Application Gateway `ResponseStatus`の5xxグループ
- VM `Percentage CPU` / availability metric
- Application Gateway Access Log
- Log Analytics Workspace
- Application Insights Standard Availability Test

通知先未指定のためAction Groupは初期構成へ含めない。アクセスログの保持期間を短くし、高額なVM InsightsやAzure Firewallは追加しない。

Terraform実装、アラーム条件、実コスト、障害試験結果は基盤確認後に追記する。

