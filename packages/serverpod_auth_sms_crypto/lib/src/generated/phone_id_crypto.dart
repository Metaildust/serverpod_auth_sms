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
import 'dart:typed_data' as _i3;
import 'package:serverpod_auth_sms_crypto_server/src/generated/protocol.dart'
    as _i4;

/// Encrypted phone storage.
abstract class PhoneIdCrypto
    implements _i1.TableRow<_i1.UuidValue?>, _i1.ProtocolSerialization {
  PhoneIdCrypto._({
    this.id,
    required this.authUserId,
    this.authUser,
    DateTime? createdAt,
    required this.phoneHash,
    required this.phoneEncrypted,
    required this.nonce,
    required this.mac,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PhoneIdCrypto({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    DateTime? createdAt,
    required String phoneHash,
    required _i3.ByteData phoneEncrypted,
    required _i3.ByteData nonce,
    required _i3.ByteData mac,
  }) = _PhoneIdCryptoImpl;

  factory PhoneIdCrypto.fromJson(Map<String, dynamic> jsonSerialization) {
    return PhoneIdCrypto(
      id: jsonSerialization['id'] == null
          ? null
          : _i1.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _i4.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['authUser'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      phoneHash: jsonSerialization['phoneHash'] as String,
      phoneEncrypted: _i1.ByteDataJsonExtension.fromJson(
        jsonSerialization['phoneEncrypted'],
      ),
      nonce: _i1.ByteDataJsonExtension.fromJson(jsonSerialization['nonce']),
      mac: _i1.ByteDataJsonExtension.fromJson(jsonSerialization['mac']),
    );
  }

  static final t = PhoneIdCryptoTable();

  static const db = PhoneIdCryptoRepository._();

  @override
  _i1.UuidValue? id;

  _i1.UuidValue authUserId;

  _i2.AuthUser? authUser;

  DateTime createdAt;

  String phoneHash;

  _i3.ByteData phoneEncrypted;

  _i3.ByteData nonce;

  _i3.ByteData mac;

  @override
  _i1.Table<_i1.UuidValue?> get table => t;

  /// Returns a shallow copy of this [PhoneIdCrypto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PhoneIdCrypto copyWith({
    _i1.UuidValue? id,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    DateTime? createdAt,
    String? phoneHash,
    _i3.ByteData? phoneEncrypted,
    _i3.ByteData? nonce,
    _i3.ByteData? mac,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_auth_sms_crypto.PhoneIdCrypto',
      if (id != null) 'id': id?.toJson(),
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'createdAt': createdAt.toJson(),
      'phoneHash': phoneHash,
      'phoneEncrypted': phoneEncrypted.toJson(),
      'nonce': nonce.toJson(),
      'mac': mac.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {};
  }

  static PhoneIdCryptoInclude include({_i2.AuthUserInclude? authUser}) {
    return PhoneIdCryptoInclude._(authUser: authUser);
  }

  static PhoneIdCryptoIncludeList includeList({
    _i1.WhereExpressionBuilder<PhoneIdCryptoTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhoneIdCryptoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhoneIdCryptoTable>? orderByList,
    PhoneIdCryptoInclude? include,
  }) {
    return PhoneIdCryptoIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PhoneIdCrypto.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PhoneIdCrypto.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PhoneIdCryptoImpl extends PhoneIdCrypto {
  _PhoneIdCryptoImpl({
    _i1.UuidValue? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    DateTime? createdAt,
    required String phoneHash,
    required _i3.ByteData phoneEncrypted,
    required _i3.ByteData nonce,
    required _i3.ByteData mac,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         createdAt: createdAt,
         phoneHash: phoneHash,
         phoneEncrypted: phoneEncrypted,
         nonce: nonce,
         mac: mac,
       );

  /// Returns a shallow copy of this [PhoneIdCrypto]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PhoneIdCrypto copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    Object? authUser = _Undefined,
    DateTime? createdAt,
    String? phoneHash,
    _i3.ByteData? phoneEncrypted,
    _i3.ByteData? nonce,
    _i3.ByteData? mac,
  }) {
    return PhoneIdCrypto(
      id: id is _i1.UuidValue? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _i2.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      createdAt: createdAt ?? this.createdAt,
      phoneHash: phoneHash ?? this.phoneHash,
      phoneEncrypted: phoneEncrypted ?? this.phoneEncrypted.clone(),
      nonce: nonce ?? this.nonce.clone(),
      mac: mac ?? this.mac.clone(),
    );
  }
}

class PhoneIdCryptoUpdateTable extends _i1.UpdateTable<PhoneIdCryptoTable> {
  PhoneIdCryptoUpdateTable(super.table);

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

  _i1.ColumnValue<_i3.ByteData, _i3.ByteData> phoneEncrypted(
    _i3.ByteData value,
  ) => _i1.ColumnValue(
    table.phoneEncrypted,
    value,
  );

  _i1.ColumnValue<_i3.ByteData, _i3.ByteData> nonce(_i3.ByteData value) =>
      _i1.ColumnValue(
        table.nonce,
        value,
      );

  _i1.ColumnValue<_i3.ByteData, _i3.ByteData> mac(_i3.ByteData value) =>
      _i1.ColumnValue(
        table.mac,
        value,
      );
}

class PhoneIdCryptoTable extends _i1.Table<_i1.UuidValue?> {
  PhoneIdCryptoTable({super.tableRelation})
    : super(tableName: 'serverpod_auth_sms_phone_id_crypto') {
    updateTable = PhoneIdCryptoUpdateTable(this);
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
    phoneEncrypted = _i1.ColumnByteData(
      'phoneEncrypted',
      this,
    );
    nonce = _i1.ColumnByteData(
      'nonce',
      this,
    );
    mac = _i1.ColumnByteData(
      'mac',
      this,
    );
  }

  late final PhoneIdCryptoUpdateTable updateTable;

  late final _i1.ColumnUuid authUserId;

  _i2.AuthUserTable? _authUser;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnString phoneHash;

  late final _i1.ColumnByteData phoneEncrypted;

  late final _i1.ColumnByteData nonce;

  late final _i1.ColumnByteData mac;

  _i2.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _i1.createRelationTable(
      relationFieldName: 'authUser',
      field: PhoneIdCrypto.t.authUserId,
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
    phoneEncrypted,
    nonce,
    mac,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class PhoneIdCryptoInclude extends _i1.IncludeObject {
  PhoneIdCryptoInclude._({_i2.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _i2.AuthUserInclude? _authUser;

  @override
  Map<String, _i1.Include?> get includes => {'authUser': _authUser};

  @override
  _i1.Table<_i1.UuidValue?> get table => PhoneIdCrypto.t;
}

class PhoneIdCryptoIncludeList extends _i1.IncludeList {
  PhoneIdCryptoIncludeList._({
    _i1.WhereExpressionBuilder<PhoneIdCryptoTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PhoneIdCrypto.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<_i1.UuidValue?> get table => PhoneIdCrypto.t;
}

class PhoneIdCryptoRepository {
  const PhoneIdCryptoRepository._();

  final attachRow = const PhoneIdCryptoAttachRowRepository._();

  /// Returns a list of [PhoneIdCrypto]s matching the given query parameters.
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
  Future<List<PhoneIdCrypto>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhoneIdCryptoTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhoneIdCryptoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhoneIdCryptoTable>? orderByList,
    _i1.Transaction? transaction,
    PhoneIdCryptoInclude? include,
  }) async {
    return session.db.find<PhoneIdCrypto>(
      where: where?.call(PhoneIdCrypto.t),
      orderBy: orderBy?.call(PhoneIdCrypto.t),
      orderByList: orderByList?.call(PhoneIdCrypto.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Returns the first matching [PhoneIdCrypto] matching the given query parameters.
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
  Future<PhoneIdCrypto?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhoneIdCryptoTable>? where,
    int? offset,
    _i1.OrderByBuilder<PhoneIdCryptoTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PhoneIdCryptoTable>? orderByList,
    _i1.Transaction? transaction,
    PhoneIdCryptoInclude? include,
  }) async {
    return session.db.findFirstRow<PhoneIdCrypto>(
      where: where?.call(PhoneIdCrypto.t),
      orderBy: orderBy?.call(PhoneIdCrypto.t),
      orderByList: orderByList?.call(PhoneIdCrypto.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
    );
  }

  /// Finds a single [PhoneIdCrypto] by its [id] or null if no such row exists.
  Future<PhoneIdCrypto?> findById(
    _i1.Session session,
    _i1.UuidValue id, {
    _i1.Transaction? transaction,
    PhoneIdCryptoInclude? include,
  }) async {
    return session.db.findById<PhoneIdCrypto>(
      id,
      transaction: transaction,
      include: include,
    );
  }

  /// Inserts all [PhoneIdCrypto]s in the list and returns the inserted rows.
  ///
  /// The returned [PhoneIdCrypto]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<PhoneIdCrypto>> insert(
    _i1.Session session,
    List<PhoneIdCrypto> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<PhoneIdCrypto>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [PhoneIdCrypto] and returns the inserted row.
  ///
  /// The returned [PhoneIdCrypto] will have its `id` field set.
  Future<PhoneIdCrypto> insertRow(
    _i1.Session session,
    PhoneIdCrypto row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PhoneIdCrypto>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PhoneIdCrypto]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PhoneIdCrypto>> update(
    _i1.Session session,
    List<PhoneIdCrypto> rows, {
    _i1.ColumnSelections<PhoneIdCryptoTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PhoneIdCrypto>(
      rows,
      columns: columns?.call(PhoneIdCrypto.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PhoneIdCrypto]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PhoneIdCrypto> updateRow(
    _i1.Session session,
    PhoneIdCrypto row, {
    _i1.ColumnSelections<PhoneIdCryptoTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PhoneIdCrypto>(
      row,
      columns: columns?.call(PhoneIdCrypto.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PhoneIdCrypto] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<PhoneIdCrypto?> updateById(
    _i1.Session session,
    _i1.UuidValue id, {
    required _i1.ColumnValueListBuilder<PhoneIdCryptoUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<PhoneIdCrypto>(
      id,
      columnValues: columnValues(PhoneIdCrypto.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [PhoneIdCrypto]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<PhoneIdCrypto>> updateWhere(
    _i1.Session session, {
    required _i1.ColumnValueListBuilder<PhoneIdCryptoUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<PhoneIdCryptoTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PhoneIdCryptoTable>? orderBy,
    _i1.OrderByListBuilder<PhoneIdCryptoTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<PhoneIdCrypto>(
      columnValues: columnValues(PhoneIdCrypto.t.updateTable),
      where: where(PhoneIdCrypto.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PhoneIdCrypto.t),
      orderByList: orderByList?.call(PhoneIdCrypto.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [PhoneIdCrypto]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PhoneIdCrypto>> delete(
    _i1.Session session,
    List<PhoneIdCrypto> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PhoneIdCrypto>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PhoneIdCrypto].
  Future<PhoneIdCrypto> deleteRow(
    _i1.Session session,
    PhoneIdCrypto row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PhoneIdCrypto>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PhoneIdCrypto>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PhoneIdCryptoTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PhoneIdCrypto>(
      where: where(PhoneIdCrypto.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PhoneIdCryptoTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PhoneIdCrypto>(
      where: where?.call(PhoneIdCrypto.t),
      limit: limit,
      transaction: transaction,
    );
  }
}

class PhoneIdCryptoAttachRowRepository {
  const PhoneIdCryptoAttachRowRepository._();

  /// Creates a relation between the given [PhoneIdCrypto] and [AuthUser]
  /// by setting the [PhoneIdCrypto]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _i1.Session session,
    PhoneIdCrypto phoneIdCrypto,
    _i2.AuthUser authUser, {
    _i1.Transaction? transaction,
  }) async {
    if (phoneIdCrypto.id == null) {
      throw ArgumentError.notNull('phoneIdCrypto.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $phoneIdCrypto = phoneIdCrypto.copyWith(authUserId: authUser.id);
    await session.db.updateRow<PhoneIdCrypto>(
      $phoneIdCrypto,
      columns: [PhoneIdCrypto.t.authUserId],
      transaction: transaction,
    );
  }
}
