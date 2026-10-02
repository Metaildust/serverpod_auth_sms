## 0.1.8
- Align bundled constraints to `serverpod_auth_sms_core_server` `^0.2.0`, `serverpod_auth_sms_hash_server` `^0.1.8`, and `serverpod_auth_sms_crypto_server` `^0.1.8`.
- Bundling core `0.2.0` requires phone-store implementors to override `matchHashes`, `rewriteMatchedPhoneToCanonical`, and `unbindPhoneByHash`.
- Registration, password-reset, and the phone portion of bind request rate limits now use the canonical phone hash, so a number with separators and the same number without separators share one bucket.

## 0.1.7
- Docs: use generic Serverpod app wording in README and library comments.

## 0.1.6
- Version bump for SMS bind conflict confirmation release alignment.
- Updated bundled dependency constraints to `^0.1.6` baseline.

## 0.1.5
- Synchronized version numbers across all packages
- Updated dependency constraints

## 0.1.4
- Clarify Tencent Cloud SMS is for China business

## 0.1.3
- Reorganized README to clearly show this package supports both hash and crypto storage
- Moved storage comparison to "Step 1: Choose Storage Method" section
- Emphasized that sub-packages are for advanced users only
- Clarified crypto covers all hash functionality in the configuration section

## 0.1.2
- Comprehensive README rewrite with complete configuration guide
- Added full passwords.yaml example with all options
- Emphasized recommendation to use combined package
- Clarified that crypto storage covers all hash functionality
- Added storage comparison table and troubleshooting section

## 0.1.1
- Switch README to English as default, Chinese as README.zh.md

## 0.1.0

- Initial release: combined SMS auth package.
