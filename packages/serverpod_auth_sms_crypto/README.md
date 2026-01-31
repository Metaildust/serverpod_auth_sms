# serverpod_auth_sms_crypto_server

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms_crypto_server.svg)](https://pub.dev/packages/serverpod_auth_sms_crypto_server)

Serverpod 短信认证手机号加密存储实现（服务端）。

[English](README.en.md)

## 功能特性

- **可逆加密** - 使用 AES-256-GCM 加密手机号，可安全解密
- **双重索引** - 同时存储哈希值（用于查找）和加密值（用于解密）
- **完整性验证** - GCM 模式提供认证加密，防止数据篡改
- **密钥管理** - 支持从配置文件安全加载密钥

## 适用场景

- 需要获取用户原始手机号的业务场景（如客服联系、订单通知）
- 需要向用户展示部分手机号的场景（如 138****1234）
- 数据分析需要对手机号进行脱敏处理的场景

## 安装

服务端：
```yaml
# gen_server/pubspec.yaml
dependencies:
  serverpod_auth_sms_crypto_server: ^0.1.0
  serverpod_auth_sms_core_server: ^0.1.0
```

客户端：
```yaml
# gen_client/pubspec.yaml
dependencies:
  serverpod_auth_sms_crypto_client: ^0.1.0
  serverpod_auth_sms_core_client: ^0.1.0
```

## 数据库迁移

添加依赖后，需要创建数据库迁移：

```bash
cd your_server_project
serverpod create-migration
```

## 使用方法

### 1. 生成加密密钥

```bash
# 生成 32 字节随机密钥并 Base64 编码
openssl rand -base64 32
```

### 2. 配置密钥

在 `config/passwords.yaml` 中添加：

```yaml
shared:
  phoneHashPepper: '你的手机号哈希密钥'
  phoneEncryptionKey: 'Base64编码的32字节AES密钥'
```

> **重要**:
> - 密钥一旦设置后**不可更改**
> - 密钥必须严格保密，泄露将导致所有手机号可被解密
> - 建议使用 HSM 或密钥管理服务保护密钥

### 3. 创建存储实例

```dart
import 'package:serverpod_auth_sms_crypto_server/serverpod_auth_sms_crypto_server.dart'
    hide Protocol, Endpoints;  // 避免命名冲突

// 从配置文件加载
final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);

// 或手动创建
final phoneIdStore = PhoneIdCryptoStore(
  pepper: 'your-hash-pepper',
  encryptionKeyBytes: base64Decode('your-base64-key'),
);
```

### 4. 获取原始手机号

```dart
// 通过用户 ID 获取解密后的手机号
final phone = await phoneIdStore.getPhone(
  session,
  authUserId: userId,
);
```

## 数据库表

本模块会创建以下数据库表：

```sql
CREATE TABLE serverpod_auth_sms_phone_id_crypto (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
  authUserId UUID NOT NULL UNIQUE REFERENCES serverpod_auth_core_user(id) ON DELETE CASCADE,
  phoneHash TEXT NOT NULL UNIQUE,
  phoneEncrypted BYTEA NOT NULL,
  nonce BYTEA NOT NULL,
  mac BYTEA NOT NULL
);
```

## 存储格式

| 字段 | 说明 |
|------|------|
| `authUserId` | 关联的用户 ID |
| `phoneHash` | HMAC-SHA256 哈希值（用于唯一索引） |
| `phoneEncrypted` | AES-256-GCM 加密的手机号密文 |
| `nonce` | 加密随机数（12 字节） |
| `mac` | 消息认证码（16 字节） |

## 安全注意事项

1. **密钥保护** - 加密密钥是最关键的安全要素，必须妥善保护
2. **访问控制** - 限制 `getPhone()` 方法的调用权限
3. **审计日志** - 记录所有解密操作以便安全审计
4. **合规要求** - 确保符合当地数据保护法规的加密要求

## 与 Hash 存储的对比

| 特性 | Crypto 存储 | Hash 存储 |
|------|-------------|-----------|
| 可逆性 | 可解密 | 不可逆 |
| 存储空间 | 较大 | 较小 |
| 功能 | 可获取原号码 | 仅能验证 |
| 密钥依赖 | 需要加密密钥 | 仅需哈希密钥 |

## 相关包

- [serverpod_auth_sms_core_server](https://pub.dev/packages/serverpod_auth_sms_core_server) - 核心模块
- [serverpod_auth_sms_hash_server](https://pub.dev/packages/serverpod_auth_sms_hash_server) - 哈希存储实现
- [serverpod_auth_sms](https://pub.dev/packages/serverpod_auth_sms) - 组合包

## 许可证

MIT License
