# [0604] Transit Gateway Route Table Associationの作成

## About
VPCを作成するCLI手順書。

本手順では、Transit Gateway AttachmentをRoute Tableに関連づける。


## When: 作業の条件

### Before: 事前前提条件

以下を作業の前提条件とする。

1. 対象のTransit Gateway Attachmentが存在する
1. 対象のTransit Gateway Route Tableが存在する


### After: 作業終了状況

以下が完了の条件。

1. 対象のTransit Gateway Route Tablにアタッチメントが関連づけられている。


## How: 以下は作業手順

### 1. 前処理

#### 1.1 処理パラメータの準備

パラメータの事後確認用ファイルの設定

```bash
RUNBOOK_TITLE="0604-associate-attachment-to-route-table"
DIR_PARAMETER="."
FILE_PARAMETER="${DIR_PARAMETER}/$(date +%Y-%m-%d)-${RUNBOOK_TITLE}.env" \
    && echo ${FILE_PARAMETER}
```

手順の実行パラメータ
```bash
# 変数に値をセット
AWS_REGION="ap-northeast-1"
VPC_TGW_ATT_NAME="project-dev-main-att"
VPC_TGW_RTBL_NAME="project-dev-main-tgwrtbl"
```

```bash
# 値を確認
cat << ETX
    AWS_REGION=           ${AWS_REGION}
    VPC_TGW_ATT_NAME=     ${VPC_TGW_ATT_NAME}
    VPC_TGW_RTBL_NAME=     ${VPC_TGW_RTBL_NAME}

ETX
```


#### 1.2 事前条件1の確認

対象のTransit Gateway Attachmentが存在する

```bash
aws ec2 describe-transit-gateway-vpc-attachments \
    --filters "Name=tag:Name,Values=${VPC_TGW_ATT_NAME}" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "TransitGatewayVpcAttachments": [
        {
            "TransitGatewayAttachmentId": "tgw-attach-0b9444761b2899568",
            "TransitGatewayId": "tgw-077d31c2ff4f44413",
            "VpcId": "vpc-0469f7ff591ec393f",
            "VpcOwnerId": "276300016017",
            "State": "available",
            "SubnetIds": [
                "subnet-03a3b997352f62b8b",
                "subnet-0dc4efc75a94104b1"
            ],
            "CreationTime": "2022-08-18T08:52:04+00:00",
            "Options": {
                "DnsSupport": "enable",
                "Ipv6Support": "disable",
                "ApplianceModeSupport": "disable"
            },
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "project-dev-main-att"
                }
            ]
        }
    ]
}
```

Attachmentが作成済みならば、Attachment IDを取得しておく。

```bash
VPC_TGW_ATT_ID=$(aws ec2 describe-transit-gateway-vpc-attachments \
    --filters "Name=tag:Name,Values=${VPC_TGW_ATT_NAME}" \
    --query "TransitGatewayVpcAttachments[].TransitGatewayAttachmentId" \
    --output text \
    --region ${AWS_REGION}) && echo ${VPC_TGW_ATT_ID}
```

出力例
```output
tgw-attach-0b9444761b2899568
```

#### 1.3 事前条件2の確認

対象のTransit Gateway Route Tableが存在する

```bash
aws ec2 describe-transit-gateway-route-tables \
    --filters "Name=tag:Name,Values=${VPC_TGW_RTBL_NAME}" \
    --region ${AWS_REGION}
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

Transit Gateway Route Tableが作成済みならば、Route Table IDを取得しておく。

```bash
VPC_TGW_RTBL_ID=$(aws ec2 describe-transit-gateway-route-tables \
    --filters "Name=tag:Name,Values=${VPC_TGW_RTBL_NAME}" \
    --query "TransitGatewayRouteTables[].TransitGatewayRouteTableId" \
    --output text \
    --region ${AWS_REGION}) && echo ${VPC_TGW_RTBL_ID}
```

結果の例
```output
tgw-rtb-0aabce3c4f06f4810
```


### 2. 主処理

#### 2.1 リソースの操作 (ASSOCIATE)

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 associate-transit-gateway-route-table \
    --transit-gateway-route-table-id ${VPC_TGW_RTBL_ID} \
    --transit-gateway-attachment-id ${VPC_TGW_ATT_ID} \
    --region ${AWS_REGION}
        
EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 associate-transit-gateway-route-table \
    --transit-gateway-route-table-id ${VPC_TGW_RTBL_ID} \
    --transit-gateway-attachment-id ${VPC_TGW_ATT_ID} \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "Association": {
        "TransitGatewayRouteTableId": "tgw-rtb-04940311f2b894841",
        "TransitGatewayAttachmentId": "tgw-attach-0b9444761b2899568",
        "ResourceId": "vpc-0469f7ff591ec393f",
        "ResourceType": "vpc",
        "State": "associating"
    }
}
```


### 3. 後処理

#### 3.1 完了条件1、2の結果確認

1. 対象のTransit Gateway Route Tablにアタッチメントが関連づけられている。

```bash
aws ec2 get-transit-gateway-route-table-associations \
    --transit-gateway-route-table-id ${VPC_TGW_RTBL_ID} \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "Associations": [
        {
            "TransitGatewayAttachmentId": "tgw-attach-00f6d6560efb30fc6",
            "ResourceId": "vpc-0c736bdf614e0b81d",
            "ResourceType": "vpc",
            "State": "associated"
        }
    ]
}
```

#### 3.99 中間リソースの削除

今回は特になし

#### Navigation

Next: [Propagationを設定する](./0605-PropagateRoute-Runbook.md)

# EOD
