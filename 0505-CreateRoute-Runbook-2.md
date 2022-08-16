# [0505] VPC Routing Tableの作成

## About
VPCを作成するCLI手順書。

本手順では、Public Route Tableにルートを追加し、Route TableをPublic Subnetに関連づける。


## When: 作業の条件

### Before: 事前前提条件

以下を作業の前提条件とする。
1. VPCが作成済みである。
1. Route Tableが作成済みである。
1. Internet Gatewayが作成済みである。
1. Subnetが作成済みである。

### After: 作業終了状況

以下が完了の条件。
1. 対象のRoute Tableにルートが追加されている。
1. 対象のSubnetにRoute Tableが関連づけられている。


## How: 以下は作業手順

### 1. 前処理

#### 1.1 処理パラメータの準備

パラメータの事後確認用ファイルの設定

```bash
RUNBOOK_TITLE="0505-create-public-rtbl-route"
DIR_PARAMETER="."
FILE_PARAMETER="${DIR_PARAMETER}/$(date +%Y-%m-%d)-${RUNBOOK_TITLE}.env" \
    && echo ${FILE_PARAMETER}
```

手順の実行パラメータ
```bash
# 変数に値をセット
AWS_REGION="ap-northeast-1"
VPC_CIDR="10.0.0.0/24"
VPC_SUBNET_CIDR_1="10.0.0.64/27"
VPC_SUBNET_CIDR_2="10.0.0.192/27"
VPC_DEST_CIDR_DEFAULT="0.0.0.0/0"
VPC_RTBL_NAME="project-dev-public-rtbl"
VPC_IGW_NAME="project-dev-main-igw"
```

```bash
# 値を確認
cat << ETX
    AWS_REGION=${AWS_REGION}
    VPC_CIDR=${VPC_CIDR}
    VPC_DEST_CIDR_DEFAULT=${VPC_DEST_CIDR_DEFAULT}
    VPC_IGW_NAME=${VPC_IGW_NAME}

ETX
```


#### 1.2 事前条件1の確認

VPCが作成済みである。

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

Route Tableが作成済みである。


```bash
aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:Name,Values=${VPC_RTBL_NAME}" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "RouteTables": [
        {
            "Associations": [],
            "PropagatingVgws": [],
            "RouteTableId": "rtb-0a56ec319ff9be3fc",
            "Routes": [
                {
                    "DestinationCidrBlock": "10.0.0.0/24",
                    "GatewayId": "local",
                    "Origin": "CreateRouteTable",
                    "State": "active"
                }
            ],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "project-dev-private-rtbl"
                }
            ],
            "VpcId": "vpc-0756cd50821dadaf3",
            "OwnerId": "123456789012"
        }
    ]
}
```

Route Tableが作成済みならば、RouteTable IDを取得しておく。

```bash
VPC_RTBL_ID=$(aws ec2 describe-route-tables \
    --filters "Name=vpc-id,Values=${VPC_ID}" "Name=tag:Name,Values=${VPC_RTBL_NAME}" \
    --query "RouteTables[].RouteTableId" \
    --output text \
    --region ${AWS_REGION}) && echo ${VPC_RTBL_ID}
```

結果の例
```output
rtb-0a56ec319ff9be3fc
```

#### 1.4 事前条件3の確認

Internet Gatewayが作成済みである。

```bash
aws ec2 describe-internet-gateways \
    --filters "Name=tag:Name,Values=${VPC_IGW_NAME}" \
    --region ${AWS_REGION}
```

```output
{
    "InternetGateways": [
        {
            "Attachments": [
                {
                    "State": "available",
                    "VpcId": "vpc-0756cd50821dadaf3"
                }
            ],
            "InternetGatewayId": "igw-0f27f5c68aff2554f",
            "OwnerId": "123456789012",
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "project-dev-main-igw"
                }
            ]
        }
    ]
}
```

Internet Gatewayが作成済みならば、Internet Gateway IDを取得しておく。

```bash
VPC_IGW_ID=$(aws ec2 describe-internet-gateways \
    --filters "Name=tag:Name,Values=${VPC_IGW_NAME}" \
    --query "InternetGateways[].InternetGatewayId" \
    --output text \
    --region ${AWS_REGION}) && echo ${VPC_IGW_ID}
```

結果の例
```output
igw-0f27f5c68aff2554f
```

#### 1.5 事前条件4の確認

サブネットが作成済みである。

