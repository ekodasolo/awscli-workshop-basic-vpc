# [0602] Transit Gateway Attachmentの作成

## About
VPCを作成するCLI手順書。

本手順では、Transit Gateway VPC Attachmentを作成する。


## When: 作業の条件

### Before: 事前前提条件

以下を作業の前提条件とする。

1. 対象のTransit Gatewayが存在する
1. 対象のVPCが存在する
1. 対象のサブネット2つ存在する
1. 対象のVPCに既にAttachmentが作成されていない


### After: 作業終了状況

以下が完了の条件。

1. Transit Gateway Attachmentが作成されている。
1. Attachmentは指定したVPCに配置されている。
1. Attachmentは指定したTransit Gatewayに紐づいている。


## How: 以下は作業手順

### 1. 前処理

#### 1.1 処理パラメータの準備

パラメータの事後確認用ファイルの設定

```bash
RUNBOOK_TITLE="0602-create-transit-gateway-attachment"
DIR_PARAMETER="."
FILE_PARAMETER="${DIR_PARAMETER}/$(date +%Y-%m-%d)-${RUNBOOK_TITLE}.env" \
    && echo ${FILE_PARAMETER}
```

手順の実行パラメータ
```bash
# 変数に値をセット
AWS_REGION="ap-northeast-1"
VPC_CIDR="10.0.0.0/24"
VPC_TGW_NAME="project-dev-main-tgw"
VPC_TGW_ATT_NAME="project-dev-main-att"
VPC_SUBNET_CIDR_1="10.0.0.96/28"
VPC_SUBNET_CIDR_2="10.0.0.224/28"
```

```bash
# 値を確認
cat << ETX
    AWS_REGION=           ${AWS_REGION}
    VPC_CIDR=             ${VPC_CIDR}
    VPC_TGW_DESC=         ${VPC_TGW_DESC}
    VPC_TGW_NAME=         ${VPC_TGW_NAME}
    VPC_TGW_ATT_NAME      ${VPC_TGW_ATT_NAME}
    VPC_SUBNET_CIDR_1=    ${VPC_SUBNET_CIDR_1}
    VPC_SUBNET_CIDR_2=    ${VPC_SUBNET_CIDR_2}

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

#### 1.3 事前条件2の確認

対象のVPCが存在する

VPCが作成済みか、事前に確認する。

```bash
# 既存のVPCを確認
aws ec2 describe-vpcs --filters "Name=cidr,Values=${VPC_CIDR}"
```

VPCが作成済みであれば、期待通り。

結果の例
```output
{
    "Vpcs": [
        {
            "CidrBlock": "10.0.0.0/24",
            "DhcpOptionsId": "dopt-19edf471",
            "State": "available",
            "VpcId": "vpc-0e9801d129EXAMPLE",
            "OwnerId": "111122223333",
            "InstanceTenancy": "default",
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-062c64cfafEXAMPLE",
                    "CidrBlock": "10.0.0.0/24",
                    "CidrBlockState": {
                        "State": "associated"
                    }
                }
            ],
            "IsDefault": false,
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "Not Shared"
                }
            ]
        }
    ]
}
```

VPCが作成済みならば、VPC IDを取得しておく。

```bash
VPC_ID=$(aws ec2 describe-vpcs \
    --filters "Name=cidr,Values=${VPC_CIDR}" \
    --query "Vpcs[].VpcId" \
    --region ${AWS_REGION} \
    --output text) && echo ${VPC_ID}
```

出力例
```output
vpc-0a60eb65b4EXAMPLE
```

#### 1.4 事前条件3の確認

対象のサブネット2つ存在する


```bash
aws ec2 describe-subnets \
    --filters "Name=cidrBlock,Values=${VPC_SUBNET_CIDR_1}" \
    --region ${AWS_REGION}

aws ec2 describe-subnets \
    --filters "Name=cidrBlock,Values=${VPC_SUBNET_CIDR_2}" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "Subnets": [
        {
            "AvailabilityZone": "ap-northeast-1a",
            "AvailabilityZoneId": "apne1-az4",
            "AvailableIpAddressCount": 59,
            "CidrBlock": "10.0.0.0/26",
            "DefaultForAz": false,
            "MapPublicIpOnLaunch": false,
            "MapCustomerOwnedIpOnLaunch": false,
            "State": "available",
            "SubnetId": "subnet-02628d223dabe8c90",
            "VpcId": "vpc-0756cd50821dadaf3",
            "OwnerId": "123456789012",
            "AssignIpv6AddressOnCreation": false,
            "Ipv6CidrBlockAssociationSet": [],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "project-dev-priv1-subnet"
                }
            ],
            "SubnetArn": "arn:aws:ec2:ap-northeast-1:123456789012:subnet/subnet-02628d223dabe8c90",
            "EnableDns64": false,
            "Ipv6Native": false,
            "PrivateDnsNameOptionsOnLaunch": {
                "HostnameType": "ip-name",
                "EnableResourceNameDnsARecord": false,
                "EnableResourceNameDnsAAAARecord": false
            }
        }
    ]
}
```

Subnetが作成済みならば、Subnet IDを取得しておく。

```bash
VPC_SUBNET_ID_1=$(aws ec2 describe-subnets \
    --filters "Name=cidrBlock,Values=${VPC_SUBNET_CIDR_1}" \
    --query "Subnets[].SubnetId" \
    --output text \
    --region ${AWS_REGION})

