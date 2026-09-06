# CI/CD・OIDC・Remote State

## 採用設計

- Backend: Azure Blob Storage
- Authentication: Microsoft Entra ID
- State locking: Blob lease
- Recovery: Blob Versioning、Blob / Container Soft Delete
- Storage Key / SAS / Client Secret: 不使用
- PR Identity: 対象Resource Group Reader + State Blob Data Reader
- apply Identity: 対象Resource Group Contributor + State Blob Data Contributor
- Federation subjects: 同一repositoryの`pull_request`と`terraform-production` Environmentに限定

GitHub-hosted runnerを維持するためStorage public network endpointは到達可能とするが、匿名public access、Shared Key認証、container public accessは禁止する。

## Bootstrap実装結果

専用Resource Group内に次をTerraformで作成した。

- Standard LRS Storage Account
- private Blob Container
- Blob Versioning
- Blob / Container Soft Delete（7日）
- User Assigned Managed Identity（PR用・apply用）
- GitHub Actions用Federated Identity Credential（PR用・Environment用）
- workload Resource GroupおよびState Containerに限定したRBAC
- State移行者向けの一時的な`Storage Blob Data Contributor`

bootstrap planは12追加、0変更、0削除、置換0で、apply後のplanは`No changes`だった。StorageはHTTPS限定、TLS 1.2以上、匿名Blob access禁止、Shared Key禁止、Microsoft Entra認証を既定とした。FederationのissuerはGitHub Actions、audienceは`api://AzureADTokenExchange`、subjectは対象repositoryのPRと保護Environmentに限定した。

## Local State移行

1. 移行先Containerが空であることをMicrosoft Entra認証で確認した。
2. Local StateをGit管理対象外の`.state-backups/`へ複製した。
3. 元StateとバックアップのサイズおよびSHA-256が一致することを確認した。
4. backendを`azurerm`、`use_azuread_auth = true`、`use_cli = true`として設定した。
5. State Keyを`terraform/azure-validation.tfstate`に固定した。
6. `terraform init -migrate-state -force-copy`でBlobへ移行した。
7. 指定KeyにState Objectが1件存在することをMicrosoft Entra認証で確認した。
8. 移行後のroot planが`No changes`であることを確認した。

Subscription ID、Tenant ID、Storage Account名、Client IDなどの実環境値は公開文書へ記載しない。backend固有値もGit管理対象外とし、CIではGitHub Variablesから与える。

## State locking実動作確認

Azure Blob leaseを60秒だけ手動取得した状態でroot planを実行し、TerraformがState lock取得エラーで同時処理を拒否することを確認した。leaseを確実に解放した後、root planが再び成功して`No changes`となった。AWS編のS3 native lockfileとは異なり、AzureRM BackendはState Blob自体のleaseを排他制御に利用する。

## 使用した権限

- 移行時: State Container scopeの`Storage Blob Data Contributor`のみ
- PR Identity: workload Resource Groupの`Reader`、State Containerの`Storage Blob Data Reader`
- apply Identity: workload Resource Groupの`Contributor`、State Containerの`Storage Blob Data Contributor`
- Storage Account Key、SAS、Client Secret: 不使用

State移行時の一時RBACはCI/CD実動作確認後、cleanup対象として削除する。

## 人間介入とAI自律実行

- 人間介入: 使用Subscriptionの指定、public network endpointを利用する低コストState設計の承認
- AI自律実行: bootstrap設計・実装、plan/apply、Storage security検証、Federation設定検証、Local Stateバックアップ、State移行、Blob lease試験、移行前後の整合性確認
