# HashiCorp Vault 是什么

HashiCorp Vault 是一个专门管理敏感信息（Secrets）的系统。可以把它理解成：
企业级密码保险柜 + 密钥管理中心 + 身份认证中心。
它不仅能保存密码，还能动态生成凭据、管理证书、加密数据、控制访问权限并记录审计日志。


Vault 解决什么问题？

假设你的系统有：
Go API
Envoy
MySQL
Redis
MinIO
Kafka
AWS

这些服务都会用到各种敏感信息：
MySQL Password
Redis Password
JWT Secret
TLS Private Key
API Key
AWS Access Key
MinIO Secret
OAuth Client Secret

很多项目会直接写在：
config.yaml
password: abc123

或者：
MYSQL_PASSWORD=abc123

这会带来风险：
Git 泄漏
配置文件泄漏
日志打印
无法方便地轮换密码

Vault 就是用来解决这些问题的。

Vault 的基本架构
                Client
                   │
                   ▼
              Vault Server
          ┌────────┼────────┐
          │        │        │
     KV Secret   PKI     Transit
          │        │        │
          ▼        ▼        ▼
     Password   Cert     Encrypt

客户端不直接保存 Secret，而是运行时向 Vault 获取。

例如：
secret := vault.Read("database/password")

而不是：
password := "123456"
Vault 的主要功能
1. Secret Storage（最常用）

像一个 Key-Value 数据库：

secret/database

username = root
password = abc123

Go：
secret := vault.Read("database")
得到：

{
    "username": "root",
    "password": "abc123"
}

2. Dynamic Secret（Vault 最厉害的功能）

传统做法：
MySQL
root
password123

所有服务都用这一组账号。

Vault 可以这样：

Go
 │
 ▼
Vault
 │
 ▼
MySQL
 │
 ▼
生成：

user_xxx
password_xxx

TTL = 30 min

30 分钟后：
自动删除数据库账号
因此即使密码泄漏，也很快失效。

支持：
MySQL
PostgreSQL
MongoDB
Redis
RabbitMQ
Kafka
AWS IAM
GCP
Azure

3. PKI（证书中心）

Vault 可以充当企业内部 CA。

例如：
Envoy
     │
     ▼
Vault PKI
     │
     ▼
签发 TLS 证书

不用自己维护：
OpenSSL
CA
中间证书

很多 Service Mesh 都这么做。

4. Transit（加密服务）
这是很多人不知道的功能。

Vault 可以：
明文
 │
 ▼
Vault
 │
 ▼
返回密文

以后：
密文
 │
 ▼
Vault
 │
 ▼
返回明文

应用永远不需要保存加密密钥。

例如：
Metadata
↓
ciphertext:vault:v1:xxxxx

Filter：
ciphertext
↓
Vault
↓
明文

特别适合保护配置中的敏感数据。

5. 身份认证（Authentication）

Vault 支持很多登录方式：

Token
Kubernetes
JWT
OIDC
LDAP
GitHub
AWS IAM
GCP IAM
AppRole

例如：
Kubernetes Pod
↓
ServiceAccount
↓
Vault
↓
允许读取 Secret
无需在 Pod 中写 Token。

6. 权限控制（Policy）
可以做到非常细粒度。

例如：
team-a

