## 0.2.0
- BREAKING: `PhoneIdStore` implementors must override `matchHashes`, `rewriteMatchedPhoneToCanonical`, and `unbindPhoneByHash`.
- Registration, password-reset, and the phone portion of bind request rate limits now use the canonical phone hash, so a number with separators and the same number without separators share one bucket. Login request rate limits stay on that hash. Bind buckets still prefix the auth user id.
- Added dedicated password reset flow: `startPasswordReset`, `verifyPasswordResetCode`, and `finishPasswordReset`.
- Added password reset protocol models and exceptions, including `SmsVerifyPasswordResetResult`, `SmsPasswordResetBlockedReason`, and `SmsPasswordResetException`.
- Added password reset config hooks for send callback, verification-code lifetime, allowed attempts, and request rate limit.

## 0.1.6
- Added phone-bind conflict V2 protocol and endpoints (`verifyBindCodeV2` / `finishBindPhoneV2`) with conflict snapshot and decision flow.
- Added bind conflict reasons (`conflictStateChanged`, `bindAndLoginDisabled`) and server-side conflict policy hooks.
- Added `PhoneIdStore.unbindPhoneByHash` and implemented it in hash/crypto stores to support phone migration flow.

## 0.1.5
- Synchronized version numbers across all packages

## 0.1.2
- Documentation improvements: added recommendation to use combined package
- Clarified Protocol/Endpoints hide requirement for direct imports

## 0.1.1
- Switch README to English as default, Chinese as README.zh.md

## 0.1.0

- Initial release: SMS registration/login core for Serverpod.
