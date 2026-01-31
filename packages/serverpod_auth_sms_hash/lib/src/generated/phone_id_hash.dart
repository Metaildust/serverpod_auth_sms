/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i2;
import 'package:serverpod_auth_sms_hash_server/src/generated/protocol.dart'
    as _i3;

/// Phone hash storage.
abstract class PhoneIdHash
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  PhoneIdHash._({
    this.id,
    required this.authUserId,
    this.authUser,
    DateTime? createdAt,
    required this.phoneHash,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PhoneIdHash({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    DateTime? createdAt,
    required String phoneHash,
  }) = _PhoneIdHashImpl;

  factory PhoneIdHash.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhoneIdHash(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['authUser'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      phoneHash: jsonSerialization['phoneHash'] as String,
    );
  }

  static final t = PhoneIdHashTable();

  static const db = PhoneIdHashRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue authUserId;

  _i2.AuthUser? authUser;

  DateTime createdAt;

  String phoneHash;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [PhoneIdHash]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PhoneIdHash copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    DateTime? createdAt,
    String? phoneHash,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_auth_sms_hash.PhoneIdHash',
      if (id != null) 'id': id?.toJson(),
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'createdAt': createdAt.toJson(),
      'phoneHash': phoneHash,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PhoneIdHashInclude include({_i2.AuthUserInclude? authUser}) {
    return PhoneIdHashInclude._(authUser: authUser);
  }

  static PhoneIdHashIncludeList includeList({
    _i1.WhereExpressionBuilder<PhoneIdHashTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhoneIdHashTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhoneIdHashTable>? orderByList,
    PhoneIdHashInclude? include,
  }) {
    return PhoneIdHashIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PhoneIdHash.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PhoneIdHash.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhoneIdHashImpl extends PhoneIdHash {
  _PhoneIdHashImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    DateTime? createdAt,
    required String phoneHash,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         createdAt: createdAt,
         phoneHash: phoneHash,
       );

  /// Returns a shallow copy of this [PhoneIdHash]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PhoneIdHash copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    Object? authUser = _Undefined,
    DateTime? createdAt,
    String? phoneHash,
  }) {
    return PhoneIdHash(
      id: id is _i1.UuidValue? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _i2.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
      phoneHash: phoneHash ?? this.phoneHash,
    );
  }
}

class PhoneIdHashUpdateTable extends _i1.UpdateTable<PhoneIdHashTable> {
  PhoneIdHashUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.authUserId,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _i1.ColumnValue(
        table.createdAt,
        value,
      );

  _i1.ColumnValue<String, String> phoneHash(String value) => _i1.ColumnValue(
    table.phoneHash,
    value,
  );
}

class PhoneIdHashTable extends _i1.Table<_i1.UuidValue?> {
  PhoneIdHashTable({super.tableRelation})
    : super(tableName: 'serverpod_auth_sms_phone_id_hash') {
    updateTable = PhoneIdHashUpdateTable(this);
    authUserId = _i1.ColumnUuid(
      'authUserId',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
      hasDefault: true,
    );
    phoneHash = _i1.ColumnString(
      'phoneHash',
      this,
    );
  }

  late final PhoneIdHashUpdateTable updateTable;

  late final _i1.ColumnUuid authUserId;

  _i2.AuthUserTable? _authUser;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnString phoneHash;

