# serverpod_auth_sms_hash_client

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms_hash_client.svg)](https://pub.dev/packages/serverpod_auth_sms_hash_client)

Client package for Serverpod SMS authentication hash storage module.

[中文文档](README.zh.md)

## Overview

This package contains the client protocol code generated from `serverpod_auth_sms_hash_server` module. Since the hash storage module mainly runs on the server side, this client package is primarily for protocol serialization support.

## Installation

You typically don't need to install this package directly. When you generate Serverpod client code for your Flutter app and the server depends on `serverpod_auth_sms_hash_server`, this package is usually included as a transitive dependency.

For manual installation:

```yaml
dependencies:
  serverpod_auth_sms_hash_client: ^0.1.6
```

## Related Packages

- [serverpod_auth_sms_hash_server](https://pub.dev/packages/serverpod_auth_sms_hash_server) - Server-side hash storage module
- [serverpod_auth_sms_core_client](https://pub.dev/packages/serverpod_auth_sms_core_client) - Core module client
- [serverpod_auth_sms_crypto_client](https://pub.dev/packages/serverpod_auth_sms_crypto_client) - Crypto storage client

## License

MIT License
