# [0301] Internet Gatewayを作成する

## About
VPCを作成するCLI手順書。

本手順では、Internet Gateway(IGW)を作成する。


## When: 作業の条件

### Before: 事前前提条件

以下を作業の前提条件とする。
1. 作業リージョンVPCでIGWの作成数上限に達しておらずIGWが作成可能である。
1. アタッチ対象のVPCが存在している。
1. 対象のVPCでIGWがアタッチされていない

### After: 作業終了状況

以下が完了の条件。
1. IGWが作成されている。
1. IGWがアタッチ対象のVPCにアタッチされている。


## How: 以下は作業手順

### 1. 前処理

#### 1.1 処理パラメータの準備

パラメータの事後確認用ファイルの設定

```bash
RUNBOOK_TITLE="0301-create-igw"
DIR_PARAMETER="."
FILE_PARAMETER="${DIR_PARAMETER}/$(date +%Y-%m-%d)-${RUNBOOK_TITLE}.env" \
    && echo ${FILE_PARAMETER}
```

手順の実行パラメータ
```bash
# 変数に値をセット
AWS_REGION="ap-northeast-1"
VPC_CIDR="10.0.2.0/24"
VPC_IGW_NAME="project-dev-main-igw"
```

```bash
# 値を確認
cat << ETX
    AWS_REGION=${AWS_REGION}
    VPC_CIDR=${VPC_CIDR}
    VPC_NAME=${VPC_IGW_NAME}

ETX
```


#### 1.2 事前条件1の確認

作業リージョンVPCでIGWの作成数上限に達しておらずIGWが作成可能である。

```bash
aws ec2 describe-internet-gateways \
    --query "InternetGateways[].[InternetGatewayId,Attachments]"
```

結果の例
```output
[
    [
        "igw-1bccf77f",
        [
            {
                "State": "available",
                "VpcId": "vpc-a63e01c1"
            }
        ]
    ]
]
```

#### 1.3 事前条件2の確認

アタッチ対象のVPCが存在している。

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

#### 1.4 事前条件3の確認

対象のVPCでIGWがアタッチされていない

```bash
aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=${VPC_ID}"
```

結果の例
```output
{
    "InternetGateways": []
}
```

### 2. 主処理

#### 2.1 リソースの操作 (CREATE)

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 create-internet-gateway \
    --tag-specifications ResourceType=internet-gateway,Tags="[{ Key=Name,Value=${VPC_IGW_NAME} }]" \
    --region ${AWS_REGION}
        
EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 create-internet-gateway \
    --tag-specifications ResourceType=internet-gateway,Tags="[{ Key=Name,Value=${VPC_IGW_NAME} }]" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "InternetGateway": {
        "Attachments": [],
        "InternetGatewayId": "igw-0f27f5c68aff2554f",
        "OwnerId": "123456789012",
        "Tags": [
            {
                "Key": "Name",
                "Value": "project-dev-main-igw"
            }
        ]
    }
}
```

IGWのIDを取得しておく。

```bash
VPC_IGW_ID=$(aws ec2 describe-internet-gateways \
    --filters "Name=tag:Name,Values=${VPC_IGW_NAME}" \
    --query "InternetGateways[].InternetGatewayId" \
    --output text \
    --region ${AWS_REGION}) && echo ${VPC_IGW_ID}
```

#### 2.2 リソースの操作 (Attach)

作成したIGWをVPCにアタッチする。

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 attach-internet-gateway \
    --internet-gateway-id ${VPC_IGW_ID} \
    --vpc-id ${VPC_ID} \
    --region ${AWS_REGION}

EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 attach-internet-gateway \
    --internet-gateway-id ${VPC_IGW_ID} \
    --vpc-id ${VPC_ID} \
    --region ${AWS_REGION}
```

結果の例
```output
(出力無し)
```



### 3. 後処理

#### 3.1 完了条件1、2の結果確認

1. IGWが作成されている。
1. IGWがアタッチ対象のVPCにアタッチされている。

```bash
aws ec2 describe-internet-gateways \
    --filters "Name=tag:Name,Values=${VPC_IGW_NAME}"
```

結果の例
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

アタッチされたVPC IDを指定していして、IGWを表示。

```bash
aws ec2 describe-internet-gateways \
    --filters "Name=attachment.vpc-id,Values=${VPC_ID}"
```

結果の例
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




#### 3.99 中間リソースの削除

今回は特になし

#### Navigation

Next: [NGWを作成する](./0400-CreateNGW-Scenario.md)

# EOD
