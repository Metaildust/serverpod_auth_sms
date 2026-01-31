/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// UI hint for same-password reset banter.
abstract class SmsSamePasswordBanter implements _i1.SerializableModel {
  SmsSamePasswordBanter._({
    required this.enabled,
    this.title,
    this.body,
  });

  factory SmsSamePasswordBanter({
    required bool enabled,
    String? title,
    String? body,
  }) = _SmsSamePasswordBanterImpl;

  factory SmsSamePasswordBanter.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SmsSamePasswordBanter(
      enabled: jsonSerialization['enabled'] as bool,
      title: jsonSerialization['title'] as String?,
      body: jsonSerialization['body'] as String?,
    );
  }

  bool enabled;

  String? title;

  String? body;

  /// Returns a shallow copy of this [SmsSamePasswordBanter]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SmsSamePasswordBanter copyWith({
    bool? enabled,
    String? title,
    String? body,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_auth_sms_core.SmsSamePasswordBanter',
      'enabled': enabled,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SmsSamePasswordBanterImpl extends SmsSamePasswordBanter {
  _SmsSamePasswordBanterImpl({
    required bool enabled,
    String? title,
    String? body,
  }) : super._(
         enabled: enabled,
         title: title,
         body: body,
       );

  /// Returns a shallow copy of this [SmsSamePasswordBanter]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SmsSamePasswordBanter copyWith({
    bool? enabled,
    Object? title = _Undefined,
    Object? body = _Undefined,
  }) {
    return SmsSamePasswordBanter(
      enabled: enabled ?? this.enabled,
      title: title is String? ? title : this.title,
      body: body is String? ? body : this.body,
    );
  }
}
