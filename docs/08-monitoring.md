# Monitoring

## 設計

既存のApplication GatewayとVMが自動提供するAzure Monitorプラットフォームメトリクスを主に使用する。詳細VM監視エージェント、VM Insights、Application Insights、NATやネットワーク構成の追加は行わない。

Application Gatewayのアクセスログだけを専用のStandard LRS Storage Accountへ保存する。保存先は匿名公開を禁止し、Storage firewallでAzure trusted services以外を拒否する。診断設定の保存期間指定は廃止済みのため、Storage lifecycle policyで30日後に削除する。

Log Analyticsは今回不採用とした。対象Subscriptionでは必要なResource Providerが未登録であり、短期検証のためにサブスクリプション全体の設定変更とログ取り込み課金を追加しないためである。

## 監視項目

| 対象 | シグナル | 条件 | 期間 | 重大度 |
|---|---|---:|---:|---:|
| Web停止 | `HealthyHostCount` | 1未満 | 5分 | 1 |
| Backend異常 | `UnhealthyHostCount` | 0超 | 5分 | 2 |
| HTTP 5xx | `ResponseStatus` / `5xx` | 5件超 | 5分 | 2 |
| VM CPU | `Percentage CPU` | 平均80%超 | 5分 | 2 |
| VM可用性 | `VmAvailabilityMetric` | 平均1未満 | 5分 | 1 |
| 明示的VM停止 | Activity Logのdeallocate操作 | 操作発生 | イベント | - |

Action GroupはすべてのAlert Ruleへ接続する。通知Receiverは個人情報をリポジトリへ入れないため未設定で、Fired / Resolved状態はAzure Monitorで確認する。実運用では組織管理の通知先を別途追加する。

Azure Portal/CLIから標準メトリクス、Alert history、Activity Logを確認できる。Application Gatewayアクセスログは専用Storageへ保存される。Nginx guest log収集は、Azure Monitor AgentとData Collection Ruleの運用負荷・通信・ログ量を避けるため今回の最小構成には含めない。

## コスト

標準プラットフォームメトリクス自体は追加収集設定を必要としない。課金対象は主にMetric Alertの時系列評価、Action Group通知を追加した場合の通知、少量のStorage容量・トランザクションである。短期・低トラフィック検証では既存Application Gateway費用に比べ小さい想定だが、正確な額は実際のログ量とAzure Monitorの地域別料金による。

## AWS編との主な違い

- CloudWatch AlarmではなくAzure Monitor Metric AlertとAction Groupを使う。
- VM停止・状態異常にはAzure固有の`VmAvailabilityMetric`とActivity Logを組み合わせる。
- Application GatewayのBackend healthは`HealthyHostCount` / `UnhealthyHostCount`で監視する。
- CloudWatch Logs相当の検索基盤は追加せず、低コストなStorage archiveを選択した。
- AzureでCLI/PortalからVMを停止するとAvailability Metricが欠損する場合があるため、明示的なdeallocate操作もActivity Logで補完する。

## 公式資料

- [Monitor Azure Application Gateway](https://learn.microsoft.com/azure/application-gateway/monitor-application-gateway)
- [Monitoring data reference for Azure Virtual Machines](https://learn.microsoft.com/azure/virtual-machines/monitor-vm-reference)
- [Diagnostic settings in Azure Monitor](https://learn.microsoft.com/azure/azure-monitor/platform/diagnostic-settings)
- [Azure Monitor cost and usage](https://learn.microsoft.com/azure/azure-monitor/fundamentals/cost-usage)

## 実装・検証結果

- `terraform fmt -check -recursive`: 成功
- `terraform validate`: 成功
- ローカルplan: 12追加・0変更・0削除
- plan検査: 既存リソースのupdate / replace / destroyなし
- 追加内訳: Action Group 1、Metric Alert 7、Activity Log Alert 1、Diagnostic Setting 1、ログStorage 1、Lifecycle Policy 1

GitHub Actionsと障害試験の結果は実行後に追記する。
