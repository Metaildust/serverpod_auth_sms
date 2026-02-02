# serverpod_auth_sms_hash_server

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms_hash_server.svg)](https://pub.dev/packages/serverpod_auth_sms_hash_server)

Serverpod 短信认证手机号哈希存储实现（服务端）。

[English](README.md)

> **💡 推荐**：使用组合包 [`serverpod_auth_sms`](https://pub.dev/packages/serverpod_auth_sms) 而不是直接导入本包。组合包已自动处理 `Protocol`/`Endpoints` 冲突。
>
> **注意**：[`serverpod_auth_sms_crypto_server`](https://pub.dev/packages/serverpod_auth_sms_crypto_server) 包含了 hash 的所有功能，还支持解密手机号。除非有严格的数据最小化要求，否则建议使用 crypto 存储。

## 功能特性

- **不可逆存储** - 使用 HMAC-SHA256 哈希手机号，无法还原原始号码
- **隐私保护** - 即使数据库泄露，也无法获取用户真实手机号
- **唯一索引** - 通过哈希值确保手机号唯一性
- **合规友好** - 适合对个人信息保护有严格要求的场景

## 适用场景

- 仅需要验证用户身份，不需要获取原始手机号
- 对数据安全和隐私保护有较高要求
- 符合最小化数据收集原则的应用

## 安装

服务端：
```yaml
# gen_server/pubspec.yaml
dependencies:
  serverpod_auth_sms_hash_server: ^0.1.2
  serverpod_auth_sms_core_server: ^0.1.2
```

客户端：
```yaml
# gen_client/pubspec.yaml
dependencies:
  serverpod_auth_sms_hash_client: ^0.1.2
  serverpod_auth_sms_core_client: ^0.1.2
```

## 数据库迁移

添加依赖后，需要创建数据库迁移：

```bash
cd your_server_project
serverpod create-migration
```

## 使用方法

### 1. 配置密钥

在 `config/passwords.yaml` 中添加：

```yaml
shared:
  phoneHashPepper: '你的手机号哈希密钥-请使用强随机字符串'
```

> **重要**: 密钥一旦设置后**不可更改**，否则将无法匹配已有用户的手机号。

### 2. 创建存储实例

```dart
import 'package:serverpod_auth_sms_hash_server/serverpod_auth_sms_hash_server.dart'
    hide Protocol, Endpoints;  // 避免命名冲突

// 从配置文件加载
final phoneIdStore = PhoneIdHashStore.fromPasswords(pod);

// 或手动创建
final phoneIdStore = PhoneIdHashStore(pepper: 'your-secret-pepper');
```

### 3. 配置到认证服务

```dart
pod.initializeAuthServices(
  identityProviderBuilders: [
    SmsIdpConfigFromPasswords(
      phoneIdStore: phoneIdStore,
      // ... 其他配置
    ),
  ],
);
```

## 数据库表

本模块会创建以下数据库表：

```sql
CREATE TABLE serverpod_auth_sms_phone_id_hash (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
  authUserId UUID NOT NULL UNIQUE REFERENCES serverpod_auth_core_user(id) ON DELETE CASCADE,
  phoneHash TEXT NOT NULL UNIQUE
);
```

## 存储格式

| 字段 | 说明 |
|------|------|
| `authUserId` | 关联的用户 ID |
| `phoneHash` | HMAC-SHA256(手机号, pepper) 的十六进制字符串 |

## 与 Crypto 存储的对比

| 特性 | Hash 存储 | Crypto 存储 |
|------|-----------|-------------|
| 可逆性 | 不可逆 | 可解密 |
| 存储空间 | 较小（仅哈希） | 较大（哈希+密文+nonce+mac） |
| 安全性 | 更高（无法还原） | 高（需保护密钥） |
| 适用场景 | 身份验证 | 需要获取原号码 |

## 相关包

- [serverpod_auth_sms_core_server](https://pub.dev/packages/serverpod_auth_sms_core_server) - 核心模块
- [serverpod_auth_sms_crypto_server](https://pub.dev/packages/serverpod_auth_sms_crypto_server) - 加密存储实现
- [serverpod_auth_sms](https://pub.dev/packages/serverpod_auth_sms) - 组合包

## 许可证

MIT License
