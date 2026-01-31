# serverpod_auth_sms_crypto_server

[![pub package](https://img.shields.io/pub/v/serverpod_auth_sms_crypto_server.svg)](https://pub.dev/packages/serverpod_auth_sms_crypto_server)

Encrypted phone number storage implementation for Serverpod SMS authentication (server-side).

[中文文档](README.md)

## Features

- **Reversible Encryption** - Uses AES-256-GCM to encrypt phone numbers, safely decryptable
- **Dual Indexing** - Stores both hash (for lookup) and encrypted value (for decryption)
- **Integrity Verification** - GCM mode provides authenticated encryption, prevents tampering
- **Key Management** - Supports secure key loading from configuration files

## Use Cases

- Business scenarios requiring original phone numbers (e.g., customer support, order notifications)
- Scenarios displaying partial phone numbers to users (e.g., 138****1234)
- Data analysis requiring phone number anonymization

## Installation

Server:
```yaml
# gen_server/pubspec.yaml
dependencies:
  serverpod_auth_sms_crypto_server: ^0.1.0
  serverpod_auth_sms_core_server: ^0.1.0
```

Client:
```yaml
# gen_client/pubspec.yaml
dependencies:
  serverpod_auth_sms_crypto_client: ^0.1.0
  serverpod_auth_sms_core_client: ^0.1.0
```

## Database Migration

After adding the dependency, create database migrations:

```bash
cd your_server_project
serverpod create-migration
```

## Usage

### 1. Generate Encryption Key

```bash
# Generate 32-byte random key and Base64 encode
openssl rand -base64 32
```

### 2. Configure Secrets

Add to `config/passwords.yaml`:

```yaml
shared:
  phoneHashPepper: 'your-phone-hash-pepper'
  phoneEncryptionKey: 'base64-encoded-32-byte-AES-key'
```

> **Important**:
> - Keys **cannot be changed** once set
> - Keys must be kept strictly confidential; leakage allows decryption of all phone numbers
> - Consider using HSM or key management service to protect keys

### 3. Create Storage Instance

```dart
import 'package:serverpod_auth_sms_crypto_server/serverpod_auth_sms_crypto_server.dart'
    hide Protocol, Endpoints;  // Avoid naming conflicts

// Load from config file
final phoneIdStore = PhoneIdCryptoStore.fromPasswords(pod);

// Or create manually
final phoneIdStore = PhoneIdCryptoStore(
  pepper: 'your-hash-pepper',
  encryptionKeyBytes: base64Decode('your-base64-key'),
);
```

### 4. Retrieve Original Phone Number

```dart
// Get decrypted phone number by user ID
final phone = await phoneIdStore.getPhone(
  session,
  authUserId: userId,
);
```

## Database Table

This module creates the following database table:

```sql
CREATE TABLE serverpod_auth_sms_phone_id_crypto (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid_v7(),
  authUserId UUID NOT NULL UNIQUE REFERENCES serverpod_auth_core_user(id) ON DELETE CASCADE,
  phoneHash TEXT NOT NULL UNIQUE,
  phoneEncrypted BYTEA NOT NULL,
  nonce BYTEA NOT NULL,
  mac BYTEA NOT NULL
);
```

## Storage Format

| Field | Description |
|-------|-------------|
| `authUserId` | Associated user ID |
| `phoneHash` | HMAC-SHA256 hash (for unique index) |
| `phoneEncrypted` | AES-256-GCM encrypted phone ciphertext |
| `nonce` | Encryption nonce (12 bytes) |
| `mac` | Message Authentication Code (16 bytes) |

## Security Considerations

1. **Key Protection** - Encryption key is the most critical security element
2. **Access Control** - Restrict access to `getPhone()` method
3. **Audit Logging** - Log all decryption operations for security audit
4. **Compliance** - Ensure compliance with local data protection regulations

## Comparison with Hash Storage

| Feature | Crypto Storage | Hash Storage |
|---------|----------------|--------------|
| Reversibility | Decryptable | Irreversible |
| Storage Space | Larger | Smaller |
| Functionality | Can retrieve original | Verification only |
| Key Dependency | Needs encryption key | Hash pepper only |

## Related Packages

- [serverpod_auth_sms_core_server](https://pub.dev/packages/serverpod_auth_sms_core_server) - Core module
- [serverpod_auth_sms_hash_server](https://pub.dev/packages/serverpod_auth_sms_hash_server) - Hash storage implementation
- [serverpod_auth_sms](https://pub.dev/packages/serverpod_auth_sms) - Combined package

## License

MIT License
