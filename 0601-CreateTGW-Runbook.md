# [0601] Transit Gatewayの作成

## About
VPCを作成するCLI手順書。

本手順では、VPC間を中継するTransit Gatewayを作成する。


## When: 作業の条件

### Before: 事前前提条件

以下を作業の前提条件とする。
1. 指定したAS番号を使った既存のTransit Gatewayが存在しない

### After: 作業終了状況

以下が完了の条件。

1. Transit Gatewayが作成されている。
1. Transit Gatewayは指定したAS番号を使う様に設定されている。


## How: 以下は作業手順

### 1. 前処理

#### 1.1 処理パラメータの準備

パラメータの事後確認用ファイルの設定

```bash
RUNBOOK_TITLE="0601-create-transit-gateway"
DIR_PARAMETER="."
FILE_PARAMETER="${DIR_PARAMETER}/$(date +%Y-%m-%d)-${RUNBOOK_TITLE}.env" \
    && echo ${FILE_PARAMETER}
```

手順の実行パラメータ
```bash
# 変数に値をセット
AWS_REGION="ap-northeast-1"
VPC_TGW_NAME="project-dev-main-tgw"
VPC_TGW_DESC="My project Transit Gateway"
VPC_TGW_OPTIONS_ASN="64512"
VPC_TGW_OPTIONS_ACCEPT_SHARED_ATT="disable"
VPC_TGW_OPTIONS_DEFAULT_RTBL_ASSOC="disable"
VPC_TGW_OPTIONS_DEFAULT_RTBL_PRPG="disable"
VPC_TGW_OPTIONS_ECMP="disable"
VPC_TGW_OPTIONS_DNS="enable"
VPC_TGW_OPTIONS="AmazonSideAsn=${VPC_TGW_OPTIONS_ASN},AutoAcceptSharedAttachments=${VPC_TGW_OPTIONS_ACCEPT_SHARED_ATT},DefaultRouteTableAssociation=${VPC_TGW_OPTIONS_DEFAULT_RTBL_ASSOC},DefaultRouteTablePropagation=${VPC_TGW_OPTIONS_DEFAULT_RTBL_PRPG},VpnEcmpSupport=${VPC_TGW_OPTIONS_ECMP},DnsSupport=${VPC_TGW_OPTIONS_DNS}"
###
```

```bash
# 値を確認
cat << ETX
    AWS_REGION=${AWS_REGION}
    VPC_TGW_NAME=                       ${VPC_TGW_NAME}
    VPC_TGW_DESC=                       ${VPC_TGW_DESC}
    VPC_TGW_OPTIONS_ASN=                ${VPC_TGW_OPTIONS_ASN}
    VPC_TGW_OPTIONS_ACCEPT_SHARED_ATT=  ${VPC_TGW_OPTIONS_ACCEPT_SHARED_ATT}
    VPC_TGW_OPTIONS_DEFAULT_RTBL_ASSOC= ${VPC_TGW_OPTIONS_DEFAULT_RTBL_ASSOC}
    VPC_TGW_OPTIONS_DEFAULT_RTBL_PRPG=  ${VPC_TGW_OPTIONS_DEFAULT_RTBL_PRPG}
    VPC_TGW_OPTIONS_ECMP=               ${VPC_TGW_OPTIONS_ECMP}
    VPC_TGW_OPTIONS_DNS=                ${VPC_TGW_OPTIONS_DNS}
    VPC_TGW_OPTIONS=                    ${VPC_TGW_OPTIONS}

ETX
```


#### 1.2 事前条件1の確認

指定したAS番号を使った既存のTransit Gatewayが存在しない

```bash
aws ec2 describe-transit-gateways \
    --filters "Name=options.amazon-side-asn,Values=${VPC_TGW_OPTIONS_ASN}"
```

結果の例
```output
{
    "TransitGateways": []
}
```


### 2. 主処理

#### 2.1 リソースの操作 (CREATE)

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 create-transit-gateway \
    --description "${VPC_TGW_DESC}" \
    --tag-specifications "ResourceType=transit-gateway,Tags=[{ Key=Name,Value=${VPC_TGW_NAME} }]" \
    --options "${VPC_TGW_OPTIONS}" \
    --region ${AWS_REGION}
        
EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 create-transit-gateway \
    --description "${VPC_TGW_DESC}" \
    --tag-specifications "ResourceType=transit-gateway,Tags=[{ Key=Name,Value=${VPC_TGW_NAME} }]" \
    --options "${VPC_TGW_OPTIONS}" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "TransitGateway": {
        "TransitGatewayId": "tgw-077d31c2ff4f44413",
        "TransitGatewayArn": "arn:aws:ec2:ap-northeast-1:123456789012:transit-gateway/tgw-077d31c2ff4f44413",
        "State": "pending",
        "OwnerId": "123456789012",
        "Description": "My project Transit Gateway",
        "CreationTime": "2022-08-18T07:32:33+00:00",
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
}
```


### 3. 後処理

#### 3.1 完了条件1、2の結果確認

1. Transit Gatewayが作成されている。
1. Transit Gatewayは指定したAS番号を使う様に設定されている。


```bash
aws ec2 describe-transit-gateways \
    --filters "Name=options.amazon-side-asn,Values=${VPC_TGW_OPTIONS_ASN}"
```

結果の例
```output
{
    "TransitGateways": [
        {
            "TransitGatewayId": "tgw-077d31c2ff4f44413",
            "TransitGatewayArn": "arn:aws:ec2:ap-northeast-1:123456789012:transit-gateway/tgw-077d31c2ff4f44413",
            "State": "available",
            "OwnerId": "123456789012",
            "Description": "My project Transit Gateway",
            "CreationTime": "2022-08-18T07:32:33+00:00",
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


#### 3.99 中間リソースの削除

今回は特になし

#### Navigation

Next: [Attachmentを作成する](./0602-CreateTGWAttachment-Runbook.md)

# EOD
