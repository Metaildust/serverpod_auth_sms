# serverpod_auth_sms_core_server

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms_core_server.svg)](https://pub.dev/packages/serverpod_auth_sms_core_server)

Core SMS authentication module for Serverpod (server-side), providing SMS registration, verification code login, and phone number binding.

[中文文档](README.zh.md)

## Features

- **SMS Registration** - Register new accounts with phone number and verification code
- **Verification Code Login** - Registered users can login directly with verification code
- **Auto-register on Login** - Unregistered users can auto-create account when logging in (password required)
- **Phone Binding** - Logged-in users can bind phone number to existing account
- **Provider-Agnostic** - Support any SMS provider via callbacks (Tencent Cloud, Alibaba Cloud, Twilio, etc.)
- **Configurable Callbacks** - Custom SMS sending, password validation callbacks
- **UI Configuration** - Configurable UI elements like password-unchanged hints

## Installation

```yaml
dependencies:
  serverpod_auth_sms_core_server: ^0.1.1
```

## Usage

### 1. Choose Phone Storage Method

This package requires either `serverpod_auth_sms_hash_server` or `serverpod_auth_sms_crypto_server`:

- **Hash Storage** - Stores only phone hash, irreversible, for identity verification only
- **Crypto Storage** - Stores both hash and encrypted value, decryptable, for scenarios requiring original phone number

### 2. Configure Server

```dart
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart';
import 'package:serverpod_auth_sms_crypto_server/serverpod_auth_sms_crypto_server.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Choose storage method
  final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);
  // Or: final phoneIdStore = PhoneIdHashStore.fromPasswords(pod);

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

### 3. Configure Secrets

Add to `config/passwords.yaml`:

```yaml
shared:
  smsSecretHashPepper: 'your-verification-code-hash-pepper'
  phoneHashPepper: 'your-phone-hash-pepper'
  phoneEncryptionKey: '32-byte-base64-encoded-AES-key'  # Only for Crypto storage
```

### 4. Create Endpoints

```dart
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart';

class SmsIdpEndpoint extends SmsIdpBaseEndpoint {}
class PhoneBindEndpoint extends SmsPhoneBindBaseEndpoint {}
class SmsAuthUiEndpoint extends SmsAuthUiBaseEndpoint {}
```

## Implementing SMS Callbacks (Custom Provider)

This package **does not bind to any specific SMS provider**. You need to provide your own SMS sending logic through callback functions, allowing you to use any SMS provider.

### Callback Function Signature

```dart
typedef SendSmsVerificationCodeFunction = FutureOr<void> Function(
  Session session, {
  required String phone,           // Normalized phone number
  required UuidValue requestId,    // Request ID (for logging)
  required String verificationCode, // Generated verification code
  required Transaction? transaction,
});
```

### Example: Custom Implementation

```dart
Future<void> _sendSmsCode(
  Session session, {
  required String phone,
  required UuidValue requestId,
  required String verificationCode,
  required Transaction? transaction,
}) async {
  // Call your SMS provider API here
  // Examples: Tencent Cloud, Alibaba Cloud, Twilio, Vonage, etc.
  await yourSmsClient.sendCode(phone, verificationCode);
  session.log('Sending code $verificationCode to $phone');
}
```

## For Chinese Users

For users in mainland China, we recommend using [tencent_sms_serverpod](https://pub.dev/packages/tencent_sms_serverpod) for quick Tencent Cloud SMS integration:

```yaml
dependencies:
  tencent_sms_serverpod: ^0.1.0
```

Configure `config/passwords.yaml`:

```yaml
shared:
  tencentSmsSecretId: 'your-secret-id'
  tencentSmsSecretKey: 'your-secret-key'
  tencentSmsSdkAppId: '1400000000'
  tencentSmsSignName: 'YourSignName'
  tencentSmsVerificationTemplateId: '123456'
```

Usage example:

```dart
import 'package:tencent_sms_serverpod/tencent_sms_serverpod.dart';
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';

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

## Configuration Options

### Feature Toggles

| Option | Description | Default |
|--------|-------------|---------|
| `enableRegistration` | Enable SMS registration | `true` |
| `enableLogin` | Enable verification code login | `true` |
| `enableBind` | Enable phone binding | `true` |
| `requirePasswordOnUnregisteredLogin` | Require password for unregistered login | `true` |
| `allowPhoneRebind` | Allow users to change bound phone | `false` |

### Verification Code Settings

| Option | Description | Default |
|--------|-------------|---------|
| `verificationCodeLength` | Verification code length | `6` |
| `registrationVerificationCodeLifetime` | Registration code lifetime | `10 minutes` |
| `loginVerificationCodeLifetime` | Login code lifetime | `10 minutes` |
| `bindVerificationCodeLifetime` | Bind code lifetime | `10 minutes` |

### Rate Limiting

| Option | Description | Default |
|--------|-------------|---------|
| `registrationVerificationCodeAllowedAttempts` | Registration code max attempts | `5` |
| `loginVerificationCodeAllowedAttempts` | Login code max attempts | `5` |
| `bindVerificationCodeAllowedAttempts` | Bind code max attempts | `5` |
| `registrationRequestRateLimit` | Registration request rate limit | `5/10min` |
| `loginRequestRateLimit` | Login request rate limit | `5/10min` |
| `bindRequestRateLimit` | Bind request rate limit | `5/10min` |

Configuration example:

```dart
SmsIdpConfigFromPasswords(
  phoneIdStore: phoneIdStore,
  // Verification code settings
  verificationCodeLength: 6,
  loginVerificationCodeLifetime: Duration(minutes: 5),
  // Rate limiting
  loginVerificationCodeAllowedAttempts: 5,
  loginRequestRateLimit: SmsRateLimit(
    maxAttempts: 5,
    timeframe: Duration(minutes: 10),
  ),
  // ...other config
)
```

## Database Tables

This module creates the following database tables:

- `serverpod_auth_sms_account` - SMS account credentials
- `serverpod_auth_sms_account_request` - Registration requests
- `serverpod_auth_sms_login_request` - Login requests
- `serverpod_auth_sms_bind_request` - Binding requests

## Troubleshooting

### 1. Import Conflict: Protocol and Endpoints

If you import individual packages directly (`serverpod_auth_sms_core_server`, `serverpod_auth_sms_hash_server`, `serverpod_auth_sms_crypto_server`), you need to add `hide` to avoid conflicts with your project's generated classes:

```dart
// ❌ Wrong - will cause Protocol/Endpoints conflict
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart';

// ✅ Correct - hide conflicting classes
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart'
    hide Protocol, Endpoints;
import 'package:serverpod_auth_sms_crypto_server/serverpod_auth_sms_crypto_server.dart'
    hide Protocol, Endpoints;
```

**Recommended**: Use the combined package `serverpod_auth_sms`, which handles the hide logic internally:

```dart
// ✅ Recommended - use combined package, no manual hide needed
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';
```

### 2. SMS Sending Function Must Handle Async Properly

`SendSmsVerificationCodeFunction` has return type `FutureOr<void>`. If your SMS sending logic is async, **you must ensure the function is declared `async` or returns a `Future`**:

```dart
// ❌ Wrong - async operation without await, causes "Session is closed" error
void _sendSmsCode(Session session, {...}) {
  smsClient.send(...);  // async but not awaited
}

// ✅ Correct - declare as async and await
Future<void> _sendSmsCode(Session session, {...}) async {
  await smsClient.send(...);
}
```

### 3. External SMS Provider Rate Limits

When using SMS providers like Tencent Cloud or Alibaba Cloud, be aware of their sending rate limits. Common Tencent Cloud errors:

| Error Code | Description | Solution |
|------------|-------------|----------|
| `LimitExceeded.PhoneNumberOneHourLimit` | Exceeded hourly limit for single phone | Wait or adjust limit in console |
| `LimitExceeded.PhoneNumberDailyLimit` | Exceeded daily limit for single phone | Same as above |
| `LimitExceeded.PhoneNumberThirtySecondLimit` | Exceeded 30-second rate limit | Add cooldown timer in frontend |

We recommend implementing a cooldown countdown (e.g., 60 seconds) in your frontend to prevent users from triggering rate limits.

### 4. RateLimit Class Naming

This package uses `SmsRateLimit` instead of `RateLimit` to avoid conflicts with `RateLimit` from `serverpod_auth_idp_server`:

```dart
// Configure login request rate limit
SmsIdpConfigFromPasswords(
  // ...
  loginRequestRateLimit: SmsRateLimit(
    maxAttempts: 5,
    timeframe: Duration(minutes: 10),
  ),
)
```

### 5. Password Validation Function

When customizing password validation, be aware of Dart regex escaping rules. In raw strings `r'...'`, `\W` matches non-word characters:

```dart
// ❌ Wrong - excessive escaping
if (!password.contains(RegExp(r'[\\W_]'))) return false;

// ✅ Correct - use \W directly in raw string
if (!password.contains(RegExp(r'[\W_]'))) return false;
```

## Related Packages

- [serverpod_auth_sms_hash_server](https://pub.dev/packages/serverpod_auth_sms_hash_server) - Hash storage implementation
- [serverpod_auth_sms_crypto_server](https://pub.dev/packages/serverpod_auth_sms_crypto_server) - Crypto storage implementation
- [serverpod_auth_sms](https://pub.dev/packages/serverpod_auth_sms) - Combined package

## License

MIT License
