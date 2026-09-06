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

以降、GitHub Actions CI/CD、Monitoring、障害試験、cleanupの結果を追記する。
