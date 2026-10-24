// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ClientsTableTable extends ClientsTable
    with TableInfo<$ClientsTableTable, ClientData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientTypeMeta =
      const VerificationMeta('clientType');
  @override
  late final GeneratedColumn<String> clientType = GeneratedColumn<String>(
      'client_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('individual'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 191),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _contactPersonMeta =
      const VerificationMeta('contactPerson');
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
      'contact_person', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 191),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _phonePrimaryMeta =
      const VerificationMeta('phonePrimary');
  @override
  late final GeneratedColumn<String> phonePrimary = GeneratedColumn<String>(
      'phone_primary', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _phoneSecondaryMeta =
      const VerificationMeta('phoneSecondary');
  @override
  late final GeneratedColumn<String> phoneSecondary = GeneratedColumn<String>(
      'phone_secondary', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _physicalAddressMeta =
      const VerificationMeta('physicalAddress');
  @override
  late final GeneratedColumn<String> physicalAddress = GeneratedColumn<String>(
      'physical_address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        clientType,
        name,
        contactPerson,
        phonePrimary,
        phoneSecondary,
        physicalAddress,
        notes,
        createdAt,
        updatedAt,
        deletedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(Insertable<ClientData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('client_type')) {
      context.handle(
          _clientTypeMeta,
          clientType.isAcceptableOrUnknown(
              data['client_type']!, _clientTypeMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact_person')) {
      context.handle(
          _contactPersonMeta,
          contactPerson.isAcceptableOrUnknown(
              data['contact_person']!, _contactPersonMeta));
    }
    if (data.containsKey('phone_primary')) {
      context.handle(
          _phonePrimaryMeta,
          phonePrimary.isAcceptableOrUnknown(
              data['phone_primary']!, _phonePrimaryMeta));
    } else if (isInserting) {
      context.missing(_phonePrimaryMeta);
    }
    if (data.containsKey('phone_secondary')) {
      context.handle(
          _phoneSecondaryMeta,
          phoneSecondary.isAcceptableOrUnknown(
              data['phone_secondary']!, _phoneSecondaryMeta));
    }
    if (data.containsKey('physical_address')) {
      context.handle(
          _physicalAddressMeta,
          physicalAddress.isAcceptableOrUnknown(
              data['physical_address']!, _physicalAddressMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClientData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClientData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      clientType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_type'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      contactPerson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contact_person']),
      phonePrimary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_primary'])!,
      phoneSecondary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_secondary']),
      physicalAddress: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}physical_address']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ClientsTableTable createAlias(String alias) {
    return $ClientsTableTable(attachedDatabase, alias);
  }
}

class ClientData extends DataClass implements Insertable<ClientData> {
  /// Primary UUIDv4 / UUIDv7 identifier
  final String id;

  /// Practice tenant isolation identifier
  final String tenantId;

  /// Client classification: individual, commercial_farm, rescue_center, breeder
  final String clientType;

  /// Full client name or organization title
  final String name;

  /// Primary representative or emergency contact name
  final String? contactPerson;

  /// Primary communication telephone number
  final String phonePrimary;

  /// Secondary telephone number
  final String? phoneSecondary;

  /// Street address or geolocation notes
  final String? physicalAddress;

  /// General client billing notes or preferences
  final String? notes;

  /// Timestamp of creation
  final DateTime createdAt;

  /// Timestamp of latest modification
  final DateTime updatedAt;

  /// Soft delete timestamp (null if active)
  final DateTime? deletedAt;

  /// Offline synchronization status: 'synced', 'pending_create', 'pending_update', 'pending_delete'
  final String syncStatus;

  /// Timestamp of last successful server round-trip
  final DateTime? lastSyncedAt;
  const ClientData(
      {required this.id,
      required this.tenantId,
      required this.clientType,
      required this.name,
      this.contactPerson,
      required this.phonePrimary,
      this.phoneSecondary,
      this.physicalAddress,
      this.notes,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['client_type'] = Variable<String>(clientType);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contactPerson != null) {
      map['contact_person'] = Variable<String>(contactPerson);
    }
    map['phone_primary'] = Variable<String>(phonePrimary);
    if (!nullToAbsent || phoneSecondary != null) {
      map['phone_secondary'] = Variable<String>(phoneSecondary);
    }
    if (!nullToAbsent || physicalAddress != null) {
      map['physical_address'] = Variable<String>(physicalAddress);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ClientsTableCompanion toCompanion(bool nullToAbsent) {
    return ClientsTableCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      clientType: Value(clientType),
      name: Value(name),
      contactPerson: contactPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPerson),
      phonePrimary: Value(phonePrimary),
      phoneSecondary: phoneSecondary == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneSecondary),
      physicalAddress: physicalAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(physicalAddress),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory ClientData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClientData(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      clientType: serializer.fromJson<String>(json['clientType']),
      name: serializer.fromJson<String>(json['name']),
      contactPerson: serializer.fromJson<String?>(json['contactPerson']),
      phonePrimary: serializer.fromJson<String>(json['phonePrimary']),
      phoneSecondary: serializer.fromJson<String?>(json['phoneSecondary']),
      physicalAddress: serializer.fromJson<String?>(json['physicalAddress']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'clientType': serializer.toJson<String>(clientType),
      'name': serializer.toJson<String>(name),
      'contactPerson': serializer.toJson<String?>(contactPerson),
      'phonePrimary': serializer.toJson<String>(phonePrimary),
      'phoneSecondary': serializer.toJson<String?>(phoneSecondary),
      'physicalAddress': serializer.toJson<String?>(physicalAddress),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  ClientData copyWith(
          {String? id,
          String? tenantId,
          String? clientType,
          String? name,
          Value<String?> contactPerson = const Value.absent(),
          String? phonePrimary,
          Value<String?> phoneSecondary = const Value.absent(),
          Value<String?> physicalAddress = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      ClientData(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        clientType: clientType ?? this.clientType,
        name: name ?? this.name,
        contactPerson:
            contactPerson.present ? contactPerson.value : this.contactPerson,
        phonePrimary: phonePrimary ?? this.phonePrimary,
        phoneSecondary:
            phoneSecondary.present ? phoneSecondary.value : this.phoneSecondary,
        physicalAddress: physicalAddress.present
            ? physicalAddress.value
            : this.physicalAddress,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  ClientData copyWithCompanion(ClientsTableCompanion data) {
    return ClientData(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      clientType:
          data.clientType.present ? data.clientType.value : this.clientType,
      name: data.name.present ? data.name.value : this.name,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      phonePrimary: data.phonePrimary.present
          ? data.phonePrimary.value
          : this.phonePrimary,
      phoneSecondary: data.phoneSecondary.present
          ? data.phoneSecondary.value
          : this.phoneSecondary,
      physicalAddress: data.physicalAddress.present
          ? data.physicalAddress.value
          : this.physicalAddress,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClientData(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('clientType: $clientType, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phonePrimary: $phonePrimary, ')
          ..write('phoneSecondary: $phoneSecondary, ')
          ..write('physicalAddress: $physicalAddress, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tenantId,
      clientType,
      name,
      contactPerson,
      phonePrimary,
      phoneSecondary,
      physicalAddress,
      notes,
      createdAt,
      updatedAt,
      deletedAt,
      syncStatus,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClientData &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.clientType == this.clientType &&
          other.name == this.name &&
          other.contactPerson == this.contactPerson &&
          other.phonePrimary == this.phonePrimary &&
          other.phoneSecondary == this.phoneSecondary &&
          other.physicalAddress == this.physicalAddress &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ClientsTableCompanion extends UpdateCompanion<ClientData> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> clientType;
  final Value<String> name;
  final Value<String?> contactPerson;
  final Value<String> phonePrimary;
  final Value<String?> phoneSecondary;
  final Value<String?> physicalAddress;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ClientsTableCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.clientType = const Value.absent(),
    this.name = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.phonePrimary = const Value.absent(),
    this.phoneSecondary = const Value.absent(),
    this.physicalAddress = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsTableCompanion.insert({
    required String id,
    required String tenantId,
    this.clientType = const Value.absent(),
    required String name,
    this.contactPerson = const Value.absent(),
    required String phonePrimary,
    this.phoneSecondary = const Value.absent(),
    this.physicalAddress = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        name = Value(name),
        phonePrimary = Value(phonePrimary),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ClientData> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? clientType,
    Expression<String>? name,
    Expression<String>? contactPerson,
    Expression<String>? phonePrimary,
    Expression<String>? phoneSecondary,
    Expression<String>? physicalAddress,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (clientType != null) 'client_type': clientType,
      if (name != null) 'name': name,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (phonePrimary != null) 'phone_primary': phonePrimary,
      if (phoneSecondary != null) 'phone_secondary': phoneSecondary,
      if (physicalAddress != null) 'physical_address': physicalAddress,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? clientType,
      Value<String>? name,
      Value<String?>? contactPerson,
      Value<String>? phonePrimary,
      Value<String?>? phoneSecondary,
      Value<String?>? physicalAddress,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ClientsTableCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      clientType: clientType ?? this.clientType,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      phonePrimary: phonePrimary ?? this.phonePrimary,
      phoneSecondary: phoneSecondary ?? this.phoneSecondary,
      physicalAddress: physicalAddress ?? this.physicalAddress,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (clientType.present) {
      map['client_type'] = Variable<String>(clientType.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (phonePrimary.present) {
      map['phone_primary'] = Variable<String>(phonePrimary.value);
    }
    if (phoneSecondary.present) {
      map['phone_secondary'] = Variable<String>(phoneSecondary.value);
    }
    if (physicalAddress.present) {
      map['physical_address'] = Variable<String>(physicalAddress.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsTableCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('clientType: $clientType, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('phonePrimary: $phonePrimary, ')
          ..write('phoneSecondary: $phoneSecondary, ')
          ..write('physicalAddress: $physicalAddress, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PatientsTableTable extends PatientsTable
    with TableInfo<$PatientsTableTable, PatientData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientIdMeta =
      const VerificationMeta('clientId');
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
      'client_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES clients (id)'));
  static const VerificationMeta _nameOrTagMeta =
      const VerificationMeta('nameOrTag');
  @override
  late final GeneratedColumn<String> nameOrTag = GeneratedColumn<String>(
      'name_or_tag', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _speciesMeta =
      const VerificationMeta('species');
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
      'species', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _breedMeta = const VerificationMeta('breed');
  @override
  late final GeneratedColumn<String> breed = GeneratedColumn<String>(
      'breed', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unknown'));
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dateOfBirthMeta =
      const VerificationMeta('dateOfBirth');
  @override
  late final GeneratedColumn<DateTime> dateOfBirth = GeneratedColumn<DateTime>(
      'date_of_birth', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _isApproximateAgeMeta =
      const VerificationMeta('isApproximateAge');
  @override
  late final GeneratedColumn<bool> isApproximateAge = GeneratedColumn<bool>(
      'is_approximate_age', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_approximate_age" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _microchipNumberMeta =
      const VerificationMeta('microchipNumber');
  @override
  late final GeneratedColumn<String> microchipNumber = GeneratedColumn<String>(
      'microchip_number', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _earTagIdMeta =
      const VerificationMeta('earTagId');
  @override
  late final GeneratedColumn<String> earTagId = GeneratedColumn<String>(
      'ear_tag_id', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _coatColorMarkingsMeta =
      const VerificationMeta('coatColorMarkings');
  @override
  late final GeneratedColumn<String> coatColorMarkings =
      GeneratedColumn<String>('coat_color_markings', aliasedName, true,
          additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 191),
          type: DriftSqlType.string,
          requiredDuringInsert: false);
  static const VerificationMeta _currentWeightKgMeta =
      const VerificationMeta('currentWeightKg');
  @override
  late final GeneratedColumn<double> currentWeightKg = GeneratedColumn<double>(
      'current_weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _weightRecordedAtMeta =
      const VerificationMeta('weightRecordedAt');
  @override
  late final GeneratedColumn<DateTime> weightRecordedAt =
      GeneratedColumn<DateTime>('weight_recorded_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _historyMeta =
      const VerificationMeta('history');
  @override
  late final GeneratedColumn<String> history = GeneratedColumn<String>(
      'history', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _deceasedAtMeta =
      const VerificationMeta('deceasedAt');
  @override
  late final GeneratedColumn<DateTime> deceasedAt = GeneratedColumn<DateTime>(
      'deceased_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _allergiesMeta =
      const VerificationMeta('allergies');
  @override
  late final GeneratedColumn<String> allergies = GeneratedColumn<String>(
      'allergies', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        clientId,
        nameOrTag,
        species,
        breed,
        gender,
        age,
        dateOfBirth,
        isApproximateAge,
        microchipNumber,
        earTagId,
        coatColorMarkings,
        currentWeightKg,
        weightRecordedAt,
        history,
        notes,
        status,
        deceasedAt,
        allergies,
        createdAt,
        updatedAt,
        deletedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(Insertable<PatientData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(_clientIdMeta,
          clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta));
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('name_or_tag')) {
      context.handle(
          _nameOrTagMeta,
          nameOrTag.isAcceptableOrUnknown(
              data['name_or_tag']!, _nameOrTagMeta));
    } else if (isInserting) {
      context.missing(_nameOrTagMeta);
    }
    if (data.containsKey('species')) {
      context.handle(_speciesMeta,
          species.isAcceptableOrUnknown(data['species']!, _speciesMeta));
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('breed')) {
      context.handle(
          _breedMeta, breed.isAcceptableOrUnknown(data['breed']!, _breedMeta));
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('date_of_birth')) {
      context.handle(
          _dateOfBirthMeta,
          dateOfBirth.isAcceptableOrUnknown(
              data['date_of_birth']!, _dateOfBirthMeta));
    }
    if (data.containsKey('is_approximate_age')) {
      context.handle(
          _isApproximateAgeMeta,
          isApproximateAge.isAcceptableOrUnknown(
              data['is_approximate_age']!, _isApproximateAgeMeta));
    }
    if (data.containsKey('microchip_number')) {
      context.handle(
          _microchipNumberMeta,
          microchipNumber.isAcceptableOrUnknown(
              data['microchip_number']!, _microchipNumberMeta));
    }
    if (data.containsKey('ear_tag_id')) {
      context.handle(_earTagIdMeta,
          earTagId.isAcceptableOrUnknown(data['ear_tag_id']!, _earTagIdMeta));
    }
    if (data.containsKey('coat_color_markings')) {
      context.handle(
          _coatColorMarkingsMeta,
          coatColorMarkings.isAcceptableOrUnknown(
              data['coat_color_markings']!, _coatColorMarkingsMeta));
    }
    if (data.containsKey('current_weight_kg')) {
      context.handle(
          _currentWeightKgMeta,
          currentWeightKg.isAcceptableOrUnknown(
              data['current_weight_kg']!, _currentWeightKgMeta));
    }
    if (data.containsKey('weight_recorded_at')) {
      context.handle(
          _weightRecordedAtMeta,
          weightRecordedAt.isAcceptableOrUnknown(
              data['weight_recorded_at']!, _weightRecordedAtMeta));
    }
    if (data.containsKey('history')) {
      context.handle(_historyMeta,
          history.isAcceptableOrUnknown(data['history']!, _historyMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('deceased_at')) {
      context.handle(
          _deceasedAtMeta,
          deceasedAt.isAcceptableOrUnknown(
              data['deceased_at']!, _deceasedAtMeta));
    }
    if (data.containsKey('allergies')) {
      context.handle(_allergiesMeta,
          allergies.isAcceptableOrUnknown(data['allergies']!, _allergiesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PatientData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PatientData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      clientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}client_id'])!,
      nameOrTag: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_or_tag'])!,
      species: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}species'])!,
      breed: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}breed']),
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      dateOfBirth: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date_of_birth']),
      isApproximateAge: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_approximate_age'])!,
      microchipNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}microchip_number']),
      earTagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ear_tag_id']),
      coatColorMarkings: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}coat_color_markings']),
      currentWeightKg: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}current_weight_kg']),
      weightRecordedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}weight_recorded_at']),
      history: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}history']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      deceasedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deceased_at']),
      allergies: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}allergies']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $PatientsTableTable createAlias(String alias) {
    return $PatientsTableTable(attachedDatabase, alias);
  }
}

class PatientData extends DataClass implements Insertable<PatientData> {
  /// Primary UUID identifier
  final String id;

  /// Practice tenant isolation identifier
  final String tenantId;

  /// Foreign key linking patient to owner
  final String clientId;

  /// Pet name or livestock visual ear tag
  final String nameOrTag;

  /// Biological species: Canine, Feline, Equine, Bovine, Ovine, Caprine, Avian, Reptile, Other
  final String species;

  /// Specific breed or mixed heritage
  final String? breed;

  /// Gender & reproductive status: male_intact, male_neutered, female_intact, female_spayed, unknown
  final String gender;

  /// Approximate or calculated age in whole years
  final int? age;

  /// Verified date of birth if known
  final DateTime? dateOfBirth;

  /// Indicates if age was estimated during triage
  final bool isApproximateAge;

  /// ISO 11784/11785 15-digit RFID microchip implant identifier
  final String? microchipNumber;

  /// Official livestock visual identification tag
  final String? earTagId;

  /// Coat coloration, patterns, and distinctive scars
  final String? coatColorMarkings;

  /// Current body weight in kilograms (accurate to 3 decimals)
  final double? currentWeightKg;

  /// Timestamp when current weight was recorded
  final DateTime? weightRecordedAt;

  /// Chronic medical conditions, vaccination background
  final String? history;

  /// Behavioral cautions (e.g. muzzle required, fractious feline)
  final String? notes;

  /// Patient status: active, deceased, archived, transferred
  final String status;

  /// Date/time of passing if deceased
  final DateTime? deceasedAt;

  /// Known drug or dietary allergies stored as serialized JSON array
  final String? allergies;

  /// Creation timestamp
  final DateTime createdAt;

  /// Modification timestamp
  final DateTime updatedAt;

  /// Soft deletion timestamp
  final DateTime? deletedAt;

  /// Offline synchronization lifecycle: synced, pending_create, pending_update, pending_delete
  final String syncStatus;

  /// Last server sync timestamp
  final DateTime? lastSyncedAt;
  const PatientData(
      {required this.id,
      required this.tenantId,
      required this.clientId,
      required this.nameOrTag,
      required this.species,
      this.breed,
      required this.gender,
      this.age,
      this.dateOfBirth,
      required this.isApproximateAge,
      this.microchipNumber,
      this.earTagId,
      this.coatColorMarkings,
      this.currentWeightKg,
      this.weightRecordedAt,
      this.history,
      this.notes,
      required this.status,
      this.deceasedAt,
      this.allergies,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['client_id'] = Variable<String>(clientId);
    map['name_or_tag'] = Variable<String>(nameOrTag);
    map['species'] = Variable<String>(species);
    if (!nullToAbsent || breed != null) {
      map['breed'] = Variable<String>(breed);
    }
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || dateOfBirth != null) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth);
    }
    map['is_approximate_age'] = Variable<bool>(isApproximateAge);
    if (!nullToAbsent || microchipNumber != null) {
      map['microchip_number'] = Variable<String>(microchipNumber);
    }
    if (!nullToAbsent || earTagId != null) {
      map['ear_tag_id'] = Variable<String>(earTagId);
    }
    if (!nullToAbsent || coatColorMarkings != null) {
      map['coat_color_markings'] = Variable<String>(coatColorMarkings);
    }
    if (!nullToAbsent || currentWeightKg != null) {
      map['current_weight_kg'] = Variable<double>(currentWeightKg);
    }
    if (!nullToAbsent || weightRecordedAt != null) {
      map['weight_recorded_at'] = Variable<DateTime>(weightRecordedAt);
    }
    if (!nullToAbsent || history != null) {
      map['history'] = Variable<String>(history);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || deceasedAt != null) {
      map['deceased_at'] = Variable<DateTime>(deceasedAt);
    }
    if (!nullToAbsent || allergies != null) {
      map['allergies'] = Variable<String>(allergies);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  PatientsTableCompanion toCompanion(bool nullToAbsent) {
    return PatientsTableCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      clientId: Value(clientId),
      nameOrTag: Value(nameOrTag),
      species: Value(species),
      breed:
          breed == null && nullToAbsent ? const Value.absent() : Value(breed),
      gender: Value(gender),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      dateOfBirth: dateOfBirth == null && nullToAbsent
          ? const Value.absent()
          : Value(dateOfBirth),
      isApproximateAge: Value(isApproximateAge),
      microchipNumber: microchipNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(microchipNumber),
      earTagId: earTagId == null && nullToAbsent
          ? const Value.absent()
          : Value(earTagId),
      coatColorMarkings: coatColorMarkings == null && nullToAbsent
          ? const Value.absent()
          : Value(coatColorMarkings),
      currentWeightKg: currentWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(currentWeightKg),
      weightRecordedAt: weightRecordedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(weightRecordedAt),
      history: history == null && nullToAbsent
          ? const Value.absent()
          : Value(history),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      status: Value(status),
      deceasedAt: deceasedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deceasedAt),
      allergies: allergies == null && nullToAbsent
          ? const Value.absent()
          : Value(allergies),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory PatientData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PatientData(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      clientId: serializer.fromJson<String>(json['clientId']),
      nameOrTag: serializer.fromJson<String>(json['nameOrTag']),
      species: serializer.fromJson<String>(json['species']),
      breed: serializer.fromJson<String?>(json['breed']),
      gender: serializer.fromJson<String>(json['gender']),
      age: serializer.fromJson<int?>(json['age']),
      dateOfBirth: serializer.fromJson<DateTime?>(json['dateOfBirth']),
      isApproximateAge: serializer.fromJson<bool>(json['isApproximateAge']),
      microchipNumber: serializer.fromJson<String?>(json['microchipNumber']),
      earTagId: serializer.fromJson<String?>(json['earTagId']),
      coatColorMarkings:
          serializer.fromJson<String?>(json['coatColorMarkings']),
      currentWeightKg: serializer.fromJson<double?>(json['currentWeightKg']),
      weightRecordedAt:
          serializer.fromJson<DateTime?>(json['weightRecordedAt']),
      history: serializer.fromJson<String?>(json['history']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      deceasedAt: serializer.fromJson<DateTime?>(json['deceasedAt']),
      allergies: serializer.fromJson<String?>(json['allergies']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'clientId': serializer.toJson<String>(clientId),
      'nameOrTag': serializer.toJson<String>(nameOrTag),
      'species': serializer.toJson<String>(species),
      'breed': serializer.toJson<String?>(breed),
      'gender': serializer.toJson<String>(gender),
      'age': serializer.toJson<int?>(age),
      'dateOfBirth': serializer.toJson<DateTime?>(dateOfBirth),
      'isApproximateAge': serializer.toJson<bool>(isApproximateAge),
      'microchipNumber': serializer.toJson<String?>(microchipNumber),
      'earTagId': serializer.toJson<String?>(earTagId),
      'coatColorMarkings': serializer.toJson<String?>(coatColorMarkings),
      'currentWeightKg': serializer.toJson<double?>(currentWeightKg),
      'weightRecordedAt': serializer.toJson<DateTime?>(weightRecordedAt),
      'history': serializer.toJson<String?>(history),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'deceasedAt': serializer.toJson<DateTime?>(deceasedAt),
      'allergies': serializer.toJson<String?>(allergies),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  PatientData copyWith(
          {String? id,
          String? tenantId,
          String? clientId,
          String? nameOrTag,
          String? species,
          Value<String?> breed = const Value.absent(),
          String? gender,
          Value<int?> age = const Value.absent(),
          Value<DateTime?> dateOfBirth = const Value.absent(),
          bool? isApproximateAge,
          Value<String?> microchipNumber = const Value.absent(),
          Value<String?> earTagId = const Value.absent(),
          Value<String?> coatColorMarkings = const Value.absent(),
          Value<double?> currentWeightKg = const Value.absent(),
          Value<DateTime?> weightRecordedAt = const Value.absent(),
          Value<String?> history = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          String? status,
          Value<DateTime?> deceasedAt = const Value.absent(),
          Value<String?> allergies = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      PatientData(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        clientId: clientId ?? this.clientId,
        nameOrTag: nameOrTag ?? this.nameOrTag,
        species: species ?? this.species,
        breed: breed.present ? breed.value : this.breed,
        gender: gender ?? this.gender,
        age: age.present ? age.value : this.age,
        dateOfBirth: dateOfBirth.present ? dateOfBirth.value : this.dateOfBirth,
        isApproximateAge: isApproximateAge ?? this.isApproximateAge,
        microchipNumber: microchipNumber.present
            ? microchipNumber.value
            : this.microchipNumber,
        earTagId: earTagId.present ? earTagId.value : this.earTagId,
        coatColorMarkings: coatColorMarkings.present
            ? coatColorMarkings.value
            : this.coatColorMarkings,
        currentWeightKg: currentWeightKg.present
            ? currentWeightKg.value
            : this.currentWeightKg,
        weightRecordedAt: weightRecordedAt.present
            ? weightRecordedAt.value
            : this.weightRecordedAt,
        history: history.present ? history.value : this.history,
        notes: notes.present ? notes.value : this.notes,
        status: status ?? this.status,
        deceasedAt: deceasedAt.present ? deceasedAt.value : this.deceasedAt,
        allergies: allergies.present ? allergies.value : this.allergies,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  PatientData copyWithCompanion(PatientsTableCompanion data) {
    return PatientData(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      nameOrTag: data.nameOrTag.present ? data.nameOrTag.value : this.nameOrTag,
      species: data.species.present ? data.species.value : this.species,
      breed: data.breed.present ? data.breed.value : this.breed,
      gender: data.gender.present ? data.gender.value : this.gender,
      age: data.age.present ? data.age.value : this.age,
      dateOfBirth:
          data.dateOfBirth.present ? data.dateOfBirth.value : this.dateOfBirth,
      isApproximateAge: data.isApproximateAge.present
          ? data.isApproximateAge.value
          : this.isApproximateAge,
      microchipNumber: data.microchipNumber.present
          ? data.microchipNumber.value
          : this.microchipNumber,
      earTagId: data.earTagId.present ? data.earTagId.value : this.earTagId,
      coatColorMarkings: data.coatColorMarkings.present
          ? data.coatColorMarkings.value
          : this.coatColorMarkings,
      currentWeightKg: data.currentWeightKg.present
          ? data.currentWeightKg.value
          : this.currentWeightKg,
      weightRecordedAt: data.weightRecordedAt.present
          ? data.weightRecordedAt.value
          : this.weightRecordedAt,
      history: data.history.present ? data.history.value : this.history,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      deceasedAt:
          data.deceasedAt.present ? data.deceasedAt.value : this.deceasedAt,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PatientData(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('clientId: $clientId, ')
          ..write('nameOrTag: $nameOrTag, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('gender: $gender, ')
          ..write('age: $age, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('isApproximateAge: $isApproximateAge, ')
          ..write('microchipNumber: $microchipNumber, ')
          ..write('earTagId: $earTagId, ')
          ..write('coatColorMarkings: $coatColorMarkings, ')
          ..write('currentWeightKg: $currentWeightKg, ')
          ..write('weightRecordedAt: $weightRecordedAt, ')
          ..write('history: $history, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('deceasedAt: $deceasedAt, ')
          ..write('allergies: $allergies, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        tenantId,
        clientId,
        nameOrTag,
        species,
        breed,
        gender,
        age,
        dateOfBirth,
        isApproximateAge,
        microchipNumber,
        earTagId,
        coatColorMarkings,
        currentWeightKg,
        weightRecordedAt,
        history,
        notes,
        status,
        deceasedAt,
        allergies,
        createdAt,
        updatedAt,
        deletedAt,
        syncStatus,
        lastSyncedAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PatientData &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.clientId == this.clientId &&
          other.nameOrTag == this.nameOrTag &&
          other.species == this.species &&
          other.breed == this.breed &&
          other.gender == this.gender &&
          other.age == this.age &&
          other.dateOfBirth == this.dateOfBirth &&
          other.isApproximateAge == this.isApproximateAge &&
          other.microchipNumber == this.microchipNumber &&
          other.earTagId == this.earTagId &&
          other.coatColorMarkings == this.coatColorMarkings &&
          other.currentWeightKg == this.currentWeightKg &&
          other.weightRecordedAt == this.weightRecordedAt &&
          other.history == this.history &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.deceasedAt == this.deceasedAt &&
          other.allergies == this.allergies &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class PatientsTableCompanion extends UpdateCompanion<PatientData> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> clientId;
  final Value<String> nameOrTag;
  final Value<String> species;
  final Value<String?> breed;
  final Value<String> gender;
  final Value<int?> age;
  final Value<DateTime?> dateOfBirth;
  final Value<bool> isApproximateAge;
  final Value<String?> microchipNumber;
  final Value<String?> earTagId;
  final Value<String?> coatColorMarkings;
  final Value<double?> currentWeightKg;
  final Value<DateTime?> weightRecordedAt;
  final Value<String?> history;
  final Value<String?> notes;
  final Value<String> status;
  final Value<DateTime?> deceasedAt;
  final Value<String?> allergies;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const PatientsTableCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.clientId = const Value.absent(),
    this.nameOrTag = const Value.absent(),
    this.species = const Value.absent(),
    this.breed = const Value.absent(),
    this.gender = const Value.absent(),
    this.age = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.isApproximateAge = const Value.absent(),
    this.microchipNumber = const Value.absent(),
    this.earTagId = const Value.absent(),
    this.coatColorMarkings = const Value.absent(),
    this.currentWeightKg = const Value.absent(),
    this.weightRecordedAt = const Value.absent(),
    this.history = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.deceasedAt = const Value.absent(),
    this.allergies = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsTableCompanion.insert({
    required String id,
    required String tenantId,
    required String clientId,
    required String nameOrTag,
    required String species,
    this.breed = const Value.absent(),
    this.gender = const Value.absent(),
    this.age = const Value.absent(),
    this.dateOfBirth = const Value.absent(),
    this.isApproximateAge = const Value.absent(),
    this.microchipNumber = const Value.absent(),
    this.earTagId = const Value.absent(),
    this.coatColorMarkings = const Value.absent(),
    this.currentWeightKg = const Value.absent(),
    this.weightRecordedAt = const Value.absent(),
    this.history = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.deceasedAt = const Value.absent(),
    this.allergies = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        clientId = Value(clientId),
        nameOrTag = Value(nameOrTag),
        species = Value(species),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<PatientData> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? clientId,
    Expression<String>? nameOrTag,
    Expression<String>? species,
    Expression<String>? breed,
    Expression<String>? gender,
    Expression<int>? age,
    Expression<DateTime>? dateOfBirth,
    Expression<bool>? isApproximateAge,
    Expression<String>? microchipNumber,
    Expression<String>? earTagId,
    Expression<String>? coatColorMarkings,
    Expression<double>? currentWeightKg,
    Expression<DateTime>? weightRecordedAt,
    Expression<String>? history,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<DateTime>? deceasedAt,
    Expression<String>? allergies,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (clientId != null) 'client_id': clientId,
      if (nameOrTag != null) 'name_or_tag': nameOrTag,
      if (species != null) 'species': species,
      if (breed != null) 'breed': breed,
      if (gender != null) 'gender': gender,
      if (age != null) 'age': age,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (isApproximateAge != null) 'is_approximate_age': isApproximateAge,
      if (microchipNumber != null) 'microchip_number': microchipNumber,
      if (earTagId != null) 'ear_tag_id': earTagId,
      if (coatColorMarkings != null) 'coat_color_markings': coatColorMarkings,
      if (currentWeightKg != null) 'current_weight_kg': currentWeightKg,
      if (weightRecordedAt != null) 'weight_recorded_at': weightRecordedAt,
      if (history != null) 'history': history,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (deceasedAt != null) 'deceased_at': deceasedAt,
      if (allergies != null) 'allergies': allergies,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? clientId,
      Value<String>? nameOrTag,
      Value<String>? species,
      Value<String?>? breed,
      Value<String>? gender,
      Value<int?>? age,
      Value<DateTime?>? dateOfBirth,
      Value<bool>? isApproximateAge,
      Value<String?>? microchipNumber,
      Value<String?>? earTagId,
      Value<String?>? coatColorMarkings,
      Value<double?>? currentWeightKg,
      Value<DateTime?>? weightRecordedAt,
      Value<String?>? history,
      Value<String?>? notes,
      Value<String>? status,
      Value<DateTime?>? deceasedAt,
      Value<String?>? allergies,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return PatientsTableCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      clientId: clientId ?? this.clientId,
      nameOrTag: nameOrTag ?? this.nameOrTag,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isApproximateAge: isApproximateAge ?? this.isApproximateAge,
      microchipNumber: microchipNumber ?? this.microchipNumber,
      earTagId: earTagId ?? this.earTagId,
      coatColorMarkings: coatColorMarkings ?? this.coatColorMarkings,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      weightRecordedAt: weightRecordedAt ?? this.weightRecordedAt,
      history: history ?? this.history,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      deceasedAt: deceasedAt ?? this.deceasedAt,
      allergies: allergies ?? this.allergies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (nameOrTag.present) {
      map['name_or_tag'] = Variable<String>(nameOrTag.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (breed.present) {
      map['breed'] = Variable<String>(breed.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (dateOfBirth.present) {
      map['date_of_birth'] = Variable<DateTime>(dateOfBirth.value);
    }
    if (isApproximateAge.present) {
      map['is_approximate_age'] = Variable<bool>(isApproximateAge.value);
    }
    if (microchipNumber.present) {
      map['microchip_number'] = Variable<String>(microchipNumber.value);
    }
    if (earTagId.present) {
      map['ear_tag_id'] = Variable<String>(earTagId.value);
    }
    if (coatColorMarkings.present) {
      map['coat_color_markings'] = Variable<String>(coatColorMarkings.value);
    }
    if (currentWeightKg.present) {
      map['current_weight_kg'] = Variable<double>(currentWeightKg.value);
    }
    if (weightRecordedAt.present) {
      map['weight_recorded_at'] = Variable<DateTime>(weightRecordedAt.value);
    }
    if (history.present) {
      map['history'] = Variable<String>(history.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deceasedAt.present) {
      map['deceased_at'] = Variable<DateTime>(deceasedAt.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(allergies.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PatientsTableCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('clientId: $clientId, ')
          ..write('nameOrTag: $nameOrTag, ')
          ..write('species: $species, ')
          ..write('breed: $breed, ')
          ..write('gender: $gender, ')
          ..write('age: $age, ')
          ..write('dateOfBirth: $dateOfBirth, ')
          ..write('isApproximateAge: $isApproximateAge, ')
          ..write('microchipNumber: $microchipNumber, ')
          ..write('earTagId: $earTagId, ')
          ..write('coatColorMarkings: $coatColorMarkings, ')
          ..write('currentWeightKg: $currentWeightKg, ')
          ..write('weightRecordedAt: $weightRecordedAt, ')
          ..write('history: $history, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('deceasedAt: $deceasedAt, ')
          ..write('allergies: $allergies, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClinicalCasesTableTable extends ClinicalCasesTable
    with TableInfo<$ClinicalCasesTableTable, ClinicalCaseData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClinicalCasesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caseNumberMeta =
      const VerificationMeta('caseNumber');
  @override
  late final GeneratedColumn<String> caseNumber = GeneratedColumn<String>(
      'case_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 32),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES patients (id)'));
  static const VerificationMeta _primaryVeterinarianIdMeta =
      const VerificationMeta('primaryVeterinarianId');
  @override
  late final GeneratedColumn<String> primaryVeterinarianId =
      GeneratedColumn<String>('primary_veterinarian_id', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _primaryVeterinarianNameMeta =
      const VerificationMeta('primaryVeterinarianName');
  @override
  late final GeneratedColumn<String> primaryVeterinarianName =
      GeneratedColumn<String>('primary_veterinarian_name', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _caseTypeMeta =
      const VerificationMeta('caseType');
  @override
  late final GeneratedColumn<String> caseType = GeneratedColumn<String>(
      'case_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('outpatient'));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('open'));
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('routine'));
  static const VerificationMeta _chiefComplaintMeta =
      const VerificationMeta('chiefComplaint');
  @override
  late final GeneratedColumn<String> chiefComplaint = GeneratedColumn<String>(
      'chief_complaint', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _provisionalDiagnosisMeta =
      const VerificationMeta('provisionalDiagnosis');
  @override
  late final GeneratedColumn<String> provisionalDiagnosis =
      GeneratedColumn<String>('provisional_diagnosis', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _finalDiagnosisMeta =
      const VerificationMeta('finalDiagnosis');
  @override
  late final GeneratedColumn<String> finalDiagnosis = GeneratedColumn<String>(
      'final_diagnosis', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _admittedAtMeta =
      const VerificationMeta('admittedAt');
  @override
  late final GeneratedColumn<DateTime> admittedAt = GeneratedColumn<DateTime>(
      'admitted_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dischargedAtMeta =
      const VerificationMeta('dischargedAt');
  @override
  late final GeneratedColumn<DateTime> dischargedAt = GeneratedColumn<DateTime>(
      'discharged_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _deletedAtMeta =
      const VerificationMeta('deletedAt');
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
      'deleted_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  static const VerificationMeta _lastSyncedAtMeta =
      const VerificationMeta('lastSyncedAt');
  @override
  late final GeneratedColumn<DateTime> lastSyncedAt = GeneratedColumn<DateTime>(
      'last_synced_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        caseNumber,
        patientId,
        primaryVeterinarianId,
        primaryVeterinarianName,
        caseType,
        status,
        priority,
        chiefComplaint,
        provisionalDiagnosis,
        finalDiagnosis,
        admittedAt,
        dischargedAt,
        createdAt,
        updatedAt,
        deletedAt,
        syncStatus,
        lastSyncedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cases';
  @override
  VerificationContext validateIntegrity(Insertable<ClinicalCaseData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('case_number')) {
      context.handle(
          _caseNumberMeta,
          caseNumber.isAcceptableOrUnknown(
              data['case_number']!, _caseNumberMeta));
    } else if (isInserting) {
      context.missing(_caseNumberMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('primary_veterinarian_id')) {
      context.handle(
          _primaryVeterinarianIdMeta,
          primaryVeterinarianId.isAcceptableOrUnknown(
              data['primary_veterinarian_id']!, _primaryVeterinarianIdMeta));
    } else if (isInserting) {
      context.missing(_primaryVeterinarianIdMeta);
    }
    if (data.containsKey('primary_veterinarian_name')) {
      context.handle(
          _primaryVeterinarianNameMeta,
          primaryVeterinarianName.isAcceptableOrUnknown(
              data['primary_veterinarian_name']!,
              _primaryVeterinarianNameMeta));
    }
    if (data.containsKey('case_type')) {
      context.handle(_caseTypeMeta,
          caseType.isAcceptableOrUnknown(data['case_type']!, _caseTypeMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('chief_complaint')) {
      context.handle(
          _chiefComplaintMeta,
          chiefComplaint.isAcceptableOrUnknown(
              data['chief_complaint']!, _chiefComplaintMeta));
    } else if (isInserting) {
      context.missing(_chiefComplaintMeta);
    }
    if (data.containsKey('provisional_diagnosis')) {
      context.handle(
          _provisionalDiagnosisMeta,
          provisionalDiagnosis.isAcceptableOrUnknown(
              data['provisional_diagnosis']!, _provisionalDiagnosisMeta));
    }
    if (data.containsKey('final_diagnosis')) {
      context.handle(
          _finalDiagnosisMeta,
          finalDiagnosis.isAcceptableOrUnknown(
              data['final_diagnosis']!, _finalDiagnosisMeta));
    }
    if (data.containsKey('admitted_at')) {
      context.handle(
          _admittedAtMeta,
          admittedAt.isAcceptableOrUnknown(
              data['admitted_at']!, _admittedAtMeta));
    } else if (isInserting) {
      context.missing(_admittedAtMeta);
    }
    if (data.containsKey('discharged_at')) {
      context.handle(
          _dischargedAtMeta,
          dischargedAt.isAcceptableOrUnknown(
              data['discharged_at']!, _dischargedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(_deletedAtMeta,
          deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
          _lastSyncedAtMeta,
          lastSyncedAt.isAcceptableOrUnknown(
              data['last_synced_at']!, _lastSyncedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClinicalCaseData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClinicalCaseData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      caseNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_number'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      primaryVeterinarianId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}primary_veterinarian_id'])!,
      primaryVeterinarianName: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}primary_veterinarian_name']),
      caseType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_type'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      chiefComplaint: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}chief_complaint'])!,
      provisionalDiagnosis: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}provisional_diagnosis']),
      finalDiagnosis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}final_diagnosis']),
      admittedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}admitted_at'])!,
      dischargedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}discharged_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      deletedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deleted_at']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_synced_at']),
    );
  }

  @override
  $ClinicalCasesTableTable createAlias(String alias) {
    return $ClinicalCasesTableTable(attachedDatabase, alias);
  }
}

class ClinicalCaseData extends DataClass
    implements Insertable<ClinicalCaseData> {
  /// Primary UUID identifier
  final String id;

  /// Practice tenant isolation identifier
  final String tenantId;

  /// Human-readable encounter code (e.g., CAS-2026-0042)
  final String caseNumber;

  /// Foreign key linking encounter to animal patient
  final String patientId;

  /// Assigned veterinarian identifier
  final String primaryVeterinarianId;

  /// Cached veterinarian display name for immediate offline rendering
  final String? primaryVeterinarianName;

  /// Encounter workflow type: outpatient, inpatient, emergency, surgery, herd_check, telemedicine
  final String caseType;

  /// Clinical lifecycle status: open, in_progress, under_observation, awaiting_lab, pending_discharge, closed
  final String status;

  /// Triage severity level: routine, urgent, critical
  final String priority;

  /// Chief complaint presented by owner upon arrival
  final String chiefComplaint;

  /// Working diagnostic hypothesis
  final String? provisionalDiagnosis;

  /// Confirmed post-investigation diagnosis
  final String? finalDiagnosis;

  /// Admission date & time
  final DateTime admittedAt;

  /// Discharge date & time (null if still admitted)
  final DateTime? dischargedAt;

  /// Creation timestamp
  final DateTime createdAt;

  /// Modification timestamp
  final DateTime updatedAt;

  /// Soft deletion timestamp
  final DateTime? deletedAt;

  /// Offline synchronization lifecycle: synced, pending_create, pending_update, pending_delete
  final String syncStatus;

  /// Last server sync timestamp
  final DateTime? lastSyncedAt;
  const ClinicalCaseData(
      {required this.id,
      required this.tenantId,
      required this.caseNumber,
      required this.patientId,
      required this.primaryVeterinarianId,
      this.primaryVeterinarianName,
      required this.caseType,
      required this.status,
      required this.priority,
      required this.chiefComplaint,
      this.provisionalDiagnosis,
      this.finalDiagnosis,
      required this.admittedAt,
      this.dischargedAt,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      required this.syncStatus,
      this.lastSyncedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['case_number'] = Variable<String>(caseNumber);
    map['patient_id'] = Variable<String>(patientId);
    map['primary_veterinarian_id'] = Variable<String>(primaryVeterinarianId);
    if (!nullToAbsent || primaryVeterinarianName != null) {
      map['primary_veterinarian_name'] =
          Variable<String>(primaryVeterinarianName);
    }
    map['case_type'] = Variable<String>(caseType);
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<String>(priority);
    map['chief_complaint'] = Variable<String>(chiefComplaint);
    if (!nullToAbsent || provisionalDiagnosis != null) {
      map['provisional_diagnosis'] = Variable<String>(provisionalDiagnosis);
    }
    if (!nullToAbsent || finalDiagnosis != null) {
      map['final_diagnosis'] = Variable<String>(finalDiagnosis);
    }
    map['admitted_at'] = Variable<DateTime>(admittedAt);
    if (!nullToAbsent || dischargedAt != null) {
      map['discharged_at'] = Variable<DateTime>(dischargedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt);
    }
    return map;
  }

  ClinicalCasesTableCompanion toCompanion(bool nullToAbsent) {
    return ClinicalCasesTableCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      caseNumber: Value(caseNumber),
      patientId: Value(patientId),
      primaryVeterinarianId: Value(primaryVeterinarianId),
      primaryVeterinarianName: primaryVeterinarianName == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryVeterinarianName),
      caseType: Value(caseType),
      status: Value(status),
      priority: Value(priority),
      chiefComplaint: Value(chiefComplaint),
      provisionalDiagnosis: provisionalDiagnosis == null && nullToAbsent
          ? const Value.absent()
          : Value(provisionalDiagnosis),
      finalDiagnosis: finalDiagnosis == null && nullToAbsent
          ? const Value.absent()
          : Value(finalDiagnosis),
      admittedAt: Value(admittedAt),
      dischargedAt: dischargedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dischargedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory ClinicalCaseData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClinicalCaseData(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      caseNumber: serializer.fromJson<String>(json['caseNumber']),
      patientId: serializer.fromJson<String>(json['patientId']),
      primaryVeterinarianId:
          serializer.fromJson<String>(json['primaryVeterinarianId']),
      primaryVeterinarianName:
          serializer.fromJson<String?>(json['primaryVeterinarianName']),
      caseType: serializer.fromJson<String>(json['caseType']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<String>(json['priority']),
      chiefComplaint: serializer.fromJson<String>(json['chiefComplaint']),
      provisionalDiagnosis:
          serializer.fromJson<String?>(json['provisionalDiagnosis']),
      finalDiagnosis: serializer.fromJson<String?>(json['finalDiagnosis']),
      admittedAt: serializer.fromJson<DateTime>(json['admittedAt']),
      dischargedAt: serializer.fromJson<DateTime?>(json['dischargedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      lastSyncedAt: serializer.fromJson<DateTime?>(json['lastSyncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'caseNumber': serializer.toJson<String>(caseNumber),
      'patientId': serializer.toJson<String>(patientId),
      'primaryVeterinarianId': serializer.toJson<String>(primaryVeterinarianId),
      'primaryVeterinarianName':
          serializer.toJson<String?>(primaryVeterinarianName),
      'caseType': serializer.toJson<String>(caseType),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<String>(priority),
      'chiefComplaint': serializer.toJson<String>(chiefComplaint),
      'provisionalDiagnosis': serializer.toJson<String?>(provisionalDiagnosis),
      'finalDiagnosis': serializer.toJson<String?>(finalDiagnosis),
      'admittedAt': serializer.toJson<DateTime>(admittedAt),
      'dischargedAt': serializer.toJson<DateTime?>(dischargedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'lastSyncedAt': serializer.toJson<DateTime?>(lastSyncedAt),
    };
  }

  ClinicalCaseData copyWith(
          {String? id,
          String? tenantId,
          String? caseNumber,
          String? patientId,
          String? primaryVeterinarianId,
          Value<String?> primaryVeterinarianName = const Value.absent(),
          String? caseType,
          String? status,
          String? priority,
          String? chiefComplaint,
          Value<String?> provisionalDiagnosis = const Value.absent(),
          Value<String?> finalDiagnosis = const Value.absent(),
          DateTime? admittedAt,
          Value<DateTime?> dischargedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt,
          Value<DateTime?> deletedAt = const Value.absent(),
          String? syncStatus,
          Value<DateTime?> lastSyncedAt = const Value.absent()}) =>
      ClinicalCaseData(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        caseNumber: caseNumber ?? this.caseNumber,
        patientId: patientId ?? this.patientId,
        primaryVeterinarianId:
            primaryVeterinarianId ?? this.primaryVeterinarianId,
        primaryVeterinarianName: primaryVeterinarianName.present
            ? primaryVeterinarianName.value
            : this.primaryVeterinarianName,
        caseType: caseType ?? this.caseType,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        chiefComplaint: chiefComplaint ?? this.chiefComplaint,
        provisionalDiagnosis: provisionalDiagnosis.present
            ? provisionalDiagnosis.value
            : this.provisionalDiagnosis,
        finalDiagnosis:
            finalDiagnosis.present ? finalDiagnosis.value : this.finalDiagnosis,
        admittedAt: admittedAt ?? this.admittedAt,
        dischargedAt:
            dischargedAt.present ? dischargedAt.value : this.dischargedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt:
            lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
      );
  ClinicalCaseData copyWithCompanion(ClinicalCasesTableCompanion data) {
    return ClinicalCaseData(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      caseNumber:
          data.caseNumber.present ? data.caseNumber.value : this.caseNumber,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      primaryVeterinarianId: data.primaryVeterinarianId.present
          ? data.primaryVeterinarianId.value
          : this.primaryVeterinarianId,
      primaryVeterinarianName: data.primaryVeterinarianName.present
          ? data.primaryVeterinarianName.value
          : this.primaryVeterinarianName,
      caseType: data.caseType.present ? data.caseType.value : this.caseType,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      chiefComplaint: data.chiefComplaint.present
          ? data.chiefComplaint.value
          : this.chiefComplaint,
      provisionalDiagnosis: data.provisionalDiagnosis.present
          ? data.provisionalDiagnosis.value
          : this.provisionalDiagnosis,
      finalDiagnosis: data.finalDiagnosis.present
          ? data.finalDiagnosis.value
          : this.finalDiagnosis,
      admittedAt:
          data.admittedAt.present ? data.admittedAt.value : this.admittedAt,
      dischargedAt: data.dischargedAt.present
          ? data.dischargedAt.value
          : this.dischargedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalCaseData(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('caseNumber: $caseNumber, ')
          ..write('patientId: $patientId, ')
          ..write('primaryVeterinarianId: $primaryVeterinarianId, ')
          ..write('primaryVeterinarianName: $primaryVeterinarianName, ')
          ..write('caseType: $caseType, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('provisionalDiagnosis: $provisionalDiagnosis, ')
          ..write('finalDiagnosis: $finalDiagnosis, ')
          ..write('admittedAt: $admittedAt, ')
          ..write('dischargedAt: $dischargedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tenantId,
      caseNumber,
      patientId,
      primaryVeterinarianId,
      primaryVeterinarianName,
      caseType,
      status,
      priority,
      chiefComplaint,
      provisionalDiagnosis,
      finalDiagnosis,
      admittedAt,
      dischargedAt,
      createdAt,
      updatedAt,
      deletedAt,
      syncStatus,
      lastSyncedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClinicalCaseData &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.caseNumber == this.caseNumber &&
          other.patientId == this.patientId &&
          other.primaryVeterinarianId == this.primaryVeterinarianId &&
          other.primaryVeterinarianName == this.primaryVeterinarianName &&
          other.caseType == this.caseType &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.chiefComplaint == this.chiefComplaint &&
          other.provisionalDiagnosis == this.provisionalDiagnosis &&
          other.finalDiagnosis == this.finalDiagnosis &&
          other.admittedAt == this.admittedAt &&
          other.dischargedAt == this.dischargedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class ClinicalCasesTableCompanion extends UpdateCompanion<ClinicalCaseData> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> caseNumber;
  final Value<String> patientId;
  final Value<String> primaryVeterinarianId;
  final Value<String?> primaryVeterinarianName;
  final Value<String> caseType;
  final Value<String> status;
  final Value<String> priority;
  final Value<String> chiefComplaint;
  final Value<String?> provisionalDiagnosis;
  final Value<String?> finalDiagnosis;
  final Value<DateTime> admittedAt;
  final Value<DateTime?> dischargedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> syncStatus;
  final Value<DateTime?> lastSyncedAt;
  final Value<int> rowid;
  const ClinicalCasesTableCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.caseNumber = const Value.absent(),
    this.patientId = const Value.absent(),
    this.primaryVeterinarianId = const Value.absent(),
    this.primaryVeterinarianName = const Value.absent(),
    this.caseType = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.provisionalDiagnosis = const Value.absent(),
    this.finalDiagnosis = const Value.absent(),
    this.admittedAt = const Value.absent(),
    this.dischargedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClinicalCasesTableCompanion.insert({
    required String id,
    required String tenantId,
    required String caseNumber,
    required String patientId,
    required String primaryVeterinarianId,
    this.primaryVeterinarianName = const Value.absent(),
    this.caseType = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    required String chiefComplaint,
    this.provisionalDiagnosis = const Value.absent(),
    this.finalDiagnosis = const Value.absent(),
    required DateTime admittedAt,
    this.dischargedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        caseNumber = Value(caseNumber),
        patientId = Value(patientId),
        primaryVeterinarianId = Value(primaryVeterinarianId),
        chiefComplaint = Value(chiefComplaint),
        admittedAt = Value(admittedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ClinicalCaseData> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? caseNumber,
    Expression<String>? patientId,
    Expression<String>? primaryVeterinarianId,
    Expression<String>? primaryVeterinarianName,
    Expression<String>? caseType,
    Expression<String>? status,
    Expression<String>? priority,
    Expression<String>? chiefComplaint,
    Expression<String>? provisionalDiagnosis,
    Expression<String>? finalDiagnosis,
    Expression<DateTime>? admittedAt,
    Expression<DateTime>? dischargedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (caseNumber != null) 'case_number': caseNumber,
      if (patientId != null) 'patient_id': patientId,
      if (primaryVeterinarianId != null)
        'primary_veterinarian_id': primaryVeterinarianId,
      if (primaryVeterinarianName != null)
        'primary_veterinarian_name': primaryVeterinarianName,
      if (caseType != null) 'case_type': caseType,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (chiefComplaint != null) 'chief_complaint': chiefComplaint,
      if (provisionalDiagnosis != null)
        'provisional_diagnosis': provisionalDiagnosis,
      if (finalDiagnosis != null) 'final_diagnosis': finalDiagnosis,
      if (admittedAt != null) 'admitted_at': admittedAt,
      if (dischargedAt != null) 'discharged_at': dischargedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClinicalCasesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? caseNumber,
      Value<String>? patientId,
      Value<String>? primaryVeterinarianId,
      Value<String?>? primaryVeterinarianName,
      Value<String>? caseType,
      Value<String>? status,
      Value<String>? priority,
      Value<String>? chiefComplaint,
      Value<String?>? provisionalDiagnosis,
      Value<String?>? finalDiagnosis,
      Value<DateTime>? admittedAt,
      Value<DateTime?>? dischargedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<DateTime?>? deletedAt,
      Value<String>? syncStatus,
      Value<DateTime?>? lastSyncedAt,
      Value<int>? rowid}) {
    return ClinicalCasesTableCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      caseNumber: caseNumber ?? this.caseNumber,
      patientId: patientId ?? this.patientId,
      primaryVeterinarianId:
          primaryVeterinarianId ?? this.primaryVeterinarianId,
      primaryVeterinarianName:
          primaryVeterinarianName ?? this.primaryVeterinarianName,
      caseType: caseType ?? this.caseType,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      provisionalDiagnosis: provisionalDiagnosis ?? this.provisionalDiagnosis,
      finalDiagnosis: finalDiagnosis ?? this.finalDiagnosis,
      admittedAt: admittedAt ?? this.admittedAt,
      dischargedAt: dischargedAt ?? this.dischargedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (caseNumber.present) {
      map['case_number'] = Variable<String>(caseNumber.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (primaryVeterinarianId.present) {
      map['primary_veterinarian_id'] =
          Variable<String>(primaryVeterinarianId.value);
    }
    if (primaryVeterinarianName.present) {
      map['primary_veterinarian_name'] =
          Variable<String>(primaryVeterinarianName.value);
    }
    if (caseType.present) {
      map['case_type'] = Variable<String>(caseType.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (chiefComplaint.present) {
      map['chief_complaint'] = Variable<String>(chiefComplaint.value);
    }
    if (provisionalDiagnosis.present) {
      map['provisional_diagnosis'] =
          Variable<String>(provisionalDiagnosis.value);
    }
    if (finalDiagnosis.present) {
      map['final_diagnosis'] = Variable<String>(finalDiagnosis.value);
    }
    if (admittedAt.present) {
      map['admitted_at'] = Variable<DateTime>(admittedAt.value);
    }
    if (dischargedAt.present) {
      map['discharged_at'] = Variable<DateTime>(dischargedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<DateTime>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalCasesTableCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('caseNumber: $caseNumber, ')
          ..write('patientId: $patientId, ')
          ..write('primaryVeterinarianId: $primaryVeterinarianId, ')
          ..write('primaryVeterinarianName: $primaryVeterinarianName, ')
          ..write('caseType: $caseType, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('provisionalDiagnosis: $provisionalDiagnosis, ')
          ..write('finalDiagnosis: $finalDiagnosis, ')
          ..write('admittedAt: $admittedAt, ')
          ..write('dischargedAt: $dischargedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClinicalProgressNotesTableTable extends ClinicalProgressNotesTable
    with TableInfo<$ClinicalProgressNotesTableTable, ClinicalProgressNoteData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClinicalProgressNotesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
      'case_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES cases (id)'));
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _veterinarianIdMeta =
      const VerificationMeta('veterinarianId');
  @override
  late final GeneratedColumn<String> veterinarianId = GeneratedColumn<String>(
      'veterinarian_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _veterinarianNameMeta =
      const VerificationMeta('veterinarianName');
  @override
  late final GeneratedColumn<String> veterinarianName = GeneratedColumn<String>(
      'veterinarian_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteTypeMeta =
      const VerificationMeta('noteType');
  @override
  late final GeneratedColumn<String> noteType = GeneratedColumn<String>(
      'note_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('soap'));
  static const VerificationMeta _subjectiveMeta =
      const VerificationMeta('subjective');
  @override
  late final GeneratedColumn<String> subjective = GeneratedColumn<String>(
      'subjective', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _objectiveMeta =
      const VerificationMeta('objective');
  @override
  late final GeneratedColumn<String> objective = GeneratedColumn<String>(
      'objective', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _assessmentMeta =
      const VerificationMeta('assessment');
  @override
  late final GeneratedColumn<String> assessment = GeneratedColumn<String>(
      'assessment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _planMeta = const VerificationMeta('plan');
  @override
  late final GeneratedColumn<String> plan = GeneratedColumn<String>(
      'plan', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _temperatureCelsiusMeta =
      const VerificationMeta('temperatureCelsius');
  @override
  late final GeneratedColumn<double> temperatureCelsius =
      GeneratedColumn<double>('temperature_celsius', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _heartRateBpmMeta =
      const VerificationMeta('heartRateBpm');
  @override
  late final GeneratedColumn<int> heartRateBpm = GeneratedColumn<int>(
      'heart_rate_bpm', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _respiratoryRateBpmMeta =
      const VerificationMeta('respiratoryRateBpm');
  @override
  late final GeneratedColumn<int> respiratoryRateBpm = GeneratedColumn<int>(
      'respiratory_rate_bpm', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bodyConditionScoreMeta =
      const VerificationMeta('bodyConditionScore');
  @override
  late final GeneratedColumn<int> bodyConditionScore = GeneratedColumn<int>(
      'body_condition_score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _painScoreMeta =
      const VerificationMeta('painScore');
  @override
  late final GeneratedColumn<int> painScore = GeneratedColumn<int>(
      'pain_score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _recordedAtMeta =
      const VerificationMeta('recordedAt');
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
      'recorded_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        caseId,
        patientId,
        veterinarianId,
        veterinarianName,
        noteType,
        subjective,
        objective,
        assessment,
        plan,
        temperatureCelsius,
        heartRateBpm,
        respiratoryRateBpm,
        bodyConditionScore,
        painScore,
        recordedAt,
        createdAt,
        updatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clinical_progress_notes';
  @override
  VerificationContext validateIntegrity(
      Insertable<ClinicalProgressNoteData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('case_id')) {
      context.handle(_caseIdMeta,
          caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta));
    } else if (isInserting) {
      context.missing(_caseIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('veterinarian_id')) {
      context.handle(
          _veterinarianIdMeta,
          veterinarianId.isAcceptableOrUnknown(
              data['veterinarian_id']!, _veterinarianIdMeta));
    } else if (isInserting) {
      context.missing(_veterinarianIdMeta);
    }
    if (data.containsKey('veterinarian_name')) {
      context.handle(
          _veterinarianNameMeta,
          veterinarianName.isAcceptableOrUnknown(
              data['veterinarian_name']!, _veterinarianNameMeta));
    } else if (isInserting) {
      context.missing(_veterinarianNameMeta);
    }
    if (data.containsKey('note_type')) {
      context.handle(_noteTypeMeta,
          noteType.isAcceptableOrUnknown(data['note_type']!, _noteTypeMeta));
    }
    if (data.containsKey('subjective')) {
      context.handle(
          _subjectiveMeta,
          subjective.isAcceptableOrUnknown(
              data['subjective']!, _subjectiveMeta));
    }
    if (data.containsKey('objective')) {
      context.handle(_objectiveMeta,
          objective.isAcceptableOrUnknown(data['objective']!, _objectiveMeta));
    }
    if (data.containsKey('assessment')) {
      context.handle(
          _assessmentMeta,
          assessment.isAcceptableOrUnknown(
              data['assessment']!, _assessmentMeta));
    }
    if (data.containsKey('plan')) {
      context.handle(
          _planMeta, plan.isAcceptableOrUnknown(data['plan']!, _planMeta));
    }
    if (data.containsKey('temperature_celsius')) {
      context.handle(
          _temperatureCelsiusMeta,
          temperatureCelsius.isAcceptableOrUnknown(
              data['temperature_celsius']!, _temperatureCelsiusMeta));
    }
    if (data.containsKey('heart_rate_bpm')) {
      context.handle(
          _heartRateBpmMeta,
          heartRateBpm.isAcceptableOrUnknown(
              data['heart_rate_bpm']!, _heartRateBpmMeta));
    }
    if (data.containsKey('respiratory_rate_bpm')) {
      context.handle(
          _respiratoryRateBpmMeta,
          respiratoryRateBpm.isAcceptableOrUnknown(
              data['respiratory_rate_bpm']!, _respiratoryRateBpmMeta));
    }
    if (data.containsKey('body_condition_score')) {
      context.handle(
          _bodyConditionScoreMeta,
          bodyConditionScore.isAcceptableOrUnknown(
              data['body_condition_score']!, _bodyConditionScoreMeta));
    }
    if (data.containsKey('pain_score')) {
      context.handle(_painScoreMeta,
          painScore.isAcceptableOrUnknown(data['pain_score']!, _painScoreMeta));
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
          _recordedAtMeta,
          recordedAt.isAcceptableOrUnknown(
              data['recorded_at']!, _recordedAtMeta));
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClinicalProgressNoteData map(Map<String, dynamic> data,
      {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClinicalProgressNoteData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      caseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_id'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      veterinarianId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}veterinarian_id'])!,
      veterinarianName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}veterinarian_name'])!,
      noteType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note_type'])!,
      subjective: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subjective']),
      objective: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}objective']),
      assessment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}assessment']),
      plan: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan']),
      temperatureCelsius: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}temperature_celsius']),
      heartRateBpm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}heart_rate_bpm']),
      respiratoryRateBpm: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}respiratory_rate_bpm']),
      bodyConditionScore: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}body_condition_score']),
      painScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pain_score']),
      recordedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}recorded_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $ClinicalProgressNotesTableTable createAlias(String alias) {
    return $ClinicalProgressNotesTableTable(attachedDatabase, alias);
  }
}

class ClinicalProgressNoteData extends DataClass
    implements Insertable<ClinicalProgressNoteData> {
  /// Primary UUID identifier
  final String id;

  /// Foreign key linking note to clinical encounter
  final String caseId;

  /// Patient identifier
  final String patientId;

  /// Authoring clinician or veterinary nurse identifier
  final String veterinarianId;

  /// Clinician display name
  final String veterinarianName;

  /// Note category: soap, nursing_log, discharge_summary, addendum
  final String noteType;

  /// SOAP (S): Owner observations, demeanor, appetite, vomiting/diarrhea history
  final String? subjective;

  /// SOAP (O): Clinical examination findings, physical palpation
  final String? objective;

  /// SOAP (A): Clinical interpretation & differential diagnosis
  final String? assessment;

  /// SOAP (P): Treatment protocols, surgical plan, prescriptions
  final String? plan;

  /// Objective Vital: Rectal temperature in degrees Celsius (e.g. 38.5)
  final double? temperatureCelsius;

  /// Objective Vital: Heart rate in beats per minute
  final int? heartRateBpm;

  /// Objective Vital: Respiratory rate in breaths per minute
  final int? respiratoryRateBpm;

  /// Body Condition Score (1 to 9 Purina scale)
  final int? bodyConditionScore;

  /// Colorado State University Acute Pain Scale (0 to 4)
  final int? painScore;

  /// Timestamp when clinical examination was performed
  final DateTime recordedAt;

  /// Creation timestamp
  final DateTime createdAt;

  /// Modification timestamp
  final DateTime updatedAt;

  /// Offline synchronization lifecycle: synced, pending_create, pending_update, pending_delete
  final String syncStatus;
  const ClinicalProgressNoteData(
      {required this.id,
      required this.caseId,
      required this.patientId,
      required this.veterinarianId,
      required this.veterinarianName,
      required this.noteType,
      this.subjective,
      this.objective,
      this.assessment,
      this.plan,
      this.temperatureCelsius,
      this.heartRateBpm,
      this.respiratoryRateBpm,
      this.bodyConditionScore,
      this.painScore,
      required this.recordedAt,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['case_id'] = Variable<String>(caseId);
    map['patient_id'] = Variable<String>(patientId);
    map['veterinarian_id'] = Variable<String>(veterinarianId);
    map['veterinarian_name'] = Variable<String>(veterinarianName);
    map['note_type'] = Variable<String>(noteType);
    if (!nullToAbsent || subjective != null) {
      map['subjective'] = Variable<String>(subjective);
    }
    if (!nullToAbsent || objective != null) {
      map['objective'] = Variable<String>(objective);
    }
    if (!nullToAbsent || assessment != null) {
      map['assessment'] = Variable<String>(assessment);
    }
    if (!nullToAbsent || plan != null) {
      map['plan'] = Variable<String>(plan);
    }
    if (!nullToAbsent || temperatureCelsius != null) {
      map['temperature_celsius'] = Variable<double>(temperatureCelsius);
    }
    if (!nullToAbsent || heartRateBpm != null) {
      map['heart_rate_bpm'] = Variable<int>(heartRateBpm);
    }
    if (!nullToAbsent || respiratoryRateBpm != null) {
      map['respiratory_rate_bpm'] = Variable<int>(respiratoryRateBpm);
    }
    if (!nullToAbsent || bodyConditionScore != null) {
      map['body_condition_score'] = Variable<int>(bodyConditionScore);
    }
    if (!nullToAbsent || painScore != null) {
      map['pain_score'] = Variable<int>(painScore);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ClinicalProgressNotesTableCompanion toCompanion(bool nullToAbsent) {
    return ClinicalProgressNotesTableCompanion(
      id: Value(id),
      caseId: Value(caseId),
      patientId: Value(patientId),
      veterinarianId: Value(veterinarianId),
      veterinarianName: Value(veterinarianName),
      noteType: Value(noteType),
      subjective: subjective == null && nullToAbsent
          ? const Value.absent()
          : Value(subjective),
      objective: objective == null && nullToAbsent
          ? const Value.absent()
          : Value(objective),
      assessment: assessment == null && nullToAbsent
          ? const Value.absent()
          : Value(assessment),
      plan: plan == null && nullToAbsent ? const Value.absent() : Value(plan),
      temperatureCelsius: temperatureCelsius == null && nullToAbsent
          ? const Value.absent()
          : Value(temperatureCelsius),
      heartRateBpm: heartRateBpm == null && nullToAbsent
          ? const Value.absent()
          : Value(heartRateBpm),
      respiratoryRateBpm: respiratoryRateBpm == null && nullToAbsent
          ? const Value.absent()
          : Value(respiratoryRateBpm),
      bodyConditionScore: bodyConditionScore == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyConditionScore),
      painScore: painScore == null && nullToAbsent
          ? const Value.absent()
          : Value(painScore),
      recordedAt: Value(recordedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ClinicalProgressNoteData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClinicalProgressNoteData(
      id: serializer.fromJson<String>(json['id']),
      caseId: serializer.fromJson<String>(json['caseId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      veterinarianId: serializer.fromJson<String>(json['veterinarianId']),
      veterinarianName: serializer.fromJson<String>(json['veterinarianName']),
      noteType: serializer.fromJson<String>(json['noteType']),
      subjective: serializer.fromJson<String?>(json['subjective']),
      objective: serializer.fromJson<String?>(json['objective']),
      assessment: serializer.fromJson<String?>(json['assessment']),
      plan: serializer.fromJson<String?>(json['plan']),
      temperatureCelsius:
          serializer.fromJson<double?>(json['temperatureCelsius']),
      heartRateBpm: serializer.fromJson<int?>(json['heartRateBpm']),
      respiratoryRateBpm: serializer.fromJson<int?>(json['respiratoryRateBpm']),
      bodyConditionScore: serializer.fromJson<int?>(json['bodyConditionScore']),
      painScore: serializer.fromJson<int?>(json['painScore']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'caseId': serializer.toJson<String>(caseId),
      'patientId': serializer.toJson<String>(patientId),
      'veterinarianId': serializer.toJson<String>(veterinarianId),
      'veterinarianName': serializer.toJson<String>(veterinarianName),
      'noteType': serializer.toJson<String>(noteType),
      'subjective': serializer.toJson<String?>(subjective),
      'objective': serializer.toJson<String?>(objective),
      'assessment': serializer.toJson<String?>(assessment),
      'plan': serializer.toJson<String?>(plan),
      'temperatureCelsius': serializer.toJson<double?>(temperatureCelsius),
      'heartRateBpm': serializer.toJson<int?>(heartRateBpm),
      'respiratoryRateBpm': serializer.toJson<int?>(respiratoryRateBpm),
      'bodyConditionScore': serializer.toJson<int?>(bodyConditionScore),
      'painScore': serializer.toJson<int?>(painScore),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ClinicalProgressNoteData copyWith(
          {String? id,
          String? caseId,
          String? patientId,
          String? veterinarianId,
          String? veterinarianName,
          String? noteType,
          Value<String?> subjective = const Value.absent(),
          Value<String?> objective = const Value.absent(),
          Value<String?> assessment = const Value.absent(),
          Value<String?> plan = const Value.absent(),
          Value<double?> temperatureCelsius = const Value.absent(),
          Value<int?> heartRateBpm = const Value.absent(),
          Value<int?> respiratoryRateBpm = const Value.absent(),
          Value<int?> bodyConditionScore = const Value.absent(),
          Value<int?> painScore = const Value.absent(),
          DateTime? recordedAt,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus}) =>
      ClinicalProgressNoteData(
        id: id ?? this.id,
        caseId: caseId ?? this.caseId,
        patientId: patientId ?? this.patientId,
        veterinarianId: veterinarianId ?? this.veterinarianId,
        veterinarianName: veterinarianName ?? this.veterinarianName,
        noteType: noteType ?? this.noteType,
        subjective: subjective.present ? subjective.value : this.subjective,
        objective: objective.present ? objective.value : this.objective,
        assessment: assessment.present ? assessment.value : this.assessment,
        plan: plan.present ? plan.value : this.plan,
        temperatureCelsius: temperatureCelsius.present
            ? temperatureCelsius.value
            : this.temperatureCelsius,
        heartRateBpm:
            heartRateBpm.present ? heartRateBpm.value : this.heartRateBpm,
        respiratoryRateBpm: respiratoryRateBpm.present
            ? respiratoryRateBpm.value
            : this.respiratoryRateBpm,
        bodyConditionScore: bodyConditionScore.present
            ? bodyConditionScore.value
            : this.bodyConditionScore,
        painScore: painScore.present ? painScore.value : this.painScore,
        recordedAt: recordedAt ?? this.recordedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  ClinicalProgressNoteData copyWithCompanion(
      ClinicalProgressNotesTableCompanion data) {
    return ClinicalProgressNoteData(
      id: data.id.present ? data.id.value : this.id,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      veterinarianId: data.veterinarianId.present
          ? data.veterinarianId.value
          : this.veterinarianId,
      veterinarianName: data.veterinarianName.present
          ? data.veterinarianName.value
          : this.veterinarianName,
      noteType: data.noteType.present ? data.noteType.value : this.noteType,
      subjective:
          data.subjective.present ? data.subjective.value : this.subjective,
      objective: data.objective.present ? data.objective.value : this.objective,
      assessment:
          data.assessment.present ? data.assessment.value : this.assessment,
      plan: data.plan.present ? data.plan.value : this.plan,
      temperatureCelsius: data.temperatureCelsius.present
          ? data.temperatureCelsius.value
          : this.temperatureCelsius,
      heartRateBpm: data.heartRateBpm.present
          ? data.heartRateBpm.value
          : this.heartRateBpm,
      respiratoryRateBpm: data.respiratoryRateBpm.present
          ? data.respiratoryRateBpm.value
          : this.respiratoryRateBpm,
      bodyConditionScore: data.bodyConditionScore.present
          ? data.bodyConditionScore.value
          : this.bodyConditionScore,
      painScore: data.painScore.present ? data.painScore.value : this.painScore,
      recordedAt:
          data.recordedAt.present ? data.recordedAt.value : this.recordedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalProgressNoteData(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('patientId: $patientId, ')
          ..write('veterinarianId: $veterinarianId, ')
          ..write('veterinarianName: $veterinarianName, ')
          ..write('noteType: $noteType, ')
          ..write('subjective: $subjective, ')
          ..write('objective: $objective, ')
          ..write('assessment: $assessment, ')
          ..write('plan: $plan, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('heartRateBpm: $heartRateBpm, ')
          ..write('respiratoryRateBpm: $respiratoryRateBpm, ')
          ..write('bodyConditionScore: $bodyConditionScore, ')
          ..write('painScore: $painScore, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      caseId,
      patientId,
      veterinarianId,
      veterinarianName,
      noteType,
      subjective,
      objective,
      assessment,
      plan,
      temperatureCelsius,
      heartRateBpm,
      respiratoryRateBpm,
      bodyConditionScore,
      painScore,
      recordedAt,
      createdAt,
      updatedAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClinicalProgressNoteData &&
          other.id == this.id &&
          other.caseId == this.caseId &&
          other.patientId == this.patientId &&
          other.veterinarianId == this.veterinarianId &&
          other.veterinarianName == this.veterinarianName &&
          other.noteType == this.noteType &&
          other.subjective == this.subjective &&
          other.objective == this.objective &&
          other.assessment == this.assessment &&
          other.plan == this.plan &&
          other.temperatureCelsius == this.temperatureCelsius &&
          other.heartRateBpm == this.heartRateBpm &&
          other.respiratoryRateBpm == this.respiratoryRateBpm &&
          other.bodyConditionScore == this.bodyConditionScore &&
          other.painScore == this.painScore &&
          other.recordedAt == this.recordedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class ClinicalProgressNotesTableCompanion
    extends UpdateCompanion<ClinicalProgressNoteData> {
  final Value<String> id;
  final Value<String> caseId;
  final Value<String> patientId;
  final Value<String> veterinarianId;
  final Value<String> veterinarianName;
  final Value<String> noteType;
  final Value<String?> subjective;
  final Value<String?> objective;
  final Value<String?> assessment;
  final Value<String?> plan;
  final Value<double?> temperatureCelsius;
  final Value<int?> heartRateBpm;
  final Value<int?> respiratoryRateBpm;
  final Value<int?> bodyConditionScore;
  final Value<int?> painScore;
  final Value<DateTime> recordedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ClinicalProgressNotesTableCompanion({
    this.id = const Value.absent(),
    this.caseId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.veterinarianId = const Value.absent(),
    this.veterinarianName = const Value.absent(),
    this.noteType = const Value.absent(),
    this.subjective = const Value.absent(),
    this.objective = const Value.absent(),
    this.assessment = const Value.absent(),
    this.plan = const Value.absent(),
    this.temperatureCelsius = const Value.absent(),
    this.heartRateBpm = const Value.absent(),
    this.respiratoryRateBpm = const Value.absent(),
    this.bodyConditionScore = const Value.absent(),
    this.painScore = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClinicalProgressNotesTableCompanion.insert({
    required String id,
    required String caseId,
    required String patientId,
    required String veterinarianId,
    required String veterinarianName,
    this.noteType = const Value.absent(),
    this.subjective = const Value.absent(),
    this.objective = const Value.absent(),
    this.assessment = const Value.absent(),
    this.plan = const Value.absent(),
    this.temperatureCelsius = const Value.absent(),
    this.heartRateBpm = const Value.absent(),
    this.respiratoryRateBpm = const Value.absent(),
    this.bodyConditionScore = const Value.absent(),
    this.painScore = const Value.absent(),
    required DateTime recordedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        caseId = Value(caseId),
        patientId = Value(patientId),
        veterinarianId = Value(veterinarianId),
        veterinarianName = Value(veterinarianName),
        recordedAt = Value(recordedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<ClinicalProgressNoteData> custom({
    Expression<String>? id,
    Expression<String>? caseId,
    Expression<String>? patientId,
    Expression<String>? veterinarianId,
    Expression<String>? veterinarianName,
    Expression<String>? noteType,
    Expression<String>? subjective,
    Expression<String>? objective,
    Expression<String>? assessment,
    Expression<String>? plan,
    Expression<double>? temperatureCelsius,
    Expression<int>? heartRateBpm,
    Expression<int>? respiratoryRateBpm,
    Expression<int>? bodyConditionScore,
    Expression<int>? painScore,
    Expression<DateTime>? recordedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (caseId != null) 'case_id': caseId,
      if (patientId != null) 'patient_id': patientId,
      if (veterinarianId != null) 'veterinarian_id': veterinarianId,
      if (veterinarianName != null) 'veterinarian_name': veterinarianName,
      if (noteType != null) 'note_type': noteType,
      if (subjective != null) 'subjective': subjective,
      if (objective != null) 'objective': objective,
      if (assessment != null) 'assessment': assessment,
      if (plan != null) 'plan': plan,
      if (temperatureCelsius != null) 'temperature_celsius': temperatureCelsius,
      if (heartRateBpm != null) 'heart_rate_bpm': heartRateBpm,
      if (respiratoryRateBpm != null)
        'respiratory_rate_bpm': respiratoryRateBpm,
      if (bodyConditionScore != null)
        'body_condition_score': bodyConditionScore,
      if (painScore != null) 'pain_score': painScore,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClinicalProgressNotesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? caseId,
      Value<String>? patientId,
      Value<String>? veterinarianId,
      Value<String>? veterinarianName,
      Value<String>? noteType,
      Value<String?>? subjective,
      Value<String?>? objective,
      Value<String?>? assessment,
      Value<String?>? plan,
      Value<double?>? temperatureCelsius,
      Value<int?>? heartRateBpm,
      Value<int?>? respiratoryRateBpm,
      Value<int?>? bodyConditionScore,
      Value<int?>? painScore,
      Value<DateTime>? recordedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return ClinicalProgressNotesTableCompanion(
      id: id ?? this.id,
      caseId: caseId ?? this.caseId,
      patientId: patientId ?? this.patientId,
      veterinarianId: veterinarianId ?? this.veterinarianId,
      veterinarianName: veterinarianName ?? this.veterinarianName,
      noteType: noteType ?? this.noteType,
      subjective: subjective ?? this.subjective,
      objective: objective ?? this.objective,
      assessment: assessment ?? this.assessment,
      plan: plan ?? this.plan,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      heartRateBpm: heartRateBpm ?? this.heartRateBpm,
      respiratoryRateBpm: respiratoryRateBpm ?? this.respiratoryRateBpm,
      bodyConditionScore: bodyConditionScore ?? this.bodyConditionScore,
      painScore: painScore ?? this.painScore,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (veterinarianId.present) {
      map['veterinarian_id'] = Variable<String>(veterinarianId.value);
    }
    if (veterinarianName.present) {
      map['veterinarian_name'] = Variable<String>(veterinarianName.value);
    }
    if (noteType.present) {
      map['note_type'] = Variable<String>(noteType.value);
    }
    if (subjective.present) {
      map['subjective'] = Variable<String>(subjective.value);
    }
    if (objective.present) {
      map['objective'] = Variable<String>(objective.value);
    }
    if (assessment.present) {
      map['assessment'] = Variable<String>(assessment.value);
    }
    if (plan.present) {
      map['plan'] = Variable<String>(plan.value);
    }
    if (temperatureCelsius.present) {
      map['temperature_celsius'] = Variable<double>(temperatureCelsius.value);
    }
    if (heartRateBpm.present) {
      map['heart_rate_bpm'] = Variable<int>(heartRateBpm.value);
    }
    if (respiratoryRateBpm.present) {
      map['respiratory_rate_bpm'] = Variable<int>(respiratoryRateBpm.value);
    }
    if (bodyConditionScore.present) {
      map['body_condition_score'] = Variable<int>(bodyConditionScore.value);
    }
    if (painScore.present) {
      map['pain_score'] = Variable<int>(painScore.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClinicalProgressNotesTableCompanion(')
          ..write('id: $id, ')
          ..write('caseId: $caseId, ')
          ..write('patientId: $patientId, ')
          ..write('veterinarianId: $veterinarianId, ')
          ..write('veterinarianName: $veterinarianName, ')
          ..write('noteType: $noteType, ')
          ..write('subjective: $subjective, ')
          ..write('objective: $objective, ')
          ..write('assessment: $assessment, ')
          ..write('plan: $plan, ')
          ..write('temperatureCelsius: $temperatureCelsius, ')
          ..write('heartRateBpm: $heartRateBpm, ')
          ..write('respiratoryRateBpm: $respiratoryRateBpm, ')
          ..write('bodyConditionScore: $bodyConditionScore, ')
          ..write('painScore: $painScore, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DiagnosesTableTable extends DiagnosesTable
    with TableInfo<$DiagnosesTableTable, DiagnosisData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiagnosesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES patients (id)'));
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
      'case_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES cases (id)'));
  static const VerificationMeta _diagnosisMeta =
      const VerificationMeta('diagnosis');
  @override
  late final GeneratedColumn<String> diagnosis = GeneratedColumn<String>(
      'diagnosis', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _diagnosedAtMeta =
      const VerificationMeta('diagnosedAt');
  @override
  late final GeneratedColumn<DateTime> diagnosedAt = GeneratedColumn<DateTime>(
      'diagnosed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('synced'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        patientId,
        userId,
        caseId,
        diagnosis,
        description,
        status,
        notes,
        diagnosedAt,
        createdAt,
        updatedAt,
        syncStatus
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diagnoses';
  @override
  VerificationContext validateIntegrity(Insertable<DiagnosisData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('case_id')) {
      context.handle(_caseIdMeta,
          caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta));
    }
    if (data.containsKey('diagnosis')) {
      context.handle(_diagnosisMeta,
          diagnosis.isAcceptableOrUnknown(data['diagnosis']!, _diagnosisMeta));
    } else if (isInserting) {
      context.missing(_diagnosisMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('diagnosed_at')) {
      context.handle(
          _diagnosedAtMeta,
          diagnosedAt.isAcceptableOrUnknown(
              data['diagnosed_at']!, _diagnosedAtMeta));
    } else if (isInserting) {
      context.missing(_diagnosedAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DiagnosisData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiagnosisData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      caseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_id']),
      diagnosis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diagnosis'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      diagnosedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}diagnosed_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
    );
  }

  @override
  $DiagnosesTableTable createAlias(String alias) {
    return $DiagnosesTableTable(attachedDatabase, alias);
  }
}

class DiagnosisData extends DataClass implements Insertable<DiagnosisData> {
  /// Primary UUID identifier
  final String id;

  /// Foreign key linking diagnosis to animal patient
  final String patientId;

  /// Clinician who established diagnosis
  final String userId;

  /// Optional foreign key linking diagnosis to an encounter
  final String? caseId;

  /// Primary diagnostic term (e.g. "Canine Parvoviral Enteritis", "Feline Lower Urinary Tract Disease")
  final String diagnosis;

  /// Pathological details, staging, or etiology
  final String? description;

  /// Diagnostic status: active, resolved, rule_out, chronic
  final String status;

  /// Clinician notes regarding response to treatment
  final String? notes;

  /// Timestamp when diagnosis was confirmed
  final DateTime diagnosedAt;

  /// Creation timestamp
  final DateTime createdAt;

  /// Modification timestamp
  final DateTime updatedAt;

  /// Offline synchronization lifecycle: synced, pending_create, pending_update, pending_delete
  final String syncStatus;
  const DiagnosisData(
      {required this.id,
      required this.patientId,
      required this.userId,
      this.caseId,
      required this.diagnosis,
      this.description,
      required this.status,
      this.notes,
      required this.diagnosedAt,
      required this.createdAt,
      required this.updatedAt,
      required this.syncStatus});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    map['user_id'] = Variable<String>(userId);
    if (!nullToAbsent || caseId != null) {
      map['case_id'] = Variable<String>(caseId);
    }
    map['diagnosis'] = Variable<String>(diagnosis);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['diagnosed_at'] = Variable<DateTime>(diagnosedAt);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  DiagnosesTableCompanion toCompanion(bool nullToAbsent) {
    return DiagnosesTableCompanion(
      id: Value(id),
      patientId: Value(patientId),
      userId: Value(userId),
      caseId:
          caseId == null && nullToAbsent ? const Value.absent() : Value(caseId),
      diagnosis: Value(diagnosis),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      diagnosedAt: Value(diagnosedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory DiagnosisData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiagnosisData(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      userId: serializer.fromJson<String>(json['userId']),
      caseId: serializer.fromJson<String?>(json['caseId']),
      diagnosis: serializer.fromJson<String>(json['diagnosis']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      diagnosedAt: serializer.fromJson<DateTime>(json['diagnosedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'userId': serializer.toJson<String>(userId),
      'caseId': serializer.toJson<String?>(caseId),
      'diagnosis': serializer.toJson<String>(diagnosis),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'diagnosedAt': serializer.toJson<DateTime>(diagnosedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  DiagnosisData copyWith(
          {String? id,
          String? patientId,
          String? userId,
          Value<String?> caseId = const Value.absent(),
          String? diagnosis,
          Value<String?> description = const Value.absent(),
          String? status,
          Value<String?> notes = const Value.absent(),
          DateTime? diagnosedAt,
          DateTime? createdAt,
          DateTime? updatedAt,
          String? syncStatus}) =>
      DiagnosisData(
        id: id ?? this.id,
        patientId: patientId ?? this.patientId,
        userId: userId ?? this.userId,
        caseId: caseId.present ? caseId.value : this.caseId,
        diagnosis: diagnosis ?? this.diagnosis,
        description: description.present ? description.value : this.description,
        status: status ?? this.status,
        notes: notes.present ? notes.value : this.notes,
        diagnosedAt: diagnosedAt ?? this.diagnosedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        syncStatus: syncStatus ?? this.syncStatus,
      );
  DiagnosisData copyWithCompanion(DiagnosesTableCompanion data) {
    return DiagnosisData(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      userId: data.userId.present ? data.userId.value : this.userId,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      diagnosis: data.diagnosis.present ? data.diagnosis.value : this.diagnosis,
      description:
          data.description.present ? data.description.value : this.description,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      diagnosedAt:
          data.diagnosedAt.present ? data.diagnosedAt.value : this.diagnosedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosisData(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('userId: $userId, ')
          ..write('caseId: $caseId, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('diagnosedAt: $diagnosedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      patientId,
      userId,
      caseId,
      diagnosis,
      description,
      status,
      notes,
      diagnosedAt,
      createdAt,
      updatedAt,
      syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiagnosisData &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.userId == this.userId &&
          other.caseId == this.caseId &&
          other.diagnosis == this.diagnosis &&
          other.description == this.description &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.diagnosedAt == this.diagnosedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.syncStatus == this.syncStatus);
}

class DiagnosesTableCompanion extends UpdateCompanion<DiagnosisData> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String> userId;
  final Value<String?> caseId;
  final Value<String> diagnosis;
  final Value<String?> description;
  final Value<String> status;
  final Value<String?> notes;
  final Value<DateTime> diagnosedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const DiagnosesTableCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.userId = const Value.absent(),
    this.caseId = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.diagnosedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiagnosesTableCompanion.insert({
    required String id,
    required String patientId,
    required String userId,
    this.caseId = const Value.absent(),
    required String diagnosis,
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime diagnosedAt,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        patientId = Value(patientId),
        userId = Value(userId),
        diagnosis = Value(diagnosis),
        diagnosedAt = Value(diagnosedAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<DiagnosisData> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? userId,
    Expression<String>? caseId,
    Expression<String>? diagnosis,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? diagnosedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (userId != null) 'user_id': userId,
      if (caseId != null) 'case_id': caseId,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (diagnosedAt != null) 'diagnosed_at': diagnosedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiagnosesTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? patientId,
      Value<String>? userId,
      Value<String?>? caseId,
      Value<String>? diagnosis,
      Value<String?>? description,
      Value<String>? status,
      Value<String?>? notes,
      Value<DateTime>? diagnosedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<String>? syncStatus,
      Value<int>? rowid}) {
    return DiagnosesTableCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      userId: userId ?? this.userId,
      caseId: caseId ?? this.caseId,
      diagnosis: diagnosis ?? this.diagnosis,
      description: description ?? this.description,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      diagnosedAt: diagnosedAt ?? this.diagnosedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (diagnosis.present) {
      map['diagnosis'] = Variable<String>(diagnosis.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (diagnosedAt.present) {
      map['diagnosed_at'] = Variable<DateTime>(diagnosedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiagnosesTableCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('userId: $userId, ')
          ..write('caseId: $caseId, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('diagnosedAt: $diagnosedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaUploadQueueTableTable extends MediaUploadQueueTable
    with TableInfo<$MediaUploadQueueTableTable, MediaUploadQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaUploadQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _caseIdMeta = const VerificationMeta('caseId');
  @override
  late final GeneratedColumn<String> caseId = GeneratedColumn<String>(
      'case_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES cases (id)'));
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES patients (id)'));
  static const VerificationMeta _localFilePathMeta =
      const VerificationMeta('localFilePath');
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
      'local_file_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteUrlMeta =
      const VerificationMeta('remoteUrl');
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
      'remote_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('image/webp'));
  static const VerificationMeta _fileSizeBytesMeta =
      const VerificationMeta('fileSizeBytes');
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
      'file_size_bytes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _checksumSha256Meta =
      const VerificationMeta('checksumSha256');
  @override
  late final GeneratedColumn<String> checksumSha256 = GeneratedColumn<String>(
      'checksum_sha256', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 64, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      additionalChecks: GeneratedColumn.checkTextLength(maxTextLength: 191),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _errorMessageMeta =
      const VerificationMeta('errorMessage');
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
      'error_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _uploadedAtMeta =
      const VerificationMeta('uploadedAt');
  @override
  late final GeneratedColumn<DateTime> uploadedAt = GeneratedColumn<DateTime>(
      'uploaded_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        caseId,
        patientId,
        localFilePath,
        remoteUrl,
        mimeType,
        fileSizeBytes,
        checksumSha256,
        title,
        status,
        retryCount,
        errorMessage,
        createdAt,
        uploadedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_upload_queue';
  @override
  VerificationContext validateIntegrity(
      Insertable<MediaUploadQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('case_id')) {
      context.handle(_caseIdMeta,
          caseId.isAcceptableOrUnknown(data['case_id']!, _caseIdMeta));
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
          _localFilePathMeta,
          localFilePath.isAcceptableOrUnknown(
              data['local_file_path']!, _localFilePathMeta));
    } else if (isInserting) {
      context.missing(_localFilePathMeta);
    }
    if (data.containsKey('remote_url')) {
      context.handle(_remoteUrlMeta,
          remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta));
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
          _fileSizeBytesMeta,
          fileSizeBytes.isAcceptableOrUnknown(
              data['file_size_bytes']!, _fileSizeBytesMeta));
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('checksum_sha256')) {
      context.handle(
          _checksumSha256Meta,
          checksumSha256.isAcceptableOrUnknown(
              data['checksum_sha256']!, _checksumSha256Meta));
    } else if (isInserting) {
      context.missing(_checksumSha256Meta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('error_message')) {
      context.handle(
          _errorMessageMeta,
          errorMessage.isAcceptableOrUnknown(
              data['error_message']!, _errorMessageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('uploaded_at')) {
      context.handle(
          _uploadedAtMeta,
          uploadedAt.isAcceptableOrUnknown(
              data['uploaded_at']!, _uploadedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaUploadQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaUploadQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      caseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}case_id']),
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id']),
      localFilePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}local_file_path'])!,
      remoteUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_url']),
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type'])!,
      fileSizeBytes: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}file_size_bytes'])!,
      checksumSha256: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}checksum_sha256'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      errorMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error_message']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      uploadedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}uploaded_at']),
    );
  }

  @override
  $MediaUploadQueueTableTable createAlias(String alias) {
    return $MediaUploadQueueTableTable(attachedDatabase, alias);
  }
}

class MediaUploadQueueData extends DataClass
    implements Insertable<MediaUploadQueueData> {
  /// Primary UUID identifier
  final String id;

  /// Practice tenant isolation identifier
  final String tenantId;

  /// Optional association to clinical encounter
  final String? caseId;

  /// Optional association directly to patient record
  final String? patientId;

  /// Local cached device file path (WebP compressed artifact)
  final String localFilePath;

  /// Cloudflare R2 public / presigned URL once uploaded
  final String? remoteUrl;

  /// Media MIME type: image/webp, image/jpeg, application/pdf
  final String mimeType;

  /// Byte length for progress tracking and storage audits
  final int fileSizeBytes;

  /// SHA-256 cryptographic digest for payload integrity verification
  final String checksumSha256;

  /// Optional clinician description (e.g., "Right lateral abdominal radiograph")
  final String? title;

  /// Processing state: pending, uploading, completed, failed
  final String status;

  /// Number of retry attempts executed
  final int retryCount;

  /// Diagnostic error log from Cloudflare R2 or network failure
  final String? errorMessage;

  /// Queue entry timestamp
  final DateTime createdAt;

  /// Completion timestamp
  final DateTime? uploadedAt;
  const MediaUploadQueueData(
      {required this.id,
      required this.tenantId,
      this.caseId,
      this.patientId,
      required this.localFilePath,
      this.remoteUrl,
      required this.mimeType,
      required this.fileSizeBytes,
      required this.checksumSha256,
      this.title,
      required this.status,
      required this.retryCount,
      this.errorMessage,
      required this.createdAt,
      this.uploadedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    if (!nullToAbsent || caseId != null) {
      map['case_id'] = Variable<String>(caseId);
    }
    if (!nullToAbsent || patientId != null) {
      map['patient_id'] = Variable<String>(patientId);
    }
    map['local_file_path'] = Variable<String>(localFilePath);
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    map['mime_type'] = Variable<String>(mimeType);
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    map['checksum_sha256'] = Variable<String>(checksumSha256);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || uploadedAt != null) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt);
    }
    return map;
  }

  MediaUploadQueueTableCompanion toCompanion(bool nullToAbsent) {
    return MediaUploadQueueTableCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      caseId:
          caseId == null && nullToAbsent ? const Value.absent() : Value(caseId),
      patientId: patientId == null && nullToAbsent
          ? const Value.absent()
          : Value(patientId),
      localFilePath: Value(localFilePath),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      mimeType: Value(mimeType),
      fileSizeBytes: Value(fileSizeBytes),
      checksumSha256: Value(checksumSha256),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      status: Value(status),
      retryCount: Value(retryCount),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      uploadedAt: uploadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(uploadedAt),
    );
  }

  factory MediaUploadQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaUploadQueueData(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      caseId: serializer.fromJson<String?>(json['caseId']),
      patientId: serializer.fromJson<String?>(json['patientId']),
      localFilePath: serializer.fromJson<String>(json['localFilePath']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      checksumSha256: serializer.fromJson<String>(json['checksumSha256']),
      title: serializer.fromJson<String?>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      errorMessage: serializer.fromJson<String?>(json['errorMessage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      uploadedAt: serializer.fromJson<DateTime?>(json['uploadedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'caseId': serializer.toJson<String?>(caseId),
      'patientId': serializer.toJson<String?>(patientId),
      'localFilePath': serializer.toJson<String>(localFilePath),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'mimeType': serializer.toJson<String>(mimeType),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'checksumSha256': serializer.toJson<String>(checksumSha256),
      'title': serializer.toJson<String?>(title),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'errorMessage': serializer.toJson<String?>(errorMessage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'uploadedAt': serializer.toJson<DateTime?>(uploadedAt),
    };
  }

  MediaUploadQueueData copyWith(
          {String? id,
          String? tenantId,
          Value<String?> caseId = const Value.absent(),
          Value<String?> patientId = const Value.absent(),
          String? localFilePath,
          Value<String?> remoteUrl = const Value.absent(),
          String? mimeType,
          int? fileSizeBytes,
          String? checksumSha256,
          Value<String?> title = const Value.absent(),
          String? status,
          int? retryCount,
          Value<String?> errorMessage = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> uploadedAt = const Value.absent()}) =>
      MediaUploadQueueData(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        caseId: caseId.present ? caseId.value : this.caseId,
        patientId: patientId.present ? patientId.value : this.patientId,
        localFilePath: localFilePath ?? this.localFilePath,
        remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
        mimeType: mimeType ?? this.mimeType,
        fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
        checksumSha256: checksumSha256 ?? this.checksumSha256,
        title: title.present ? title.value : this.title,
        status: status ?? this.status,
        retryCount: retryCount ?? this.retryCount,
        errorMessage:
            errorMessage.present ? errorMessage.value : this.errorMessage,
        createdAt: createdAt ?? this.createdAt,
        uploadedAt: uploadedAt.present ? uploadedAt.value : this.uploadedAt,
      );
  MediaUploadQueueData copyWithCompanion(MediaUploadQueueTableCompanion data) {
    return MediaUploadQueueData(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      caseId: data.caseId.present ? data.caseId.value : this.caseId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      checksumSha256: data.checksumSha256.present
          ? data.checksumSha256.value
          : this.checksumSha256,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      uploadedAt:
          data.uploadedAt.present ? data.uploadedAt.value : this.uploadedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaUploadQueueData(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('caseId: $caseId, ')
          ..write('patientId: $patientId, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('uploadedAt: $uploadedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tenantId,
      caseId,
      patientId,
      localFilePath,
      remoteUrl,
      mimeType,
      fileSizeBytes,
      checksumSha256,
      title,
      status,
      retryCount,
      errorMessage,
      createdAt,
      uploadedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaUploadQueueData &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.caseId == this.caseId &&
          other.patientId == this.patientId &&
          other.localFilePath == this.localFilePath &&
          other.remoteUrl == this.remoteUrl &&
          other.mimeType == this.mimeType &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.checksumSha256 == this.checksumSha256 &&
          other.title == this.title &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.uploadedAt == this.uploadedAt);
}

class MediaUploadQueueTableCompanion
    extends UpdateCompanion<MediaUploadQueueData> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String?> caseId;
  final Value<String?> patientId;
  final Value<String> localFilePath;
  final Value<String?> remoteUrl;
  final Value<String> mimeType;
  final Value<int> fileSizeBytes;
  final Value<String> checksumSha256;
  final Value<String?> title;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> errorMessage;
  final Value<DateTime> createdAt;
  final Value<DateTime?> uploadedAt;
  final Value<int> rowid;
  const MediaUploadQueueTableCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.caseId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.checksumSha256 = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.uploadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaUploadQueueTableCompanion.insert({
    required String id,
    required String tenantId,
    this.caseId = const Value.absent(),
    this.patientId = const Value.absent(),
    required String localFilePath,
    this.remoteUrl = const Value.absent(),
    this.mimeType = const Value.absent(),
    required int fileSizeBytes,
    required String checksumSha256,
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required DateTime createdAt,
    this.uploadedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        localFilePath = Value(localFilePath),
        fileSizeBytes = Value(fileSizeBytes),
        checksumSha256 = Value(checksumSha256),
        createdAt = Value(createdAt);
  static Insertable<MediaUploadQueueData> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? caseId,
    Expression<String>? patientId,
    Expression<String>? localFilePath,
    Expression<String>? remoteUrl,
    Expression<String>? mimeType,
    Expression<int>? fileSizeBytes,
    Expression<String>? checksumSha256,
    Expression<String>? title,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? errorMessage,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? uploadedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (caseId != null) 'case_id': caseId,
      if (patientId != null) 'patient_id': patientId,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (checksumSha256 != null) 'checksum_sha256': checksumSha256,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (uploadedAt != null) 'uploaded_at': uploadedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaUploadQueueTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String?>? caseId,
      Value<String?>? patientId,
      Value<String>? localFilePath,
      Value<String?>? remoteUrl,
      Value<String>? mimeType,
      Value<int>? fileSizeBytes,
      Value<String>? checksumSha256,
      Value<String?>? title,
      Value<String>? status,
      Value<int>? retryCount,
      Value<String?>? errorMessage,
      Value<DateTime>? createdAt,
      Value<DateTime?>? uploadedAt,
      Value<int>? rowid}) {
    return MediaUploadQueueTableCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      caseId: caseId ?? this.caseId,
      patientId: patientId ?? this.patientId,
      localFilePath: localFilePath ?? this.localFilePath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      mimeType: mimeType ?? this.mimeType,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
      title: title ?? this.title,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (caseId.present) {
      map['case_id'] = Variable<String>(caseId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (checksumSha256.present) {
      map['checksum_sha256'] = Variable<String>(checksumSha256.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (uploadedAt.present) {
      map['uploaded_at'] = Variable<DateTime>(uploadedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaUploadQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('caseId: $caseId, ')
          ..write('patientId: $patientId, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('uploadedAt: $uploadedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTableTable extends SyncQueueTable
    with TableInfo<$SyncQueueTableTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tenantIdMeta =
      const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
      'tenant_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _entityIdMeta =
      const VerificationMeta('entityId');
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
      'entity_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
      'action', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 16),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _clientTimestampMeta =
      const VerificationMeta('clientTimestamp');
  @override
  late final GeneratedColumn<DateTime> clientTimestamp =
      GeneratedColumn<DateTime>('client_timestamp', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 16, maxTextLength: 64),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tenantId,
        entityType,
        entityId,
        action,
        payload,
        clientTimestamp,
        idempotencyKey,
        status,
        attempts,
        lastError,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(_tenantIdMeta,
          tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta));
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(_entityIdMeta,
          entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta));
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(_actionMeta,
          action.isAcceptableOrUnknown(data['action']!, _actionMeta));
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('client_timestamp')) {
      context.handle(
          _clientTimestampMeta,
          clientTimestamp.isAcceptableOrUnknown(
              data['client_timestamp']!, _clientTimestampMeta));
    } else if (isInserting) {
      context.missing(_clientTimestampMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tenantId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tenant_id'])!,
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type'])!,
      entityId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_id'])!,
      action: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload'])!,
      clientTimestamp: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}client_timestamp'])!,
      idempotencyKey: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}idempotency_key'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SyncQueueTableTable createAlias(String alias) {
    return $SyncQueueTableTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  /// Primary UUID identifier
  final String id;

  /// Practice tenant isolation identifier
  final String tenantId;

  /// Domain entity type: client, patient, case, progress_note, diagnosis
  final String entityType;

  /// Entity UUID
  final String entityId;

  /// Mutation verb: create, update, delete
  final String action;

  /// Full JSON snapshot payload sent to backend sync endpoint
  final String payload;

  /// Offline client local timestamp of mutation
  final DateTime clientTimestamp;

  /// Unique UUIDv7 idempotency key preventing duplicate server execution
  final String idempotencyKey;

  /// Queue status: pending, in_flight, failed, synced
  final String status;

  /// Cumulative transmission attempts
  final int attempts;

  /// Detailed error string or HTTP response upon sync failure
  final String? lastError;

  /// Creation timestamp
  final DateTime createdAt;
  const SyncQueueData(
      {required this.id,
      required this.tenantId,
      required this.entityType,
      required this.entityId,
      required this.action,
      required this.payload,
      required this.clientTimestamp,
      required this.idempotencyKey,
      required this.status,
      required this.attempts,
      this.lastError,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    map['payload'] = Variable<String>(payload);
    map['client_timestamp'] = Variable<DateTime>(clientTimestamp);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncQueueTableCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueTableCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      payload: Value(payload),
      clientTimestamp: Value(clientTimestamp),
      idempotencyKey: Value(idempotencyKey),
      status: Value(status),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      payload: serializer.fromJson<String>(json['payload']),
      clientTimestamp: serializer.fromJson<DateTime>(json['clientTimestamp']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'payload': serializer.toJson<String>(payload),
      'clientTimestamp': serializer.toJson<DateTime>(clientTimestamp),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncQueueData copyWith(
          {String? id,
          String? tenantId,
          String? entityType,
          String? entityId,
          String? action,
          String? payload,
          DateTime? clientTimestamp,
          String? idempotencyKey,
          String? status,
          int? attempts,
          Value<String?> lastError = const Value.absent(),
          DateTime? createdAt}) =>
      SyncQueueData(
        id: id ?? this.id,
        tenantId: tenantId ?? this.tenantId,
        entityType: entityType ?? this.entityType,
        entityId: entityId ?? this.entityId,
        action: action ?? this.action,
        payload: payload ?? this.payload,
        clientTimestamp: clientTimestamp ?? this.clientTimestamp,
        idempotencyKey: idempotencyKey ?? this.idempotencyKey,
        status: status ?? this.status,
        attempts: attempts ?? this.attempts,
        lastError: lastError.present ? lastError.value : this.lastError,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncQueueData copyWithCompanion(SyncQueueTableCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      payload: data.payload.present ? data.payload.value : this.payload,
      clientTimestamp: data.clientTimestamp.present
          ? data.clientTimestamp.value
          : this.clientTimestamp,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('clientTimestamp: $clientTimestamp, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tenantId,
      entityType,
      entityId,
      action,
      payload,
      clientTimestamp,
      idempotencyKey,
      status,
      attempts,
      lastError,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.payload == this.payload &&
          other.clientTimestamp == this.clientTimestamp &&
          other.idempotencyKey == this.idempotencyKey &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class SyncQueueTableCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String> payload;
  final Value<DateTime> clientTimestamp;
  final Value<String> idempotencyKey;
  final Value<String> status;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SyncQueueTableCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.payload = const Value.absent(),
    this.clientTimestamp = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueTableCompanion.insert({
    required String id,
    required String tenantId,
    required String entityType,
    required String entityId,
    required String action,
    required String payload,
    required DateTime clientTimestamp,
    required String idempotencyKey,
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tenantId = Value(tenantId),
        entityType = Value(entityType),
        entityId = Value(entityId),
        action = Value(action),
        payload = Value(payload),
        clientTimestamp = Value(clientTimestamp),
        idempotencyKey = Value(idempotencyKey),
        createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? payload,
    Expression<DateTime>? clientTimestamp,
    Expression<String>? idempotencyKey,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (payload != null) 'payload': payload,
      if (clientTimestamp != null) 'client_timestamp': clientTimestamp,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueTableCompanion copyWith(
      {Value<String>? id,
      Value<String>? tenantId,
      Value<String>? entityType,
      Value<String>? entityId,
      Value<String>? action,
      Value<String>? payload,
      Value<DateTime>? clientTimestamp,
      Value<String>? idempotencyKey,
      Value<String>? status,
      Value<int>? attempts,
      Value<String?>? lastError,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SyncQueueTableCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      payload: payload ?? this.payload,
      clientTimestamp: clientTimestamp ?? this.clientTimestamp,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (clientTimestamp.present) {
      map['client_timestamp'] = Variable<DateTime>(clientTimestamp.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueTableCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('payload: $payload, ')
          ..write('clientTimestamp: $clientTimestamp, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientsTableTable clientsTable = $ClientsTableTable(this);
  late final $PatientsTableTable patientsTable = $PatientsTableTable(this);
  late final $ClinicalCasesTableTable clinicalCasesTable =
      $ClinicalCasesTableTable(this);
  late final $ClinicalProgressNotesTableTable clinicalProgressNotesTable =
      $ClinicalProgressNotesTableTable(this);
  late final $DiagnosesTableTable diagnosesTable = $DiagnosesTableTable(this);
  late final $MediaUploadQueueTableTable mediaUploadQueueTable =
      $MediaUploadQueueTableTable(this);
  late final $SyncQueueTableTable syncQueueTable = $SyncQueueTableTable(this);
  late final ClinicalCaseDao clinicalCaseDao =
      ClinicalCaseDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        clientsTable,
        patientsTable,
        clinicalCasesTable,
        clinicalProgressNotesTable,
        diagnosesTable,
        mediaUploadQueueTable,
        syncQueueTable
      ];
}

typedef $$ClientsTableTableCreateCompanionBuilder = ClientsTableCompanion
    Function({
  required String id,
  required String tenantId,
  Value<String> clientType,
  required String name,
  Value<String?> contactPerson,
  required String phonePrimary,
  Value<String?> phoneSecondary,
  Value<String?> physicalAddress,
  Value<String?> notes,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ClientsTableTableUpdateCompanionBuilder = ClientsTableCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> clientType,
  Value<String> name,
  Value<String?> contactPerson,
  Value<String> phonePrimary,
  Value<String?> phoneSecondary,
  Value<String?> physicalAddress,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

final class $$ClientsTableTableReferences
    extends BaseReferences<_$AppDatabase, $ClientsTableTable, ClientData> {
  $$ClientsTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PatientsTableTable, List<PatientData>>
      _patientsTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.patientsTable,
              aliasName: $_aliasNameGenerator(
                  db.clientsTable.id, db.patientsTable.clientId));

  $$PatientsTableTableProcessedTableManager get patientsTableRefs {
    final manager = $$PatientsTableTableTableManager($_db, $_db.patientsTable)
        .filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_patientsTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ClientsTableTableFilterComposer
    extends Composer<_$AppDatabase, $ClientsTableTable> {
  $$ClientsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get clientType => $composableBuilder(
      column: $table.clientType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phonePrimary => $composableBuilder(
      column: $table.phonePrimary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneSecondary => $composableBuilder(
      column: $table.phoneSecondary,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get physicalAddress => $composableBuilder(
      column: $table.physicalAddress,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> patientsTableRefs(
      Expression<bool> Function($$PatientsTableTableFilterComposer f) f) {
    final $$PatientsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.patientsTable,
        getReferencedColumn: (t) => t.clientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatientsTableTableFilterComposer(
              $db: $db,
              $table: $db.patientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClientsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientsTableTable> {
  $$ClientsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get clientType => $composableBuilder(
      column: $table.clientType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phonePrimary => $composableBuilder(
      column: $table.phonePrimary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneSecondary => $composableBuilder(
      column: $table.phoneSecondary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get physicalAddress => $composableBuilder(
      column: $table.physicalAddress,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));
}

class $$ClientsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientsTableTable> {
  $$ClientsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get clientType => $composableBuilder(
      column: $table.clientType, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contactPerson => $composableBuilder(
      column: $table.contactPerson, builder: (column) => column);

  GeneratedColumn<String> get phonePrimary => $composableBuilder(
      column: $table.phonePrimary, builder: (column) => column);

  GeneratedColumn<String> get phoneSecondary => $composableBuilder(
      column: $table.phoneSecondary, builder: (column) => column);

  GeneratedColumn<String> get physicalAddress => $composableBuilder(
      column: $table.physicalAddress, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  Expression<T> patientsTableRefs<T extends Object>(
      Expression<T> Function($$PatientsTableTableAnnotationComposer a) f) {
    final $$PatientsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.patientsTable,
        getReferencedColumn: (t) => t.clientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatientsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.patientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ClientsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClientsTableTable,
    ClientData,
    $$ClientsTableTableFilterComposer,
    $$ClientsTableTableOrderingComposer,
    $$ClientsTableTableAnnotationComposer,
    $$ClientsTableTableCreateCompanionBuilder,
    $$ClientsTableTableUpdateCompanionBuilder,
    (ClientData, $$ClientsTableTableReferences),
    ClientData,
    PrefetchHooks Function({bool patientsTableRefs})> {
  $$ClientsTableTableTableManager(_$AppDatabase db, $ClientsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> clientType = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> contactPerson = const Value.absent(),
            Value<String> phonePrimary = const Value.absent(),
            Value<String?> phoneSecondary = const Value.absent(),
            Value<String?> physicalAddress = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClientsTableCompanion(
            id: id,
            tenantId: tenantId,
            clientType: clientType,
            name: name,
            contactPerson: contactPerson,
            phonePrimary: phonePrimary,
            phoneSecondary: phoneSecondary,
            physicalAddress: physicalAddress,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<String> clientType = const Value.absent(),
            required String name,
            Value<String?> contactPerson = const Value.absent(),
            required String phonePrimary,
            Value<String?> phoneSecondary = const Value.absent(),
            Value<String?> physicalAddress = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClientsTableCompanion.insert(
            id: id,
            tenantId: tenantId,
            clientType: clientType,
            name: name,
            contactPerson: contactPerson,
            phonePrimary: phonePrimary,
            phoneSecondary: phoneSecondary,
            physicalAddress: physicalAddress,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ClientsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({patientsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (patientsTableRefs) db.patientsTable
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (patientsTableRefs)
                    await $_getPrefetchedData<ClientData, $ClientsTableTable,
                            PatientData>(
                        currentTable: table,
                        referencedTable: $$ClientsTableTableReferences
                            ._patientsTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClientsTableTableReferences(db, table, p0)
                                .patientsTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.clientId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ClientsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClientsTableTable,
    ClientData,
    $$ClientsTableTableFilterComposer,
    $$ClientsTableTableOrderingComposer,
    $$ClientsTableTableAnnotationComposer,
    $$ClientsTableTableCreateCompanionBuilder,
    $$ClientsTableTableUpdateCompanionBuilder,
    (ClientData, $$ClientsTableTableReferences),
    ClientData,
    PrefetchHooks Function({bool patientsTableRefs})>;
typedef $$PatientsTableTableCreateCompanionBuilder = PatientsTableCompanion
    Function({
  required String id,
  required String tenantId,
  required String clientId,
  required String nameOrTag,
  required String species,
  Value<String?> breed,
  Value<String> gender,
  Value<int?> age,
  Value<DateTime?> dateOfBirth,
  Value<bool> isApproximateAge,
  Value<String?> microchipNumber,
  Value<String?> earTagId,
  Value<String?> coatColorMarkings,
  Value<double?> currentWeightKg,
  Value<DateTime?> weightRecordedAt,
  Value<String?> history,
  Value<String?> notes,
  Value<String> status,
  Value<DateTime?> deceasedAt,
  Value<String?> allergies,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$PatientsTableTableUpdateCompanionBuilder = PatientsTableCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> clientId,
  Value<String> nameOrTag,
  Value<String> species,
  Value<String?> breed,
  Value<String> gender,
  Value<int?> age,
  Value<DateTime?> dateOfBirth,
  Value<bool> isApproximateAge,
  Value<String?> microchipNumber,
  Value<String?> earTagId,
  Value<String?> coatColorMarkings,
  Value<double?> currentWeightKg,
  Value<DateTime?> weightRecordedAt,
  Value<String?> history,
  Value<String?> notes,
  Value<String> status,
  Value<DateTime?> deceasedAt,
  Value<String?> allergies,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

final class $$PatientsTableTableReferences
    extends BaseReferences<_$AppDatabase, $PatientsTableTable, PatientData> {
  $$PatientsTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTableTable _clientIdTable(_$AppDatabase db) =>
      db.clientsTable.createAlias(
          $_aliasNameGenerator(db.patientsTable.clientId, db.clientsTable.id));

  $$ClientsTableTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableTableManager($_db, $_db.clientsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ClinicalCasesTableTable, List<ClinicalCaseData>>
      _clinicalCasesTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.clinicalCasesTable,
              aliasName: $_aliasNameGenerator(
                  db.patientsTable.id, db.clinicalCasesTable.patientId));

  $$ClinicalCasesTableTableProcessedTableManager get clinicalCasesTableRefs {
    final manager = $$ClinicalCasesTableTableTableManager(
            $_db, $_db.clinicalCasesTable)
        .filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_clinicalCasesTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DiagnosesTableTable, List<DiagnosisData>>
      _diagnosesTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.diagnosesTable,
              aliasName: $_aliasNameGenerator(
                  db.patientsTable.id, db.diagnosesTable.patientId));

  $$DiagnosesTableTableProcessedTableManager get diagnosesTableRefs {
    final manager = $$DiagnosesTableTableTableManager($_db, $_db.diagnosesTable)
        .filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_diagnosesTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MediaUploadQueueTableTable,
      List<MediaUploadQueueData>> _mediaUploadQueueTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.mediaUploadQueueTable,
          aliasName: $_aliasNameGenerator(
              db.patientsTable.id, db.mediaUploadQueueTable.patientId));

  $$MediaUploadQueueTableTableProcessedTableManager
      get mediaUploadQueueTableRefs {
    final manager = $$MediaUploadQueueTableTableTableManager(
            $_db, $_db.mediaUploadQueueTable)
        .filter((f) => f.patientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_mediaUploadQueueTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PatientsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTableTable> {
  $$PatientsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameOrTag => $composableBuilder(
      column: $table.nameOrTag, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isApproximateAge => $composableBuilder(
      column: $table.isApproximateAge,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get microchipNumber => $composableBuilder(
      column: $table.microchipNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get earTagId => $composableBuilder(
      column: $table.earTagId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coatColorMarkings => $composableBuilder(
      column: $table.coatColorMarkings,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentWeightKg => $composableBuilder(
      column: $table.currentWeightKg,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get weightRecordedAt => $composableBuilder(
      column: $table.weightRecordedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get history => $composableBuilder(
      column: $table.history, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deceasedAt => $composableBuilder(
      column: $table.deceasedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get allergies => $composableBuilder(
      column: $table.allergies, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  $$ClientsTableTableFilterComposer get clientId {
    final $$ClientsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clientId,
        referencedTable: $db.clientsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientsTableTableFilterComposer(
              $db: $db,
              $table: $db.clientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> clinicalCasesTableRefs(
      Expression<bool> Function($$ClinicalCasesTableTableFilterComposer f) f) {
    final $$ClinicalCasesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.clinicalCasesTable,
        getReferencedColumn: (t) => t.patientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClinicalCasesTableTableFilterComposer(
              $db: $db,
              $table: $db.clinicalCasesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> diagnosesTableRefs(
      Expression<bool> Function($$DiagnosesTableTableFilterComposer f) f) {
    final $$DiagnosesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.diagnosesTable,
        getReferencedColumn: (t) => t.patientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DiagnosesTableTableFilterComposer(
              $db: $db,
              $table: $db.diagnosesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> mediaUploadQueueTableRefs(
      Expression<bool> Function($$MediaUploadQueueTableTableFilterComposer f)
          f) {
    final $$MediaUploadQueueTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.mediaUploadQueueTable,
            getReferencedColumn: (t) => t.patientId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MediaUploadQueueTableTableFilterComposer(
                  $db: $db,
                  $table: $db.mediaUploadQueueTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PatientsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTableTable> {
  $$PatientsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameOrTag => $composableBuilder(
      column: $table.nameOrTag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get species => $composableBuilder(
      column: $table.species, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get breed => $composableBuilder(
      column: $table.breed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isApproximateAge => $composableBuilder(
      column: $table.isApproximateAge,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get microchipNumber => $composableBuilder(
      column: $table.microchipNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get earTagId => $composableBuilder(
      column: $table.earTagId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coatColorMarkings => $composableBuilder(
      column: $table.coatColorMarkings,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentWeightKg => $composableBuilder(
      column: $table.currentWeightKg,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get weightRecordedAt => $composableBuilder(
      column: $table.weightRecordedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get history => $composableBuilder(
      column: $table.history, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deceasedAt => $composableBuilder(
      column: $table.deceasedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allergies => $composableBuilder(
      column: $table.allergies, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  $$ClientsTableTableOrderingComposer get clientId {
    final $$ClientsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clientId,
        referencedTable: $db.clientsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientsTableTableOrderingComposer(
              $db: $db,
              $table: $db.clientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PatientsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTableTable> {
  $$PatientsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get nameOrTag =>
      $composableBuilder(column: $table.nameOrTag, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<String> get breed =>
      $composableBuilder(column: $table.breed, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<DateTime> get dateOfBirth => $composableBuilder(
      column: $table.dateOfBirth, builder: (column) => column);

  GeneratedColumn<bool> get isApproximateAge => $composableBuilder(
      column: $table.isApproximateAge, builder: (column) => column);

  GeneratedColumn<String> get microchipNumber => $composableBuilder(
      column: $table.microchipNumber, builder: (column) => column);

  GeneratedColumn<String> get earTagId =>
      $composableBuilder(column: $table.earTagId, builder: (column) => column);

  GeneratedColumn<String> get coatColorMarkings => $composableBuilder(
      column: $table.coatColorMarkings, builder: (column) => column);

  GeneratedColumn<double> get currentWeightKg => $composableBuilder(
      column: $table.currentWeightKg, builder: (column) => column);

  GeneratedColumn<DateTime> get weightRecordedAt => $composableBuilder(
      column: $table.weightRecordedAt, builder: (column) => column);

  GeneratedColumn<String> get history =>
      $composableBuilder(column: $table.history, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get deceasedAt => $composableBuilder(
      column: $table.deceasedAt, builder: (column) => column);

  GeneratedColumn<String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  $$ClientsTableTableAnnotationComposer get clientId {
    final $$ClientsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.clientId,
        referencedTable: $db.clientsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClientsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.clientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> clinicalCasesTableRefs<T extends Object>(
      Expression<T> Function($$ClinicalCasesTableTableAnnotationComposer a) f) {
    final $$ClinicalCasesTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.clinicalCasesTable,
            getReferencedColumn: (t) => t.patientId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ClinicalCasesTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.clinicalCasesTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> diagnosesTableRefs<T extends Object>(
      Expression<T> Function($$DiagnosesTableTableAnnotationComposer a) f) {
    final $$DiagnosesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.diagnosesTable,
        getReferencedColumn: (t) => t.patientId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DiagnosesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.diagnosesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> mediaUploadQueueTableRefs<T extends Object>(
      Expression<T> Function($$MediaUploadQueueTableTableAnnotationComposer a)
          f) {
    final $$MediaUploadQueueTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.mediaUploadQueueTable,
            getReferencedColumn: (t) => t.patientId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MediaUploadQueueTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.mediaUploadQueueTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$PatientsTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PatientsTableTable,
    PatientData,
    $$PatientsTableTableFilterComposer,
    $$PatientsTableTableOrderingComposer,
    $$PatientsTableTableAnnotationComposer,
    $$PatientsTableTableCreateCompanionBuilder,
    $$PatientsTableTableUpdateCompanionBuilder,
    (PatientData, $$PatientsTableTableReferences),
    PatientData,
    PrefetchHooks Function(
        {bool clientId,
        bool clinicalCasesTableRefs,
        bool diagnosesTableRefs,
        bool mediaUploadQueueTableRefs})> {
  $$PatientsTableTableTableManager(_$AppDatabase db, $PatientsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> clientId = const Value.absent(),
            Value<String> nameOrTag = const Value.absent(),
            Value<String> species = const Value.absent(),
            Value<String?> breed = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<bool> isApproximateAge = const Value.absent(),
            Value<String?> microchipNumber = const Value.absent(),
            Value<String?> earTagId = const Value.absent(),
            Value<String?> coatColorMarkings = const Value.absent(),
            Value<double?> currentWeightKg = const Value.absent(),
            Value<DateTime?> weightRecordedAt = const Value.absent(),
            Value<String?> history = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> deceasedAt = const Value.absent(),
            Value<String?> allergies = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsTableCompanion(
            id: id,
            tenantId: tenantId,
            clientId: clientId,
            nameOrTag: nameOrTag,
            species: species,
            breed: breed,
            gender: gender,
            age: age,
            dateOfBirth: dateOfBirth,
            isApproximateAge: isApproximateAge,
            microchipNumber: microchipNumber,
            earTagId: earTagId,
            coatColorMarkings: coatColorMarkings,
            currentWeightKg: currentWeightKg,
            weightRecordedAt: weightRecordedAt,
            history: history,
            notes: notes,
            status: status,
            deceasedAt: deceasedAt,
            allergies: allergies,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String clientId,
            required String nameOrTag,
            required String species,
            Value<String?> breed = const Value.absent(),
            Value<String> gender = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<DateTime?> dateOfBirth = const Value.absent(),
            Value<bool> isApproximateAge = const Value.absent(),
            Value<String?> microchipNumber = const Value.absent(),
            Value<String?> earTagId = const Value.absent(),
            Value<String?> coatColorMarkings = const Value.absent(),
            Value<double?> currentWeightKg = const Value.absent(),
            Value<DateTime?> weightRecordedAt = const Value.absent(),
            Value<String?> history = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> deceasedAt = const Value.absent(),
            Value<String?> allergies = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsTableCompanion.insert(
            id: id,
            tenantId: tenantId,
            clientId: clientId,
            nameOrTag: nameOrTag,
            species: species,
            breed: breed,
            gender: gender,
            age: age,
            dateOfBirth: dateOfBirth,
            isApproximateAge: isApproximateAge,
            microchipNumber: microchipNumber,
            earTagId: earTagId,
            coatColorMarkings: coatColorMarkings,
            currentWeightKg: currentWeightKg,
            weightRecordedAt: weightRecordedAt,
            history: history,
            notes: notes,
            status: status,
            deceasedAt: deceasedAt,
            allergies: allergies,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$PatientsTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {clientId = false,
              clinicalCasesTableRefs = false,
              diagnosesTableRefs = false,
              mediaUploadQueueTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (clinicalCasesTableRefs) db.clinicalCasesTable,
                if (diagnosesTableRefs) db.diagnosesTable,
                if (mediaUploadQueueTableRefs) db.mediaUploadQueueTable
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (clientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.clientId,
                    referencedTable:
                        $$PatientsTableTableReferences._clientIdTable(db),
                    referencedColumn:
                        $$PatientsTableTableReferences._clientIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (clinicalCasesTableRefs)
                    await $_getPrefetchedData<PatientData, $PatientsTableTable,
                            ClinicalCaseData>(
                        currentTable: table,
                        referencedTable: $$PatientsTableTableReferences
                            ._clinicalCasesTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PatientsTableTableReferences(db, table, p0)
                                .clinicalCasesTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.patientId == item.id),
                        typedResults: items),
                  if (diagnosesTableRefs)
                    await $_getPrefetchedData<PatientData, $PatientsTableTable,
                            DiagnosisData>(
                        currentTable: table,
                        referencedTable: $$PatientsTableTableReferences
                            ._diagnosesTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PatientsTableTableReferences(db, table, p0)
                                .diagnosesTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.patientId == item.id),
                        typedResults: items),
                  if (mediaUploadQueueTableRefs)
                    await $_getPrefetchedData<PatientData, $PatientsTableTable,
                            MediaUploadQueueData>(
                        currentTable: table,
                        referencedTable: $$PatientsTableTableReferences
                            ._mediaUploadQueueTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PatientsTableTableReferences(db, table, p0)
                                .mediaUploadQueueTableRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.patientId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PatientsTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PatientsTableTable,
    PatientData,
    $$PatientsTableTableFilterComposer,
    $$PatientsTableTableOrderingComposer,
    $$PatientsTableTableAnnotationComposer,
    $$PatientsTableTableCreateCompanionBuilder,
    $$PatientsTableTableUpdateCompanionBuilder,
    (PatientData, $$PatientsTableTableReferences),
    PatientData,
    PrefetchHooks Function(
        {bool clientId,
        bool clinicalCasesTableRefs,
        bool diagnosesTableRefs,
        bool mediaUploadQueueTableRefs})>;
typedef $$ClinicalCasesTableTableCreateCompanionBuilder
    = ClinicalCasesTableCompanion Function({
  required String id,
  required String tenantId,
  required String caseNumber,
  required String patientId,
  required String primaryVeterinarianId,
  Value<String?> primaryVeterinarianName,
  Value<String> caseType,
  Value<String> status,
  Value<String> priority,
  required String chiefComplaint,
  Value<String?> provisionalDiagnosis,
  Value<String?> finalDiagnosis,
  required DateTime admittedAt,
  Value<DateTime?> dischargedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});
typedef $$ClinicalCasesTableTableUpdateCompanionBuilder
    = ClinicalCasesTableCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> caseNumber,
  Value<String> patientId,
  Value<String> primaryVeterinarianId,
  Value<String?> primaryVeterinarianName,
  Value<String> caseType,
  Value<String> status,
  Value<String> priority,
  Value<String> chiefComplaint,
  Value<String?> provisionalDiagnosis,
  Value<String?> finalDiagnosis,
  Value<DateTime> admittedAt,
  Value<DateTime?> dischargedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<String> syncStatus,
  Value<DateTime?> lastSyncedAt,
  Value<int> rowid,
});

final class $$ClinicalCasesTableTableReferences extends BaseReferences<
    _$AppDatabase, $ClinicalCasesTableTable, ClinicalCaseData> {
  $$ClinicalCasesTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PatientsTableTable _patientIdTable(_$AppDatabase db) =>
      db.patientsTable.createAlias($_aliasNameGenerator(
          db.clinicalCasesTable.patientId, db.patientsTable.id));

  $$PatientsTableTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableTableManager($_db, $_db.patientsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ClinicalProgressNotesTableTable,
      List<ClinicalProgressNoteData>> _clinicalProgressNotesTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.clinicalProgressNotesTable,
          aliasName: $_aliasNameGenerator(
              db.clinicalCasesTable.id, db.clinicalProgressNotesTable.caseId));

  $$ClinicalProgressNotesTableTableProcessedTableManager
      get clinicalProgressNotesTableRefs {
    final manager = $$ClinicalProgressNotesTableTableTableManager(
            $_db, $_db.clinicalProgressNotesTable)
        .filter((f) => f.caseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult
        .readTableOrNull(_clinicalProgressNotesTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$DiagnosesTableTable, List<DiagnosisData>>
      _diagnosesTableRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.diagnosesTable,
              aliasName: $_aliasNameGenerator(
                  db.clinicalCasesTable.id, db.diagnosesTable.caseId));

  $$DiagnosesTableTableProcessedTableManager get diagnosesTableRefs {
    final manager = $$DiagnosesTableTableTableManager($_db, $_db.diagnosesTable)
        .filter((f) => f.caseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_diagnosesTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$MediaUploadQueueTableTable,
      List<MediaUploadQueueData>> _mediaUploadQueueTableRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.mediaUploadQueueTable,
          aliasName: $_aliasNameGenerator(
              db.clinicalCasesTable.id, db.mediaUploadQueueTable.caseId));

  $$MediaUploadQueueTableTableProcessedTableManager
      get mediaUploadQueueTableRefs {
    final manager = $$MediaUploadQueueTableTableTableManager(
            $_db, $_db.mediaUploadQueueTable)
        .filter((f) => f.caseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_mediaUploadQueueTableRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ClinicalCasesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ClinicalCasesTableTable> {
  $$ClinicalCasesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caseNumber => $composableBuilder(
      column: $table.caseNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get primaryVeterinarianId => $composableBuilder(
      column: $table.primaryVeterinarianId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get primaryVeterinarianName => $composableBuilder(
      column: $table.primaryVeterinarianName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get caseType => $composableBuilder(
      column: $table.caseType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chiefComplaint => $composableBuilder(
      column: $table.chiefComplaint,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provisionalDiagnosis => $composableBuilder(
      column: $table.provisionalDiagnosis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get finalDiagnosis => $composableBuilder(
      column: $table.finalDiagnosis,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get admittedAt => $composableBuilder(
      column: $table.admittedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dischargedAt => $composableBuilder(
      column: $table.dischargedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => ColumnFilters(column));

  $$PatientsTableTableFilterComposer get patientId {
    final $$PatientsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patientId,
        referencedTable: $db.patientsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatientsTableTableFilterComposer(
              $db: $db,
              $table: $db.patientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> clinicalProgressNotesTableRefs(
      Expression<bool> Function(
              $$ClinicalProgressNotesTableTableFilterComposer f)
          f) {
    final $$ClinicalProgressNotesTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.clinicalProgressNotesTable,
            getReferencedColumn: (t) => t.caseId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ClinicalProgressNotesTableTableFilterComposer(
                  $db: $db,
                  $table: $db.clinicalProgressNotesTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<bool> diagnosesTableRefs(
      Expression<bool> Function($$DiagnosesTableTableFilterComposer f) f) {
    final $$DiagnosesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.diagnosesTable,
        getReferencedColumn: (t) => t.caseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DiagnosesTableTableFilterComposer(
              $db: $db,
              $table: $db.diagnosesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> mediaUploadQueueTableRefs(
      Expression<bool> Function($$MediaUploadQueueTableTableFilterComposer f)
          f) {
    final $$MediaUploadQueueTableTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.mediaUploadQueueTable,
            getReferencedColumn: (t) => t.caseId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MediaUploadQueueTableTableFilterComposer(
                  $db: $db,
                  $table: $db.mediaUploadQueueTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ClinicalCasesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ClinicalCasesTableTable> {
  $$ClinicalCasesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caseNumber => $composableBuilder(
      column: $table.caseNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get primaryVeterinarianId => $composableBuilder(
      column: $table.primaryVeterinarianId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get primaryVeterinarianName => $composableBuilder(
      column: $table.primaryVeterinarianName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get caseType => $composableBuilder(
      column: $table.caseType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chiefComplaint => $composableBuilder(
      column: $table.chiefComplaint,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provisionalDiagnosis => $composableBuilder(
      column: $table.provisionalDiagnosis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get finalDiagnosis => $composableBuilder(
      column: $table.finalDiagnosis,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get admittedAt => $composableBuilder(
      column: $table.admittedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dischargedAt => $composableBuilder(
      column: $table.dischargedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
      column: $table.deletedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt,
      builder: (column) => ColumnOrderings(column));

  $$PatientsTableTableOrderingComposer get patientId {
    final $$PatientsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patientId,
        referencedTable: $db.patientsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatientsTableTableOrderingComposer(
              $db: $db,
              $table: $db.patientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClinicalCasesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClinicalCasesTableTable> {
  $$ClinicalCasesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get caseNumber => $composableBuilder(
      column: $table.caseNumber, builder: (column) => column);

  GeneratedColumn<String> get primaryVeterinarianId => $composableBuilder(
      column: $table.primaryVeterinarianId, builder: (column) => column);

  GeneratedColumn<String> get primaryVeterinarianName => $composableBuilder(
      column: $table.primaryVeterinarianName, builder: (column) => column);

  GeneratedColumn<String> get caseType =>
      $composableBuilder(column: $table.caseType, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get chiefComplaint => $composableBuilder(
      column: $table.chiefComplaint, builder: (column) => column);

  GeneratedColumn<String> get provisionalDiagnosis => $composableBuilder(
      column: $table.provisionalDiagnosis, builder: (column) => column);

  GeneratedColumn<String> get finalDiagnosis => $composableBuilder(
      column: $table.finalDiagnosis, builder: (column) => column);

  GeneratedColumn<DateTime> get admittedAt => $composableBuilder(
      column: $table.admittedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get dischargedAt => $composableBuilder(
      column: $table.dischargedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSyncedAt => $composableBuilder(
      column: $table.lastSyncedAt, builder: (column) => column);

  $$PatientsTableTableAnnotationComposer get patientId {
    final $$PatientsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patientId,
        referencedTable: $db.patientsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatientsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.patientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> clinicalProgressNotesTableRefs<T extends Object>(
      Expression<T> Function(
              $$ClinicalProgressNotesTableTableAnnotationComposer a)
          f) {
    final $$ClinicalProgressNotesTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.clinicalProgressNotesTable,
            getReferencedColumn: (t) => t.caseId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ClinicalProgressNotesTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.clinicalProgressNotesTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }

  Expression<T> diagnosesTableRefs<T extends Object>(
      Expression<T> Function($$DiagnosesTableTableAnnotationComposer a) f) {
    final $$DiagnosesTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.diagnosesTable,
        getReferencedColumn: (t) => t.caseId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DiagnosesTableTableAnnotationComposer(
              $db: $db,
              $table: $db.diagnosesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> mediaUploadQueueTableRefs<T extends Object>(
      Expression<T> Function($$MediaUploadQueueTableTableAnnotationComposer a)
          f) {
    final $$MediaUploadQueueTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.mediaUploadQueueTable,
            getReferencedColumn: (t) => t.caseId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MediaUploadQueueTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.mediaUploadQueueTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ClinicalCasesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClinicalCasesTableTable,
    ClinicalCaseData,
    $$ClinicalCasesTableTableFilterComposer,
    $$ClinicalCasesTableTableOrderingComposer,
    $$ClinicalCasesTableTableAnnotationComposer,
    $$ClinicalCasesTableTableCreateCompanionBuilder,
    $$ClinicalCasesTableTableUpdateCompanionBuilder,
    (ClinicalCaseData, $$ClinicalCasesTableTableReferences),
    ClinicalCaseData,
    PrefetchHooks Function(
        {bool patientId,
        bool clinicalProgressNotesTableRefs,
        bool diagnosesTableRefs,
        bool mediaUploadQueueTableRefs})> {
  $$ClinicalCasesTableTableTableManager(
      _$AppDatabase db, $ClinicalCasesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClinicalCasesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClinicalCasesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClinicalCasesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> caseNumber = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<String> primaryVeterinarianId = const Value.absent(),
            Value<String?> primaryVeterinarianName = const Value.absent(),
            Value<String> caseType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<String> chiefComplaint = const Value.absent(),
            Value<String?> provisionalDiagnosis = const Value.absent(),
            Value<String?> finalDiagnosis = const Value.absent(),
            Value<DateTime> admittedAt = const Value.absent(),
            Value<DateTime?> dischargedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClinicalCasesTableCompanion(
            id: id,
            tenantId: tenantId,
            caseNumber: caseNumber,
            patientId: patientId,
            primaryVeterinarianId: primaryVeterinarianId,
            primaryVeterinarianName: primaryVeterinarianName,
            caseType: caseType,
            status: status,
            priority: priority,
            chiefComplaint: chiefComplaint,
            provisionalDiagnosis: provisionalDiagnosis,
            finalDiagnosis: finalDiagnosis,
            admittedAt: admittedAt,
            dischargedAt: dischargedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String caseNumber,
            required String patientId,
            required String primaryVeterinarianId,
            Value<String?> primaryVeterinarianName = const Value.absent(),
            Value<String> caseType = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> priority = const Value.absent(),
            required String chiefComplaint,
            Value<String?> provisionalDiagnosis = const Value.absent(),
            Value<String?> finalDiagnosis = const Value.absent(),
            required DateTime admittedAt,
            Value<DateTime?> dischargedAt = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<DateTime?> deletedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime?> lastSyncedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClinicalCasesTableCompanion.insert(
            id: id,
            tenantId: tenantId,
            caseNumber: caseNumber,
            patientId: patientId,
            primaryVeterinarianId: primaryVeterinarianId,
            primaryVeterinarianName: primaryVeterinarianName,
            caseType: caseType,
            status: status,
            priority: priority,
            chiefComplaint: chiefComplaint,
            provisionalDiagnosis: provisionalDiagnosis,
            finalDiagnosis: finalDiagnosis,
            admittedAt: admittedAt,
            dischargedAt: dischargedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            syncStatus: syncStatus,
            lastSyncedAt: lastSyncedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ClinicalCasesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {patientId = false,
              clinicalProgressNotesTableRefs = false,
              diagnosesTableRefs = false,
              mediaUploadQueueTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (clinicalProgressNotesTableRefs)
                  db.clinicalProgressNotesTable,
                if (diagnosesTableRefs) db.diagnosesTable,
                if (mediaUploadQueueTableRefs) db.mediaUploadQueueTable
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (patientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.patientId,
                    referencedTable:
                        $$ClinicalCasesTableTableReferences._patientIdTable(db),
                    referencedColumn: $$ClinicalCasesTableTableReferences
                        ._patientIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (clinicalProgressNotesTableRefs)
                    await $_getPrefetchedData<ClinicalCaseData,
                            $ClinicalCasesTableTable, ClinicalProgressNoteData>(
                        currentTable: table,
                        referencedTable: $$ClinicalCasesTableTableReferences
                            ._clinicalProgressNotesTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClinicalCasesTableTableReferences(db, table, p0)
                                .clinicalProgressNotesTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.caseId == item.id),
                        typedResults: items),
                  if (diagnosesTableRefs)
                    await $_getPrefetchedData<ClinicalCaseData,
                            $ClinicalCasesTableTable, DiagnosisData>(
                        currentTable: table,
                        referencedTable: $$ClinicalCasesTableTableReferences
                            ._diagnosesTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClinicalCasesTableTableReferences(db, table, p0)
                                .diagnosesTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.caseId == item.id),
                        typedResults: items),
                  if (mediaUploadQueueTableRefs)
                    await $_getPrefetchedData<ClinicalCaseData,
                            $ClinicalCasesTableTable, MediaUploadQueueData>(
                        currentTable: table,
                        referencedTable: $$ClinicalCasesTableTableReferences
                            ._mediaUploadQueueTableRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ClinicalCasesTableTableReferences(db, table, p0)
                                .mediaUploadQueueTableRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.caseId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ClinicalCasesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClinicalCasesTableTable,
    ClinicalCaseData,
    $$ClinicalCasesTableTableFilterComposer,
    $$ClinicalCasesTableTableOrderingComposer,
    $$ClinicalCasesTableTableAnnotationComposer,
    $$ClinicalCasesTableTableCreateCompanionBuilder,
    $$ClinicalCasesTableTableUpdateCompanionBuilder,
    (ClinicalCaseData, $$ClinicalCasesTableTableReferences),
    ClinicalCaseData,
    PrefetchHooks Function(
        {bool patientId,
        bool clinicalProgressNotesTableRefs,
        bool diagnosesTableRefs,
        bool mediaUploadQueueTableRefs})>;
typedef $$ClinicalProgressNotesTableTableCreateCompanionBuilder
    = ClinicalProgressNotesTableCompanion Function({
  required String id,
  required String caseId,
  required String patientId,
  required String veterinarianId,
  required String veterinarianName,
  Value<String> noteType,
  Value<String?> subjective,
  Value<String?> objective,
  Value<String?> assessment,
  Value<String?> plan,
  Value<double?> temperatureCelsius,
  Value<int?> heartRateBpm,
  Value<int?> respiratoryRateBpm,
  Value<int?> bodyConditionScore,
  Value<int?> painScore,
  required DateTime recordedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$ClinicalProgressNotesTableTableUpdateCompanionBuilder
    = ClinicalProgressNotesTableCompanion Function({
  Value<String> id,
  Value<String> caseId,
  Value<String> patientId,
  Value<String> veterinarianId,
  Value<String> veterinarianName,
  Value<String> noteType,
  Value<String?> subjective,
  Value<String?> objective,
  Value<String?> assessment,
  Value<String?> plan,
  Value<double?> temperatureCelsius,
  Value<int?> heartRateBpm,
  Value<int?> respiratoryRateBpm,
  Value<int?> bodyConditionScore,
  Value<int?> painScore,
  Value<DateTime> recordedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$ClinicalProgressNotesTableTableReferences extends BaseReferences<
    _$AppDatabase, $ClinicalProgressNotesTableTable, ClinicalProgressNoteData> {
  $$ClinicalProgressNotesTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ClinicalCasesTableTable _caseIdTable(_$AppDatabase db) =>
      db.clinicalCasesTable.createAlias($_aliasNameGenerator(
          db.clinicalProgressNotesTable.caseId, db.clinicalCasesTable.id));

  $$ClinicalCasesTableTableProcessedTableManager get caseId {
    final $_column = $_itemColumn<String>('case_id')!;

    final manager =
        $$ClinicalCasesTableTableTableManager($_db, $_db.clinicalCasesTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_caseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ClinicalProgressNotesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ClinicalProgressNotesTableTable> {
  $$ClinicalProgressNotesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get veterinarianId => $composableBuilder(
      column: $table.veterinarianId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get veterinarianName => $composableBuilder(
      column: $table.veterinarianName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get noteType => $composableBuilder(
      column: $table.noteType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjective => $composableBuilder(
      column: $table.subjective, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get objective => $composableBuilder(
      column: $table.objective, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assessment => $composableBuilder(
      column: $table.assessment, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get plan => $composableBuilder(
      column: $table.plan, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get temperatureCelsius => $composableBuilder(
      column: $table.temperatureCelsius,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get heartRateBpm => $composableBuilder(
      column: $table.heartRateBpm, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get respiratoryRateBpm => $composableBuilder(
      column: $table.respiratoryRateBpm,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get bodyConditionScore => $composableBuilder(
      column: $table.bodyConditionScore,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get painScore => $composableBuilder(
      column: $table.painScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  $$ClinicalCasesTableTableFilterComposer get caseId {
    final $$ClinicalCasesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.caseId,
        referencedTable: $db.clinicalCasesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClinicalCasesTableTableFilterComposer(
              $db: $db,
              $table: $db.clinicalCasesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClinicalProgressNotesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ClinicalProgressNotesTableTable> {
  $$ClinicalProgressNotesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get veterinarianId => $composableBuilder(
      column: $table.veterinarianId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get veterinarianName => $composableBuilder(
      column: $table.veterinarianName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get noteType => $composableBuilder(
      column: $table.noteType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjective => $composableBuilder(
      column: $table.subjective, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get objective => $composableBuilder(
      column: $table.objective, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assessment => $composableBuilder(
      column: $table.assessment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get plan => $composableBuilder(
      column: $table.plan, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get temperatureCelsius => $composableBuilder(
      column: $table.temperatureCelsius,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get heartRateBpm => $composableBuilder(
      column: $table.heartRateBpm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get respiratoryRateBpm => $composableBuilder(
      column: $table.respiratoryRateBpm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get bodyConditionScore => $composableBuilder(
      column: $table.bodyConditionScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get painScore => $composableBuilder(
      column: $table.painScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  $$ClinicalCasesTableTableOrderingComposer get caseId {
    final $$ClinicalCasesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.caseId,
        referencedTable: $db.clinicalCasesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClinicalCasesTableTableOrderingComposer(
              $db: $db,
              $table: $db.clinicalCasesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ClinicalProgressNotesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClinicalProgressNotesTableTable> {
  $$ClinicalProgressNotesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get veterinarianId => $composableBuilder(
      column: $table.veterinarianId, builder: (column) => column);

  GeneratedColumn<String> get veterinarianName => $composableBuilder(
      column: $table.veterinarianName, builder: (column) => column);

  GeneratedColumn<String> get noteType =>
      $composableBuilder(column: $table.noteType, builder: (column) => column);

  GeneratedColumn<String> get subjective => $composableBuilder(
      column: $table.subjective, builder: (column) => column);

  GeneratedColumn<String> get objective =>
      $composableBuilder(column: $table.objective, builder: (column) => column);

  GeneratedColumn<String> get assessment => $composableBuilder(
      column: $table.assessment, builder: (column) => column);

  GeneratedColumn<String> get plan =>
      $composableBuilder(column: $table.plan, builder: (column) => column);

  GeneratedColumn<double> get temperatureCelsius => $composableBuilder(
      column: $table.temperatureCelsius, builder: (column) => column);

  GeneratedColumn<int> get heartRateBpm => $composableBuilder(
      column: $table.heartRateBpm, builder: (column) => column);

  GeneratedColumn<int> get respiratoryRateBpm => $composableBuilder(
      column: $table.respiratoryRateBpm, builder: (column) => column);

  GeneratedColumn<int> get bodyConditionScore => $composableBuilder(
      column: $table.bodyConditionScore, builder: (column) => column);

  GeneratedColumn<int> get painScore =>
      $composableBuilder(column: $table.painScore, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
      column: $table.recordedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  $$ClinicalCasesTableTableAnnotationComposer get caseId {
    final $$ClinicalCasesTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.caseId,
            referencedTable: $db.clinicalCasesTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ClinicalCasesTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.clinicalCasesTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$ClinicalProgressNotesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClinicalProgressNotesTableTable,
    ClinicalProgressNoteData,
    $$ClinicalProgressNotesTableTableFilterComposer,
    $$ClinicalProgressNotesTableTableOrderingComposer,
    $$ClinicalProgressNotesTableTableAnnotationComposer,
    $$ClinicalProgressNotesTableTableCreateCompanionBuilder,
    $$ClinicalProgressNotesTableTableUpdateCompanionBuilder,
    (ClinicalProgressNoteData, $$ClinicalProgressNotesTableTableReferences),
    ClinicalProgressNoteData,
    PrefetchHooks Function({bool caseId})> {
  $$ClinicalProgressNotesTableTableTableManager(
      _$AppDatabase db, $ClinicalProgressNotesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClinicalProgressNotesTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ClinicalProgressNotesTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClinicalProgressNotesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> caseId = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<String> veterinarianId = const Value.absent(),
            Value<String> veterinarianName = const Value.absent(),
            Value<String> noteType = const Value.absent(),
            Value<String?> subjective = const Value.absent(),
            Value<String?> objective = const Value.absent(),
            Value<String?> assessment = const Value.absent(),
            Value<String?> plan = const Value.absent(),
            Value<double?> temperatureCelsius = const Value.absent(),
            Value<int?> heartRateBpm = const Value.absent(),
            Value<int?> respiratoryRateBpm = const Value.absent(),
            Value<int?> bodyConditionScore = const Value.absent(),
            Value<int?> painScore = const Value.absent(),
            Value<DateTime> recordedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClinicalProgressNotesTableCompanion(
            id: id,
            caseId: caseId,
            patientId: patientId,
            veterinarianId: veterinarianId,
            veterinarianName: veterinarianName,
            noteType: noteType,
            subjective: subjective,
            objective: objective,
            assessment: assessment,
            plan: plan,
            temperatureCelsius: temperatureCelsius,
            heartRateBpm: heartRateBpm,
            respiratoryRateBpm: respiratoryRateBpm,
            bodyConditionScore: bodyConditionScore,
            painScore: painScore,
            recordedAt: recordedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String caseId,
            required String patientId,
            required String veterinarianId,
            required String veterinarianName,
            Value<String> noteType = const Value.absent(),
            Value<String?> subjective = const Value.absent(),
            Value<String?> objective = const Value.absent(),
            Value<String?> assessment = const Value.absent(),
            Value<String?> plan = const Value.absent(),
            Value<double?> temperatureCelsius = const Value.absent(),
            Value<int?> heartRateBpm = const Value.absent(),
            Value<int?> respiratoryRateBpm = const Value.absent(),
            Value<int?> bodyConditionScore = const Value.absent(),
            Value<int?> painScore = const Value.absent(),
            required DateTime recordedAt,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClinicalProgressNotesTableCompanion.insert(
            id: id,
            caseId: caseId,
            patientId: patientId,
            veterinarianId: veterinarianId,
            veterinarianName: veterinarianName,
            noteType: noteType,
            subjective: subjective,
            objective: objective,
            assessment: assessment,
            plan: plan,
            temperatureCelsius: temperatureCelsius,
            heartRateBpm: heartRateBpm,
            respiratoryRateBpm: respiratoryRateBpm,
            bodyConditionScore: bodyConditionScore,
            painScore: painScore,
            recordedAt: recordedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ClinicalProgressNotesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({caseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (caseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.caseId,
                    referencedTable: $$ClinicalProgressNotesTableTableReferences
                        ._caseIdTable(db),
                    referencedColumn:
                        $$ClinicalProgressNotesTableTableReferences
                            ._caseIdTable(db)
                            .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ClinicalProgressNotesTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ClinicalProgressNotesTableTable,
        ClinicalProgressNoteData,
        $$ClinicalProgressNotesTableTableFilterComposer,
        $$ClinicalProgressNotesTableTableOrderingComposer,
        $$ClinicalProgressNotesTableTableAnnotationComposer,
        $$ClinicalProgressNotesTableTableCreateCompanionBuilder,
        $$ClinicalProgressNotesTableTableUpdateCompanionBuilder,
        (ClinicalProgressNoteData, $$ClinicalProgressNotesTableTableReferences),
        ClinicalProgressNoteData,
        PrefetchHooks Function({bool caseId})>;
typedef $$DiagnosesTableTableCreateCompanionBuilder = DiagnosesTableCompanion
    Function({
  required String id,
  required String patientId,
  required String userId,
  Value<String?> caseId,
  required String diagnosis,
  Value<String?> description,
  Value<String> status,
  Value<String?> notes,
  required DateTime diagnosedAt,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$DiagnosesTableTableUpdateCompanionBuilder = DiagnosesTableCompanion
    Function({
  Value<String> id,
  Value<String> patientId,
  Value<String> userId,
  Value<String?> caseId,
  Value<String> diagnosis,
  Value<String?> description,
  Value<String> status,
  Value<String?> notes,
  Value<DateTime> diagnosedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> syncStatus,
  Value<int> rowid,
});

final class $$DiagnosesTableTableReferences
    extends BaseReferences<_$AppDatabase, $DiagnosesTableTable, DiagnosisData> {
  $$DiagnosesTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $PatientsTableTable _patientIdTable(_$AppDatabase db) =>
      db.patientsTable.createAlias($_aliasNameGenerator(
          db.diagnosesTable.patientId, db.patientsTable.id));

  $$PatientsTableTableProcessedTableManager get patientId {
    final $_column = $_itemColumn<String>('patient_id')!;

    final manager = $$PatientsTableTableTableManager($_db, $_db.patientsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $ClinicalCasesTableTable _caseIdTable(_$AppDatabase db) =>
      db.clinicalCasesTable.createAlias($_aliasNameGenerator(
          db.diagnosesTable.caseId, db.clinicalCasesTable.id));

  $$ClinicalCasesTableTableProcessedTableManager? get caseId {
    final $_column = $_itemColumn<String>('case_id');
    if ($_column == null) return null;
    final manager =
        $$ClinicalCasesTableTableTableManager($_db, $_db.clinicalCasesTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_caseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$DiagnosesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DiagnosesTableTable> {
  $$DiagnosesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diagnosis => $composableBuilder(
      column: $table.diagnosis, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get diagnosedAt => $composableBuilder(
      column: $table.diagnosedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  $$PatientsTableTableFilterComposer get patientId {
    final $$PatientsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patientId,
        referencedTable: $db.patientsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatientsTableTableFilterComposer(
              $db: $db,
              $table: $db.patientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ClinicalCasesTableTableFilterComposer get caseId {
    final $$ClinicalCasesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.caseId,
        referencedTable: $db.clinicalCasesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClinicalCasesTableTableFilterComposer(
              $db: $db,
              $table: $db.clinicalCasesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DiagnosesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DiagnosesTableTable> {
  $$DiagnosesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diagnosis => $composableBuilder(
      column: $table.diagnosis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get diagnosedAt => $composableBuilder(
      column: $table.diagnosedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  $$PatientsTableTableOrderingComposer get patientId {
    final $$PatientsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patientId,
        referencedTable: $db.patientsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatientsTableTableOrderingComposer(
              $db: $db,
              $table: $db.patientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ClinicalCasesTableTableOrderingComposer get caseId {
    final $$ClinicalCasesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.caseId,
        referencedTable: $db.clinicalCasesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClinicalCasesTableTableOrderingComposer(
              $db: $db,
              $table: $db.clinicalCasesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$DiagnosesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiagnosesTableTable> {
  $$DiagnosesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get diagnosis =>
      $composableBuilder(column: $table.diagnosis, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get diagnosedAt => $composableBuilder(
      column: $table.diagnosedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  $$PatientsTableTableAnnotationComposer get patientId {
    final $$PatientsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patientId,
        referencedTable: $db.patientsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatientsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.patientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$ClinicalCasesTableTableAnnotationComposer get caseId {
    final $$ClinicalCasesTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.caseId,
            referencedTable: $db.clinicalCasesTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ClinicalCasesTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.clinicalCasesTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$DiagnosesTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DiagnosesTableTable,
    DiagnosisData,
    $$DiagnosesTableTableFilterComposer,
    $$DiagnosesTableTableOrderingComposer,
    $$DiagnosesTableTableAnnotationComposer,
    $$DiagnosesTableTableCreateCompanionBuilder,
    $$DiagnosesTableTableUpdateCompanionBuilder,
    (DiagnosisData, $$DiagnosesTableTableReferences),
    DiagnosisData,
    PrefetchHooks Function({bool patientId, bool caseId})> {
  $$DiagnosesTableTableTableManager(
      _$AppDatabase db, $DiagnosesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiagnosesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiagnosesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiagnosesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String?> caseId = const Value.absent(),
            Value<String> diagnosis = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> diagnosedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiagnosesTableCompanion(
            id: id,
            patientId: patientId,
            userId: userId,
            caseId: caseId,
            diagnosis: diagnosis,
            description: description,
            status: status,
            notes: notes,
            diagnosedAt: diagnosedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String patientId,
            required String userId,
            Value<String?> caseId = const Value.absent(),
            required String diagnosis,
            Value<String?> description = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            required DateTime diagnosedAt,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<String> syncStatus = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DiagnosesTableCompanion.insert(
            id: id,
            patientId: patientId,
            userId: userId,
            caseId: caseId,
            diagnosis: diagnosis,
            description: description,
            status: status,
            notes: notes,
            diagnosedAt: diagnosedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            syncStatus: syncStatus,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DiagnosesTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({patientId = false, caseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (patientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.patientId,
                    referencedTable:
                        $$DiagnosesTableTableReferences._patientIdTable(db),
                    referencedColumn:
                        $$DiagnosesTableTableReferences._patientIdTable(db).id,
                  ) as T;
                }
                if (caseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.caseId,
                    referencedTable:
                        $$DiagnosesTableTableReferences._caseIdTable(db),
                    referencedColumn:
                        $$DiagnosesTableTableReferences._caseIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$DiagnosesTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DiagnosesTableTable,
    DiagnosisData,
    $$DiagnosesTableTableFilterComposer,
    $$DiagnosesTableTableOrderingComposer,
    $$DiagnosesTableTableAnnotationComposer,
    $$DiagnosesTableTableCreateCompanionBuilder,
    $$DiagnosesTableTableUpdateCompanionBuilder,
    (DiagnosisData, $$DiagnosesTableTableReferences),
    DiagnosisData,
    PrefetchHooks Function({bool patientId, bool caseId})>;
typedef $$MediaUploadQueueTableTableCreateCompanionBuilder
    = MediaUploadQueueTableCompanion Function({
  required String id,
  required String tenantId,
  Value<String?> caseId,
  Value<String?> patientId,
  required String localFilePath,
  Value<String?> remoteUrl,
  Value<String> mimeType,
  required int fileSizeBytes,
  required String checksumSha256,
  Value<String?> title,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> errorMessage,
  required DateTime createdAt,
  Value<DateTime?> uploadedAt,
  Value<int> rowid,
});
typedef $$MediaUploadQueueTableTableUpdateCompanionBuilder
    = MediaUploadQueueTableCompanion Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String?> caseId,
  Value<String?> patientId,
  Value<String> localFilePath,
  Value<String?> remoteUrl,
  Value<String> mimeType,
  Value<int> fileSizeBytes,
  Value<String> checksumSha256,
  Value<String?> title,
  Value<String> status,
  Value<int> retryCount,
  Value<String?> errorMessage,
  Value<DateTime> createdAt,
  Value<DateTime?> uploadedAt,
  Value<int> rowid,
});

final class $$MediaUploadQueueTableTableReferences extends BaseReferences<
    _$AppDatabase, $MediaUploadQueueTableTable, MediaUploadQueueData> {
  $$MediaUploadQueueTableTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ClinicalCasesTableTable _caseIdTable(_$AppDatabase db) =>
      db.clinicalCasesTable.createAlias($_aliasNameGenerator(
          db.mediaUploadQueueTable.caseId, db.clinicalCasesTable.id));

  $$ClinicalCasesTableTableProcessedTableManager? get caseId {
    final $_column = $_itemColumn<String>('case_id');
    if ($_column == null) return null;
    final manager =
        $$ClinicalCasesTableTableTableManager($_db, $_db.clinicalCasesTable)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_caseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PatientsTableTable _patientIdTable(_$AppDatabase db) =>
      db.patientsTable.createAlias($_aliasNameGenerator(
          db.mediaUploadQueueTable.patientId, db.patientsTable.id));

  $$PatientsTableTableProcessedTableManager? get patientId {
    final $_column = $_itemColumn<String>('patient_id');
    if ($_column == null) return null;
    final manager = $$PatientsTableTableTableManager($_db, $_db.patientsTable)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MediaUploadQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $MediaUploadQueueTableTable> {
  $$MediaUploadQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get localFilePath => $composableBuilder(
      column: $table.localFilePath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksumSha256 => $composableBuilder(
      column: $table.checksumSha256,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => ColumnFilters(column));

  $$ClinicalCasesTableTableFilterComposer get caseId {
    final $$ClinicalCasesTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.caseId,
        referencedTable: $db.clinicalCasesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClinicalCasesTableTableFilterComposer(
              $db: $db,
              $table: $db.clinicalCasesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PatientsTableTableFilterComposer get patientId {
    final $$PatientsTableTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patientId,
        referencedTable: $db.patientsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatientsTableTableFilterComposer(
              $db: $db,
              $table: $db.patientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MediaUploadQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaUploadQueueTableTable> {
  $$MediaUploadQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get localFilePath => $composableBuilder(
      column: $table.localFilePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
      column: $table.remoteUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksumSha256 => $composableBuilder(
      column: $table.checksumSha256,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => ColumnOrderings(column));

  $$ClinicalCasesTableTableOrderingComposer get caseId {
    final $$ClinicalCasesTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.caseId,
        referencedTable: $db.clinicalCasesTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ClinicalCasesTableTableOrderingComposer(
              $db: $db,
              $table: $db.clinicalCasesTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PatientsTableTableOrderingComposer get patientId {
    final $$PatientsTableTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patientId,
        referencedTable: $db.patientsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatientsTableTableOrderingComposer(
              $db: $db,
              $table: $db.patientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MediaUploadQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaUploadQueueTableTable> {
  $$MediaUploadQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
      column: $table.localFilePath, builder: (column) => column);

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
      column: $table.fileSizeBytes, builder: (column) => column);

  GeneratedColumn<String> get checksumSha256 => $composableBuilder(
      column: $table.checksumSha256, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get errorMessage => $composableBuilder(
      column: $table.errorMessage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get uploadedAt => $composableBuilder(
      column: $table.uploadedAt, builder: (column) => column);

  $$ClinicalCasesTableTableAnnotationComposer get caseId {
    final $$ClinicalCasesTableTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.caseId,
            referencedTable: $db.clinicalCasesTable,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ClinicalCasesTableTableAnnotationComposer(
                  $db: $db,
                  $table: $db.clinicalCasesTable,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }

  $$PatientsTableTableAnnotationComposer get patientId {
    final $$PatientsTableTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patientId,
        referencedTable: $db.patientsTable,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PatientsTableTableAnnotationComposer(
              $db: $db,
              $table: $db.patientsTable,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MediaUploadQueueTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MediaUploadQueueTableTable,
    MediaUploadQueueData,
    $$MediaUploadQueueTableTableFilterComposer,
    $$MediaUploadQueueTableTableOrderingComposer,
    $$MediaUploadQueueTableTableAnnotationComposer,
    $$MediaUploadQueueTableTableCreateCompanionBuilder,
    $$MediaUploadQueueTableTableUpdateCompanionBuilder,
    (MediaUploadQueueData, $$MediaUploadQueueTableTableReferences),
    MediaUploadQueueData,
    PrefetchHooks Function({bool caseId, bool patientId})> {
  $$MediaUploadQueueTableTableTableManager(
      _$AppDatabase db, $MediaUploadQueueTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaUploadQueueTableTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaUploadQueueTableTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaUploadQueueTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String?> caseId = const Value.absent(),
            Value<String?> patientId = const Value.absent(),
            Value<String> localFilePath = const Value.absent(),
            Value<String?> remoteUrl = const Value.absent(),
            Value<String> mimeType = const Value.absent(),
            Value<int> fileSizeBytes = const Value.absent(),
            Value<String> checksumSha256 = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> uploadedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaUploadQueueTableCompanion(
            id: id,
            tenantId: tenantId,
            caseId: caseId,
            patientId: patientId,
            localFilePath: localFilePath,
            remoteUrl: remoteUrl,
            mimeType: mimeType,
            fileSizeBytes: fileSizeBytes,
            checksumSha256: checksumSha256,
            title: title,
            status: status,
            retryCount: retryCount,
            errorMessage: errorMessage,
            createdAt: createdAt,
            uploadedAt: uploadedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            Value<String?> caseId = const Value.absent(),
            Value<String?> patientId = const Value.absent(),
            required String localFilePath,
            Value<String?> remoteUrl = const Value.absent(),
            Value<String> mimeType = const Value.absent(),
            required int fileSizeBytes,
            required String checksumSha256,
            Value<String?> title = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> errorMessage = const Value.absent(),
            required DateTime createdAt,
            Value<DateTime?> uploadedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MediaUploadQueueTableCompanion.insert(
            id: id,
            tenantId: tenantId,
            caseId: caseId,
            patientId: patientId,
            localFilePath: localFilePath,
            remoteUrl: remoteUrl,
            mimeType: mimeType,
            fileSizeBytes: fileSizeBytes,
            checksumSha256: checksumSha256,
            title: title,
            status: status,
            retryCount: retryCount,
            errorMessage: errorMessage,
            createdAt: createdAt,
            uploadedAt: uploadedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MediaUploadQueueTableTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({caseId = false, patientId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (caseId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.caseId,
                    referencedTable:
                        $$MediaUploadQueueTableTableReferences._caseIdTable(db),
                    referencedColumn: $$MediaUploadQueueTableTableReferences
                        ._caseIdTable(db)
                        .id,
                  ) as T;
                }
                if (patientId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.patientId,
                    referencedTable: $$MediaUploadQueueTableTableReferences
                        ._patientIdTable(db),
                    referencedColumn: $$MediaUploadQueueTableTableReferences
                        ._patientIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MediaUploadQueueTableTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $MediaUploadQueueTableTable,
        MediaUploadQueueData,
        $$MediaUploadQueueTableTableFilterComposer,
        $$MediaUploadQueueTableTableOrderingComposer,
        $$MediaUploadQueueTableTableAnnotationComposer,
        $$MediaUploadQueueTableTableCreateCompanionBuilder,
        $$MediaUploadQueueTableTableUpdateCompanionBuilder,
        (MediaUploadQueueData, $$MediaUploadQueueTableTableReferences),
        MediaUploadQueueData,
        PrefetchHooks Function({bool caseId, bool patientId})>;
typedef $$SyncQueueTableTableCreateCompanionBuilder = SyncQueueTableCompanion
    Function({
  required String id,
  required String tenantId,
  required String entityType,
  required String entityId,
  required String action,
  required String payload,
  required DateTime clientTimestamp,
  required String idempotencyKey,
  Value<String> status,
  Value<int> attempts,
  Value<String?> lastError,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SyncQueueTableTableUpdateCompanionBuilder = SyncQueueTableCompanion
    Function({
  Value<String> id,
  Value<String> tenantId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<String> payload,
  Value<DateTime> clientTimestamp,
  Value<String> idempotencyKey,
  Value<String> status,
  Value<int> attempts,
  Value<String?> lastError,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$SyncQueueTableTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get clientTimestamp => $composableBuilder(
      column: $table.clientTimestamp,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId => $composableBuilder(
      column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityId => $composableBuilder(
      column: $table.entityId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get action => $composableBuilder(
      column: $table.action, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get clientTimestamp => $composableBuilder(
      column: $table.clientTimestamp,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTableTable> {
  $$SyncQueueTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get clientTimestamp => $composableBuilder(
      column: $table.clientTimestamp, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncQueueTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueTableTable,
    SyncQueueData,
    $$SyncQueueTableTableFilterComposer,
    $$SyncQueueTableTableOrderingComposer,
    $$SyncQueueTableTableAnnotationComposer,
    $$SyncQueueTableTableCreateCompanionBuilder,
    $$SyncQueueTableTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()> {
  $$SyncQueueTableTableTableManager(
      _$AppDatabase db, $SyncQueueTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<String> entityType = const Value.absent(),
            Value<String> entityId = const Value.absent(),
            Value<String> action = const Value.absent(),
            Value<String> payload = const Value.absent(),
            Value<DateTime> clientTimestamp = const Value.absent(),
            Value<String> idempotencyKey = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueTableCompanion(
            id: id,
            tenantId: tenantId,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payload: payload,
            clientTimestamp: clientTimestamp,
            idempotencyKey: idempotencyKey,
            status: status,
            attempts: attempts,
            lastError: lastError,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tenantId,
            required String entityType,
            required String entityId,
            required String action,
            required String payload,
            required DateTime clientTimestamp,
            required String idempotencyKey,
            Value<String> status = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueTableCompanion.insert(
            id: id,
            tenantId: tenantId,
            entityType: entityType,
            entityId: entityId,
            action: action,
            payload: payload,
            clientTimestamp: clientTimestamp,
            idempotencyKey: idempotencyKey,
            status: status,
            attempts: attempts,
            lastError: lastError,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueTableTable,
    SyncQueueData,
    $$SyncQueueTableTableFilterComposer,
    $$SyncQueueTableTableOrderingComposer,
    $$SyncQueueTableTableAnnotationComposer,
    $$SyncQueueTableTableCreateCompanionBuilder,
    $$SyncQueueTableTableUpdateCompanionBuilder,
    (
      SyncQueueData,
      BaseReferences<_$AppDatabase, $SyncQueueTableTable, SyncQueueData>
    ),
    SyncQueueData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientsTableTableTableManager get clientsTable =>
      $$ClientsTableTableTableManager(_db, _db.clientsTable);
  $$PatientsTableTableTableManager get patientsTable =>
      $$PatientsTableTableTableManager(_db, _db.patientsTable);
  $$ClinicalCasesTableTableTableManager get clinicalCasesTable =>
      $$ClinicalCasesTableTableTableManager(_db, _db.clinicalCasesTable);
  $$ClinicalProgressNotesTableTableTableManager
      get clinicalProgressNotesTable =>
          $$ClinicalProgressNotesTableTableTableManager(
              _db, _db.clinicalProgressNotesTable);
  $$DiagnosesTableTableTableManager get diagnosesTable =>
      $$DiagnosesTableTableTableManager(_db, _db.diagnosesTable);
  $$MediaUploadQueueTableTableTableManager get mediaUploadQueueTable =>
      $$MediaUploadQueueTableTableTableManager(_db, _db.mediaUploadQueueTable);
  $$SyncQueueTableTableTableManager get syncQueueTable =>
      $$SyncQueueTableTableTableManager(_db, _db.syncQueueTable);
}
