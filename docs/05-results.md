# 検証結果

## 現在の結果

- Azure CLIログイン: 成功
- 対象Subscription選択: 成功（実ID非掲載）
- Region: Japan East / Japan West利用可能
- VM SKU: Standard_B1sをJapan Eastで利用可能
- B-series quota: 2台を作成可能
- Terraform初回安全plan: 30追加、0変更、0削除、置換0
- Backend NICのPublic IP: 0
- Internet向けSSH規則: 0
- Webアクセス: Application Gateway経由でHTTP 200
- Application Gateway backend health: 2台ともHealthy
- VM: 2台ともRunning
- apply後のroot plan: `No changes`
- bootstrap: 12追加、0変更、0削除、置換0
- bootstrap apply後のplan: `No changes`
- Remote State: Azure Blobへの移行成功
- State locking: Blob leaseで競合拒否と解放後復旧を実動作確認
- State移行後のroot plan: `No changes`
- GitHub OIDC Azure login: 成功
- GitHub Actions Remote State初期化: 成功
- main workflow: validate / plan / applyまで実行成功
- CI入力差により12件の追加タグだけが削除されたが、入力値を共通化してタグだけを修復
- 修復後のローカル`terraform plan`: `No changes`
- 修復内容を反映したGitHub Actions: OIDC / Remote State / validate / plan / applyが成功
- 修復後のCI `terraform plan`: `No changes`
- 修復後のCI apply: 0追加・0変更・0削除

以降、GitHub Actions CI/CD、Monitoring、障害試験、cleanupの結果を追記する。
