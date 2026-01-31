# Serverpod Auth SMS

[![Pub Version](https://img.shields.io/pub/v/serverpod_auth_sms)](https://pub.dev/packages/serverpod_auth_sms)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Serverpod 短信认证模块 - 支持短信注册、验证码登录和手机号绑定。

[English](README.en.md)

## 功能特性

- **短信注册** - 通过手机号和验证码注册新账号
- **验证码登录** - 已注册用户直接通过验证码登录
- **自动注册登录** - 未注册用户可自动创建账号（需提供密码）
- **手机号绑定** - 已登录用户可绑定手机号到现有账号
- **短信服务商无关** - 通过回调函数支持任意短信服务商
- **双重存储方案** - 支持不可逆哈希存储和可解密加密存储

## 包结构

| 包名 | 说明 |
|------|------|
| [serverpod_auth_sms](packages/serverpod_auth_sms/) | 组合包，包含所有服务端模块 |
| [serverpod_auth_sms_core_server](packages/serverpod_auth_sms_core/) | 核心认证逻辑 |
| [serverpod_auth_sms_hash_server](packages/serverpod_auth_sms_hash/) | 哈希存储实现（不可逆） |
| [serverpod_auth_sms_crypto_server](packages/serverpod_auth_sms_crypto/) | 加密存储实现（可解密） |
| [serverpod_auth_sms_core_client](packages/serverpod_auth_sms_core_client/) | 核心客户端 |
| [serverpod_auth_sms_hash_client](packages/serverpod_auth_sms_hash_client/) | 哈希存储客户端 |
| [serverpod_auth_sms_crypto_client](packages/serverpod_auth_sms_crypto_client/) | 加密存储客户端 |

## 快速开始

```yaml
dependencies:
  serverpod_auth_sms: ^0.1.0
```

```dart
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);

  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      SmsIdpConfigFromPasswords(
        phoneIdStore: phoneIdStore,
        sendRegistrationVerificationCode: _sendSmsCode,
        sendLoginVerificationCode: _sendSmsCode,
        sendBindVerificationCode: _sendSmsCode,
      ),
    ],
  );

  await pod.start();
}
```

## 中国用户推荐

配合 [tencent_sms_serverpod](https://pub.dev/packages/tencent_sms_serverpod) 快速集成腾讯云短信。

## 文档

详细文档请参阅各包的 README：
- [核心模块文档](packages/serverpod_auth_sms_core/README.md)
- [哈希存储文档](packages/serverpod_auth_sms_hash/README.md)
- [加密存储文档](packages/serverpod_auth_sms_crypto/README.md)

## 许可证

MIT License
