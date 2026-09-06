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

## 現在の進捗

- [x] ローカルCLI・Azureログイン・Subscription・Region確認
- [x] Azureアーキテクチャと概算コストのレビュー
- [x] Terraform基盤コード作成
- [x] `terraform init / validate / plan`（30追加、0変更、0削除、置換なし）
- [ ] Web基盤apply・HTTP 200確認
- [ ] Remote State移行
- [ ] GitHub OIDC CI/CD
- [ ] Monitoring・障害試験
- [ ] AWS比較・最終cleanup

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

## ドキュメント

- [検証シナリオ](docs/01-scenario.md)
- [Azureアーキテクチャ](docs/02-architecture.md)
- [Terraform実装](docs/03-implementation.md)
- [トラブルシューティング](docs/04-troubleshooting.md)
- [検証結果](docs/05-results.md)
- [学びとAWS比較](docs/06-lessons-learned.md)
- [CI/CD・OIDC・Remote State](docs/07-cicd-oidc-remote-state.md)
- [Monitoring](docs/08-monitoring.md)
