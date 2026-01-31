# serverpod_auth_sms_core_client

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms_core_client.svg)](https://pub.dev/packages/serverpod_auth_sms_core_client)

Serverpod 短信认证核心模块的客户端包。

[English](README.md)

## 概述

此包包含 `serverpod_auth_sms_core_server` 模块生成的客户端协议代码，用于 Flutter 应用与服务端通信。

## 安装

通常不需要直接安装此包。当你在 Flutter 项目中使用 `gen_client` 生成客户端代码时，如果服务端依赖了 `serverpod_auth_sms_core_server`，此包会自动作为传递依赖被引入。

如需手动安装：

```yaml
dependencies:
  serverpod_auth_sms_core_client: ^0.1.0
```

## 导出内容

此包导出以下类型：

### 异常类
- `SmsAccountRequestException` - 注册请求异常
- `SmsAccountRequestExceptionReason` - 注册请求异常原因枚举
- `SmsLoginException` - 登录异常
- `SmsLoginExceptionReason` - 登录异常原因枚举
- `SmsPhoneBindException` - 手机绑定异常
- `SmsPhoneBindExceptionReason` - 手机绑定异常原因枚举

### 数据模型
- `SmsVerifyLoginResult` - 登录验证码验证结果（包含 `token` 和 `needsPassword`）
- `SmsSamePasswordBanter` - 密码未变更提示配置

## 前端使用示例

### 处理登录验证码验证结果

`verifyLoginCode` 返回 `SmsVerifyLoginResult`，包含 `needsPassword` 字段指示是否需要设置密码（新用户自动注册时）：

```dart
final result = await client.smsIdp.verifyLoginCode(
  loginRequestId: requestId,
  verificationCode: code,
);

if (result.needsPassword) {
  // 新用户 - 显示密码输入界面
  showPasswordDialog();
} else {
  // 已有用户 - 直接完成登录
  final authResult = await client.smsIdp.finishLogin(
    loginToken: result.token,
    phone: phone,
  );
  await client.auth.updateSignedInUser(authResult);
}
```

## 相关包

- [serverpod_auth_sms_core_server](https://pub.dev/packages/serverpod_auth_sms_core_server) - 服务端核心模块
- [serverpod_auth_sms_hash_client](https://pub.dev/packages/serverpod_auth_sms_hash_client) - 哈希存储客户端
- [serverpod_auth_sms_crypto_client](https://pub.dev/packages/serverpod_auth_sms_crypto_client) - 加密存储客户端

## 许可证

MIT License
