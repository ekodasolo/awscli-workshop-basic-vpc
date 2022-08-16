# Training用VPC-Subnetの作成

## About
トレーニングに利用するVPCを作成するCLI手順シナリオ。


## Why: 作業の目的
基本的なネットワークを構築する。

本シナリオでは、Subnetを作成する。

## What: 操作するもの
作成するリソースは以下。すべて東京リージョン（ap-northeast-1）に作成する。

|  Name                              |  用途                         | 備考                            |
| ---------------------------------- | ----------------------------- | ------------------------------- |
| hubtraining-dev-priv1-vpc          | Private Subnet AZ1            | AZ1のプライベートサブネット       |
| hubtraining-dev-priv2-vpc          | Private Subnet AZ2            | AZ2のプライベートサブネット       |
| hubtraining-dev-pub1-vpc           | Public Subnet AZ1             | AZ1のパブリックサブネット         |
| hubtraining-dev-pub2-vpc           | Public Subnet AZ2             | AZ2のパブリックサブネット         |
| hubtraining-dev-tran1-vpc          | Transit Subnet AZ1            | AZ1のトランジットサブネット       |
| hubtraining-dev-tran2-vpc          | Transit Subnet AZ2            | AZ2のトランジットサブネット       |


## Who: 作業者の前提

1. AWS CLIでS3の操作ができること
1. VPCへのアクセス権があること


## Where: 作業環境の条件

- 会社の環境からAWS CloudShellに接続し、CloudShell上で作業することを前提とする
- 作業時のIAM Roleはsysadmin-roleを使用していること

### Subnetの基本仕様

- Availability Zoneを2つ使い、それぞれのAZで、Public/Private/Transitサブネットを作成する。
- このVPCの中に、2つのAvailability Zoneを使って、合計6個のサブネットを作成する


## 詳細手順

1. [VCPを作成する](./hubtraining-0101-CreateVPC-Runbook.md)


# EOD