  _i2.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _i1.createRelationTable(
      relationFieldName: 'authUser',
      field: PhoneIdHash.t.authUserId,
      foreignField: _i2.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _authUser!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    authUserId,
    createdAt,
    phoneHash,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class PhoneIdHashInclude extends _i1.IncludeObject {
  PhoneIdHashInclude._({_i2.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _i2.AuthUserInclude? _authUser;

  @override
  Map<String, _i1.Include?> get includes => {'authUser': _authUser};

  @override
  _i1.Table<_i1.UuidValue?> get table => PhoneIdHash.t;
}

class PhoneIdHashIncludeList extends _i1.IncludeList {
  PhoneIdHashIncludeList._({
    _i1.WhereExpressionBuilder<PhoneIdHashTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PhoneIdHash.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PhoneIdHash.t;
}

class PhoneIdHashRepository {
  const PhoneIdHashRepository._();

  final attachRow = const PhoneIdHashAttachRowRepository._();

  /// Returns a list of [PhoneIdHash]s matching the given query parameters.
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
  Future<List<PhoneIdHash>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhoneIdHashTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhoneIdHashTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhoneIdHashTable>? orderByList,
    _i1.Transaction? transaction,
    PhoneIdHashInclude? include,
  }) async {
    return session.db.find<PhoneIdHash>(
      where: where?.call(PhoneIdHash.t),
      orderBy: orderBy?.call(PhoneIdHash.t),
      orderByList: orderByList?.call(PhoneIdHash.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [PhoneIdHash] matching the given query parameters.
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
  Future<PhoneIdHash?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhoneIdHashTable>? where,
    int? offset,
    _i1.OrderByBuilder<PhoneIdHashTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhoneIdHashTable>? orderByList,
    _i1.Transaction? transaction,
    PhoneIdHashInclude? include,
  }) async {
    return session.db.findFirstRow<PhoneIdHash>(
      where: where?.call(PhoneIdHash.t),
      orderBy: orderBy?.call(PhoneIdHash.t),
      orderByList: orderByList?.call(PhoneIdHash.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [PhoneIdHash] by its [id] or null if no such row exists.
  Future<PhoneIdHash?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    PhoneIdHashInclude? include,
  }) async {
    return session.db.findById<PhoneIdHash>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [PhoneIdHash]s in the list and returns the inserted rows.
  ///
  /// The returned [PhoneIdHash]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<PhoneIdHash>> insert(
    _i1.Session session,
    List<PhoneIdHash> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<PhoneIdHash>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [PhoneIdHash] and returns the inserted row.
  ///
  /// The returned [PhoneIdHash] will have its `id` field set.
  Future<PhoneIdHash> insertRow(
    _i1.Session session,
    PhoneIdHash row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PhoneIdHash>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PhoneIdHash]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PhoneIdHash>> update(
    _i1.Session session,
    List<PhoneIdHash> rows, {
    _i1.ColumnSelections<PhoneIdHashTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PhoneIdHash>(
      rows,
      columns: columns?.call(PhoneIdHash.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PhoneIdHash]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PhoneIdHash> updateRow(
    _i1.Session session,
    PhoneIdHash row, {
    _i1.ColumnSelections<PhoneIdHashTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PhoneIdHash>(
      row,
      columns: columns?.call(PhoneIdHash.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PhoneIdHash] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PhoneIdHash?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PhoneIdHashUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PhoneIdHash>(
      id,
      columnValues: columnValues(PhoneIdHash.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PhoneIdHash]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PhoneIdHash>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<PhoneIdHashUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PhoneIdHashTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhoneIdHashTable>? orderBy,
    _i1.OrderByListBuilder<PhoneIdHashTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PhoneIdHash>(
      columnValues: columnValues(PhoneIdHash.t.updateTable),
      where: where(PhoneIdHash.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PhoneIdHash.t),
      orderByList: orderByList?.call(PhoneIdHash.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PhoneIdHash]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PhoneIdHash>> delete(
    _i1.Session session,
    List<PhoneIdHash> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PhoneIdHash>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PhoneIdHash].
  Future<PhoneIdHash> deleteRow(
    _i1.Session session,
    PhoneIdHash row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PhoneIdHash>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PhoneIdHash>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PhoneIdHashTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PhoneIdHash>(
      where: where(PhoneIdHash.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhoneIdHashTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PhoneIdHash>(
      where: where?.call(PhoneIdHash.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class PhoneIdHashAttachRowRepository {
  const PhoneIdHashAttachRowRepository._();

  /// Creates a relation between the given [PhoneIdHash] and [AuthUser]
  /// by setting the [PhoneIdHash]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _i1.Session session,
    PhoneIdHash phoneIdHash,
    _i2.AuthUser authUser, {
    _i1.Transaction? transaction,
  }) async {
    if (phoneIdHash.id == null) {
      throw ArgumentError.notNull('phoneIdHash.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $phoneIdHash = phoneIdHash.copyWith(authUserId: authUser.id);
    await session.db.updateRow<PhoneIdHash>(
      $phoneIdHash,
      columns: [PhoneIdHash.t.authUserId],
      transaction: transaction,
    );
  }
}
