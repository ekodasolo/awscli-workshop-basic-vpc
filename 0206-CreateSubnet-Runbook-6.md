# [0206] Subnetを作成する

## About
VPCを作成するCLI手順書。

本手順では、ap-northeast-1cにTransit Subnetを作成する


## When: 作業の条件

### Before: 事前前提条件

以下を作業の前提条件とする。
1. VPCが作成済みである。
1. 割り当てたIPアドレス範囲と重複する既存のサブネットが無く、作成可能である。

### After: 作業終了状況

以下が完了の条件。
1. Subnetが作成されている。
1. SubnetのCIDR範囲は指定どおりになっている。


## How: 以下は作業手順

### 1. 前処理

#### 1.1 処理パラメータの準備

パラメータの事後確認用ファイルの設定

```bash
RUNBOOK_TITLE="0206-create-subnet-6"
DIR_PARAMETER="."
FILE_PARAMETER="${DIR_PARAMETER}/$(date +%Y-%m-%d)-${RUNBOOK_TITLE}.env" \
    && echo ${FILE_PARAMETER}
```

手順の実行パラメータ
```bash
# 変数に値をセット
AWS_REGION="ap-northeast-1"
VPC_CIDR="10.0.1.0/24"
VPC_SUBNET_CIDR="10.0.1.224/28"
VPC_SUBNET_AZ="ap-northeast-1c"
VPC_SUBNET_NAME="project-dev-tran2-subnet"
```

```bash
# 値を確認
cat << ETX
    AWS_REGION=${AWS_REGION}
    VPC_SUBNET_AZ=${VPC_SUBNET_AZ}
    VPC_CIDR=${VPC_CIDR}
    VPC_SUBNET_CIDR=${VPC_SUBNET_CIDR}
    VPC_SUBNET_NAME=${VPC_SUBNET_NAME}

ETX
```


#### 1.2 事前条件1の確認

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


#### 1.3 事前条件2の確認

割り当てたIPアドレス範囲と重複する既存のサブネットが無く、作成可能である。

```bash
### 同じCIDRのSubnetが無いことを確認
aws ec2 describe-subnets \
    --filters "Name=cidrBlock,Values=${VPC_SUBNET_CIDR}" \
    --region ${AWS_REGION}
```

結果の例
```output
(出力無し)
```

### 2. 主処理

#### 2.1 リソースの操作 (CREATE)

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 create-subnet \
    --vpc-id ${VPC_ID} \
    --cidr-block ${VPC_SUBNET_CIDR} \
    --availability-zone ${VPC_SUBNET_AZ} \
    --tag-specifications ResourceType=subnet,Tags="[{ Key=Name,Value=${VPC_SUBNET_NAME} }]" \
    --region ${AWS_REGION}
        
EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 create-subnet \
    --vpc-id ${VPC_ID} \
    --cidr-block ${VPC_SUBNET_CIDR} \
    --availability-zone ${VPC_SUBNET_AZ} \
    --tag-specifications ResourceType=subnet,Tags="[{ Key=Name,Value=${VPC_SUBNET_NAME} }]" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "Subnet": {
        "AvailabilityZone": "ap-northeast-1a",
        "AvailabilityZoneId": "apne1-az4",
        "AvailableIpAddressCount": 59,
        "CidrBlock": "10.0.0.0/26",
        "DefaultForAz": false,
        "MapPublicIpOnLaunch": false,
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
}
```

### 3. 後処理

#### 3.1 完了条件1、2の結果確認

1. Subnetが作成されている。
1. SubnetのCIDR範囲は指定どおりになっている。


```bash
aws ec2 describe-subnets \
    --filters "Name=cidrBlock,Values=${VPC_SUBNET_CIDR}" \
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


#### 3.99 中間リソースの削除

今回は特になし

#### Navigation

Next: [Internet Gatewayを作成する](./0300-CreateIGW-Scenario.md)

# EOD
