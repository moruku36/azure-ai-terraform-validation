# トラブルシューティング

検証中のエラーを次の形式で追記する。

## 記録形式

- 症状
- エラーメッセージ（実IDは匿名化）
- 原因
- Azure固有仕様
- Terraform Providerの挙動
- 修正内容
- 修正後の結果
- AI自律修正 / 人間承認の区別

## 初期確認で発生した事象

### 同名Subscriptionが複数存在

- 症状: Subscription表示名だけの`az account set`が複数一致で失敗した。
- 原因: ログイン中の一覧に同じ表示名のSubscriptionが複数存在した。
- 修正: ユーザー提供画面で確認できたID先頭をメモリ上でだけ照合し、一意のSubscriptionを選択した。
- 情報管理: 完全なSubscription ID、Tenant IDはファイルや公開ログへ保存していない。

### AzureRM 5.xのApplication Gateway属性変更

- 症状: 初回`terraform validate`が`enable_http2`をUnsupported argumentとして拒否した。
- 原因: AzureRM 5.2.0では属性名が`http2_enabled`である。
- Terraform Providerの挙動: 旧版の例にある属性名は現行schemaで利用できない。
- 修正: `terraform providers schema -json`で現行属性を確認し、`http2_enabled`へ修正した。
- 区分: AIがコードだけを自律修正。Azure変更・権限追加なし。

### Application Gateway probeのHost要件

- 症状: 初回planがHTTP probeについて`host`と`pick_host_name_from_backend_http_settings`のいずれかが必要として停止した。
- 原因: AzureRM ProviderがHTTP/HTTPS probeのHost headerを必須検証する。
- 修正: 任意Hostを受けるNginxに対し、probe専用Hostとして`127.0.0.1`を明示した。
- 修正後の方針: planを破棄して再生成する。失敗planはapplyしない。
- 区分: AIが自律修正。Azure変更・Security緩和なし。

### `AzurePlatformDNS` Service TagのAllow規則が拒否された

- 症状: 初回applyは29リソースを作成後、Backend NSGのDNS許可規則でHTTP 400となった。
- エラー: `SecurityRuleInvalidAccessType`。`AzurePlatformDNS`に対するAccess `Allow`は無効で、許可値は`Deny`と返された。
- 原因: `AzurePlatformDNS`はAzureプラットフォームDNSを明示的に遮断するための特殊Service Tagであり、Allow規則には使用できない。
- 修正: 無効なAllow規則だけをコードから削除した。Azure提供DNSを遮断する規則は追加しない。
- 安全性: 作成済み29リソースはState管理下。権限追加、Public IP追加、SSH公開、egress拡張は行っていない。
- 区分: AIがログからAzure固有仕様を特定し自律修正。

### 古いAzure CLIにFederated Credential用サブコマンドがない

- 症状: ローカルのAzure CLI 2.35.0では`az identity federated-credential`が利用できなかった。
- 原因: 現行機能より古いCLIを利用していた。
- 修正: CLI更新や権限追加は行わず、Azure Resource Manager APIを読み取り専用で呼び出してissuer、audience、subjectを検証した。
- 修正後の結果: PR用・apply用の2資格情報と、限定されたclaim条件を確認できた。
- 区分: AIが互換性問題を自律回避。Azureリソース変更なし。
