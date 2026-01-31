# serverpod_auth_sms_core_server

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms_core_server.svg)](https://pub.dev/packages/serverpod_auth_sms_core_server)

Serverpod 短信认证核心模块（服务端），提供短信注册、验证码登录和手机号绑定功能。

[English](README.md)

## 功能特性

- **短信注册** - 通过手机号和验证码注册新账号
- **验证码登录** - 支持已注册用户直接通过验证码登录
- **自动注册登录** - 未注册用户尝试登录时可自动创建账号（需提供密码）
- **手机号绑定** - 已登录用户可绑定手机号到现有账号
- **短信服务商无关** - 通过回调函数支持任意短信服务商（腾讯云、阿里云、Twilio 等）
- **可配置回调** - 支持自定义短信发送、密码验证等回调
- **UI 配置** - 可配置密码未变更时的提示文案等 UI 元素

## 安装

```yaml
dependencies:
  serverpod_auth_sms_core_server: ^0.1.0
```

## 使用方法

### 1. 选择手机号存储方式

本包需要配合 `serverpod_auth_sms_hash_server` 或 `serverpod_auth_sms_crypto_server` 使用：

- **Hash 存储** - 仅存储手机号哈希值，不可逆，适合仅需验证身份的场景
- **Crypto 存储** - 同时存储哈希值和加密值，可解密，适合需要获取原始手机号的场景

### 2. 配置服务端

```dart
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart';
import 'package:serverpod_auth_sms_crypto_server/serverpod_auth_sms_crypto_server.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  // 选择存储方式
  final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);
  // 或: final phoneIdStore = PhoneIdHashStore.fromPasswords(pod);

  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      SmsIdpConfigFromPasswords(
        phoneIdStore: phoneIdStore,
        sendRegistrationVerificationCode: _sendSmsCode,
        sendLoginVerificationCode: _sendSmsCode,
        sendBindVerificationCode: _sendSmsCode,
        passwordValidationFunction: _validatePassword,
        requirePasswordOnUnregisteredLogin: true,
        allowPhoneRebind: false,
      ),
    ],
  );

  await pod.start();
}
```

### 3. 配置密钥

在 `config/passwords.yaml` 中添加：

```yaml
shared:
  smsSecretHashPepper: '你的验证码哈希密钥'
  phoneHashPepper: '你的手机号哈希密钥'
  phoneEncryptionKey: '32字节Base64编码的AES密钥'  # 仅 Crypto 存储需要
```

### 4. 创建端点

```dart
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart';

class SmsIdpEndpoint extends SmsIdpBaseEndpoint {}
class PhoneBindEndpoint extends SmsPhoneBindBaseEndpoint {}
class SmsAuthUiEndpoint extends SmsAuthUiBaseEndpoint {}
```

## 实现短信发送回调（自定义服务商）

本包**不绑定任何特定短信服务商**。你需要通过回调函数提供自己的短信发送逻辑，可以使用任意短信服务商。

### 回调函数签名

```dart
typedef SendSmsVerificationCodeFunction = FutureOr<void> Function(
  Session session, {
  required String phone,           // 已标准化的手机号
  required UuidValue requestId,    // 请求 ID（用于日志追踪）
  required String verificationCode, // 生成的验证码
  required Transaction? transaction,
});
```

### 示例：自定义实现

```dart
Future<void> _sendSmsCode(
  Session session, {
  required String phone,
  required UuidValue requestId,
  required String verificationCode,
  required Transaction? transaction,
}) async {
  // 在这里调用你的短信服务商 API
  // 例如：腾讯云、阿里云、Twilio、Vonage 等
  await yourSmsClient.sendCode(phone, verificationCode);
  session.log('发送验证码 $verificationCode 到 $phone');
}
```

## 中国用户推荐

对于中国大陆用户，推荐使用 [tencent_sms_serverpod](https://pub.dev/packages/tencent_sms_serverpod) 包快速集成腾讯云短信：

```yaml
dependencies:
  tencent_sms_serverpod: ^0.1.0
```

配置 `config/passwords.yaml`：

```yaml
shared:
  tencentSmsSecretId: 'your-secret-id'
  tencentSmsSecretKey: 'your-secret-key'
  tencentSmsSdkAppId: '1400000000'
  tencentSmsSignName: '你的签名'
  tencentSmsVerificationTemplateId: '123456'
```

使用示例：

```dart
import 'package:tencent_sms_serverpod/tencent_sms_serverpod.dart';
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  // 创建腾讯云短信客户端
  final smsConfig = TencentSmsConfigServerpod.fromServerpod(pod);
  final smsClient = TencentSmsClient(smsConfig);
  final smsHelper = SmsAuthCallbackHelper(smsClient);

  final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);

  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      SmsIdpConfigFromPasswords(
        phoneIdStore: phoneIdStore,
        sendRegistrationVerificationCode: smsHelper.sendForRegistration,
        sendLoginVerificationCode: smsHelper.sendForLogin,
        sendBindVerificationCode: smsHelper.sendForBind,
      ),
    ],
  );

  await pod.start();
}
```

## 配置选项

### 功能开关

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `enableRegistration` | 启用短信注册 | `true` |
| `enableLogin` | 启用验证码登录 | `true` |
| `enableBind` | 启用手机号绑定 | `true` |
| `requirePasswordOnUnregisteredLogin` | 未注册用户登录时需提供密码 | `true` |
| `allowPhoneRebind` | 允许用户更换绑定的手机号 | `false` |

### 验证码配置

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `verificationCodeLength` | 验证码长度 | `6` |
| `registrationVerificationCodeLifetime` | 注册验证码有效期 | `10 分钟` |
| `loginVerificationCodeLifetime` | 登录验证码有效期 | `10 分钟` |
| `bindVerificationCodeLifetime` | 绑定验证码有效期 | `10 分钟` |

### 频率限制配置

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `registrationVerificationCodeAllowedAttempts` | 注册验证码允许尝试次数 | `5` |
| `loginVerificationCodeAllowedAttempts` | 登录验证码允许尝试次数 | `5` |
| `bindVerificationCodeAllowedAttempts` | 绑定验证码允许尝试次数 | `5` |
| `registrationRequestRateLimit` | 注册请求频率限制 | `5次/10分钟` |
| `loginRequestRateLimit` | 登录请求频率限制 | `5次/10分钟` |
| `bindRequestRateLimit` | 绑定请求频率限制 | `5次/10分钟` |

配置示例：

```dart
SmsIdpConfigFromPasswords(
  phoneIdStore: phoneIdStore,
  // 验证码配置
  verificationCodeLength: 6,
  loginVerificationCodeLifetime: Duration(minutes: 5),
  // 频率限制配置
  loginVerificationCodeAllowedAttempts: 5,
  loginRequestRateLimit: SmsRateLimit(
    maxAttempts: 5,
    timeframe: Duration(minutes: 10),
  ),
  // ...其他配置
)
```

## 数据库表

本模块会创建以下数据库表：

- `serverpod_auth_sms_account` - 短信账号凭据
- `serverpod_auth_sms_account_request` - 注册请求
- `serverpod_auth_sms_login_request` - 登录请求
- `serverpod_auth_sms_bind_request` - 绑定请求

## 常见问题

### 1. 导入冲突：Protocol 和 Endpoints

如果你直接导入各个包（`serverpod_auth_sms_core_server`、`serverpod_auth_sms_hash_server`、`serverpod_auth_sms_crypto_server`），需要添加 `hide` 避免与项目生成的类冲突：

```dart
// ❌ 错误 - 会导致 Protocol/Endpoints 冲突
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart';

// ✅ 正确 - 隐藏冲突的类
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart'
    hide Protocol, Endpoints;
import 'package:serverpod_auth_sms_crypto_server/serverpod_auth_sms_crypto_server.dart'
    hide Protocol, Endpoints;
```

**推荐**：使用组合包 `serverpod_auth_sms`，它已内部处理好 hide 逻辑：

```dart
// ✅ 推荐 - 使用组合包，无需手动 hide
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';
```

### 2. 短信发送函数必须正确处理异步

`SendSmsVerificationCodeFunction` 的返回类型是 `FutureOr<void>`。如果你的短信发送逻辑是异步的，**必须确保函数声明为 `async` 或返回 `Future`**：

```dart
// ❌ 错误 - 异步操作但没有等待，会导致 "Session is closed" 错误
void _sendSmsCode(Session session, {...}) {
  smsClient.send(...);  // 异步但没 await
}

// ✅ 正确 - 声明为 async 并 await
Future<void> _sendSmsCode(Session session, {...}) async {
  await smsClient.send(...);
}
```

### 3. 外部短信服务频率限制

使用腾讯云、阿里云等短信服务时，请注意服务商的发送频率限制。例如腾讯云常见错误：

| 错误码 | 说明 | 解决方案 |
|--------|------|----------|
| `LimitExceeded.PhoneNumberOneHourLimit` | 单手机号1小时内发送数量超限 | 等待或在控制台调整限制 |
| `LimitExceeded.PhoneNumberDailyLimit` | 单手机号日发送数量超限 | 同上 |
| `LimitExceeded.PhoneNumberThirtySecondLimit` | 30秒内发送频率超限 | 前端添加冷却时间 |

建议在前端实现发送冷却倒计时（如60秒），避免用户频繁点击触发限制。

### 4. RateLimit 类型命名

本包使用 `SmsRateLimit` 而非 `RateLimit`，以避免与 `serverpod_auth_idp_server` 中的 `RateLimit` 冲突：

```dart
// 配置登录请求频率限制
SmsIdpConfigFromPasswords(
  // ...
  loginRequestRateLimit: SmsRateLimit(
    maxAttempts: 5,
    timeframe: Duration(minutes: 10),
  ),
)
```

### 5. 密码验证函数

自定义密码验证时，注意 Dart 正则表达式的转义规则。在原始字符串 `r'...'` 中，`\W` 匹配非单词字符：

```dart
// ❌ 错误 - 多余的转义
if (!password.contains(RegExp(r'[\\W_]'))) return false;

// ✅ 正确 - 原始字符串中 \W 直接使用
if (!password.contains(RegExp(r'[\W_]'))) return false;
```

## 相关包

- [serverpod_auth_sms_hash_server](https://pub.dev/packages/serverpod_auth_sms_hash_server) - 哈希存储实现
- [serverpod_auth_sms_crypto_server](https://pub.dev/packages/serverpod_auth_sms_crypto_server) - 加密存储实现
- [serverpod_auth_sms](https://pub.dev/packages/serverpod_auth_sms) - 组合包

## 许可证

MIT License
