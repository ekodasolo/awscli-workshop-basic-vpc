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
| project-dev-priv1-vpc              | Private Subnet AZ1            | AZ1のプライベートサブネット       |
| project-dev-priv2-vpc              | Private Subnet AZ2            | AZ2のプライベートサブネット       |
| project-dev-pub1-vpc               | Public Subnet AZ1             | AZ1のパブリックサブネット         |
| project-dev-pub2-vpc               | Public Subnet AZ2             | AZ2のパブリックサブネット         |
| project-dev-tran1-vpc              | Transit Subnet AZ1            | AZ1のトランジットサブネット       |
| project-dev-tran2-vpc              | Transit Subnet AZ2            | AZ2のトランジットサブネット       |


## Who: 作業者の前提

1. Unixシェルの基本操作ができること
1. TCP/IPの基本的な内容を理解しアドレス割り当てやIPルーティングが設定できること
1. AWS CLIの基本操作ができること
1. EC2/VPCへのアクセス権があること


## Where: 作業環境の条件

- CloudShellに接続し、CloudShell上で作業することを前提とする
- 必要な権限をもったIAM User/Iam RoleでCloudShellを立ち上げる


### Subnetの基本仕様

- Availability Zoneを2つ使い、それぞれのAZで、Public/Private/Transitサブネットを作成する。
- このVPCの中に、2つのAvailability Zoneを使って、合計6個のサブネットを作成する


## 詳細手順

1. [Subnetを作成する-1 Private Subnet](./0201-CreateSubnet-Runbook-1.md)
1. [Subnetを作成する-2 Public Subnet](./0202-CreateSubnet-Runbook-2.md)
1. [Subnetを作成する-3 Transit Subnet](./0203-CreateSubnet-Runbook-3.md)
1. [Subnetを作成する-4 Private Subnet](./0204-CreateSubnet-Runbook-4.md)
1. [Subnetを作成する-5 Public Subnet](./0205-CreateSubnet-Runbook-5.md)
1. [Subnetを作成する-6 Transit Subnet](./0206-CreateSubnet-Runbook-6.md)


# EOD
