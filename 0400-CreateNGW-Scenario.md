# NAT Gatewayの作成

## About
トレーニングに利用するVPCを作成するCLI手順シナリオ。


## Why: 作業の目的
基本的なネットワークを構築する。

本シナリオでは、NAT Gatewayを作成する。

## What: 操作するもの
作成するリソースは以下。すべて東京リージョン（ap-northeast-1）に作成する。

|  Name                              |  用途                         | 備考                            |
| ---------------------------------- | ----------------------------- | ------------------------------- |
| project-dev-nat1-eip               | NAT Gateway1 EIP              | 今回はシングル構成               |
| project-dev-nat1-natgw             | NAT Gateway1                  | 今回はシングル構成               |


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


### NAT Gatewayの基本仕様

- 一般的に冗長性をもったNAT環境を構築する場合は、AZごとに1つのNAT Gatewayを立てる構成を取る。
- 本トレーニングでは、簡略化のために、ap-northeast-1aに1個のNAT Gatewayを立てる構成にする。
‐ 新規にEIPを払い出し、NAT Gatewayに関連づける。


## 詳細手順

1. [NGW用のElasticIPを作成する](./0401-CreateEIP-Runbook-1.md)
1. [NGWを作成する](./0402-CreateNGW-Runbook-1.md)


# EOD
