# [0503] VPC Routing Tableの作成

## About
VPCを作成するCLI手順書。

本手順では、Transit Subnet用のRoute Tableを作成する。


## When: 作業の条件

### Before: 事前前提条件

以下を作業の前提条件とする。
1. VPCが作成済みである。

### After: 作業終了状況

以下が完了の条件。
1. Route Tableが作成されている。
1. Route Tableは対象のVPCに作成されている。


## How: 以下は作業手順

### 1. 前処理

#### 1.1 処理パラメータの準備

パラメータの事後確認用ファイルの設定

```bash
RUNBOOK_TITLE="0503-create-route-table-3"
DIR_PARAMETER="."
FILE_PARAMETER="${DIR_PARAMETER}/$(date +%Y-%m-%d)-${RUNBOOK_TITLE}.env" \
    && echo ${FILE_PARAMETER}
```

手順の実行パラメータ
```bash
# 変数に値をセット
AWS_REGION="ap-northeast-1"
VPC_CIDR="10.0.0.0/24"
VPC_RTBL_NAME="project-dev-transit-rtbl"
```

```bash
# 値を確認
cat << ETX
    AWS_REGION=${AWS_REGION}
    VPC_CIDR=${VPC_CIDR}
    VPC_RTBL_NAME=${VPC_RTBL_NAME}

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


### 2. 主処理

#### 2.1 リソースの操作 (CREATE)

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 create-route-table \
    --vpc-id ${VPC_ID} \
    --tag-specifications ResourceType=route-table,Tags="[{ Key=Name,Value=${VPC_RTBL_NAME} }]" \
    --region ${AWS_REGION}
        
EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 create-route-table \
    --vpc-id ${VPC_ID} \
    --tag-specifications ResourceType=route-table,Tags="[{ Key=Name,Value=${VPC_RTBL_NAME} }]" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "RouteTable": {
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
}
```

### 3. 後処理

#### 3.1 完了条件1、2の結果確認

1. Route Tableが作成されている。
1. Route Tableは対象のVPCに作成されている。


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


#### 3.99 中間リソースの削除

今回は特になし

# EOD