VPC_SUBNET_ID_2=$(aws ec2 describe-subnets \
    --filters "Name=cidrBlock,Values=${VPC_SUBNET_CIDR_2}" \
    --query "Subnets[].SubnetId" \
    --output text \
    --region ${AWS_REGION})

VPC_SUBNET_ID_LIST="${VPC_SUBNET_ID_1} ${VPC_SUBNET_ID_2}"

cat << ETX
    VPC_SUBNET_ID_1=    ${VPC_SUBNET_ID_1}
    VPC_SUBNET_ID_2=    ${VPC_SUBNET_ID_2}
    VPC_SUBNET_ID_LIST= ${VPC_SUBNET_ID_LIST}

ETX
```

結果の例
```output
    VPC_SUBNET_ID_1=    subnet-0dc4efc75a94104b1
    VPC_SUBNET_ID_2=    subnet-03a3b997352f62b8b
    VPC_SUBNET_ID_LIST= subnet-0dc4efc75a94104b1 subnet-03a3b997352f62b8b

```

#### 1.5 事前条件4の確認

対象のVPCに既にAttachmentが作成されていない

```bash
aws ec2 describe-transit-gateway-vpc-attachments \
    --filters "Name=vpc-id,Values=${VPC_ID}"
```

結果の例
```
{
    "TransitGatewayVpcAttachments": []
}
```



### 2. 主処理

#### 2.1 リソースの操作 (CREATE)

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 create-transit-gateway-vpc-attachment \
    --transit-gateway-id "${VPC_TGW_ID}"  \
    --vpc-id ${VPC_ID} \
    --subnet-ids ${VPC_SUBNET_ID_LIST} \
    --tag-specifications "ResourceType=transit-gateway-attachment,Tags=[{ Key=Name,Value=${VPC_TGW_ATT_NAME} }]" \
    --region ${AWS_REGION}
        
EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 create-transit-gateway-vpc-attachment \
    --transit-gateway-id "${VPC_TGW_ID}"  \
    --vpc-id ${VPC_ID} \
    --subnet-ids ${VPC_SUBNET_ID_LIST} \
    --tag-specifications "ResourceType=transit-gateway-attachment,Tags=[{ Key=Name,Value=${VPC_TGW_ATT_NAME} }]" \
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

1. Transit Gateway Attachmentが作成されている。
1. Attachmentは指定したVPCに配置されている。

```bash
aws ec2 describe-transit-gateway-vpc-attachments \
    --filters "Name=vpc-id,Values=${VPC_ID}" "Name=state,Values=available"
```

結果の例
```output
{
    "TransitGatewayVpcAttachments": [
        {
            "TransitGatewayAttachmentId": "tgw-attach-00f6d6560efb30fc6",
            "TransitGatewayId": "tgw-06a6e896802d6a03a",
            "VpcId": "vpc-0c736bdf614e0b81d",
            "VpcOwnerId": "276300016017",
            "State": "available",
            "SubnetIds": [
                "subnet-0739221200c0232b2",
                "subnet-0775fedf0a677b4f6"
            ],
            "CreationTime": "2022-08-18T04:19:23+00:00",
            "Options": {
                "DnsSupport": "enable",
                "Ipv6Support": "disable",
                "ApplianceModeSupport": "disable"
            },
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "project-dev-tran-tgw"
                }
            ]
        }
    ]
}
```

#### 3.1 完了条件3の結果確認

3. Attachmentは指定したTransit Gatewayに紐づいている。

```bash
aws ec2 describe-transit-gateway-vpc-attachments \
    --filters "Name=transit-gateway-id,Values=${VPC_TGW_ID}" "Name=state,Values=available"
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

#### 3.99 中間リソースの削除

今回は特になし

#### Navigation

Next: [TGW Route Tableを作成する](./0603-CreateTGWRouteTable-Runbook.md)

# EOD
