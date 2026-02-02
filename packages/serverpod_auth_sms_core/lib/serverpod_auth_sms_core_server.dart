library serverpod_auth_sms_core_server;

export 'src/endpoints/sms_auth_ui_base_endpoint.dart';
export 'src/endpoints/sms_idp_base_endpoint.dart';
export 'src/endpoints/sms_phone_bind_base_endpoint.dart';
export 'src/phone/phone_id_store.dart';
export 'src/phone/phone_normalizer.dart';
export 'src/sms_auth_ui_config.dart';
export 'src/sms_idp.dart';
export 'src/sms_idp_config.dart';
export 'src/sms_idp_utils.dart';

// Note: Protocol and Endpoints MUST be exported for Serverpod's generated code
// to work across modules. When importing this package directly in your server,
// use: import '...' hide Protocol, Endpoints;
// Or use the combined package `serverpod_auth_sms` which handles this for you.
export 'src/generated/endpoints.dart';
export 'src/generated/protocol.dart';
