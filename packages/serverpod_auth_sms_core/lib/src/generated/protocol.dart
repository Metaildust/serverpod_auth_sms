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
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod/protocol.dart' as _i2;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i3;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i4;
import 'exceptions/sms_account_request_exception.dart' as _i5;
import 'exceptions/sms_account_request_exception_reason.dart' as _i6;
import 'exceptions/sms_login_exception.dart' as _i7;
import 'exceptions/sms_login_exception_reason.dart' as _i8;
import 'exceptions/sms_phone_bind_exception.dart' as _i9;
import 'exceptions/sms_phone_bind_exception_reason.dart' as _i10;
import 'sms_account.dart' as _i11;
import 'sms_account_request.dart' as _i12;
import 'sms_bind_request.dart' as _i13;
import 'sms_login_request.dart' as _i14;
import 'sms_login_result.dart' as _i15;
import 'sms_same_password_banter.dart' as _i16;
export 'exceptions/sms_account_request_exception.dart';
export 'exceptions/sms_account_request_exception_reason.dart';
export 'exceptions/sms_login_exception.dart';
export 'exceptions/sms_login_exception_reason.dart';
export 'exceptions/sms_phone_bind_exception.dart';
export 'exceptions/sms_phone_bind_exception_reason.dart';
export 'sms_account.dart';
export 'sms_account_request.dart';
export 'sms_bind_request.dart';
export 'sms_login_request.dart';
export 'sms_login_result.dart';
export 'sms_same_password_banter.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'serverpod_auth_sms_account',
      dartName: 'SmsAccount',
      schema: 'public',
      module: 'serverpod_auth_sms_core',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'authUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'passwordHash',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'serverpod_auth_sms_account_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'serverpod_auth_sms_account_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'serverpod_auth_sms_account_auth_user',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'serverpod_auth_sms_account_request',
      dartName: 'SmsAccountRequest',
      schema: 'public',
      module: 'serverpod_auth_sms_core',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'phoneHash',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'challengeId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'createAccountChallengeId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'serverpod_auth_sms_account_request_fk_0',
          columns: ['challengeId'],
          referenceTable: 'serverpod_auth_idp_secret_challenge',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'serverpod_auth_sms_account_request_fk_1',
          columns: ['createAccountChallengeId'],
          referenceTable: 'serverpod_auth_idp_secret_challenge',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'serverpod_auth_sms_account_request_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'serverpod_auth_sms_account_request_phone_hash',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'phoneHash',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'serverpod_auth_sms_bind_request',
      dartName: 'SmsBindRequest',
      schema: 'public',
      module: 'serverpod_auth_sms_core',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'authUserId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'phoneHash',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'challengeId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'bindChallengeId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'serverpod_auth_sms_bind_request_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'serverpod_auth_sms_bind_request_fk_1',
          columns: ['challengeId'],
          referenceTable: 'serverpod_auth_idp_secret_challenge',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'serverpod_auth_sms_bind_request_fk_2',
          columns: ['bindChallengeId'],
          referenceTable: 'serverpod_auth_idp_secret_challenge',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'serverpod_auth_sms_bind_request_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'serverpod_auth_sms_bind_request_auth_user',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'serverpod_auth_sms_login_request',
      dartName: 'SmsLoginRequest',
      schema: 'public',
      module: 'serverpod_auth_sms_core',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue?',
          columnDefault: 'gen_random_uuid_v7()',
        ),
        _i2.ColumnDefinition(
          name: 'createdAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
          columnDefault: 'CURRENT_TIMESTAMP',
        ),
        _i2.ColumnDefinition(
          name: 'phoneHash',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'challengeId',
          columnType: _i2.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _i2.ColumnDefinition(
          name: 'loginChallengeId',
          columnType: _i2.ColumnType.uuid,
          isNullable: true,
          dartType: 'UuidValue?',
        ),
      ],
      foreignKeys: [
        _i2.ForeignKeyDefinition(
          constraintName: 'serverpod_auth_sms_login_request_fk_0',
          columns: ['challengeId'],
          referenceTable: 'serverpod_auth_idp_secret_challenge',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _i2.ForeignKeyDefinition(
          constraintName: 'serverpod_auth_sms_login_request_fk_1',
          columns: ['loginChallengeId'],
          referenceTable: 'serverpod_auth_idp_secret_challenge',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _i2.ForeignKeyAction.noAction,
          onDelete: _i2.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'serverpod_auth_sms_login_request_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'serverpod_auth_sms_login_request_phone_hash',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'phoneHash',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i3.Protocol.targetTableDefinitions,
    ..._i4.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    if (className == null) return null;
    if (!className.startsWith('serverpod_auth_sms_core.')) return className;
    return className.substring(24);
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i5.SmsAccountRequestException) {
      return _i5.SmsAccountRequestException.fromJson(data) as T;
    }
    if (t == _i6.SmsAccountRequestExceptionReason) {
      return _i6.SmsAccountRequestExceptionReason.fromJson(data) as T;
    }
    if (t == _i7.SmsLoginException) {
      return _i7.SmsLoginException.fromJson(data) as T;
    }
    if (t == _i8.SmsLoginExceptionReason) {
      return _i8.SmsLoginExceptionReason.fromJson(data) as T;
    }
    if (t == _i9.SmsPhoneBindException) {
      return _i9.SmsPhoneBindException.fromJson(data) as T;
    }
    if (t == _i10.SmsPhoneBindExceptionReason) {
      return _i10.SmsPhoneBindExceptionReason.fromJson(data) as T;
    }
    if (t == _i11.SmsAccount) {
      return _i11.SmsAccount.fromJson(data) as T;
    }
    if (t == _i12.SmsAccountRequest) {
      return _i12.SmsAccountRequest.fromJson(data) as T;
    }
    if (t == _i13.SmsBindRequest) {
      return _i13.SmsBindRequest.fromJson(data) as T;
    }
    if (t == _i14.SmsLoginRequest) {
      return _i14.SmsLoginRequest.fromJson(data) as T;
    }
    if (t == _i15.SmsVerifyLoginResult) {
      return _i15.SmsVerifyLoginResult.fromJson(data) as T;
    }
    if (t == _i16.SmsSamePasswordBanter) {
      return _i16.SmsSamePasswordBanter.fromJson(data) as T;
    }
    if (t == _i1.getType<_i5.SmsAccountRequestException?>()) {
      return (data != null
              ? _i5.SmsAccountRequestException.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i6.SmsAccountRequestExceptionReason?>()) {
      return (data != null
              ? _i6.SmsAccountRequestExceptionReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i7.SmsLoginException?>()) {
      return (data != null ? _i7.SmsLoginException.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.SmsLoginExceptionReason?>()) {
      return (data != null ? _i8.SmsLoginExceptionReason.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i9.SmsPhoneBindException?>()) {
      return (data != null ? _i9.SmsPhoneBindException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i10.SmsPhoneBindExceptionReason?>()) {
      return (data != null
              ? _i10.SmsPhoneBindExceptionReason.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i11.SmsAccount?>()) {
      return (data != null ? _i11.SmsAccount.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.SmsAccountRequest?>()) {
      return (data != null ? _i12.SmsAccountRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.SmsBindRequest?>()) {
      return (data != null ? _i13.SmsBindRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.SmsLoginRequest?>()) {
      return (data != null ? _i14.SmsLoginRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.SmsVerifyLoginResult?>()) {
      return (data != null ? _i15.SmsVerifyLoginResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.SmsSamePasswordBanter?>()) {
      return (data != null ? _i16.SmsSamePasswordBanter.fromJson(data) : null)
          as T;
    }
    try {
      return _i3.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i4.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i5.SmsAccountRequestException => 'SmsAccountRequestException',
      _i6.SmsAccountRequestExceptionReason =>
        'SmsAccountRequestExceptionReason',
      _i7.SmsLoginException => 'SmsLoginException',
      _i8.SmsLoginExceptionReason => 'SmsLoginExceptionReason',
      _i9.SmsPhoneBindException => 'SmsPhoneBindException',
      _i10.SmsPhoneBindExceptionReason => 'SmsPhoneBindExceptionReason',
      _i11.SmsAccount => 'SmsAccount',
      _i12.SmsAccountRequest => 'SmsAccountRequest',
      _i13.SmsBindRequest => 'SmsBindRequest',
      _i14.SmsLoginRequest => 'SmsLoginRequest',
      _i15.SmsVerifyLoginResult => 'SmsVerifyLoginResult',
      _i16.SmsSamePasswordBanter => 'SmsSamePasswordBanter',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'serverpod_auth_sms_core.',
        '',
      );
    }

    switch (data) {
      case _i5.SmsAccountRequestException():
        return 'SmsAccountRequestException';
      case _i6.SmsAccountRequestExceptionReason():
        return 'SmsAccountRequestExceptionReason';
      case _i7.SmsLoginException():
        return 'SmsLoginException';
      case _i8.SmsLoginExceptionReason():
        return 'SmsLoginExceptionReason';
      case _i9.SmsPhoneBindException():
        return 'SmsPhoneBindException';
      case _i10.SmsPhoneBindExceptionReason():
        return 'SmsPhoneBindExceptionReason';
      case _i11.SmsAccount():
        return 'SmsAccount';
      case _i12.SmsAccountRequest():
        return 'SmsAccountRequest';
      case _i13.SmsBindRequest():
        return 'SmsBindRequest';
      case _i14.SmsLoginRequest():
        return 'SmsLoginRequest';
      case _i15.SmsVerifyLoginResult():
        return 'SmsVerifyLoginResult';
      case _i16.SmsSamePasswordBanter():
        return 'SmsSamePasswordBanter';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    className = _i3.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i4.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'SmsAccountRequestException') {
      return deserialize<_i5.SmsAccountRequestException>(data['data']);
    }
    if (dataClassName == 'SmsAccountRequestExceptionReason') {
      return deserialize<_i6.SmsAccountRequestExceptionReason>(data['data']);
    }
    if (dataClassName == 'SmsLoginException') {
      return deserialize<_i7.SmsLoginException>(data['data']);
    }
    if (dataClassName == 'SmsLoginExceptionReason') {
      return deserialize<_i8.SmsLoginExceptionReason>(data['data']);
    }
    if (dataClassName == 'SmsPhoneBindException') {
      return deserialize<_i9.SmsPhoneBindException>(data['data']);
    }
    if (dataClassName == 'SmsPhoneBindExceptionReason') {
      return deserialize<_i10.SmsPhoneBindExceptionReason>(data['data']);
    }
    if (dataClassName == 'SmsAccount') {
      return deserialize<_i11.SmsAccount>(data['data']);
    }
    if (dataClassName == 'SmsAccountRequest') {
      return deserialize<_i12.SmsAccountRequest>(data['data']);
    }
    if (dataClassName == 'SmsBindRequest') {
      return deserialize<_i13.SmsBindRequest>(data['data']);
    }
    if (dataClassName == 'SmsLoginRequest') {
      return deserialize<_i14.SmsLoginRequest>(data['data']);
    }
    if (dataClassName == 'SmsVerifyLoginResult') {
      return deserialize<_i15.SmsVerifyLoginResult>(data['data']);
    }
    if (dataClassName == 'SmsSamePasswordBanter') {
      return deserialize<_i16.SmsSamePasswordBanter>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i3.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i4.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i3.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i4.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i11.SmsAccount:
        return _i11.SmsAccount.t;
      case _i12.SmsAccountRequest:
        return _i12.SmsAccountRequest.t;
      case _i13.SmsBindRequest:
        return _i13.SmsBindRequest.t;
      case _i14.SmsLoginRequest:
        return _i14.SmsLoginRequest.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'serverpod_auth_sms_core';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i3.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i4.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
