# serverpod_auth_sms

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms.svg)](https://pub.dev/packages/serverpod_auth_sms)

Combined package for Serverpod SMS authentication, re-exporting all SMS auth modules.

[中文文档](README.zh.md)

## Overview

This is a convenience package that includes all server-side modules for Serverpod SMS authentication:

- `serverpod_auth_sms_core_server` - Core authentication logic
- `serverpod_auth_sms_hash_server` - Hash storage implementation
- `serverpod_auth_sms_crypto_server` - Crypto storage implementation

## Installation

```yaml
dependencies:
  serverpod_auth_sms: ^0.1.0
```

## Database Migration

After adding the dependency, create database migrations to generate the required tables:

```bash
cd your_server_project
serverpod create-migration
```

Then apply migrations when starting the server:

```bash
dart bin/main.dart --apply-migrations
```

## Quick Start

```dart
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Choose storage method (pick one)
  final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);  // Decryptable
  // final phoneIdStore = PhoneIdHashStore.fromPasswords(pod); // Irreversible

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

## Features

### Core Features (from core)
- SMS registration
- Verification code login (`verifyLoginCode` returns `SmsVerifyLoginResult` with `needsPassword` indicating if password setup is required)
- Phone number binding
- Auto-register on login (unregistered users can login with verification code and auto-create account)
- **Provider-Agnostic** - Support any SMS provider via callbacks

### Storage Options
- **Hash Storage** - Irreversible hash, for privacy protection
- **Crypto Storage** - Decryptable storage, for scenarios requiring original number

## For Chinese Users

For users in mainland China, we recommend using [tencent_sms_serverpod](https://pub.dev/packages/tencent_sms_serverpod) for quick Tencent Cloud SMS integration:

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

  // Create Tencent Cloud SMS client
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

See [serverpod_auth_sms_core documentation](https://pub.dev/packages/serverpod_auth_sms_core_server) for details.

## Configuration

Add to `config/passwords.yaml`:

```yaml
shared:
  smsSecretHashPepper: 'verification-code-hash-pepper'
  phoneHashPepper: 'phone-hash-pepper'
  phoneEncryptionKey: 'AES-key (Crypto only)'
```

## Module Details

For detailed information about each module, see:

- [serverpod_auth_sms_core_server](https://pub.dev/packages/serverpod_auth_sms_core_server) - Core module docs
- [serverpod_auth_sms_hash_server](https://pub.dev/packages/serverpod_auth_sms_hash_server) - Hash storage docs
- [serverpod_auth_sms_crypto_server](https://pub.dev/packages/serverpod_auth_sms_crypto_server) - Crypto storage docs

## Individual Dependencies

If you only need partial functionality, you can depend on individual modules instead of this combined package:

```yaml
dependencies:
  # Use core + hash storage only
  serverpod_auth_sms_core_server: ^0.1.0
  serverpod_auth_sms_hash_server: ^0.1.0

  # Or use core + crypto storage only
  # serverpod_auth_sms_core_server: ^0.1.0
  # serverpod_auth_sms_crypto_server: ^0.1.0
```

> **Note**: When importing individual modules, you need to hide `Protocol` and `Endpoints` to avoid naming conflicts:
>
> ```dart
> import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart'
>     hide Protocol, Endpoints;
> import 'package:serverpod_auth_sms_hash_server/serverpod_auth_sms_hash_server.dart'
>     hide Protocol, Endpoints;
> ```

## Client Dependencies

If using `hash` or `crypto` storage modules, the client project (`*_client`) also needs the corresponding dependencies:

```yaml
# gen_client/pubspec.yaml
dependencies:
  serverpod_auth_sms_core_client: ^0.1.0
  serverpod_auth_sms_hash_client: ^0.1.0   # If using hash storage
  serverpod_auth_sms_crypto_client: ^0.1.0 # If using crypto storage
```

## License

MIT License
