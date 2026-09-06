# 検証結果

## 最終結果（cleanup前）

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
- Monitoring: 12追加・0変更・0削除、適用後`No changes`
- 障害試験: VM 1台停止でBackend異常AlertがFired、HTTP 200継続、復旧後Resolved
- cleanup前root plan: `No changes`
- cleanup前bootstrap plan: `No changes`

## 集計

記録とGitHub Actions APIで確認できる範囲のみを集計した。

| 項目 | 確認値 |
|---|---:|
| 初回validate成功まで | 2回 |
| 初回安全plan成功まで | 2回 |
| 初回apply完了まで | 2回 |
| 記録された主要エラー・運用事象 | 10件 |
| AIが原因特定・修正した事象 | 10件 |
| GitHub Actions失敗 | 2回 |
| 意図しないTerraform差分 | 1回（追加タグのみ） |
| 実行されたdestroy / replace | 0回 |
| destroy / replace回避の安全確認 | 少なくとも3回 |
| `No changes`確認 | 記録・ログ上少なくとも9回 |

人間介入はクリック数ではなく判断カテゴリで集計した。Subscription指定、Remote State公開endpoint設計の承認、GitHub設定・本人確認、タグ修復apply承認、最終cleanup承認の5カテゴリである。技術修正はAIが実施し、権限の自動拡張は行っていない。

cleanup結果は削除後のAzure読み取り確認を基に追記する。
