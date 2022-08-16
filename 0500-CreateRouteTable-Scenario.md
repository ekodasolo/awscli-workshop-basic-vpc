# Training用VPCの作成

## About
トレーニングに利用するVPCを作成するCLI手順シナリオ。


## Why: 作業の目的
基本的なネットワークを構築する。

本シナリオでは、VPCを作成する。

## What: 操作するもの
作成するリソースは以下。すべて東京リージョン（ap-northeast-1）に作成する。

|  Name                              |  用途                         | 備考                            |
| ---------------------------------- | ----------------------------- | ------------------------------- |
| hubtraining-dev-{your-name}-vpc    | VPC                      | VPC                 |


## Who: 作業者の前提

1. AWS CLIでS3の操作ができること
1. VPCへのアクセス権があること


## Where: 作業環境の条件

- 会社の環境からAWS CloudShellに接続し、CloudShell上で作業することを前提とする
- 作業時のIAM Roleはsysadmin-roleを使用していること

### VPCの基本仕様

- クラスAのプライベートアドレスから、1名につき/24のサイズを割り当てる
‐ 10.0.*.0/24 がトレーニング受講者に割り当てられる
- このVPCの中に、2つのAvailability Zoneを使って、合計6個のサブネットを作成する


## 詳細手順

1. [VCPを作成する](./hubtraining-0101-CreateVPC-Runbook.md)


# EOD
