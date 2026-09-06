# Azureアーキテクチャ

## 構成図

```mermaid
flowchart TB
  internet((Internet))

  subgraph azure[Azure / Japan East]
    pipAgw[Standard Public IP]

    subgraph vnet[Virtual Network]
      subgraph appgwSubnet[Application Gateway専用Subnet]
        appgw[Application Gateway Standard_v2\nHTTP listener / Health probe]
      end

      subgraph backendSubnet[Private Backend Subnet]
        vm1[Linux VM #1 / Zone 1\nNginx / Public IPなし]
        vm2[Linux VM #2 / Zone 2\nNginx / Public IPなし]
        nat[NAT Gateway\n明示的outboundのみ]
      end
    end
  end

  internet -->|HTTP 80| pipAgw --> appgw
  appgw -->|HTTP 80 only| vm1
  appgw -->|HTTP 80 only| vm2
  vm1 -->|HTTP/HTTPS package access| nat
  vm2 -->|HTTP/HTTPS package access| nat
  nat --> internet
```

## Azure固有の判断

- HTTP 5xxメトリクス、アクセスログ、HTTP Health Probeを満たすためApplication Gateway Standard_v2を採用する。
- Application GatewayはAzure仕様に従い専用Subnetへ配置する。
- 2026年以降のPrivate Subnetでは暗黙outboundへ依存せず、NAT Gatewayを明示する。
- Backend NSGのAzure既定VNet許可を明示的に上書きし、Application Gateway SubnetからTCP 80だけを許可する。
- WAF、Azure Firewall、Bastionは今回の要件外かつ高コストなため追加しない。

