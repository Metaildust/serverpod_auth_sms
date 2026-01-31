# Serverpod Auth SMS

[![Pub Version](https://img.shields.io/pub/v/serverpod_auth_sms)](https://pub.dev/packages/serverpod_auth_sms)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Serverpod SMS authentication module - SMS registration, verification code login, and phone number binding.

[中文文档](README.zh.md)

## Features

- **SMS Registration** - Register new accounts with phone number and verification code
- **Verification Code Login** - Registered users login directly with verification code
- **Auto-register on Login** - Unregistered users can auto-create account (password required)
- **Phone Binding** - Logged-in users can bind phone number to existing account
- **Provider-Agnostic** - Support any SMS provider via callbacks
- **Dual Storage Options** - Irreversible hash storage and decryptable crypto storage

## Package Structure

| Package | Description |
|---------|-------------|
| [serverpod_auth_sms](packages/serverpod_auth_sms/) | Combined package with all server modules |
| [serverpod_auth_sms_core_server](packages/serverpod_auth_sms_core/) | Core authentication logic |
| [serverpod_auth_sms_hash_server](packages/serverpod_auth_sms_hash/) | Hash storage (irreversible) |
| [serverpod_auth_sms_crypto_server](packages/serverpod_auth_sms_crypto/) | Crypto storage (decryptable) |
| [serverpod_auth_sms_core_client](packages/serverpod_auth_sms_core_client/) | Core client |
| [serverpod_auth_sms_hash_client](packages/serverpod_auth_sms_hash_client/) | Hash storage client |
| [serverpod_auth_sms_crypto_client](packages/serverpod_auth_sms_crypto_client/) | Crypto storage client |

## Quick Start

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

## For Chinese Users

Use with [tencent_sms_serverpod](https://pub.dev/packages/tencent_sms_serverpod) for quick Tencent Cloud SMS integration.

## Documentation

See individual package READMEs for detailed documentation:
- [Core Module Docs](packages/serverpod_auth_sms_core/README.md)
- [Hash Storage Docs](packages/serverpod_auth_sms_hash/README.md)
- [Crypto Storage Docs](packages/serverpod_auth_sms_crypto/README.md)

## License

MIT License