只能：
secret/team-a/*

不能访问：
secret/team-b/*

7. 审计（Audit）

所有操作都有记录：
谁
什么时候
读取了哪个 Secret

满足很多企业的合规要求。

Vault 和普通配置文件有什么区别？
配置文件	Vault
明文保存	集中安全保存
修改要发版	可运行时更新
无权限控制	精细权限控制
无审计	完整审计
固定密码	支持动态密码
无自动轮换	自动轮换
和 AWS / GCP Secret Manager 的区别

Vault 更像一个完整的 Secrets 平台。

除了保存 Secret，还提供：

动态数据库账号
动态云凭据
PKI
加密服务（Transit）
多种认证方式
多云支持
私有化部署

而云厂商的 Secret Manager 更偏向于托管的 Secret 存储服务，运维简单，但功能范围相对更聚焦。

对于你的 Go + Envoy + xDS 项目

结合你之前提到的需求（通过 xDS 下发 Cluster Metadata，并希望避免敏感信息以明文形式存在），一种比较推荐的架构是：

Go xDS Control Plane
          │
          ▼
Envoy Metadata
credential_id = "payment-api"
          │
          ▼
自定义 Envoy Filter
          │
          ▼
Vault
          │
          ▼
API Key / OAuth Token / Basic Auth

或者，如果希望 Metadata 中直接保存密文：

Metadata
ciphertext:vault:v1:xxxxx
          │
          ▼
Filter
          │
          ▼
Vault Transit 解密

这样，xDS 配置、Envoy 的 /config_dump、数据库等地方都不会出现明文凭据，同时还可以利用 Vault 的访问控制、审计和密钥轮换能力。这也是很多大型企业和多云环境中常见的设计。












HashiCorp Vault 怎么部署
Vault 的部署方式主要有 4 种，不同规模适合不同方案。

1. Docker（开发环境，最简单）

官方镜像：
docker run \
  --cap-add=IPC_LOCK \
  -p 8200:8200 \
  -e VAULT_DEV_ROOT_TOKEN_ID=root \
  hashicorp/vault

开发模式：
vault server -dev

启动后：
http://localhost:8200

登录：
Token
root

注意：
这是 Dev Mode：
数据存内存
重启全部丢失
Root Token 固定
不适合生产

2. 单机部署（小型生产）

例如：
        Vault

     BoltDB / Raft


配置：
storage "raft" {
  path = "/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = false
}

api_addr = "https://vault.example.com:8200"

启动：
vault server -config=vault.hcl

优点：
不需要数据库
数据保存在本地
比 Dev Mode 安全很多
3. HA 集群（推荐生产）

现在官方最推荐的是 Integrated Storage（Raft）。

例如：

      LB

┌────┴────┐

Vault1   Vault2
│         │
└────┬────┘
     │
  Vault3

 Raft Cluster

特点：
Leader Election
自动复制
自动 Failover
不需要 Consul

以前 Vault 常配：
Vault
↓
Consul

现在已经不推荐了。

配置：
storage "raft" {
  path = "/vault/data"

  retry_join {
    leader_api_addr = "https://vault1:8200"
  }

  retry_join {
    leader_api_addr = "https://vault2:8200"
  }
}

一般部署：
3 台
或者
5 台

4. Kubernetes（现在最常见）

HashiCorp 官方提供 Helm。

helm install vault hashicorp/vault

架构：
Kubernetes
StatefulSet
Vault-0
Vault-1
Vault-2
Raft

支持：
Auto Unseal
Injector
CSI Driver

很多公司直接：
Vault + Kubernetes
Vault 初始化

第一次启动：
vault operator init

得到：
Unseal Key 1
Unseal Key 2
Unseal Key 3
Root Token

例如：

Unseal Key 1:
xxxx

Unseal Key 2:
xxxx

Unseal Key 3:
xxxx

必须保存。

Unseal 是什么？

Vault 启动：
Encrypted Storage
不能直接使用。

必须：
Unseal Key

例如：
3/5

意思：
5 个 Key
任意 3 个即可解锁。

这是：
Shamir Secret Sharing

原理。

Auto Unseal（推荐）

生产不会每次：
vault operator unseal

一般使用：

AWS：
AWS KMS

Azure：
Azure Key Vault

GCP：
Cloud KMS

或者：
HSM
启动自动解锁。
存储 Backend

现在推荐：
Integrated Storage (Raft)

以前支持：
Consul
MySQL
PostgreSQL
DynamoDB
S3

但是官方现在推荐：

Raft
企业部署一般长这样
            HAProxy

               │

  ┌────────────┴────────────┐

Vault1                  Vault2

  │                        │

  └────────────┬───────────┘

               │

            Vault3

         Integrated Raft

客户端：

Go
↓
Vault SDK
↓
Vault Cluster
对于你的项目

根据之前的交流，你正在开发：

Go xDS Control Plane
Envoy
多租户
Cluster Metadata
Secret 管理

如果以后希望支持企业私有化部署，我建议：

开发/测试环境：Docker 或 Docker Compose 单节点 Vault。
生产环境：3 节点 Vault + Integrated Raft（无需 Consul），并启用 TLS、ACL、审计日志和 Auto Unseal。
Kubernetes 环境：直接使用官方 Helm Chart 部署 StatefulSet，这是目前最常见的生产方案。

这样既能满足高可用，又方便与你的 Go 服务通过官方 SDK 集成读取和管理 Secret。
