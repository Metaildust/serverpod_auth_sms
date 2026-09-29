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
// ignore_for_file: unnecessary_null_comparison

import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i2;
import 'sms_password_reset_blocked_reason.dart' as _i3;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _i4;
import 'package:serverpod_auth_sms_core_server/src/generated/protocol.dart'
    as _i5;

/// 待完成的短信密码重置请求。
abstract class SmsPasswordResetRequest
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  SmsPasswordResetRequest._({
    this.id,
    DateTime? createdAt,
    required this.phoneHash,
    this.authUserId,
    this.authUser,
    this.blockedReason,
    required this.challengeId,
    this.challenge,
    this.resetChallengeId,
    this.resetChallenge,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SmsPasswordResetRequest({
    _i1.UuidValue? id,
    DateTime? createdAt,
    required String phoneHash,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    _i3.SmsPasswordResetBlockedReason? blockedReason,
    required _i1.UuidValue challengeId,
    _i4.SecretChallenge? challenge,
    _i1.UuidValue? resetChallengeId,
    _i4.SecretChallenge? resetChallenge,
  }) = _SmsPasswordResetRequestImpl;

  factory SmsPasswordResetRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SmsPasswordResetRequest(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      phoneHash: jsonSerialization['phoneHash'] as String,
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _i5.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['authUser'],
            ),
      blockedReason: jsonSerialization['blockedReason'] == null
          ? null
          : _i3.SmsPasswordResetBlockedReason.fromJson(
              (jsonSerialization['blockedReason'] as String),
            ),
      challengeId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['challengeId'],
      ),
      challenge: jsonSerialization['challenge'] == null
          ? null
          : _i5.Protocol().deserialize<_i4.SecretChallenge>(
              jsonSerialization['challenge'],
            ),
      resetChallengeId: jsonSerialization['resetChallengeId'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(
              jsonSerialization['resetChallengeId'],
            ),
      resetChallenge: jsonSerialization['resetChallenge'] == null
          ? null
          : _i5.Protocol().deserialize<_i4.SecretChallenge>(
              jsonSerialization['resetChallenge'],
            ),
    );
  }

  static final t = SmsPasswordResetRequestTable();

  static const db = SmsPasswordResetRequestRepository._();

  @override
  _i1.UuidValue? id;

  DateTime createdAt;

  String phoneHash;

  _i1.UuidValue? authUserId;

  _i2.AuthUser? authUser;

  _i3.SmsPasswordResetBlockedReason? blockedReason;

  _i1.UuidValue challengeId;

  _i4.SecretChallenge? challenge;

  _i1.UuidValue? resetChallengeId;

  _i4.SecretChallenge? resetChallenge;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [SmsPasswordResetRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  SmsPasswordResetRequest copyWith({
    _i1.UuidValue? id,
    DateTime? createdAt,
    String? phoneHash,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    _i3.SmsPasswordResetBlockedReason? blockedReason,
    _i1.UuidValue? challengeId,
    _i4.SecretChallenge? challenge,
    _i1.UuidValue? resetChallengeId,
    _i4.SecretChallenge? resetChallenge,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_auth_sms_core.SmsPasswordResetRequest',
      if (id != null) 'id': id?.toJson(),
      'createdAt': createdAt.toJson(),
      'phoneHash': phoneHash,
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      if (blockedReason != null) 'blockedReason': blockedReason?.toJson(),
      'challengeId': challengeId.toJson(),
      if (challenge != null) 'challenge': challenge?.toJson(),
      if (resetChallengeId != null)
        'resetChallengeId': resetChallengeId?.toJson(),
      if (resetChallenge != null) 'resetChallenge': resetChallenge?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static SmsPasswordResetRequestInclude include({
    _i2.AuthUserInclude? authUser,
    _i4.SecretChallengeInclude? challenge,
    _i4.SecretChallengeInclude? resetChallenge,
  }) {
    return SmsPasswordResetRequestInclude._(
      authUser: authUser,
      challenge: challenge,
      resetChallenge: resetChallenge,
    );
  }

  static SmsPasswordResetRequestIncludeList includeList({
    _i1.WhereExpressionBuilder<SmsPasswordResetRequestTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SmsPasswordResetRequestTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SmsPasswordResetRequestTable>? orderByList,
    SmsPasswordResetRequestInclude? include,
  }) {
    return SmsPasswordResetRequestIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SmsPasswordResetRequest.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(SmsPasswordResetRequest.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SmsPasswordResetRequestImpl extends SmsPasswordResetRequest {
  _SmsPasswordResetRequestImpl({
    _i1.UuidValue? id,
    DateTime? createdAt,
    required String phoneHash,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    _i3.SmsPasswordResetBlockedReason? blockedReason,
    required _i1.UuidValue challengeId,
    _i4.SecretChallenge? challenge,
    _i1.UuidValue? resetChallengeId,
    _i4.SecretChallenge? resetChallenge,
  }) : super._(
         id: id,
         createdAt: createdAt,
         phoneHash: phoneHash,
         authUserId: authUserId,
         authUser: authUser,
         blockedReason: blockedReason,
         challengeId: challengeId,
         challenge: challenge,
         resetChallengeId: resetChallengeId,
         resetChallenge: resetChallenge,
       );

  /// Returns a shallow copy of this [SmsPasswordResetRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  SmsPasswordResetRequest copyWith({
    Object? id = _Undefined,
    DateTime? createdAt,
    String? phoneHash,
    Object? authUserId = _Undefined,
    Object? authUser = _Undefined,
    Object? blockedReason = _Undefined,
    _i1.UuidValue? challengeId,
    Object? challenge = _Undefined,
    Object? resetChallengeId = _Undefined,
    Object? resetChallenge = _Undefined,
  }) {
    return SmsPasswordResetRequest(
      id: id is _i1.UuidValue? ? id : this.id,
      createdAt: createdAt ?? this.createdAt,
      phoneHash: phoneHash ?? this.phoneHash,
      authUserId: authUserId is _i1.UuidValue? ? authUserId : this.authUserId,
      authUser: authUser is _i2.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      blockedReason: blockedReason is _i3.SmsPasswordResetBlockedReason?
          ? blockedReason
          : this.blockedReason,
      challengeId: challengeId ?? this.challengeId,
      challenge: challenge is _i4.SecretChallenge?
          ? challenge
          : this.challenge?.copyWith(),
      resetChallengeId: resetChallengeId is _i1.UuidValue?
          ? resetChallengeId
          : this.resetChallengeId,
      resetChallenge: resetChallenge is _i4.SecretChallenge?
          ? resetChallenge
          : this.resetChallenge?.copyWith(),
    );
  }
}

class SmsPasswordResetRequestUpdateTable
    extends _i1.UpdateTable<SmsPasswordResetRequestTable> {
  SmsPasswordResetRequestUpdateTable(super.table);

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<String, String> phoneHash(String value) => _i1.ColumnValue(
    table.phoneHash,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authUserId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.authUserId,
    value,
  );

  _i1.ColumnValue<
    _i3.SmsPasswordResetBlockedReason,
    _i3.SmsPasswordResetBlockedReason
  >
  blockedReason(_i3.SmsPasswordResetBlockedReason? value) => _i1.ColumnValue(
    table.blockedReason,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> challengeId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.challengeId,
    value,
  );

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> resetChallengeId(
    _i1.UuidValue? value,
  ) => _i1.ColumnValue(
    table.resetChallengeId,
    value,
  );
}

class SmsPasswordResetRequestTable extends _i1.Table<_i1.UuidValue?> {
  SmsPasswordResetRequestTable({super.tableRelation})
    : super(tableName: 'serverpod_auth_sms_password_reset_request') {
    updateTable = SmsPasswordResetRequestUpdateTable(this);
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    phoneHash = _i1.ColumnString(
      'phoneHash',
      this,
    );
    authUserId = _i1.ColumnUuid(
      'authUserId',
      this,
    );
    blockedReason = _i1.ColumnEnum(
      'blockedReason',
      this,
      _i1.EnumSerialization.byName,
    );
    challengeId = _i1.ColumnUuid(
      'challengeId',
      this,
    );
    resetChallengeId = _i1.ColumnUuid(
      'resetChallengeId',
      this,
    );
  }

  late final SmsPasswordResetRequestUpdateTable updateTable;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnString phoneHash;

  late final _i1.ColumnUuid authUserId;

  _i2.AuthUserTable? _authUser;

  late final _i1.ColumnEnum<_i3.SmsPasswordResetBlockedReason> blockedReason;

  late final _i1.ColumnUuid challengeId;

  _i4.SecretChallengeTable? _challenge;

  late final _i1.ColumnUuid resetChallengeId;

  _i4.SecretChallengeTable? _resetChallenge;

  _i2.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _i1.createRelationTable(
      relationFieldName: 'authUser',
      field: SmsPasswordResetRequest.t.authUserId,
      foreignField: _i2.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _authUser!;
  }

  _i4.SecretChallengeTable get challenge {
    if (_challenge != null) return _challenge!;
    _challenge = _i1.createRelationTable(
      relationFieldName: 'challenge',
      field: SmsPasswordResetRequest.t.challengeId,
      foreignField: _i4.SecretChallenge.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i4.SecretChallengeTable(tableRelation: foreignTableRelation),
    );
    return _challenge!;
  }

  _i4.SecretChallengeTable get resetChallenge {
    if (_resetChallenge != null) return _resetChallenge!;
    _resetChallenge = _i1.createRelationTable(
      relationFieldName: 'resetChallenge',
      field: SmsPasswordResetRequest.t.resetChallengeId,
      foreignField: _i4.SecretChallenge.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i4.SecretChallengeTable(tableRelation: foreignTableRelation),
    );
    return _resetChallenge!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    createdAt,
    phoneHash,
    authUserId,
    blockedReason,
    challengeId,
    resetChallengeId,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    if (relationField == 'challenge') {
      return challenge;
    }
    if (relationField == 'resetChallenge') {
      return resetChallenge;
    }
    return null;
  }
}

class SmsPasswordResetRequestInclude extends _i1.IncludeObject {
  SmsPasswordResetRequestInclude._({
    _i2.AuthUserInclude? authUser,
    _i4.SecretChallengeInclude? challenge,
    _i4.SecretChallengeInclude? resetChallenge,
  }) {
    _authUser = authUser;
    _challenge = challenge;
    _resetChallenge = resetChallenge;
  }

  _i2.AuthUserInclude? _authUser;

  _i4.SecretChallengeInclude? _challenge;

  _i4.SecretChallengeInclude? _resetChallenge;

  @override
  Map<String, _i1.Include?> get includes => {
    'authUser': _authUser,
    'challenge': _challenge,
    'resetChallenge': _resetChallenge,
  };

  @override
  _i1.Table<_i1.UuidValue?> get table => SmsPasswordResetRequest.t;
}

class SmsPasswordResetRequestIncludeList extends _i1.IncludeList {
  SmsPasswordResetRequestIncludeList._({
    _i1.WhereExpressionBuilder<SmsPasswordResetRequestTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SmsPasswordResetRequest.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => SmsPasswordResetRequest.t;
}

class SmsPasswordResetRequestRepository {
  const SmsPasswordResetRequestRepository._();

  final attachRow = const SmsPasswordResetRequestAttachRowRepository._();

  final detachRow = const SmsPasswordResetRequestDetachRowRepository._();

  /// Returns a list of [SmsPasswordResetRequest]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<SmsPasswordResetRequest>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SmsPasswordResetRequestTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SmsPasswordResetRequestTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SmsPasswordResetRequestTable>? orderByList,
    _i1.Transaction? transaction,
    SmsPasswordResetRequestInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SmsPasswordResetRequest>(
      where: where?.call(SmsPasswordResetRequest.t),
      orderBy: orderBy?.call(SmsPasswordResetRequest.t),
      orderByList: orderByList?.call(SmsPasswordResetRequest.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SmsPasswordResetRequest] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<SmsPasswordResetRequest?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SmsPasswordResetRequestTable>? where,
    int? offset,
    _i1.OrderByBuilder<SmsPasswordResetRequestTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<SmsPasswordResetRequestTable>? orderByList,
    _i1.Transaction? transaction,
    SmsPasswordResetRequestInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SmsPasswordResetRequest>(
      where: where?.call(SmsPasswordResetRequest.t),
      orderBy: orderBy?.call(SmsPasswordResetRequest.t),
      orderByList: orderByList?.call(SmsPasswordResetRequest.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SmsPasswordResetRequest] by its [id] or null if no such row exists.
  Future<SmsPasswordResetRequest?> findById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    SmsPasswordResetRequestInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SmsPasswordResetRequest>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SmsPasswordResetRequest]s in the list and returns the inserted rows.
  ///
  /// The returned [SmsPasswordResetRequest]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<SmsPasswordResetRequest>> insert(
    _i1.DatabaseSession session,
    List<SmsPasswordResetRequest> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<SmsPasswordResetRequest>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [SmsPasswordResetRequest] and returns the inserted row.
  ///
  /// The returned [SmsPasswordResetRequest] will have its `id` field set.
  Future<SmsPasswordResetRequest> insertRow(
    _i1.DatabaseSession session,
    SmsPasswordResetRequest row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<SmsPasswordResetRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [SmsPasswordResetRequest]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<SmsPasswordResetRequest>> update(
    _i1.DatabaseSession session,
    List<SmsPasswordResetRequest> rows, {
    _i1.ColumnSelections<SmsPasswordResetRequestTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<SmsPasswordResetRequest>(
      rows,
      columns: columns?.call(SmsPasswordResetRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SmsPasswordResetRequest]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SmsPasswordResetRequest> updateRow(
    _i1.DatabaseSession session,
    SmsPasswordResetRequest row, {
    _i1.ColumnSelections<SmsPasswordResetRequestTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<SmsPasswordResetRequest>(
      row,
      columns: columns?.call(SmsPasswordResetRequest.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SmsPasswordResetRequest] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SmsPasswordResetRequest?> updateById(
    _i1.DatabaseSession session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<SmsPasswordResetRequestUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<SmsPasswordResetRequest>(
      id,
      columnValues: columnValues(SmsPasswordResetRequest.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SmsPasswordResetRequest]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<SmsPasswordResetRequest>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<SmsPasswordResetRequestUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<SmsPasswordResetRequestTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<SmsPasswordResetRequestTable>? orderBy,
    _i1.OrderByListBuilder<SmsPasswordResetRequestTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<SmsPasswordResetRequest>(
      columnValues: columnValues(SmsPasswordResetRequest.t.updateTable),
      where: where(SmsPasswordResetRequest.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SmsPasswordResetRequest.t),
      orderByList: orderByList?.call(SmsPasswordResetRequest.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [SmsPasswordResetRequest]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<SmsPasswordResetRequest>> delete(
    _i1.DatabaseSession session,
    List<SmsPasswordResetRequest> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<SmsPasswordResetRequest>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [SmsPasswordResetRequest].
  Future<SmsPasswordResetRequest> deleteRow(
    _i1.DatabaseSession session,
    SmsPasswordResetRequest row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SmsPasswordResetRequest>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<SmsPasswordResetRequest>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SmsPasswordResetRequestTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<SmsPasswordResetRequest>(
      where: where(SmsPasswordResetRequest.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<SmsPasswordResetRequestTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<SmsPasswordResetRequest>(
      where: where?.call(SmsPasswordResetRequest.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SmsPasswordResetRequest] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<SmsPasswordResetRequestTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SmsPasswordResetRequest>(
      where: where(SmsPasswordResetRequest.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class SmsPasswordResetRequestAttachRowRepository {
  const SmsPasswordResetRequestAttachRowRepository._();

  /// Creates a relation between the given [SmsPasswordResetRequest] and [AuthUser]
  /// by setting the [SmsPasswordResetRequest]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _i1.DatabaseSession session,
    SmsPasswordResetRequest smsPasswordResetRequest,
    _i2.AuthUser authUser, {
    _i1.Transaction? transaction,
  }) async {
    if (smsPasswordResetRequest.id == null) {
      throw ArgumentError.notNull('smsPasswordResetRequest.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $smsPasswordResetRequest = smsPasswordResetRequest.copyWith(
      authUserId: authUser.id,
    );
    await session.db.updateRow<SmsPasswordResetRequest>(
      $smsPasswordResetRequest,
      columns: [SmsPasswordResetRequest.t.authUserId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [SmsPasswordResetRequest] and [SecretChallenge]
  /// by setting the [SmsPasswordResetRequest]'s foreign key `challengeId` to refer to the [SecretChallenge].
  Future<void> challenge(
    _i1.DatabaseSession session,
    SmsPasswordResetRequest smsPasswordResetRequest,
    _i4.SecretChallenge challenge, {
    _i1.Transaction? transaction,
  }) async {
    if (smsPasswordResetRequest.id == null) {
      throw ArgumentError.notNull('smsPasswordResetRequest.id');
    }
    if (challenge.id == null) {
      throw ArgumentError.notNull('challenge.id');
    }

    var $smsPasswordResetRequest = smsPasswordResetRequest.copyWith(
      challengeId: challenge.id,
    );
    await session.db.updateRow<SmsPasswordResetRequest>(
      $smsPasswordResetRequest,
      columns: [SmsPasswordResetRequest.t.challengeId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [SmsPasswordResetRequest] and [SecretChallenge]
  /// by setting the [SmsPasswordResetRequest]'s foreign key `resetChallengeId` to refer to the [SecretChallenge].
  Future<void> resetChallenge(
    _i1.DatabaseSession session,
    SmsPasswordResetRequest smsPasswordResetRequest,
    _i4.SecretChallenge resetChallenge, {
    _i1.Transaction? transaction,
  }) async {
    if (smsPasswordResetRequest.id == null) {
      throw ArgumentError.notNull('smsPasswordResetRequest.id');
    }
    if (resetChallenge.id == null) {
      throw ArgumentError.notNull('resetChallenge.id');
    }

    var $smsPasswordResetRequest = smsPasswordResetRequest.copyWith(
      resetChallengeId: resetChallenge.id,
    );
    await session.db.updateRow<SmsPasswordResetRequest>(
      $smsPasswordResetRequest,
      columns: [SmsPasswordResetRequest.t.resetChallengeId],
      transaction: transaction,
    );
  }
}

class SmsPasswordResetRequestDetachRowRepository {
  const SmsPasswordResetRequestDetachRowRepository._();

  /// Detaches the relation between this [SmsPasswordResetRequest] and the [AuthUser] set in `authUser`
  /// by setting the [SmsPasswordResetRequest]'s foreign key `authUserId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> authUser(
    _i1.DatabaseSession session,
    SmsPasswordResetRequest smsPasswordResetRequest, {
    _i1.Transaction? transaction,
  }) async {
    if (smsPasswordResetRequest.id == null) {
      throw ArgumentError.notNull('smsPasswordResetRequest.id');
    }

    var $smsPasswordResetRequest = smsPasswordResetRequest.copyWith(
      authUserId: null,
    );
    await session.db.updateRow<SmsPasswordResetRequest>(
      $smsPasswordResetRequest,
      columns: [SmsPasswordResetRequest.t.authUserId],
      transaction: transaction,
    );
  }

  /// Detaches the relation between this [SmsPasswordResetRequest] and the [SecretChallenge] set in `resetChallenge`
  /// by setting the [SmsPasswordResetRequest]'s foreign key `resetChallengeId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> resetChallenge(
    _i1.DatabaseSession session,
    SmsPasswordResetRequest smsPasswordResetRequest, {
    _i1.Transaction? transaction,
  }) async {
    if (smsPasswordResetRequest.id == null) {
      throw ArgumentError.notNull('smsPasswordResetRequest.id');
    }

    var $smsPasswordResetRequest = smsPasswordResetRequest.copyWith(
      resetChallengeId: null,
    );
    await session.db.updateRow<SmsPasswordResetRequest>(
      $smsPasswordResetRequest,
      columns: [SmsPasswordResetRequest.t.resetChallengeId],
      transaction: transaction,
    );
  }
}
