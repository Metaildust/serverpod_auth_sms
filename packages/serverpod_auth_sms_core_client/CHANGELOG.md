## 0.2.0

- `evaluateAuthPasswordPolicy` / `validateAuthPasswordPolicy` 新增可选命名参数 `minLength`（默认 `kDefaultPasswordMinLength = 8`），便于宿主项目与服务端对齐策略。
- **破坏性语义变更**：未传 `minLength` 时，最小长度默认值由 12 降为 8；若需保持 12 位，请显式传入 `minLength: 12`。

## 0.1.6
- Synced with core server V2 phone-bind conflict protocol.
- Added client models and endpoint signatures for `verifyBindCodeV2` / `finishBindPhoneV2`.

## 0.1.5
- Synchronized version numbers across all packages

## 0.1.2
- Documentation improvements

## 0.1.1
- Switch README to English as default, Chinese as README.zh.md

# Changelog

## 0.1.0

- Initial release
