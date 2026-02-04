# serverpod_auth_sms

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms.svg)](https://pub.dev/packages/serverpod_auth_sms)

**The recommended package** for Serverpod SMS authentication.

[中文文档](README.zh.md)

## Why Use This Package?

This package provides **complete SMS authentication functionality** with flexible storage options:

| What You Need | Just Use This Package |
|---------------|----------------------|
| Hash-only storage (irreversible) | ✅ Use `PhoneIdHashStore` |
| Crypto storage (decryptable) | ✅ Use `PhoneIdCryptoStore` |
| No manual `hide Protocol, Endpoints` | ✅ Handled automatically |

**You do NOT need to import sub-packages separately.** This package includes everything and lets you choose storage method via configuration:

```dart
// Just import this one package
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';

// Then choose your storage method:
final phoneIdStore = PhoneIdHashStore.fromPasswords(pod);   // Hash-only
// OR
final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod); // Crypto (recommended)
```

> **Sub-packages (`_core`, `_hash`, `_crypto`) are for advanced users only** and require manual `hide Protocol, Endpoints` directives. Most users should just use this package.

## Features

- **SMS Registration** - Register with phone number and verification code
- **Verification Code Login** - Login with phone + code (auto-register unregistered users)
- **Phone Binding** - Bind phone to existing accounts
- **Provider-Agnostic** - Works with any SMS provider via callbacks

## Installation

### Server Dependencies

```yaml
# gen_server/pubspec.yaml
dependencies:
  serverpod_auth_sms: ^0.1.5
  # Optional: Tencent Cloud SMS integration (for China business)
  tencent_sms_serverpod: ^0.1.2
```

### Client Dependencies

```yaml
# gen_client/pubspec.yaml
dependencies:
  serverpod_auth_sms_core_client: ^0.1.5
  # Add ONE of the following based on your storage choice:
  serverpod_auth_sms_crypto_client: ^0.1.5  # For crypto storage
  # serverpod_auth_sms_hash_client: ^0.1.5  # For hash storage
```

## Quick Start

### Step 1: Choose Storage Method

| Storage | When to Use | Configuration Required |
|---------|-------------|----------------------|
| **Crypto** (recommended) | Most cases - can verify AND retrieve phone numbers | `phoneHashPepper` + `phoneEncryptionKey` |
| **Hash** | Maximum privacy - can only verify, cannot retrieve | `phoneHashPepper` only |

> **Note**: Crypto storage internally stores hash values too, so it covers all hash functionality while also supporting phone number decryption. If you're unsure, choose crypto - you can always verify phones (like hash), plus decrypt when needed (e.g., customer support, notifications).

### Step 2: Configure passwords.yaml

```yaml
# config/passwords.yaml
shared:
  # ============================================
  # Core SMS Authentication (Required)
  # ============================================
  
  # Pepper for hashing verification codes (required)
  smsSecretHashPepper: 'your-random-string-for-verification-code-hashing'
  
  # ============================================
  # Phone Number Storage (Required)
  # ============================================
  
  # Pepper for hashing phone numbers (required for BOTH hash and crypto)
  # WARNING: Cannot be changed after deployment - existing data won't match
  phoneHashPepper: 'your-random-string-for-phone-hashing'
  
  # AES-256 encryption key (required ONLY for crypto storage)
  # Generate with: openssl rand -base64 32
  # WARNING: Cannot be changed - leakage allows decryption of all phone numbers
  phoneEncryptionKey: 'base64-encoded-32-byte-key'
  
  # ============================================
  # Tencent Cloud SMS (Optional - for China business)
  # ============================================
  
  tencentSmsSecretId: 'your-tencent-secret-id'
  tencentSmsSecretKey: 'your-tencent-secret-key'
  tencentSmsSdkAppId: '1400000000'
  tencentSmsSignName: 'YourAppName'
  tencentSmsRegion: 'ap-guangzhou'  # Optional, defaults to ap-guangzhou
  
  # Template configuration (choose ONE method):
  # Method 1: Direct template ID
  tencentSmsVerificationTemplateId: '123456'
  
  # Method 2: Scene-specific templates
  # tencentSmsVerificationTemplateNameLogin: 'LoginTemplate'
  # tencentSmsVerificationTemplateNameRegister: 'RegisterTemplate'
  # tencentSmsVerificationTemplateNameResetPassword: 'ResetTemplate'
  
  # Method 3: CSV template mapping
  # tencentSmsTemplateCsvPath: 'config/sms/templates.csv'
```

### Step 3: Configure Server

```dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  // ========================================
  // Choose ONE storage method:
  // ========================================
  
  // Option A: Crypto storage (RECOMMENDED)
  // - Can verify phone numbers (like hash)
  // - Can also decrypt to get original phone (for support, notifications, etc.)
  final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);
  
  // Option B: Hash storage
  // - Can only verify phone numbers
  // - Cannot retrieve original phone (maximum privacy)
  // final phoneIdStore = PhoneIdHashStore.fromPasswords(pod);

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

// Implement your SMS sending logic
Future<void> _sendSmsCode(
  Session session, {
  required String phone,
  required UuidValue requestId,
  required String verificationCode,
  required Transaction? transaction,
}) async {
  // Call your SMS provider API here
  await yourSmsClient.send(phone, verificationCode);
  session.log('Sent code $verificationCode to $phone');
}

// Optional: Custom password validation
bool _validatePassword(String password) {
  if (password.length < 8) return false;
  if (!password.contains(RegExp(r'[A-Z]'))) return false;
  if (!password.contains(RegExp(r'[a-z]'))) return false;
  if (!password.contains(RegExp(r'[0-9]'))) return false;
  if (!password.contains(RegExp(r'[\W_]'))) return false;  // Special char
  return true;
}
```

### With Tencent Cloud SMS (for China Business)

```dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';
import 'package:tencent_sms_serverpod/tencent_sms_serverpod.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Create Tencent Cloud SMS client (credentials from passwords.yaml, other config passed directly)
  final smsConfig = TencentSmsConfigServerpod.fromServerpod(
    pod,
    appConfig: TencentSmsAppConfig(
      smsSdkAppId: '1400000000',
      signName: 'YourSignName',
      templateCsvPath: 'config/sms/templates.csv',
      verificationTemplateNameLogin: 'Login',
      verificationTemplateNameRegister: 'Register',
      verificationTemplateNameResetPassword: 'ResetPassword',
    ),
  );
  final smsClient = TencentSmsClient(smsConfig);
  // Use Chinese error messages: TencentSmsClient(smsConfig, localizations: const SmsLocalizationsZh())
  final smsHelper = SmsAuthCallbackHelper(smsClient);

  // Choose storage method (see Step 1)
  final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);

  pod.initializeAuthServices(
    tokenManagerBuilders: [JwtConfigFromPasswords()],
    identityProviderBuilders: [
      SmsIdpConfigFromPasswords(
        phoneIdStore: phoneIdStore,
        sendRegistrationVerificationCode: smsHelper.sendForRegistration,
        sendLoginVerificationCode: smsHelper.sendForLogin,
        sendBindVerificationCode: smsHelper.sendForBind,
        passwordValidationFunction: _validatePassword,
        // Optional configurations:
        requirePasswordOnUnregisteredLogin: true,
        allowPhoneRebind: false,
        verificationCodeLength: 6,
        loginVerificationCodeLifetime: Duration(minutes: 10),
      ),
    ],
  );

  await pod.start();
}
```

### Step 4: Create Endpoints

```dart
// lib/src/endpoints/sms_idp_endpoint.dart
import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_sms/serverpod_auth_sms.dart';

class SmsIdpEndpoint extends SmsIdpBaseEndpoint {}

// lib/src/endpoints/phone_bind_endpoint.dart
class PhoneBindEndpoint extends SmsPhoneBindBaseEndpoint {}

// lib/src/endpoints/sms_auth_ui_endpoint.dart
class SmsAuthUiEndpoint extends SmsAuthUiBaseEndpoint {}
```

## Database Migration

After adding dependencies, generate and apply migrations:

```bash
cd your_server_project
serverpod create-migration
dart bin/main.dart --apply-migrations
```

Tables created:
- `serverpod_auth_sms_account` - User credentials
- `serverpod_auth_sms_account_request` - Registration requests
- `serverpod_auth_sms_login_request` - Login requests
- `serverpod_auth_sms_bind_request` - Binding requests
- `serverpod_auth_sms_phone_id_crypto` or `serverpod_auth_sms_phone_id_hash` - Phone storage

## Configuration Options

### Feature Toggles

| Option | Description | Default |
|--------|-------------|---------|
| `enableRegistration` | Enable SMS registration | `true` |
| `enableLogin` | Enable verification code login | `true` |
| `enableBind` | Enable phone binding | `true` |
| `requirePasswordOnUnregisteredLogin` | Require password for auto-register | `true` |
| `allowPhoneRebind` | Allow changing bound phone | `false` |

### Verification Code Settings

| Option | Description | Default |
|--------|-------------|---------|
| `verificationCodeLength` | Code length | `6` |
| `registrationVerificationCodeLifetime` | Registration code TTL | `10 min` |
| `loginVerificationCodeLifetime` | Login code TTL | `10 min` |
| `bindVerificationCodeLifetime` | Bind code TTL | `10 min` |

### Rate Limiting

| Option | Description | Default |
|--------|-------------|---------|
| `registrationVerificationCodeAllowedAttempts` | Max registration attempts | `5` |
| `loginVerificationCodeAllowedAttempts` | Max login attempts | `5` |
| `bindVerificationCodeAllowedAttempts` | Max bind attempts | `5` |
| `registrationRequestRateLimit` | Registration rate limit | `5/10min` |
| `loginRequestRateLimit` | Login rate limit | `5/10min` |
| `bindRequestRateLimit` | Bind rate limit | `5/10min` |

```dart
SmsIdpConfigFromPasswords(
  // ...
  loginVerificationCodeAllowedAttempts: 5,
  loginRequestRateLimit: SmsRateLimit(
    maxAttempts: 5,
    timeframe: Duration(minutes: 10),
  ),
)
```

## Troubleshooting

### Tencent Cloud Rate Limits

| Error Code | Meaning | Solution |
|------------|---------|----------|
| `LimitExceeded.PhoneNumberOneHourLimit` | Hourly limit exceeded | Wait or adjust in console |
| `LimitExceeded.PhoneNumberDailyLimit` | Daily limit exceeded | Wait until next day |
| `LimitExceeded.PhoneNumberThirtySecondLimit` | 30-second cooldown | Add frontend countdown |

### Password Regex in Raw Strings

```dart
// ❌ Wrong - double escaping
if (!password.contains(RegExp(r'[\\W_]'))) return false;

// ✅ Correct
if (!password.contains(RegExp(r'[\W_]'))) return false;
```

### Async SMS Callback

```dart
// ❌ Wrong - async without await causes "Session is closed" error
void _sendSms(Session session, {...}) {
  smsClient.send(...);  // Not awaited
}

// ✅ Correct
Future<void> _sendSms(Session session, {...}) async {
  await smsClient.send(...);
}
```

## Advanced: Individual Package Usage

> **Not recommended for most users.** Only use if you have specific requirements.

If you must use individual packages (e.g., to avoid crypto dependencies when only using hash):

```yaml
dependencies:
  serverpod_auth_sms_core_server: ^0.1.5
  serverpod_auth_sms_hash_server: ^0.1.5  # Or _crypto_server
```

```dart
// Must manually hide Protocol and Endpoints
import 'package:serverpod_auth_sms_core_server/serverpod_auth_sms_core_server.dart'
    hide Protocol, Endpoints;
import 'package:serverpod_auth_sms_hash_server/serverpod_auth_sms_hash_server.dart'
    hide Protocol, Endpoints;
```

## Related Packages

- [tencent_sms](https://pub.dev/packages/tencent_sms) - Tencent Cloud SMS SDK
- [tencent_sms_serverpod](https://pub.dev/packages/tencent_sms_serverpod) - Serverpod integration

## License

MIT License
