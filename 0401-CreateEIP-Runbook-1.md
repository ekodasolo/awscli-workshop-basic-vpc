# [0401] NAT Gateway用EIPを作成する

## About
VPCを作成するCLI手順書。

本手順では、NAT Gatewayに関連づけるための、EIPを払い出す。


## When: 作業の条件

### Before: 事前前提条件

以下を作業の前提条件とする。
1. VPCが作成済みである。
1. EIPの数がリージョンごとの上限に達しておらず、作成可能である。

### After: 作業終了状況

以下が完了の条件。
1. EIPが払い出されていること。


## How: 以下は作業手順

### 1. 前処理

#### 1.1 処理パラメータの準備

パラメータの事後確認用ファイルの設定

```bash
RUNBOOK_TITLE="0401-create-eip"
DIR_PARAMETER="."
FILE_PARAMETER="${DIR_PARAMETER}/$(date +%Y-%m-%d)-${RUNBOOK_TITLE}.env" \
    && echo ${FILE_PARAMETER}
```

手順の実行パラメータ
```bash
# 変数に値をセット
AWS_REGION="ap-northeast-1"
VPC_CIDR="10.0.2.0/24"
VPC_EIP_NAME="project-dev-nat1-eip"
```

```bash
# 値を確認
cat << ETX
    AWS_REGION=${AWS_REGION}
    VPC_CIDR=${VPC_CIDR}
    VPC_EIP_NAME=${VPC_EIP_NAME}

ETX
```


#### 1.2 事前条件1の確認

VPCが作成済みである。

```bash
# 既存のVPCを確認
aws ec2 describe-vpcs \
    --filters "Name=cidr,Values=${VPC_CIDR}"
```

アタッチ予定のVPCがあれば、期待通り。

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

EIPの数がリージョンごとの上限に達しておらず、作成可能である。

```bash
aws ec2 describe-addresses \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "Addresses": []
}
```

### 2. 主処理

#### 2.1 リソースの操作 (CREATE)

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 allocate-address \
    --tag-specifications ResourceType=elastic-ip,Tags="[{ Key=Name,Value=${VPC_EIP_NAME} }]" \
    --region ${AWS_REGION}
        
EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 allocate-address \
    --tag-specifications ResourceType=elastic-ip,Tags="[{ Key=Name,Value=${VPC_EIP_NAME} }]" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "PublicIp": "35.72.57.159",
    "AllocationId": "eipalloc-0c01530e4ab2bf446",
    "PublicIpv4Pool": "amazon",
    "NetworkBorderGroup": "ap-northeast-1",
    "Domain": "vpc"
}
```

### 3. 後処理

#### 3.1 完了条件1、2の結果確認

EIPが払い出されていること。

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


#### 3.99 中間リソースの削除

今回は特になし

#### Navigation

Next: 1. [NGWを作成する](./0402-CreateNGW-Runbook-1.md)

# EOD
