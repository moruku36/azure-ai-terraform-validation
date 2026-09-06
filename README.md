# Azure AI Terraform Validation

## 検証目的

自然言語の共通要件から、AI/CodexがAzureネイティブな構成を設計し、Terraform、GitHub Actions、Workload Identity Federation、Remote State、Monitoring、障害試験、cleanupまで自律実装できるかを検証する。

AWS編のサービス名を単純置換せず、Azure固有のネットワーク、Microsoft Entra ID、Azure RBAC、Blob lease locking、Azure Monitorの設計判断を記録する。

## アーキテクチャ概要

- Region: Japan East
- Internet公開: Application Gateway Standard_v2のHTTP 80のみ
- Backend: Availability Zoneを分けたPrivate Linux VM 2台
- VM Public IP / Internet SSH: なし
- Outbound: Private Subnetに関連付けたNAT Gateway
- Security: NSGでApplication Gateway SubnetからVMのHTTP 80だけを許可
- State: 初期構築はLocal State、後続フェーズでAzure Blobへ移行
- Monitoring / CI/CD: 基盤疎通確認後に段階的に追加

![Azure検証環境のアーキテクチャ構成図](docs/images/azure-architecture.png)

構成要素と設計判断の詳細は[Azureアーキテクチャ](docs/02-architecture.md)を参照してください。

## 最終結果

| 項目 | 結果 |
|---|---|
| Terraform Web基盤 | Private VM 2台、Application Gateway経由HTTP 200 |
| CI/CD | PRのfmt/init/validate/plan、mainの保存plan applyに成功 |
| Identity | GitHub OIDC + Entra Federated Identity。Client Secret不使用 |
| Remote State | Azure Blobへ移行、暗号化・Versioning・Soft Deleteを有効化 |
| State locking | Blob leaseによる競合拒否と解放後復旧を実証 |
| Monitoring | Azure Monitor Alert、Action Group、診断ログをTerraform管理 |
| 障害試験 | VM 1台停止を検知し、HTTP 200継続、復旧後Resolvedを確認 |
| 最終整合性 | ローカル・GitHub Actionsとも`No changes` |
| Cleanup | root 41件、bootstrap 12件を削除し、対象リソース残存0を確認 |

AIは設計、Terraform、CI/CD、OIDC、State移行、監視、障害試験、原因分析をほぼ一貫して実行できた。人間はSubscription指定、設計・権限承認、GitHub本人確認、破壊的操作の承認を担当した。

Azure編は成功と評価する。クラウドエンジニアLevel 2相当の標準的なWeb基盤、CI/CD、Federation、State、Monitoring、障害試験、cleanupは、適切な安全境界と人間の承認があればAIへ大部分を委任できた。高権限、課金・公開方式、Account本人確認、最終destroyの責任は人間に残す。

## AWS編との主な違い

- Application Gatewayは専用Subnetを必要とし、Private VMの明示的outboundにNAT Gatewayを採用した。
- Entra Federated CredentialとAzure RBACは、AWS IAM Trust PolicyとPermission PolicyよりIdentity・Federation・Scopeの役割が分離している。
- Azure Blob BackendはState Blob自体のleaseでlockingし、AWS編のS3 native lockfileとは方式が異なる。
- 監視ログはLog AnalyticsのProvider登録と取り込み費用を避け、専用Storage archiveを採用した。
- Resource Groupを明確な作成・cleanup境界として利用できる。

## Terraform実行方法

実値ファイル、State、plan、CredentialはGitへ追加しない。

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
# terraform.tfvarsへ自分のSSH公開鍵を設定する
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
# planを確認してからのみ実行する
terraform apply tfplan
terraform output -raw application_url
```

GitHub cloud plan/applyはRepository Variable `AZURE_ENVIRONMENT_ACTIVE=true`の場合だけ実行する。cleanup後は未設定または`false`にし、文書更新による意図しない再作成を防止する。

## ドキュメント

- [検証シナリオ](docs/01-scenario.md)
- [Azureアーキテクチャ](docs/02-architecture.md)
- [Terraform実装](docs/03-implementation.md)
- [トラブルシューティング](docs/04-troubleshooting.md)
- [検証結果](docs/05-results.md)
- [学びとAWS比較](docs/06-lessons-learned.md)
- [CI/CD・OIDC・Remote State](docs/07-cicd-oidc-remote-state.md)
- [Monitoring](docs/08-monitoring.md)
