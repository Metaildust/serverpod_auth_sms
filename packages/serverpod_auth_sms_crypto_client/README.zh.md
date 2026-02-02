# serverpod_auth_sms_crypto_client

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms_crypto_client.svg)](https://pub.dev/packages/serverpod_auth_sms_crypto_client)

Serverpod 短信认证加密存储模块的客户端包。

[English](README.md)

## 概述

此包包含 `serverpod_auth_sms_crypto_server` 模块生成的客户端协议代码。由于加密存储模块主要在服务端运行，此客户端包主要用于协议序列化支持。

## 安装

通常不需要直接安装此包。当你在 Flutter 项目中使用 `gen_client` 生成客户端代码时，如果服务端依赖了 `serverpod_auth_sms_crypto_server`，此包会自动作为传递依赖被引入。

如需手动安装：

```yaml
dependencies:
  serverpod_auth_sms_crypto_client: ^0.1.2
```

## 相关包

- [serverpod_auth_sms_crypto_server](https://pub.dev/packages/serverpod_auth_sms_crypto_server) - 服务端加密存储模块
- [serverpod_auth_sms_core_client](https://pub.dev/packages/serverpod_auth_sms_core_client) - 核心模块客户端
- [serverpod_auth_sms_hash_client](https://pub.dev/packages/serverpod_auth_sms_hash_client) - 哈希存储客户端

## 许可证

MIT License
