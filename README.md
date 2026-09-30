# Azure AI Terraform Validation

[English](README.md) | [日本語](README.ja.md)

An Azure-native AI-assisted Terraform lifecycle experiment covering networking, Entra ID, RBAC, workload federation, Blob state locking, monitoring, fault tests, and cleanup.

## Validation scope

The experiment follows bootstrap, core web infrastructure, state migration, federated GitHub CI/CD, monitoring, failure testing, and cleanup. Azure-specific decisions include VNet design, Application Gateway, virtual machines, Entra workload federation, Azure RBAC, Blob lease locking, and Azure Monitor.

Start with the [multi-cloud final comparison](docs/10-multi-cloud-final-report.md), then the provider-specific records in `docs/`. This is a lifecycle-validation repository; inspect the recorded status before attempting to recreate infrastructure.


## Contents

- [bootstrap/](bootstrap)
- [docs/](docs)

## Detailed documentation

The [Japanese guide](README.ja.md) retains the complete original setup instructions, configuration, examples, project status, and limitations. Supporting documents keep their existing language.
