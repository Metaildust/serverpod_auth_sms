# serverpod_auth_sms_hash_server

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms_hash_server.svg)](https://pub.dev/packages/serverpod_auth_sms_hash_server)

Hash-based phone number storage implementation for Serverpod SMS authentication (server-side).

[中文文档](README.zh.md)

## Features

- **Irreversible Storage** - Uses HMAC-SHA256 to hash phone numbers, cannot be reversed
- **Privacy Protection** - Original phone numbers cannot be retrieved even if database is compromised
- **Unique Index** - Ensures phone number uniqueness through hash values
- **Compliance Friendly** - Suitable for applications with strict personal data protection requirements

## Use Cases

- Only need to verify user identity, no need to retrieve original phone number
- High requirements for data security and privacy protection
- Applications following data minimization principles

## Installation

Server:
```yaml
# gen_server/pubspec.yaml
dependencies:
  serverpod_auth_sms_hash_server: ^0.1.0
  serverpod_auth_sms_core_server: ^0.1.0
```

Client:
```yaml
# gen_client/pubspec.yaml
dependencies:
  serverpod_auth_sms_hash_client: ^0.1.0
  serverpod_auth_sms_core_client: ^0.1.0
```

## Database Migration

After adding the dependency, create database migrations:

```bash
cd your_server_project
serverpod create-migration
```

## Usage

### 1. Configure Secrets

Add to `config/passwords.yaml`:

```yaml
shared:
  phoneHashPepper: 'your-phone-hash-pepper-use-strong-random-string'
```

> **Important**: The pepper **cannot be changed** once set, otherwise existing users' phone numbers will not match.

### 2. Create Storage Instance

```dart
import 'package:serverpod_auth_sms_hash_server/serverpod_auth_sms_hash_server.dart'
    hide Protocol, Endpoints;  // Avoid naming conflicts

// Load from config file
final phoneIdStore = PhoneIdHashStore.fromPasswords(pod);

// Or create manually
final phoneIdStore = PhoneIdHashStore(pepper: 'your-secret-pepper');
```

### 3. Configure Authentication Service

```dart
pod.initializeAuthServices(
  identityProviderBuilders: [
    SmsIdpConfigFromPasswords(
      phoneIdStore: phoneIdStore,
      // ... other configurations
    ),
  ],
);
```

## Database Table

This module creates the following database table:

```sql
CREATE TABLE serverpod_auth_sms_phone_id_hash (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
  authUserId UUID NOT NULL UNIQUE REFERENCES serverpod_auth_core_user(id) ON DELETE CASCADE,
  phoneHash TEXT NOT NULL UNIQUE
);
```

## Storage Format

| Field | Description |
|-------|-------------|
| `authUserId` | Associated user ID |
| `phoneHash` | Hex string of HMAC-SHA256(phone, pepper) |

## Comparison with Crypto Storage

| Feature | Hash Storage | Crypto Storage |
|---------|--------------|----------------|
| Reversibility | Irreversible | Decryptable |
| Storage Space | Smaller (hash only) | Larger (hash+ciphertext+nonce+mac) |
| Security | Higher (cannot reverse) | High (requires key protection) |
| Use Case | Identity verification | Need original number |

## Related Packages

- [serverpod_auth_sms_core_server](https://pub.dev/packages/serverpod_auth_sms_core_server) - Core module
- [serverpod_auth_sms_crypto_server](https://pub.dev/packages/serverpod_auth_sms_crypto_server) - Crypto storage implementation
- [serverpod_auth_sms](https://pub.dev/packages/serverpod_auth_sms) - Combined package

## License

MIT License
