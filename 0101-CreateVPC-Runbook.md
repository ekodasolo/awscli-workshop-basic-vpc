# VPCを作成する

## About
VPCを作成するCLI手順書。

本手順では、VPCを東京リージョンに作成する


## When: 作業の条件

### Before: 事前前提条件

以下を作業の前提条件とする。
1. 作業リージョンでVPCの作成数上限に達しておらずVPCが作成可能である。
1. 割り当てたIPアドレス範囲が他の既存のVPCと重複しておらず、作成可能である。

### After: 作業終了状況

以下が完了の条件。
1. VPCが作成されている。
1. 作成したVPCは東京リージョンに配置されている。


## How: 以下は作業手順

### 1. 前処理

#### 1.1 処理パラメータの準備

パラメータの事後確認用ファイルの設定

```bash
RUNBOOK_TITLE="0101-create-vpc"
DIR_PARAMETER="."
FILE_PARAMETER="${DIR_PARAMETER}/$(date +%Y-%m-%d)-${RUNBOOK_TITLE}.env" \
    && echo ${FILE_PARAMETER}
```

手順の実行パラメータ
```bash
# 変数に値をセット
AWS_REGION="ap-northeast-1"
VPC_CIDR="10.0.0.0/24"
VPC_NAME="project-dev-main-vpc"
```

```bash
# 値を確認
cat << ETX
    AWS_REGION=${AWS_REGION}
    VPC_CIDR=${VPC_CIDR}
    VPC_NAME=${VPC_NAME}

ETX
```


#### 1.2 事前条件1の確認

リージョン内に作成できるVPCの数は、特に上限緩和していなければ、リージョンあたり5個まで。現状で5個に達していないかを事前に確認する。

```bash
# 既存のVPCを確認
aws ec2 describe-vpcs --region ${AWS_REGION} --query "Vpcs[].[VpcId, CidrBlock]"
```

既存のVPCの数がすでに上限に達していなければ期待通り。

結果の例
```output
[
    [
        "30.1.0.0/16",
        "vpc-0e9801d129EXAMPLE",
    ],
    [
        "10.0.0.0/16",
        "vpc-06e4ab6c6cEXAMPLE",
    ]
]
```

#### 1.3 事前条件2の確認

依存するリソースが存在していることを確認。本作業では依存リソースは無い。


### 2. 主処理

#### 2.1 リソースの操作 (CREATE)

パラメータの最終確認

```bash
cat << EOF > ${FILE_PARAMETER}
aws ec2 create-vpc \
    --cidr-block ${VPC_CIDR} \
    --tag-specifications "ResourceType=vpc,Tags=[{ Key=Name,Value=${VPC_NAME} }]" \
    --region ${AWS_REGION}
        
EOF
cat ${FILE_PARAMETER}
```

処理の実行

```bash
aws ec2 create-vpc \
    --cidr-block ${VPC_CIDR} \
    --tag-specifications "ResourceType=vpc,Tags=[{ Key=Name,Value=${VPC_NAME} }]" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "Vpc": {
        "CidrBlock": "10.0.0.0/24",
        "DhcpOptionsId": "dopt-0ded636f18bc345d7",
        "State": "pending",
        "VpcId": "vpc-0701707c27407b25d",
        "OwnerId": "010905949244",
        "InstanceTenancy": "default",
        "Ipv6CidrBlockAssociationSet": [],
        "CidrBlockAssociationSet": [
            {
                "AssociationId": "vpc-cidr-assoc-07a876b8ac3175c6a",
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
                "Value": "project-dev-main-vpc"
            }
        ]
    }
}
```

### 3. 後処理

#### 3.1 完了条件1、2の結果確認

VPCが作成されている。

作成したVPCは東京リージョンに配置されている。

```bash
aws ec2 describe-vpcs \
    --filters "Name=cidr-block,Values=${VPC_CIDR}" \
    --region ${AWS_REGION}
```

結果の例
```output
{
    "Vpcs": [
        {
            "CidrBlock": "10.0.0.0/24",
            "DhcpOptionsId": "dopt-0ded636f18bc345d7",
            "State": "available",
            "VpcId": "vpc-0701707c27407b25d",
            "OwnerId": "010905949244",
            "InstanceTenancy": "default",
            "CidrBlockAssociationSet": [
                {
                    "AssociationId": "vpc-cidr-assoc-07a876b8ac3175c6a",
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
                    "Value": "project-dev-main-vpc"
                }
            ]
        }
    ]
}
```


#### 3.99 中間リソースの削除

今回は特になし

# EOD