```bash
aws ec2 describe-subnets \
    --filters "Name=cidrBlock,Values=${VPC_SUBNET_CIDR_1}" \
    --region ${AWS_REGION}
```

```bash
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
            "AvailableIpAddressCount": 27,
            "CidrBlock": "10.0.0.64/27",
            "DefaultForAz": false,
            "MapPublicIpOnLaunch": false,
            "MapCustomerOwnedIpOnLaunch": false,
            "State": "available",
            "SubnetId": "subnet-0d75f8c6dc1692f49",
            "VpcId": "vpc-0756cd50821dadaf3",
            "OwnerId": "123456789012",
            "AssignIpv6AddressOnCreation": false,
            "Ipv6CidrBlockAssociationSet": [],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "project-dev-pub1-subnet"
                }
            ],
            "SubnetArn": "arn:aws:ec2:ap-northeast-1:123456789012:subnet/subnet-0d75f8c6dc1692f49",
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
    --region ${AWS_REGION}) && echo ${VPC_SUBNET_ID_1}
```

```bash
VPC_SUBNET_ID_2=$(aws ec2 describe-subnets \
    --filters "Name=cidrBlock,Values=${VPC_SUBNET_CIDR_2}" \
    --query "Subnets[].SubnetId" \
    --output text \
    --region ${AWS_REGION}) && echo ${VPC_SUBNET_ID_2}
```

結果の例
```output
subnet-02628d223dabe8c90
```


### 2. 主処理

#### 2.1 リソースの操作 (CREATE)

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 create-route \
    --route-table-id ${VPC_RTBL_ID} \
    --destination-cidr-block ${VPC_DEST_CIDR_DEFAULT} \
    --gateway-id ${VPC_IGW_ID} \
    --region ${AWS_REGION}
        
EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 create-route \
    --route-table-id ${VPC_RTBL_ID} \
    --destination-cidr-block ${VPC_DEST_CIDR_DEFAULT} \
    --gateway-id ${VPC_IGW_ID} \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "Return": true
}
```

#### 2.3 リソースの操作 (Associate)

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 associate-route-table \
    --route-table-id ${VPC_RTBL_ID} \
    --subnet-id ${VPC_SUBNET_ID_1} \
    --region ${AWS_REGION}
        
aws ec2 associate-route-table \
    --route-table-id ${VPC_RTBL_ID} \
    --subnet-id ${VPC_SUBNET_ID_2} \
    --region ${AWS_REGION}
        
EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 associate-route-table \
    --route-table-id ${VPC_RTBL_ID} \
    --subnet-id ${VPC_SUBNET_ID_1} \
    --region ${AWS_REGION}
```

```bash
aws ec2 associate-route-table \
    --route-table-id ${VPC_RTBL_ID} \
    --subnet-id ${VPC_SUBNET_ID_2} \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "AssociationId": "rtbassoc-04fceeb0e3a9595d6",
    "AssociationState": {
        "State": "associated"
    }
}
```


### 3. 後処理

#### 3.1 完了条件1の結果確認

1. 対象のRoute Tableにルートが追加されている。
1. 対象のSubnetにRoute Tableが関連づけられている。


```bash
aws ec2 describe-route-tables \
    --route-table-ids ${VPC_RTBL_ID} \
    --filters "Name=association.subnet-id,Values=${VPC_SUBNET_ID_1}" \
    --region ${AWS_REGION}
```

```bash
aws ec2 describe-route-tables \
    --route-table-ids ${VPC_RTBL_ID} \
    --filters "Name=association.subnet-id,Values=${VPC_SUBNET_ID_2}" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "RouteTables": [
        {
            "Associations": [],
            "PropagatingVgws": [],
            "RouteTableId": "rtb-0a56ec319ff9be3fc",
            "Routes": [
                {
                    "DestinationCidrBlock": "10.0.0.0/24",
                    "GatewayId": "local",
                    "Origin": "CreateRouteTable",
                    "State": "active"
                },
                {
                    "DestinationCidrBlock": "0.0.0.0/0",
                    "NatGatewayId": "nat-053b1689c41cc8e5c",
                    "Origin": "CreateRoute",
                    "State": "active"
                }
            ],
            "Tags": [
                {
                    "Key": "Name",
                    "Value": "project-dev-private-rtbl"
                }
            ],
            "VpcId": "vpc-0756cd50821dadaf3",
            "OwnerId": "123456789012"
        }
    ]
}
```


#### 3.99 中間リソースの削除

今回は特になし

#### Navigation

Next: 

# EOD
