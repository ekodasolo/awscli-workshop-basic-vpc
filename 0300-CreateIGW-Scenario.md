# Training用VPC-Internet Gatewayの作成

## About
トレーニングに利用するVPCを作成するCLI手順シナリオ。


## Why: 作業の目的
基本的なネットワークを構築する。

本シナリオでは、IGWを作成する。

## What: 操作するもの
作成するリソースは以下。すべて東京リージョン（ap-northeast-1）に作成する。

|  Name                              |  用途                         | 備考                            |
| ---------------------------------- | ----------------------------- | ------------------------------- |
| project-dev-main-igw               | IGW                      | Internet Gateway                 |


## Who: 作業者の前提

1. Unixシェルの基本操作ができること
1. TCP/IPの基本的な内容を理解しアドレス割り当てやIPルーティングが設定できること
1. AWS CLIの基本操作ができること
1. EC2/VPCへのアクセス権があること


## Where: 作業環境の条件

- CloudShellに接続し、CloudShell上で作業することを前提とする
- 必要な権限をもったIAM User/Iam RoleでCloudShellを立ち上げる


### VPCの基本仕様

- クラスAのプライベートアドレスから、1名につき/24のサイズを割り当てる
‐ 10.0.*.0/24 がトレーニング受講者に割り当てられる
- このVPCの中に、2つのAvailability Zoneを使って、合計6個のサブネットを作成する


## 詳細手順

1. [IGWを作成する](./0301-CreateIGW-Runbook.md)


# EOD
