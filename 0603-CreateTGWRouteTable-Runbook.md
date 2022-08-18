# [0603] Transit Gateway Route Tableの作成

## About
VPCを作成するCLI手順書。

本手順では、Transit Gateway Route Tableを作成する。


## When: 作業の条件

### Before: 事前前提条件

以下を作業の前提条件とする。

1. 対象のTransit Gatewayが存在する


### After: 作業終了状況

以下が完了の条件。

1. Transit Gateway Route Tableが作成されている。
1. Transit Gateway Route Tableは指定したTransit Gatewayに紐づいている。


## How: 以下は作業手順

### 1. 前処理

#### 1.1 処理パラメータの準備

パラメータの事後確認用ファイルの設定

```bash
RUNBOOK_TITLE="0603-create-transit-gateway-route-table"
DIR_PARAMETER="."
FILE_PARAMETER="${DIR_PARAMETER}/$(date +%Y-%m-%d)-${RUNBOOK_TITLE}.env" \
    && echo ${FILE_PARAMETER}
```

手順の実行パラメータ
```bash
# 変数に値をセット
AWS_REGION="ap-northeast-1"
VPC_TGW_NAME="project-dev-main-tgw"
VPC_TGW_RTBL_NAME="project-dev-main-tgwrtbl"
```

```bash
# 値を確認
cat << ETX
    AWS_REGION=           ${AWS_REGION}
    VPC_TGW_NAME=         ${VPC_TGW_NAME}
    VPC_TGW_RTBL_NAME     ${VPC_TGW_RTBL_NAME}

ETX
```


#### 1.2 事前条件1の確認

対象のTransit Gatewayが存在する

```bash
aws ec2 describe-transit-gateways \
    --filters "Name=tag:Name,Values=${VPC_TGW_NAME}"  "Name=state,Values=available"
```

結果の例
```output
{
    "TransitGateways": [
        {
            "TransitGatewayId": "tgw-06a6e896802d6a03a",
            "TransitGatewayArn": "arn:aws:ec2:ap-northeast-1:276300016017:transit-gateway/tgw-06a6e896802d6a03a",
            "State": "available",
            "OwnerId": "276300016017",
            "Description": "My project transit gateway",
            "CreationTime": "2022-08-18T03:56:04+00:00",
            "Options": {
                "AmazonSideAsn": 64512,
                "AutoAcceptSharedAttachments": "disable",
                "DefaultRouteTableAssociation": "disable",
                "DefaultRouteTablePropagation": "disable",
                "VpnEcmpSupport": "disable",
                "DnsSupport": "enable",
                "MulticastSupport": "disable"
            },
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "project-dev-main-tgw"
                }
            ]
        }
    ]
}
```

Transit Gatewayが作成済みならば、Transit Gateway IDを取得しておく。

```bash
VPC_TGW_ID=$(aws ec2 describe-transit-gateways \
    --filters "Name=tag:Name,Values=${VPC_TGW_NAME}" "Name=state,Values=available" \
    --query "TransitGateways[].TransitGatewayId" \
    --output text \
    --region ${AWS_REGION}) && echo ${VPC_TGW_ID}
```

出力例
```output
tgw-06a6e896802d6a03a
```


### 2. 主処理

#### 2.1 リソースの操作 (CREATE)

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 create-transit-gateway-route-table \
    --transit-gateway-id ${VPC_TGW_ID} \
    --tag-specifications "ResourceType=transit-gateway-route-table,Tags=[{ Key=Name,Value=project-dev-main-tgwrtbl }]" \
    --region ${AWS_REGION}
        
EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 create-transit-gateway-route-table \
    --transit-gateway-id ${VPC_TGW_ID} \
    --tag-specifications "ResourceType=transit-gateway-route-table,Tags=[{ Key=Name,Value=project-dev-main-tgwrtbl }]" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "TransitGatewayRouteTable": {
        "TransitGatewayRouteTableId": "tgw-rtb-0aabce3c4f06f4810",
        "TransitGatewayId": "tgw-06a6e896802d6a03a",
        "State": "pending",
        "DefaultAssociationRouteTable": false,
        "DefaultPropagationRouteTable": false,
        "CreationTime": "2022-08-18T04:29:29+00:00",
        "Tags": [
            {
                "Key": "Name",
                "Value": "project-dev-main-tgwrtbl"
            }
        ]
    }
}
```


### 3. 後処理

#### 3.1 完了条件1、2の結果確認

1. Transit Gateway Route Tableが作成されている。
1. Transit Gateway Route Tableは指定したTransit Gatewayに紐づいている。

```bash
aws ec2 describe-transit-gateway-route-tables \
    --filters "Name=transit-gateway-id,Values=${VPC_TGW_ID}"
```

結果の例
```output
{
    "TransitGatewayRouteTables": [
        {
            "TransitGatewayRouteTableId": "tgw-rtb-0aabce3c4f06f4810",
            "TransitGatewayId": "tgw-06a6e896802d6a03a",
            "State": "available",
            "DefaultAssociationRouteTable": false,
            "DefaultPropagationRouteTable": false,
            "CreationTime": "2022-08-18T04:29:29+00:00",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "project-dev-main-tgwrtbl"
                }
            ]
        }
    ]
}
```

#### 3.99 中間リソースの削除

今回は特になし

#### Navigation

Next: [Associationを設定する-Public](./0604-AssociateAttachment-Runbook.md)

# EOD
