# serverpod_auth_sms

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms.svg)](https://pub.dev/packages/serverpod_auth_sms)

Serverpod 短信认证组合包，重新导出所有 SMS 认证相关模块。

[English](README.md)

## 概述

这是一个便捷的组合包，包含了 Serverpod 短信认证的所有服务端模块：

- `serverpod_auth_sms_core_server` - 核心认证逻辑
- `serverpod_auth_sms_hash_server` - 哈希存储实现
- `serverpod_auth_sms_crypto_server` - 加密存储实现

## 安装

```yaml
dependencies:
  serverpod_auth_sms: ^0.1.0
```

## 数据库迁移

添加依赖后，需要创建数据库迁移来生成必要的表：

```bash
cd your_server_project
serverpod create-migration
```

然后启动服务器时应用迁移：

```bash
dart bin/main.dart --apply-migrations
```

## 快速开始

```dart
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  // 选择存储方式（二选一）
  final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);  // 可解密
  // final phoneIdStore = PhoneIdHashStore.fromPasswords(pod); // 不可逆

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
```

## 功能特性

### 核心功能（来自 core）
- 短信注册
- 验证码登录（`verifyLoginCode` 返回 `SmsVerifyLoginResult`，包含 `needsPassword` 指示是否需要设置密码）
- 手机号绑定
- 自动注册登录（未注册用户可通过验证码登录并自动创建账号）
- **短信服务商无关** - 通过回调函数支持任意短信服务商

### 存储选项
- **Hash 存储** - 不可逆哈希，适合隐私保护
- **Crypto 存储** - 可解密存储，适合需要获取原号码的场景

## 中国用户推荐

对于中国大陆用户，推荐配合 [tencent_sms_serverpod](https://pub.dev/packages/tencent_sms_serverpod) 包使用，快速集成腾讯云短信：

```yaml
dependencies:
  serverpod_auth_sms: ^0.1.0
  tencent_sms_serverpod: ^0.1.0
```

```dart
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';
import 'package:tencent_sms_serverpod/tencent_sms_serverpod.dart';

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

详细信息请参阅 [serverpod_auth_sms_core 文档](https://pub.dev/packages/serverpod_auth_sms_core_server)。

## 配置

在 `config/passwords.yaml` 中添加：

```yaml
shared:
  smsSecretHashPepper: '验证码哈希密钥'
  phoneHashPepper: '手机号哈希密钥'
  phoneEncryptionKey: 'AES密钥（仅Crypto需要）'
```

## 模块详情

如需了解各模块的详细信息，请参阅：

- [serverpod_auth_sms_core_server](https://pub.dev/packages/serverpod_auth_sms_core_server) - 核心模块文档
- [serverpod_auth_sms_hash_server](https://pub.dev/packages/serverpod_auth_sms_hash_server) - 哈希存储文档
- [serverpod_auth_sms_crypto_server](https://pub.dev/packages/serverpod_auth_sms_crypto_server) - 加密存储文档

## 单独引用

如果你只需要部分功能，可以单独引用各模块而不使用此组合包：

```yaml
dependencies:
  # 仅使用核心 + 哈希存储
  serverpod_auth_sms_core_server: ^0.1.0
  serverpod_auth_sms_hash_server: ^0.1.0

  # 或仅使用核心 + 加密存储
  # serverpod_auth_sms_core_server: ^0.1.0
  # serverpod_auth_sms_crypto_server: ^0.1.0
```

> **注意**：单独引用子模块时，需要在导入时 hide 掉 `Protocol` 和 `Endpoints` 以避免命名冲突：
>
> ```dart
> import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart'
>     hide Protocol, Endpoints;
> import 'package:serverpod_auth_sms_hash_server/serverpod_auth_sms_hash_server.dart'
>     hide Protocol, Endpoints;
> ```

## 客户端依赖

如果使用 `hash` 或 `crypto` 存储模块，客户端项目 (`*_client`) 也需要添加对应的依赖：

```yaml
# gen_client/pubspec.yaml
dependencies:
  serverpod_auth_sms_core_client: ^0.1.0
  serverpod_auth_sms_hash_client: ^0.1.0   # 如果使用 hash 存储
  serverpod_auth_sms_crypto_client: ^0.1.0 # 如果使用 crypto 存储
```

## 许可证

MIT License
