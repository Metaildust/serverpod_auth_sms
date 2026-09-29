# serverpod_auth_sms_core_client

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms_core_client.svg)](https://pub.dev/packages/serverpod_auth_sms_core_client)

Serverpod 短信认证核心模块的客户端包。

[English](README.md)

## 概述

此包包含 `serverpod_auth_sms_core_server` 模块生成的客户端协议代码，用于 Flutter 应用与服务端通信。

## 安装

通常不需要直接安装此包。当你为 Flutter 应用生成 Serverpod 客户端代码且服务端依赖 `serverpod_auth_sms_core_server` 时，此包通常会作为传递依赖被引入。

如需手动安装：

```yaml
dependencies:
  serverpod_auth_sms_core_client: ^0.2.0
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
- `SmsVerifyLoginResult` - 登录验证码验证结果（包含 `token` 与是否需要设置短信密码）
- `SmsSamePasswordBanner` - 密码未变更提示配置
- `SmsVerifyBindResultV2` - 带冲突信息的绑定验证码验证结果
- `SmsBindFinishDecision` - 冲突处理用户决策枚举（`bindAndLogin` / `registerNew`）
- `SmsBindAndLoginDisabledReason` - “绑定并登录”禁用原因

## 前端使用示例

### 处理登录验证码验证结果

`verifyLoginCode` 返回 `SmsVerifyLoginResult`，其中 `needsPassword` 表示
是否需要进入“设置短信密码”步骤：

- 手机号未绑定任何账号 -> 设密后会创建新的短信账号。
- 手机号已绑定某个账号但该账号还没有 `SmsAccount` -> 设密后会把密码补写回原 `authUser`。

```dart
final result = await client.smsIdp.verifyLoginCode(
  loginRequestId: requestId,
  verificationCode: code,
);

if (result.needsPassword) {
  // 显示短信密码设定界面。
  showPasswordDialog();
} else {
  // 已有短信密码账号 - 直接完成登录。
  final authResult = await client.smsIdp.finishLogin(
    loginToken: result.token,
    phone: phone,
  );
  await client.auth.updateSignedInUser(authResult);
}
```

`SmsBindFinishDecision` 为保持包兼容性同时暴露 `bindAndLogin` 与
`registerNew`。具体应用仍可在自己的 endpoint 层拒绝 `registerNew`。

## 相关包

- [serverpod_auth_sms_core_server](https://pub.dev/packages/serverpod_auth_sms_core_server) - 服务端核心模块
- [serverpod_auth_sms_hash_client](https://pub.dev/packages/serverpod_auth_sms_hash_client) - 哈希存储客户端
- [serverpod_auth_sms_crypto_client](https://pub.dev/packages/serverpod_auth_sms_crypto_client) - 加密存储客户端

## 许可证

MIT License
