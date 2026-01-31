# serverpod_auth_sms_core_client

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms_core_client.svg)](https://pub.dev/packages/serverpod_auth_sms_core_client)

Client package for Serverpod SMS authentication core module.

[中文文档](README.zh.md)

## Overview

This package contains the client protocol code generated from `serverpod_auth_sms_core_server` module, used for Flutter app communication with the server.

## Installation

You typically don't need to install this package directly. When generating client code in your Flutter project using `gen_client`, if the server depends on `serverpod_auth_sms_core_server`, this package will be automatically included as a transitive dependency.

For manual installation:

```yaml
dependencies:
  serverpod_auth_sms_core_client: ^0.1.1
```

## Exports

This package exports the following types:

### Exceptions
- `SmsAccountRequestException` - Registration request exception
- `SmsAccountRequestExceptionReason` - Registration exception reason enum
- `SmsLoginException` - Login exception
- `SmsLoginExceptionReason` - Login exception reason enum
- `SmsPhoneBindException` - Phone binding exception
- `SmsPhoneBindExceptionReason` - Phone binding exception reason enum

### Data Models
- `SmsVerifyLoginResult` - Login verification result (contains `token` and `needsPassword`)
- `SmsSamePasswordBanter` - Password unchanged hint configuration

## Frontend Usage Example

### Handling Login Verification Result

`verifyLoginCode` returns `SmsVerifyLoginResult`, with `needsPassword` indicating whether a password is required (for auto-registration of new users):

```dart
final result = await client.smsIdp.verifyLoginCode(
  loginRequestId: requestId,
  verificationCode: code,
);

if (result.needsPassword) {
  // New user - show password input dialog
  showPasswordDialog();
} else {
  // Existing user - complete login directly
  final authResult = await client.smsIdp.finishLogin(
    loginToken: result.token,
    phone: phone,
  );
  await client.auth.updateSignedInUser(authResult);
}
```

## Related Packages

- [serverpod_auth_sms_core_server](https://pub.dev/packages/serverpod_auth_sms_core_server) - Server-side core module
- [serverpod_auth_sms_hash_client](https://pub.dev/packages/serverpod_auth_sms_hash_client) - Hash storage client
- [serverpod_auth_sms_crypto_client](https://pub.dev/packages/serverpod_auth_sms_crypto_client) - Crypto storage client

## License

MIT License
