# Training用VPCの作成

## About
トレーニングに利用するVPCを作成するCLI手順シナリオ。


## Why: 作業の目的
基本的なネットワークを構築する。

本シナリオでは、NAT Gatewayを作成する。

## What: 操作するもの
作成するリソースは以下。すべて東京リージョン（ap-northeast-1）に作成する。

|  Name                              |  用途                         | 備考                            |
| ---------------------------------- | ----------------------------- | ------------------------------- |
| hubtraining-dev-nat1-natgw         | NAT Gateway1                  | 今回はシングル構成               |


## Who: 作業者の前提

1. AWS CLIでVPCの操作ができること
1. VPCへのアクセス権があること


## Where: 作業環境の条件

- 会社の環境からAWS CloudShellに接続し、CloudShell上で作業することを前提とする
- 作業時のIAM Roleはsysadmin-roleを使用していること

### NAT Gatewayの基本仕様

- 一般的に冗長性をもったNAT環境を構築する場合は、AZごとに1つのNAT Gatewayを立てる構成を取る。
- 本トレーニングでは、簡略化のために、ap-northeast-1aに1個のNAT Gatewayを立てる構成にする。
‐ 新規にEIPを払い出し、NAT Gatewayに関連づける。


## 詳細手順

1. [VCPを作成する](./hubtraining-0101-CreateVPC-Runbook.md)


# EOD
