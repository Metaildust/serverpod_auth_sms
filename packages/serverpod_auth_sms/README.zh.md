# serverpod_auth_sms

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms.svg)](https://pub.dev/packages/serverpod_auth_sms)

**推荐使用的包** - Serverpod 短信认证组合包。本包已处理好命名冲突，无需手动 `hide`。

[English](README.md)

## 为什么用这个包？

| 导入方式 | 需要 `hide Protocol, Endpoints`？|
|---------|----------------------------------|
| `serverpod_auth_sms`（本包）| **不需要** ✓ |
| 单独导入子包（`_core`, `_hash`, `_crypto`）| 需要 |

本包包含：
- `serverpod_auth_sms_core_server` - 核心认证逻辑
- `serverpod_auth_sms_hash_server` - 哈希存储（不可逆）
- `serverpod_auth_sms_crypto_server` - 加密存储（可解密）

> **注意**：**crypto** 存储内部也会存储 hash 值，所以它涵盖了 **hash** 的所有功能，同时还支持解密还原手机号。如果将来可能需要获取原始手机号，建议选择 crypto。

## 功能特性

- **短信注册** - 使用手机号和验证码注册
- **验证码登录** - 手机号 + 验证码登录（未注册用户自动注册）
- **手机号绑定** - 为已有账号绑定手机号
- **服务商无关** - 通过回调函数支持任意短信服务商
- **两种存储方案**：
  - **Hash**：不可逆，最大隐私保护
  - **Crypto**：可解密，适合需要获取原号码的场景

## 安装

### 服务端依赖

```yaml
# gen_server/pubspec.yaml
dependencies:
  serverpod_auth_sms: ^0.1.2
  # 可选：腾讯云短信集成
  tencent_sms_serverpod: ^0.1.0
```

### 客户端依赖

```yaml
# gen_client/pubspec.yaml
dependencies:
  serverpod_auth_sms_core_client: ^0.1.2
  # 根据存储方式选择其一：
  serverpod_auth_sms_crypto_client: ^0.1.2  # 加密存储
  # serverpod_auth_sms_hash_client: ^0.1.2  # 哈希存储
```

## 完整配置

### passwords.yaml

```yaml
# config/passwords.yaml
shared:
  # ============================================
  # 核心短信认证（必需）
  # ============================================
  
  # 验证码哈希密钥（必需）
  # 用于内部安全存储验证码 challenge
  smsSecretHashPepper: '随机字符串-用于验证码哈希'
  
  # ============================================
  # 手机号存储（必需）
  # ============================================
  
  # 手机号哈希密钥（hash 和 crypto 都需要）
  # ⚠️ 警告：部署后不可更改，否则已有数据无法匹配
  phoneHashPepper: '随机字符串-用于手机号哈希'
  
  # AES-256 加密密钥（仅 crypto 存储需要）
  # 生成命令：openssl rand -base64 32
  # ⚠️ 警告：不可更改，泄露将导致所有手机号可被解密
  phoneEncryptionKey: 'base64编码的32字节密钥'
  
  # ============================================
  # 腾讯云短信（可选 - 中国用户推荐）
  # ============================================
  
  tencentSmsSecretId: '你的腾讯云SecretId'
  tencentSmsSecretKey: '你的腾讯云SecretKey'
  tencentSmsSdkAppId: '1400000000'
  tencentSmsSignName: '你的签名名称'
  tencentSmsRegion: 'ap-guangzhou'  # 可选，默认广州
  
  # 模板配置（三选一）：
  # 方式1：直接指定模板ID
  tencentSmsVerificationTemplateId: '123456'
  
  # 方式2：按场景指定模板名称
  # tencentSmsVerificationTemplateNameLogin: '登录验证码'
  # tencentSmsVerificationTemplateNameRegister: '注册验证码'
  # tencentSmsVerificationTemplateNameResetPassword: '重置密码验证码'
  
  # 方式3：CSV 模板映射
  # tencentSmsTemplateCsvPath: 'config/sms/templates.csv'
```

## 快速开始

### 基础配置（自定义短信服务商）

```dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  // 选择存储方式
  final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);  // 推荐
  // final phoneIdStore = PhoneIdHashStore.fromPasswords(pod); // 如果不需要解密

  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      SmsIdpConfigFromPasswords(
        phoneIdStore: phoneIdStore,
        sendRegistrationVerificationCode: _sendSmsCode,
        sendLoginVerificationCode: _sendSmsCode,
        sendBindVerificationCode: _sendSmsCode,
        passwordValidationFunction: _validatePassword,
      ),
    ],
  );

  await pod.start();
}

// 实现你的短信发送逻辑
Future<void> _sendSmsCode(
  Session session, {
  required String phone,
  required UuidValue requestId,
  required String verificationCode,
  required Transaction? transaction,
}) async {
  // 调用你的短信服务商 API
  await yourSmsClient.send(phone, verificationCode);
  session.log('发送验证码 $verificationCode 到 $phone');
}

// 可选：自定义密码校验
bool _validatePassword(String password) {
  if (password.length < 8) return false;
  if (!password.contains(RegExp(r'[A-Z]'))) return false;
  if (!password.contains(RegExp(r'[a-z]'))) return false;
  if (!password.contains(RegExp(r'[0-9]'))) return false;
  if (!password.contains(RegExp(r'[\W_]'))) return false;  // 特殊字符
  return true;
}
```

### 使用腾讯云短信（中国用户推荐）

```dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';
import 'package:tencent_sms_serverpod/tencent_sms_serverpod.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  // 创建腾讯云短信客户端
  final smsConfig = TencentSmsConfigServerpod.fromServerpod(pod);
  final smsClient = TencentSmsClient(smsConfig);
  // 使用中文错误消息：TencentSmsClient(smsConfig, localizations: const SmsLocalizationsZh())
  final smsHelper = SmsAuthCallbackHelper(smsClient);

  // 使用加密存储（推荐 - 同时支持哈希验证和解密）
  final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);

  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      SmsIdpConfigFromPasswords(
        phoneIdStore: phoneIdStore,
        sendRegistrationVerificationCode: smsHelper.sendForRegistration,
        sendLoginVerificationCode: smsHelper.sendForLogin,
        sendBindVerificationCode: smsHelper.sendForBind,
        passwordValidationFunction: _validatePassword,
        // 可选配置：
        requirePasswordOnUnregisteredLogin: true,  // 新用户需要设置密码
        allowPhoneRebind: false,                   // 禁止更换绑定手机
        verificationCodeLength: 6,
        loginVerificationCodeLifetime: Duration(minutes: 10),
      ),
    ],
  );

  await pod.start();
}
```

### 创建 Endpoints

```dart
// lib/src/endpoints/sms_idp_endpoint.dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';

class SmsIdpEndpoint extends SmsIdpBaseEndpoint {}

// lib/src/endpoints/phone_bind_endpoint.dart
class PhoneBindEndpoint extends SmsPhoneBindBaseEndpoint {}

// lib/src/endpoints/sms_auth_ui_endpoint.dart
class SmsAuthUiEndpoint extends SmsAuthUiBaseEndpoint {}
```

## 数据库迁移

添加依赖后，生成并应用迁移：

```bash
cd your_server_project
serverpod create-migration
dart bin/main.dart --apply-migrations
```

创建的表：
- `serverpod_auth_sms_account` - 用户凭证
- `serverpod_auth_sms_account_request` - 注册请求
- `serverpod_auth_sms_login_request` - 登录请求
- `serverpod_auth_sms_bind_request` - 绑定请求
- `serverpod_auth_sms_phone_id_crypto` 或 `serverpod_auth_sms_phone_id_hash` - 手机号存储

## 配置选项

### 功能开关

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `enableRegistration` | 启用短信注册 | `true` |
| `enableLogin` | 启用验证码登录 | `true` |
| `enableBind` | 启用手机绑定 | `true` |
| `requirePasswordOnUnregisteredLogin` | 自动注册时需要密码 | `true` |
| `allowPhoneRebind` | 允许更换绑定手机 | `false` |

### 验证码设置

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `verificationCodeLength` | 验证码长度 | `6` |
| `registrationVerificationCodeLifetime` | 注册验证码有效期 | `10分钟` |
| `loginVerificationCodeLifetime` | 登录验证码有效期 | `10分钟` |
| `bindVerificationCodeLifetime` | 绑定验证码有效期 | `10分钟` |

### 频率限制

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `registrationVerificationCodeAllowedAttempts` | 注册验证码最大尝试次数 | `5` |
| `loginVerificationCodeAllowedAttempts` | 登录验证码最大尝试次数 | `5` |
| `bindVerificationCodeAllowedAttempts` | 绑定验证码最大尝试次数 | `5` |
| `registrationRequestRateLimit` | 注册请求频率限制 | `5次/10分钟` |
| `loginRequestRateLimit` | 登录请求频率限制 | `5次/10分钟` |
| `bindRequestRateLimit` | 绑定请求频率限制 | `5次/10分钟` |

```dart
SmsIdpConfigFromPasswords(
  // ...
  loginVerificationCodeAllowedAttempts: 5,
  loginRequestRateLimit: SmsRateLimit(
    maxAttempts: 5,
    timeframe: Duration(minutes: 10),
  ),
)
```

## 存储方案对比

| 特性 | Hash 存储 | Crypto 存储 |
|------|----------|-------------|
| 可验证手机号 | ✅ | ✅ |
| 可获取原始手机号 | ❌ | ✅ |
| 存储空间 | 较小 | 较大 |
| 配置项 | 仅 `phoneHashPepper` | `phoneHashPepper` + `phoneEncryptionKey` |
| 适用场景 | 最大隐私保护 | 需要原号码（客服、通知） |

> **建议**：除非有严格的数据最小化要求，否则推荐使用 **crypto** 存储。它提供了 hash 的所有功能，还能在需要时解密。

## 常见问题

### 导入冲突（单独使用子包时）

如果使用单独的子包而不是本组合包：

```dart
// ❌ 错误 - 会导致 Protocol/Endpoints 冲突
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart';

// ✅ 正确 - 隐藏冲突的类
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart'
    hide Protocol, Endpoints;
```

**建议**：直接使用本组合包，省去麻烦。

### 腾讯云频率限制

| 错误码 | 含义 | 解决方案 |
|--------|------|----------|
| `LimitExceeded.PhoneNumberOneHourLimit` | 超过小时限制 | 等待或调整控制台配置 |
| `LimitExceeded.PhoneNumberDailyLimit` | 超过日限制 | 等待到第二天 |
| `LimitExceeded.PhoneNumberThirtySecondLimit` | 30秒冷却 | 前端添加倒计时 |

### 密码正则在原始字符串中

```dart
// ❌ 错误 - 双重转义
if (!password.contains(RegExp(r'[\\W_]'))) return false;

// ✅ 正确
if (!password.contains(RegExp(r'[\W_]'))) return false;
```

### 异步短信回调

```dart
// ❌ 错误 - 异步但没有 await，会导致 "Session is closed" 错误
void _sendSms(Session session, {...}) {
  smsClient.send(...);  // 没有 await
}

// ✅ 正确
Future<void> _sendSms(Session session, {...}) async {
  await smsClient.send(...);
}
```

## 单独使用子包（不推荐）

如果必须使用单独的子包：

```yaml
dependencies:
  serverpod_auth_sms_core_server: ^0.1.2
  serverpod_auth_sms_crypto_server: ^0.1.2  # 或 _hash_server
```

```dart
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart'
    hide Protocol, Endpoints;
import 'package:serverpod_auth_sms_crypto_server/serverpod_auth_sms_crypto_server.dart'
    hide Protocol, Endpoints;
```

## 相关包

- [tencent_sms](https://pub.dev/packages/tencent_sms) - 腾讯云短信 SDK
- [tencent_sms_serverpod](https://pub.dev/packages/tencent_sms_serverpod) - Serverpod 集成
- [serverpod_auth_sms_core_server](https://pub.dev/packages/serverpod_auth_sms_core_server) - 核心模块
- [serverpod_auth_sms_hash_server](https://pub.dev/packages/serverpod_auth_sms_hash_server) - Hash 存储
- [serverpod_auth_sms_crypto_server](https://pub.dev/packages/serverpod_auth_sms_crypto_server) - Crypto 存储

## 许可证

MIT License
