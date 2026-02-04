# serverpod_auth_sms

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms.svg)](https://pub.dev/packages/serverpod_auth_sms)

Serverpod 短信认证**推荐使用的包**。

[English](README.md)

## 为什么用这个包？

本包提供**完整的短信认证功能**，支持灵活选择存储方式：

| 你的需求 | 直接用本包即可 |
|---------|---------------|
| 仅哈希存储（不可逆）| ✅ 使用 `PhoneIdHashStore` |
| 加密存储（可解密）| ✅ 使用 `PhoneIdCryptoStore` |
| 无需手动 `hide Protocol, Endpoints` | ✅ 自动处理 |

**你不需要单独引入子包。** 本包已包含所有功能，通过配置选择存储方式即可：

```dart
// 只需导入这一个包
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';

// 然后选择存储方式：
final phoneIdStore = PhoneIdHashStore.fromPasswords(pod);   // 仅哈希
// 或
final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod); // 加密（推荐）
```

> **子包（`_core`、`_hash`、`_crypto`）仅供高级用户使用**，需要手动添加 `hide Protocol, Endpoints`。大多数用户直接用本包即可。

## 功能特性

- **短信注册** - 使用手机号和验证码注册
- **验证码登录** - 手机号 + 验证码登录（未注册用户自动注册）
- **手机号绑定** - 为已有账号绑定手机号
- **服务商无关** - 通过回调函数支持任意短信服务商

## 安装

### 服务端依赖

```yaml
# gen_server/pubspec.yaml
dependencies:
  serverpod_auth_sms: ^0.1.5
  # 可选：腾讯云短信集成（中国业务）
  tencent_sms_serverpod: ^0.1.5
```

### 客户端依赖

```yaml
# gen_client/pubspec.yaml
dependencies:
  serverpod_auth_sms_core_client: ^0.1.5
  # 根据存储方式选择其一：
  serverpod_auth_sms_crypto_client: ^0.1.5  # 加密存储
  # serverpod_auth_sms_hash_client: ^0.1.5  # 哈希存储
```

## 快速开始

### 第一步：选择存储方式

| 存储方式 | 适用场景 | 需要配置 |
|---------|---------|---------|
| **Crypto**（推荐）| 大多数情况 - 可验证也可获取手机号 | `phoneHashPepper` + `phoneEncryptionKey` |
| **Hash** | 最大隐私保护 - 只能验证，无法获取原号 | 仅 `phoneHashPepper` |

> **注意**：Crypto 存储内部也会存储哈希值，所以它涵盖了 Hash 的所有功能，同时还支持解密获取原始手机号。如果不确定，选择 Crypto - 既能验证手机号（和 Hash 一样），又能在需要时解密（如客服联系、订单通知）。

### 第二步：配置 passwords.yaml

```yaml
# config/passwords.yaml
shared:
  # ============================================
  # 核心短信认证（必需）
  # ============================================
  
  # 验证码哈希密钥（必需）
  smsSecretHashPepper: '随机字符串-用于验证码哈希'
  
  # ============================================
  # 手机号存储（必需）
  # ============================================
  
  # 手机号哈希密钥（Hash 和 Crypto 都需要）
  # ⚠️ 警告：部署后不可更改，否则已有数据无法匹配
  phoneHashPepper: '随机字符串-用于手机号哈希'
  
  # AES-256 加密密钥（仅 Crypto 存储需要）
  # 生成命令：openssl rand -base64 32
  # ⚠️ 警告：不可更改，泄露将导致所有手机号可被解密
  phoneEncryptionKey: 'base64编码的32字节密钥'
  
  # ============================================
  # 腾讯云短信（可选 - 中国业务）
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

### 第三步：配置服务器

```dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  // ========================================
  // 选择存储方式（二选一）：
  // ========================================
  
  // 方案 A：Crypto 存储（推荐）
  // - 可以验证手机号（和 Hash 一样）
  // - 还可以解密获取原始手机号（用于客服、通知等）
  final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);
  
  // 方案 B：Hash 存储
  // - 只能验证手机号
  // - 无法获取原始手机号（最大隐私保护）
  // final phoneIdStore = PhoneIdHashStore.fromPasswords(pod);

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

### 使用腾讯云短信（中国业务）

```dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';
import 'package:tencent_sms_serverpod/tencent_sms_serverpod.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  // 创建腾讯云短信客户端（凭据从 passwords.yaml 读取，其他配置直接传入）
  final smsConfig = TencentSmsConfigServerpod.fromServerpod(
    pod,
    appConfig: TencentSmsAppConfig(
      smsSdkAppId: '1400000000',
      signName: '你的签名',
      templateCsvPath: 'config/sms/templates.csv',
      verificationTemplateNameLogin: '登录',
      verificationTemplateNameRegister: '注册',
      verificationTemplateNameResetPassword: '修改密码',
    ),
  );
  final smsClient = TencentSmsClient(smsConfig);
  // 使用中文错误消息：TencentSmsClient(smsConfig, localizations: const SmsLocalizationsZh())
  final smsHelper = SmsAuthCallbackHelper(smsClient);

  // 选择存储方式（参见第一步）
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
        requirePasswordOnUnregisteredLogin: true,
        allowPhoneRebind: false,
        verificationCodeLength: 6,
        loginVerificationCodeLifetime: Duration(minutes: 10),
      ),
    ],
  );

  await pod.start();
}
```

### 第四步：创建 Endpoints

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

## 常见问题

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

## 高级：单独使用子包

> **不推荐大多数用户使用。** 仅在有特殊需求时使用。

如果必须使用单独的子包（例如只用 hash 且想避免 crypto 依赖）：

```yaml
dependencies:
  serverpod_auth_sms_core_server: ^0.1.5
  serverpod_auth_sms_hash_server: ^0.1.5  # 或 _crypto_server
```

```dart
// 必须手动 hide Protocol 和 Endpoints
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart'
    hide Protocol, Endpoints;
import 'package:serverpod_auth_sms_hash_server/serverpod_auth_sms_hash_server.dart'
    hide Protocol, Endpoints;
```

## 相关包

- [tencent_sms](https://pub.dev/packages/tencent_sms) - 腾讯云短信 SDK
- [tencent_sms_serverpod](https://pub.dev/packages/tencent_sms_serverpod) - Serverpod 集成

## 许可证

MIT License
