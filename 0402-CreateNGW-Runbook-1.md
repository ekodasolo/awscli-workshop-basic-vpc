# NAT Gatewayを作成する

## About
VPCを作成するCLI手順書。

本手順では、NAT Gatewayを作成する。


## When: 作業の条件

### Before: 事前前提条件

以下を作業の前提条件とする。
1. VPCが作成済みである。
1. サブネットが作成済みである。
1. EIPが作成済みである。
1. 対象のVPCにはNAT Gatewayが作成されていない。

### After: 作業終了状況

以下が完了の条件。
1. NAT Gatewayが作成されている。
1. NAT Gatewayは対象のサブネットに作成されている。


## How: 以下は作業手順

### 1. 前処理

#### 1.1 処理パラメータの準備

パラメータの事後確認用ファイルの設定

```bash
RUNBOOK_TITLE="0402-create-ngw"
DIR_PARAMETER="."
FILE_PARAMETER="${DIR_PARAMETER}/$(date +%Y-%m-%d)-${RUNBOOK_TITLE}.env" \
    && echo ${FILE_PARAMETER}
```

手順の実行パラメータ
```bash
# 変数に値をセット
AWS_REGION="ap-northeast-1"
VPC_CIDR="10.0.0.0/24"
VPC_SUBNET_CIDR="10.0.0.0/26"
VPC_EIP_NAME="project-dev-nat1-eip"
VPC_NGW_NAME="project-dev-nat1-natgw"
```

```bash
# 値を確認
cat << ETX
    AWS_REGION=${AWS_REGION}
    VPC_CIDR=${VPC_CIDR}
    VPC_SUBNET_CIDR=${VPC_SUBNET_CIDR}
    VPC_EIP_NAME=${VPC_EIP_NAME}

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

サブネットが作成済みである。

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

Subnetが作成済みならば、Subnet IDを取得しておく。

```bash
VPC_SUBNET_ID=$(aws ec2 describe-subnets \
    --filters "Name=cidrBlock,Values=${VPC_SUBNET_CIDR}" \
    --query "Subnets[].SubnetId" \
    --output text \
    --region ${AWS_REGION}) && echo ${VPC_SUBNET_ID}
```

結果の例
```output
subnet-02628d223dabe8c90
```

#### 1.4 事前条件3の確認

EIPが作成済みである。

```bash
aws ec2 describe-addresses \
    --filter "Name=tag:Name,Values=${VPC_EIP_NAME}" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "Addresses": [
        {
            "PublicIp": "35.72.57.159",
            "AllocationId": "eipalloc-0c01530e4ab2bf446",
            "Domain": "vpc",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "project-dev-nat1-eip"
                }
            ],
            "PublicIpv4Pool": "amazon",
            "NetworkBorderGroup": "ap-northeast-1"
        }
    ]
}
```

EIPが作成済みならば、Allocation IDを取得しておく。

```bash
VPC_EIP_ALLOC_ID=$(aws ec2 describe-addresses \
    --filter "Name=tag:Name,Values=${VPC_EIP_NAME}" \
    --query "Addresses[].AllocationId" \
    --output text \
    --region ${AWS_REGION}) && echo ${VPC_EIP_ALLOC_ID}
```

結果の例
```output
eipalloc-0c01530e4ab2bf446
```

#### 1.5 事前条件4の確認

対象のVPCにはNAT Gatewayが作成されていない。

```bash
aws ec2 describe-nat-gateways \
    --filter "Name=vpc-id,Values=${VPC_ID}" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "NatGateways": []
}
```

### 2. 主処理

#### 2.1 リソースの操作 (CREATE)

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 create-nat-gateway \
    --subnet-id ${VPC_SUBNET_ID} \
    --allocation-id ${VPC_EIP_ALLOC_ID} \
    --tag-specifications ResourceType=natgateway,Tags="[ {Key=Name,Value=${VPC_NGW_NAME} }]" \
    --region ${AWS_REGION}
        
EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 create-nat-gateway \
    --subnet-id ${VPC_SUBNET_ID} \
    --allocation-id ${VPC_EIP_ALLOC_ID} \
    --tag-specifications ResourceType=natgateway,Tags="[ {Key=Name,Value=${VPC_NGW_NAME} }]" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "ClientToken": "a4a6a4f4-cbc1-4689-bd24-b00cff6db254",
    "NatGateway": {
        "CreateTime": "2022-08-15T09:41:34+00:00",
        "NatGatewayAddresses": [
            {
                "AllocationId": "eipalloc-0c01530e4ab2bf446"
            }
        ],
        "NatGatewayId": "nat-053b1689c41cc8e5c",
        "State": "pending",
        "SubnetId": "subnet-02628d223dabe8c90",
        "VpcId": "vpc-0756cd50821dadaf3",
        "Tags": [
            {
                "Key": "Name",
                "Value": "project-dev-nat1-natgw"
            }
        ],
        "ConnectivityType": "public"
    }
}
```

### 3. 後処理

#### 3.1 完了条件1、2の結果確認

1. NAT Gatewayが作成されている。
1. NAT Gatewayは対象のサブネットに作成されている。


```bash
aws ec2 describe-nat-gateways \
    --filter "Name=subnet-id,Values=${VPC_SUBNET_ID}" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "NatGateways": [
        {
            "CreateTime": "2022-08-15T09:41:34+00:00",
            "NatGatewayAddresses": [
                {
                    "AllocationId": "eipalloc-0c01530e4ab2bf446",
                    "NetworkInterfaceId": "eni-01955aa221f2b2e6c",
                    "PrivateIp": "10.0.0.23"
                }
            ],
            "NatGatewayId": "nat-053b1689c41cc8e5c",
            "State": "pending",
            "SubnetId": "subnet-02628d223dabe8c90",
            "VpcId": "vpc-0756cd50821dadaf3",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "project-dev-nat1-natgw"
                }
            ],
            "ConnectivityType": "public"
        }
    ]
}
```


#### 3.99 中間リソースの削除

今回は特になし

# EOD
