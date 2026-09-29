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

/// UI hint for same-password reset banner.
abstract class SmsSamePasswordBanner implements _i1.SerializableModel {
  SmsSamePasswordBanner._({
    required this.enabled,
    this.title,
    this.body,
  });

  factory SmsSamePasswordBanner({
    required bool enabled,
    String? title,
    String? body,
  }) = _SmsSamePasswordBannerImpl;

  factory SmsSamePasswordBanner.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SmsSamePasswordBanner(
      enabled: _i1.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      title: jsonSerialization['title'] as String?,
      body: jsonSerialization['body'] as String?,
    );
  }

  bool enabled;

  String? title;

  String? body;

  /// Returns a shallow copy of this [SmsSamePasswordBanner]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SmsSamePasswordBanner copyWith({
    bool? enabled,
    String? title,
    String? body,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_auth_sms_core.SmsSamePasswordBanner',
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

class _SmsSamePasswordBannerImpl extends SmsSamePasswordBanner {
  _SmsSamePasswordBannerImpl({
    required bool enabled,
    String? title,
    String? body,
  }) : super._(
         enabled: enabled,
         title: title,
         body: body,
       );

  /// Returns a shallow copy of this [SmsSamePasswordBanner]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SmsSamePasswordBanner copyWith({
    bool? enabled,
    Object? title = _Undefined,
    Object? body = _Undefined,
  }) {
    return SmsSamePasswordBanner(
      enabled: enabled ?? this.enabled,
      title: title is String? ? title : this.title,
      body: body is String? ? body : this.body,
    );
  }
}
