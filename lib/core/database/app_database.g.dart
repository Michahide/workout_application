// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GymLocationsTable extends GymLocations
    with TableInfo<$GymLocationsTable, GymLocation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GymLocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending_push.name),
      ).withConverter<SyncStatus>($GymLocationsTable.$convertersyncStatus);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    name,
    address,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gym_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<GymLocation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GymLocation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GymLocation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $GymLocationsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $GymLocationsTable createAlias(String alias) {
    return $GymLocationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class GymLocation extends DataClass implements Insertable<GymLocation> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final String name;
  final String? address;
  final String? notes;
  const GymLocation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.name,
    this.address,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $GymLocationsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  GymLocationsCompanion toCompanion(bool nullToAbsent) {
    return GymLocationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      name: Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory GymLocation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GymLocation(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $GymLocationsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      name: serializer.fromJson<String>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $GymLocationsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'name': serializer.toJson<String>(name),
      'address': serializer.toJson<String?>(address),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  GymLocation copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    String? name,
    Value<String?> address = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => GymLocation(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    name: name ?? this.name,
    address: address.present ? address.value : this.address,
    notes: notes.present ? notes.value : this.notes,
  );
  GymLocation copyWithCompanion(GymLocationsCompanion data) {
    return GymLocation(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GymLocation(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    name,
    address,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GymLocation &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.name == this.name &&
          other.address == this.address &&
          other.notes == this.notes);
}

class GymLocationsCompanion extends UpdateCompanion<GymLocation> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String> name;
  final Value<String?> address;
  final Value<String?> notes;
  final Value<int> rowid;
  const GymLocationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GymLocationsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String name,
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<GymLocation> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<String>? name,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GymLocationsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<String>? name,
    Value<String?>? address,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return GymLocationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
      map['sync_status'] = Variable<String>(
        $GymLocationsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GymLocationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, Exercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending_push.name),
      ).withConverter<SyncStatus>($ExercisesTable.$convertersyncStatus);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EquipmentCategory, String>
  equipmentCategory =
      GeneratedColumn<String>(
        'equipment_category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EquipmentCategory>(
        $ExercisesTable.$converterequipmentCategory,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MuscleGroup, String>
  primaryMuscleGroup = GeneratedColumn<String>(
    'primary_muscle_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<MuscleGroup>($ExercisesTable.$converterprimaryMuscleGroup);
  @override
  late final GeneratedColumnWithTypeConverter<List<MuscleGroup>, String>
  secondaryMuscleGroups =
      GeneratedColumn<String>(
        'secondary_muscle_groups',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      ).withConverter<List<MuscleGroup>>(
        $ExercisesTable.$convertersecondaryMuscleGroups,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MuscleSizeCategory, String>
  muscleSizeCategory =
      GeneratedColumn<String>(
        'muscle_size_category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MuscleSizeCategory>(
        $ExercisesTable.$convertermuscleSizeCategory,
      );
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseType, String>
  exerciseType = GeneratedColumn<String>(
    'exercise_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ExerciseType>($ExercisesTable.$converterexerciseType);
  static const VerificationMeta _defaultWorkingRestSecondsMeta =
      const VerificationMeta('defaultWorkingRestSeconds');
  @override
  late final GeneratedColumn<int> defaultWorkingRestSeconds =
      GeneratedColumn<int>(
        'default_working_rest_seconds',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    name,
    equipmentCategory,
    primaryMuscleGroup,
    secondaryMuscleGroups,
    muscleSizeCategory,
    exerciseType,
    defaultWorkingRestSeconds,
    isCustom,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('default_working_rest_seconds')) {
      context.handle(
        _defaultWorkingRestSecondsMeta,
        defaultWorkingRestSeconds.isAcceptableOrUnknown(
          data['default_working_rest_seconds']!,
          _defaultWorkingRestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $ExercisesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      equipmentCategory: $ExercisesTable.$converterequipmentCategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}equipment_category'],
        )!,
      ),
      primaryMuscleGroup: $ExercisesTable.$converterprimaryMuscleGroup.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}primary_muscle_group'],
        )!,
      ),
      secondaryMuscleGroups: $ExercisesTable.$convertersecondaryMuscleGroups
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}secondary_muscle_groups'],
            )!,
          ),
      muscleSizeCategory: $ExercisesTable.$convertermuscleSizeCategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}muscle_size_category'],
        )!,
      ),
      exerciseType: $ExercisesTable.$converterexerciseType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}exercise_type'],
        )!,
      ),
      defaultWorkingRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_working_rest_seconds'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
  static JsonTypeConverter2<EquipmentCategory, String, String>
  $converterequipmentCategory = const EnumNameConverter<EquipmentCategory>(
    EquipmentCategory.values,
  );
  static JsonTypeConverter2<MuscleGroup, String, String>
  $converterprimaryMuscleGroup = const EnumNameConverter<MuscleGroup>(
    MuscleGroup.values,
  );
  static TypeConverter<List<MuscleGroup>, String>
  $convertersecondaryMuscleGroups = const MuscleGroupListConverter();
  static JsonTypeConverter2<MuscleSizeCategory, String, String>
  $convertermuscleSizeCategory = const EnumNameConverter<MuscleSizeCategory>(
    MuscleSizeCategory.values,
  );
  static JsonTypeConverter2<ExerciseType, String, String>
  $converterexerciseType = const EnumNameConverter<ExerciseType>(
    ExerciseType.values,
  );
}

class Exercise extends DataClass implements Insertable<Exercise> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final String name;
  final EquipmentCategory equipmentCategory;
  final MuscleGroup primaryMuscleGroup;
  final List<MuscleGroup> secondaryMuscleGroups;
  final MuscleSizeCategory muscleSizeCategory;
  final ExerciseType exerciseType;
  final int? defaultWorkingRestSeconds;
  final bool isCustom;
  const Exercise({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.name,
    required this.equipmentCategory,
    required this.primaryMuscleGroup,
    required this.secondaryMuscleGroups,
    required this.muscleSizeCategory,
    required this.exerciseType,
    this.defaultWorkingRestSeconds,
    required this.isCustom,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $ExercisesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['name'] = Variable<String>(name);
    {
      map['equipment_category'] = Variable<String>(
        $ExercisesTable.$converterequipmentCategory.toSql(equipmentCategory),
      );
    }
    {
      map['primary_muscle_group'] = Variable<String>(
        $ExercisesTable.$converterprimaryMuscleGroup.toSql(primaryMuscleGroup),
      );
    }
    {
      map['secondary_muscle_groups'] = Variable<String>(
        $ExercisesTable.$convertersecondaryMuscleGroups.toSql(
          secondaryMuscleGroups,
        ),
      );
    }
    {
      map['muscle_size_category'] = Variable<String>(
        $ExercisesTable.$convertermuscleSizeCategory.toSql(muscleSizeCategory),
      );
    }
    {
      map['exercise_type'] = Variable<String>(
        $ExercisesTable.$converterexerciseType.toSql(exerciseType),
      );
    }
    if (!nullToAbsent || defaultWorkingRestSeconds != null) {
      map['default_working_rest_seconds'] = Variable<int>(
        defaultWorkingRestSeconds,
      );
    }
    map['is_custom'] = Variable<bool>(isCustom);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      name: Value(name),
      equipmentCategory: Value(equipmentCategory),
      primaryMuscleGroup: Value(primaryMuscleGroup),
      secondaryMuscleGroups: Value(secondaryMuscleGroups),
      muscleSizeCategory: Value(muscleSizeCategory),
      exerciseType: Value(exerciseType),
      defaultWorkingRestSeconds:
          defaultWorkingRestSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultWorkingRestSeconds),
      isCustom: Value(isCustom),
    );
  }

  factory Exercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exercise(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $ExercisesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      name: serializer.fromJson<String>(json['name']),
      equipmentCategory: $ExercisesTable.$converterequipmentCategory.fromJson(
        serializer.fromJson<String>(json['equipmentCategory']),
      ),
      primaryMuscleGroup: $ExercisesTable.$converterprimaryMuscleGroup.fromJson(
        serializer.fromJson<String>(json['primaryMuscleGroup']),
      ),
      secondaryMuscleGroups: serializer.fromJson<List<MuscleGroup>>(
        json['secondaryMuscleGroups'],
      ),
      muscleSizeCategory: $ExercisesTable.$convertermuscleSizeCategory.fromJson(
        serializer.fromJson<String>(json['muscleSizeCategory']),
      ),
      exerciseType: $ExercisesTable.$converterexerciseType.fromJson(
        serializer.fromJson<String>(json['exerciseType']),
      ),
      defaultWorkingRestSeconds: serializer.fromJson<int?>(
        json['defaultWorkingRestSeconds'],
      ),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $ExercisesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'name': serializer.toJson<String>(name),
      'equipmentCategory': serializer.toJson<String>(
        $ExercisesTable.$converterequipmentCategory.toJson(equipmentCategory),
      ),
      'primaryMuscleGroup': serializer.toJson<String>(
        $ExercisesTable.$converterprimaryMuscleGroup.toJson(primaryMuscleGroup),
      ),
      'secondaryMuscleGroups': serializer.toJson<List<MuscleGroup>>(
        secondaryMuscleGroups,
      ),
      'muscleSizeCategory': serializer.toJson<String>(
        $ExercisesTable.$convertermuscleSizeCategory.toJson(muscleSizeCategory),
      ),
      'exerciseType': serializer.toJson<String>(
        $ExercisesTable.$converterexerciseType.toJson(exerciseType),
      ),
      'defaultWorkingRestSeconds': serializer.toJson<int?>(
        defaultWorkingRestSeconds,
      ),
      'isCustom': serializer.toJson<bool>(isCustom),
    };
  }

  Exercise copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    String? name,
    EquipmentCategory? equipmentCategory,
    MuscleGroup? primaryMuscleGroup,
    List<MuscleGroup>? secondaryMuscleGroups,
    MuscleSizeCategory? muscleSizeCategory,
    ExerciseType? exerciseType,
    Value<int?> defaultWorkingRestSeconds = const Value.absent(),
    bool? isCustom,
  }) => Exercise(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    name: name ?? this.name,
    equipmentCategory: equipmentCategory ?? this.equipmentCategory,
    primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
    secondaryMuscleGroups: secondaryMuscleGroups ?? this.secondaryMuscleGroups,
    muscleSizeCategory: muscleSizeCategory ?? this.muscleSizeCategory,
    exerciseType: exerciseType ?? this.exerciseType,
    defaultWorkingRestSeconds: defaultWorkingRestSeconds.present
        ? defaultWorkingRestSeconds.value
        : this.defaultWorkingRestSeconds,
    isCustom: isCustom ?? this.isCustom,
  );
  Exercise copyWithCompanion(ExercisesCompanion data) {
    return Exercise(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      name: data.name.present ? data.name.value : this.name,
      equipmentCategory: data.equipmentCategory.present
          ? data.equipmentCategory.value
          : this.equipmentCategory,
      primaryMuscleGroup: data.primaryMuscleGroup.present
          ? data.primaryMuscleGroup.value
          : this.primaryMuscleGroup,
      secondaryMuscleGroups: data.secondaryMuscleGroups.present
          ? data.secondaryMuscleGroups.value
          : this.secondaryMuscleGroups,
      muscleSizeCategory: data.muscleSizeCategory.present
          ? data.muscleSizeCategory.value
          : this.muscleSizeCategory,
      exerciseType: data.exerciseType.present
          ? data.exerciseType.value
          : this.exerciseType,
      defaultWorkingRestSeconds: data.defaultWorkingRestSeconds.present
          ? data.defaultWorkingRestSeconds.value
          : this.defaultWorkingRestSeconds,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exercise(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('name: $name, ')
          ..write('equipmentCategory: $equipmentCategory, ')
          ..write('primaryMuscleGroup: $primaryMuscleGroup, ')
          ..write('secondaryMuscleGroups: $secondaryMuscleGroups, ')
          ..write('muscleSizeCategory: $muscleSizeCategory, ')
          ..write('exerciseType: $exerciseType, ')
          ..write('defaultWorkingRestSeconds: $defaultWorkingRestSeconds, ')
          ..write('isCustom: $isCustom')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    name,
    equipmentCategory,
    primaryMuscleGroup,
    secondaryMuscleGroups,
    muscleSizeCategory,
    exerciseType,
    defaultWorkingRestSeconds,
    isCustom,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exercise &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.name == this.name &&
          other.equipmentCategory == this.equipmentCategory &&
          other.primaryMuscleGroup == this.primaryMuscleGroup &&
          other.secondaryMuscleGroups == this.secondaryMuscleGroups &&
          other.muscleSizeCategory == this.muscleSizeCategory &&
          other.exerciseType == this.exerciseType &&
          other.defaultWorkingRestSeconds == this.defaultWorkingRestSeconds &&
          other.isCustom == this.isCustom);
}

class ExercisesCompanion extends UpdateCompanion<Exercise> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String> name;
  final Value<EquipmentCategory> equipmentCategory;
  final Value<MuscleGroup> primaryMuscleGroup;
  final Value<List<MuscleGroup>> secondaryMuscleGroups;
  final Value<MuscleSizeCategory> muscleSizeCategory;
  final Value<ExerciseType> exerciseType;
  final Value<int?> defaultWorkingRestSeconds;
  final Value<bool> isCustom;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.name = const Value.absent(),
    this.equipmentCategory = const Value.absent(),
    this.primaryMuscleGroup = const Value.absent(),
    this.secondaryMuscleGroups = const Value.absent(),
    this.muscleSizeCategory = const Value.absent(),
    this.exerciseType = const Value.absent(),
    this.defaultWorkingRestSeconds = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String name,
    required EquipmentCategory equipmentCategory,
    required MuscleGroup primaryMuscleGroup,
    this.secondaryMuscleGroups = const Value.absent(),
    required MuscleSizeCategory muscleSizeCategory,
    required ExerciseType exerciseType,
    this.defaultWorkingRestSeconds = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       equipmentCategory = Value(equipmentCategory),
       primaryMuscleGroup = Value(primaryMuscleGroup),
       muscleSizeCategory = Value(muscleSizeCategory),
       exerciseType = Value(exerciseType);
  static Insertable<Exercise> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<String>? name,
    Expression<String>? equipmentCategory,
    Expression<String>? primaryMuscleGroup,
    Expression<String>? secondaryMuscleGroups,
    Expression<String>? muscleSizeCategory,
    Expression<String>? exerciseType,
    Expression<int>? defaultWorkingRestSeconds,
    Expression<bool>? isCustom,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (name != null) 'name': name,
      if (equipmentCategory != null) 'equipment_category': equipmentCategory,
      if (primaryMuscleGroup != null)
        'primary_muscle_group': primaryMuscleGroup,
      if (secondaryMuscleGroups != null)
        'secondary_muscle_groups': secondaryMuscleGroups,
      if (muscleSizeCategory != null)
        'muscle_size_category': muscleSizeCategory,
      if (exerciseType != null) 'exercise_type': exerciseType,
      if (defaultWorkingRestSeconds != null)
        'default_working_rest_seconds': defaultWorkingRestSeconds,
      if (isCustom != null) 'is_custom': isCustom,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<String>? name,
    Value<EquipmentCategory>? equipmentCategory,
    Value<MuscleGroup>? primaryMuscleGroup,
    Value<List<MuscleGroup>>? secondaryMuscleGroups,
    Value<MuscleSizeCategory>? muscleSizeCategory,
    Value<ExerciseType>? exerciseType,
    Value<int?>? defaultWorkingRestSeconds,
    Value<bool>? isCustom,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      equipmentCategory: equipmentCategory ?? this.equipmentCategory,
      primaryMuscleGroup: primaryMuscleGroup ?? this.primaryMuscleGroup,
      secondaryMuscleGroups:
          secondaryMuscleGroups ?? this.secondaryMuscleGroups,
      muscleSizeCategory: muscleSizeCategory ?? this.muscleSizeCategory,
      exerciseType: exerciseType ?? this.exerciseType,
      defaultWorkingRestSeconds:
          defaultWorkingRestSeconds ?? this.defaultWorkingRestSeconds,
      isCustom: isCustom ?? this.isCustom,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
      map['sync_status'] = Variable<String>(
        $ExercisesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (equipmentCategory.present) {
      map['equipment_category'] = Variable<String>(
        $ExercisesTable.$converterequipmentCategory.toSql(
          equipmentCategory.value,
        ),
      );
    }
    if (primaryMuscleGroup.present) {
      map['primary_muscle_group'] = Variable<String>(
        $ExercisesTable.$converterprimaryMuscleGroup.toSql(
          primaryMuscleGroup.value,
        ),
      );
    }
    if (secondaryMuscleGroups.present) {
      map['secondary_muscle_groups'] = Variable<String>(
        $ExercisesTable.$convertersecondaryMuscleGroups.toSql(
          secondaryMuscleGroups.value,
        ),
      );
    }
    if (muscleSizeCategory.present) {
      map['muscle_size_category'] = Variable<String>(
        $ExercisesTable.$convertermuscleSizeCategory.toSql(
          muscleSizeCategory.value,
        ),
      );
    }
    if (exerciseType.present) {
      map['exercise_type'] = Variable<String>(
        $ExercisesTable.$converterexerciseType.toSql(exerciseType.value),
      );
    }
    if (defaultWorkingRestSeconds.present) {
      map['default_working_rest_seconds'] = Variable<int>(
        defaultWorkingRestSeconds.value,
      );
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('name: $name, ')
          ..write('equipmentCategory: $equipmentCategory, ')
          ..write('primaryMuscleGroup: $primaryMuscleGroup, ')
          ..write('secondaryMuscleGroups: $secondaryMuscleGroups, ')
          ..write('muscleSizeCategory: $muscleSizeCategory, ')
          ..write('exerciseType: $exerciseType, ')
          ..write('defaultWorkingRestSeconds: $defaultWorkingRestSeconds, ')
          ..write('isCustom: $isCustom, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GymMachinesTable extends GymMachines
    with TableInfo<$GymMachinesTable, GymMachine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GymMachinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending_push.name),
      ).withConverter<SyncStatus>($GymMachinesTable.$convertersyncStatus);
  static const VerificationMeta _gymLocationIdMeta = const VerificationMeta(
    'gymLocationId',
  );
  @override
  late final GeneratedColumn<String> gymLocationId = GeneratedColumn<String>(
    'gym_location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gym_locations (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _brandNameMeta = const VerificationMeta(
    'brandName',
  );
  @override
  late final GeneratedColumn<String> brandName = GeneratedColumn<String>(
    'brand_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WeightUnit, String> weightUnit =
      GeneratedColumn<String>(
        'weight_unit',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(WeightUnit.KG.name),
      ).withConverter<WeightUnit>($GymMachinesTable.$converterweightUnit);
  static const VerificationMeta _pinnedNotesMeta = const VerificationMeta(
    'pinnedNotes',
  );
  @override
  late final GeneratedColumn<String> pinnedNotes = GeneratedColumn<String>(
    'pinned_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    gymLocationId,
    exerciseId,
    brandName,
    weightUnit,
    pinnedNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gym_machines';
  @override
  VerificationContext validateIntegrity(
    Insertable<GymMachine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('gym_location_id')) {
      context.handle(
        _gymLocationIdMeta,
        gymLocationId.isAcceptableOrUnknown(
          data['gym_location_id']!,
          _gymLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('brand_name')) {
      context.handle(
        _brandNameMeta,
        brandName.isAcceptableOrUnknown(data['brand_name']!, _brandNameMeta),
      );
    }
    if (data.containsKey('pinned_notes')) {
      context.handle(
        _pinnedNotesMeta,
        pinnedNotes.isAcceptableOrUnknown(
          data['pinned_notes']!,
          _pinnedNotesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GymMachine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GymMachine(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $GymMachinesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      gymLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gym_location_id'],
      ),
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      brandName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand_name'],
      ),
      weightUnit: $GymMachinesTable.$converterweightUnit.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}weight_unit'],
        )!,
      ),
      pinnedNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pinned_notes'],
      ),
    );
  }

  @override
  $GymMachinesTable createAlias(String alias) {
    return $GymMachinesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
  static JsonTypeConverter2<WeightUnit, String, String> $converterweightUnit =
      const EnumNameConverter<WeightUnit>(WeightUnit.values);
}

class GymMachine extends DataClass implements Insertable<GymMachine> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final String? gymLocationId;
  final String exerciseId;
  final String? brandName;
  final WeightUnit weightUnit;
  final String? pinnedNotes;
  const GymMachine({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    this.gymLocationId,
    required this.exerciseId,
    this.brandName,
    required this.weightUnit,
    this.pinnedNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $GymMachinesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || gymLocationId != null) {
      map['gym_location_id'] = Variable<String>(gymLocationId);
    }
    map['exercise_id'] = Variable<String>(exerciseId);
    if (!nullToAbsent || brandName != null) {
      map['brand_name'] = Variable<String>(brandName);
    }
    {
      map['weight_unit'] = Variable<String>(
        $GymMachinesTable.$converterweightUnit.toSql(weightUnit),
      );
    }
    if (!nullToAbsent || pinnedNotes != null) {
      map['pinned_notes'] = Variable<String>(pinnedNotes);
    }
    return map;
  }

  GymMachinesCompanion toCompanion(bool nullToAbsent) {
    return GymMachinesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      gymLocationId: gymLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(gymLocationId),
      exerciseId: Value(exerciseId),
      brandName: brandName == null && nullToAbsent
          ? const Value.absent()
          : Value(brandName),
      weightUnit: Value(weightUnit),
      pinnedNotes: pinnedNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(pinnedNotes),
    );
  }

  factory GymMachine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GymMachine(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $GymMachinesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      gymLocationId: serializer.fromJson<String?>(json['gymLocationId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      brandName: serializer.fromJson<String?>(json['brandName']),
      weightUnit: $GymMachinesTable.$converterweightUnit.fromJson(
        serializer.fromJson<String>(json['weightUnit']),
      ),
      pinnedNotes: serializer.fromJson<String?>(json['pinnedNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $GymMachinesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'gymLocationId': serializer.toJson<String?>(gymLocationId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'brandName': serializer.toJson<String?>(brandName),
      'weightUnit': serializer.toJson<String>(
        $GymMachinesTable.$converterweightUnit.toJson(weightUnit),
      ),
      'pinnedNotes': serializer.toJson<String?>(pinnedNotes),
    };
  }

  GymMachine copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    Value<String?> gymLocationId = const Value.absent(),
    String? exerciseId,
    Value<String?> brandName = const Value.absent(),
    WeightUnit? weightUnit,
    Value<String?> pinnedNotes = const Value.absent(),
  }) => GymMachine(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    gymLocationId: gymLocationId.present
        ? gymLocationId.value
        : this.gymLocationId,
    exerciseId: exerciseId ?? this.exerciseId,
    brandName: brandName.present ? brandName.value : this.brandName,
    weightUnit: weightUnit ?? this.weightUnit,
    pinnedNotes: pinnedNotes.present ? pinnedNotes.value : this.pinnedNotes,
  );
  GymMachine copyWithCompanion(GymMachinesCompanion data) {
    return GymMachine(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      gymLocationId: data.gymLocationId.present
          ? data.gymLocationId.value
          : this.gymLocationId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      brandName: data.brandName.present ? data.brandName.value : this.brandName,
      weightUnit: data.weightUnit.present
          ? data.weightUnit.value
          : this.weightUnit,
      pinnedNotes: data.pinnedNotes.present
          ? data.pinnedNotes.value
          : this.pinnedNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GymMachine(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('gymLocationId: $gymLocationId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('brandName: $brandName, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('pinnedNotes: $pinnedNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    gymLocationId,
    exerciseId,
    brandName,
    weightUnit,
    pinnedNotes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GymMachine &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.gymLocationId == this.gymLocationId &&
          other.exerciseId == this.exerciseId &&
          other.brandName == this.brandName &&
          other.weightUnit == this.weightUnit &&
          other.pinnedNotes == this.pinnedNotes);
}

class GymMachinesCompanion extends UpdateCompanion<GymMachine> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String?> gymLocationId;
  final Value<String> exerciseId;
  final Value<String?> brandName;
  final Value<WeightUnit> weightUnit;
  final Value<String?> pinnedNotes;
  final Value<int> rowid;
  const GymMachinesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.gymLocationId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.brandName = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.pinnedNotes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GymMachinesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.gymLocationId = const Value.absent(),
    required String exerciseId,
    this.brandName = const Value.absent(),
    this.weightUnit = const Value.absent(),
    this.pinnedNotes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId);
  static Insertable<GymMachine> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<String>? gymLocationId,
    Expression<String>? exerciseId,
    Expression<String>? brandName,
    Expression<String>? weightUnit,
    Expression<String>? pinnedNotes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (gymLocationId != null) 'gym_location_id': gymLocationId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (brandName != null) 'brand_name': brandName,
      if (weightUnit != null) 'weight_unit': weightUnit,
      if (pinnedNotes != null) 'pinned_notes': pinnedNotes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GymMachinesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<String?>? gymLocationId,
    Value<String>? exerciseId,
    Value<String?>? brandName,
    Value<WeightUnit>? weightUnit,
    Value<String?>? pinnedNotes,
    Value<int>? rowid,
  }) {
    return GymMachinesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      gymLocationId: gymLocationId ?? this.gymLocationId,
      exerciseId: exerciseId ?? this.exerciseId,
      brandName: brandName ?? this.brandName,
      weightUnit: weightUnit ?? this.weightUnit,
      pinnedNotes: pinnedNotes ?? this.pinnedNotes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
      map['sync_status'] = Variable<String>(
        $GymMachinesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (gymLocationId.present) {
      map['gym_location_id'] = Variable<String>(gymLocationId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (brandName.present) {
      map['brand_name'] = Variable<String>(brandName.value);
    }
    if (weightUnit.present) {
      map['weight_unit'] = Variable<String>(
        $GymMachinesTable.$converterweightUnit.toSql(weightUnit.value),
      );
    }
    if (pinnedNotes.present) {
      map['pinned_notes'] = Variable<String>(pinnedNotes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GymMachinesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('gymLocationId: $gymLocationId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('brandName: $brandName, ')
          ..write('weightUnit: $weightUnit, ')
          ..write('pinnedNotes: $pinnedNotes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseMediaTable extends ExerciseMedia
    with TableInfo<$ExerciseMediaTable, ExerciseMediaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseMediaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending_push.name),
      ).withConverter<SyncStatus>($ExerciseMediaTable.$convertersyncStatus);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MediaType, String> mediaType =
      GeneratedColumn<String>(
        'media_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MediaType>($ExerciseMediaTable.$convertermediaType);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _thumbnailLocalPathMeta =
      const VerificationMeta('thumbnailLocalPath');
  @override
  late final GeneratedColumn<String> thumbnailLocalPath =
      GeneratedColumn<String>(
        'thumbnail_local_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fileSizeBytesMeta = const VerificationMeta(
    'fileSizeBytes',
  );
  @override
  late final GeneratedColumn<int> fileSizeBytes = GeneratedColumn<int>(
    'file_size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _remoteUrlMeta = const VerificationMeta(
    'remoteUrl',
  );
  @override
  late final GeneratedColumn<String> remoteUrl = GeneratedColumn<String>(
    'remote_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailRemoteUrlMeta =
      const VerificationMeta('thumbnailRemoteUrl');
  @override
  late final GeneratedColumn<String> thumbnailRemoteUrl =
      GeneratedColumn<String>(
        'thumbnail_remote_url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<MediaSyncStatus, String>
  mediaSyncStatus =
      GeneratedColumn<String>(
        'media_sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(MediaSyncStatus.local_only.name),
      ).withConverter<MediaSyncStatus>(
        $ExerciseMediaTable.$convertermediaSyncStatus,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    exerciseId,
    mediaType,
    sortOrder,
    localPath,
    thumbnailLocalPath,
    fileSizeBytes,
    durationSeconds,
    remoteUrl,
    thumbnailRemoteUrl,
    mediaSyncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_media';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseMediaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('thumbnail_local_path')) {
      context.handle(
        _thumbnailLocalPathMeta,
        thumbnailLocalPath.isAcceptableOrUnknown(
          data['thumbnail_local_path']!,
          _thumbnailLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('file_size_bytes')) {
      context.handle(
        _fileSizeBytesMeta,
        fileSizeBytes.isAcceptableOrUnknown(
          data['file_size_bytes']!,
          _fileSizeBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fileSizeBytesMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('remote_url')) {
      context.handle(
        _remoteUrlMeta,
        remoteUrl.isAcceptableOrUnknown(data['remote_url']!, _remoteUrlMeta),
      );
    }
    if (data.containsKey('thumbnail_remote_url')) {
      context.handle(
        _thumbnailRemoteUrlMeta,
        thumbnailRemoteUrl.isAcceptableOrUnknown(
          data['thumbnail_remote_url']!,
          _thumbnailRemoteUrlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseMediaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseMediaData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $ExerciseMediaTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      mediaType: $ExerciseMediaTable.$convertermediaType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}media_type'],
        )!,
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      thumbnailLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_local_path'],
      ),
      fileSizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size_bytes'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      remoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_url'],
      ),
      thumbnailRemoteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_remote_url'],
      ),
      mediaSyncStatus: $ExerciseMediaTable.$convertermediaSyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}media_sync_status'],
        )!,
      ),
    );
  }

  @override
  $ExerciseMediaTable createAlias(String alias) {
    return $ExerciseMediaTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
  static JsonTypeConverter2<MediaType, String, String> $convertermediaType =
      const EnumNameConverter<MediaType>(MediaType.values);
  static JsonTypeConverter2<MediaSyncStatus, String, String>
  $convertermediaSyncStatus = const EnumNameConverter<MediaSyncStatus>(
    MediaSyncStatus.values,
  );
}

class ExerciseMediaData extends DataClass
    implements Insertable<ExerciseMediaData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final String exerciseId;
  final MediaType mediaType;
  final int sortOrder;
  final String localPath;
  final String? thumbnailLocalPath;
  final int fileSizeBytes;
  final int? durationSeconds;
  final String? remoteUrl;
  final String? thumbnailRemoteUrl;
  final MediaSyncStatus mediaSyncStatus;
  const ExerciseMediaData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.exerciseId,
    required this.mediaType,
    required this.sortOrder,
    required this.localPath,
    this.thumbnailLocalPath,
    required this.fileSizeBytes,
    this.durationSeconds,
    this.remoteUrl,
    this.thumbnailRemoteUrl,
    required this.mediaSyncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $ExerciseMediaTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['exercise_id'] = Variable<String>(exerciseId);
    {
      map['media_type'] = Variable<String>(
        $ExerciseMediaTable.$convertermediaType.toSql(mediaType),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || thumbnailLocalPath != null) {
      map['thumbnail_local_path'] = Variable<String>(thumbnailLocalPath);
    }
    map['file_size_bytes'] = Variable<int>(fileSizeBytes);
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || remoteUrl != null) {
      map['remote_url'] = Variable<String>(remoteUrl);
    }
    if (!nullToAbsent || thumbnailRemoteUrl != null) {
      map['thumbnail_remote_url'] = Variable<String>(thumbnailRemoteUrl);
    }
    {
      map['media_sync_status'] = Variable<String>(
        $ExerciseMediaTable.$convertermediaSyncStatus.toSql(mediaSyncStatus),
      );
    }
    return map;
  }

  ExerciseMediaCompanion toCompanion(bool nullToAbsent) {
    return ExerciseMediaCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      exerciseId: Value(exerciseId),
      mediaType: Value(mediaType),
      sortOrder: Value(sortOrder),
      localPath: Value(localPath),
      thumbnailLocalPath: thumbnailLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailLocalPath),
      fileSizeBytes: Value(fileSizeBytes),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      remoteUrl: remoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteUrl),
      thumbnailRemoteUrl: thumbnailRemoteUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailRemoteUrl),
      mediaSyncStatus: Value(mediaSyncStatus),
    );
  }

  factory ExerciseMediaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseMediaData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $ExerciseMediaTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      mediaType: $ExerciseMediaTable.$convertermediaType.fromJson(
        serializer.fromJson<String>(json['mediaType']),
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      localPath: serializer.fromJson<String>(json['localPath']),
      thumbnailLocalPath: serializer.fromJson<String?>(
        json['thumbnailLocalPath'],
      ),
      fileSizeBytes: serializer.fromJson<int>(json['fileSizeBytes']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      remoteUrl: serializer.fromJson<String?>(json['remoteUrl']),
      thumbnailRemoteUrl: serializer.fromJson<String?>(
        json['thumbnailRemoteUrl'],
      ),
      mediaSyncStatus: $ExerciseMediaTable.$convertermediaSyncStatus.fromJson(
        serializer.fromJson<String>(json['mediaSyncStatus']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $ExerciseMediaTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'mediaType': serializer.toJson<String>(
        $ExerciseMediaTable.$convertermediaType.toJson(mediaType),
      ),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'localPath': serializer.toJson<String>(localPath),
      'thumbnailLocalPath': serializer.toJson<String?>(thumbnailLocalPath),
      'fileSizeBytes': serializer.toJson<int>(fileSizeBytes),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'remoteUrl': serializer.toJson<String?>(remoteUrl),
      'thumbnailRemoteUrl': serializer.toJson<String?>(thumbnailRemoteUrl),
      'mediaSyncStatus': serializer.toJson<String>(
        $ExerciseMediaTable.$convertermediaSyncStatus.toJson(mediaSyncStatus),
      ),
    };
  }

  ExerciseMediaData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    String? exerciseId,
    MediaType? mediaType,
    int? sortOrder,
    String? localPath,
    Value<String?> thumbnailLocalPath = const Value.absent(),
    int? fileSizeBytes,
    Value<int?> durationSeconds = const Value.absent(),
    Value<String?> remoteUrl = const Value.absent(),
    Value<String?> thumbnailRemoteUrl = const Value.absent(),
    MediaSyncStatus? mediaSyncStatus,
  }) => ExerciseMediaData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    exerciseId: exerciseId ?? this.exerciseId,
    mediaType: mediaType ?? this.mediaType,
    sortOrder: sortOrder ?? this.sortOrder,
    localPath: localPath ?? this.localPath,
    thumbnailLocalPath: thumbnailLocalPath.present
        ? thumbnailLocalPath.value
        : this.thumbnailLocalPath,
    fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    remoteUrl: remoteUrl.present ? remoteUrl.value : this.remoteUrl,
    thumbnailRemoteUrl: thumbnailRemoteUrl.present
        ? thumbnailRemoteUrl.value
        : this.thumbnailRemoteUrl,
    mediaSyncStatus: mediaSyncStatus ?? this.mediaSyncStatus,
  );
  ExerciseMediaData copyWithCompanion(ExerciseMediaCompanion data) {
    return ExerciseMediaData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      thumbnailLocalPath: data.thumbnailLocalPath.present
          ? data.thumbnailLocalPath.value
          : this.thumbnailLocalPath,
      fileSizeBytes: data.fileSizeBytes.present
          ? data.fileSizeBytes.value
          : this.fileSizeBytes,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      remoteUrl: data.remoteUrl.present ? data.remoteUrl.value : this.remoteUrl,
      thumbnailRemoteUrl: data.thumbnailRemoteUrl.present
          ? data.thumbnailRemoteUrl.value
          : this.thumbnailRemoteUrl,
      mediaSyncStatus: data.mediaSyncStatus.present
          ? data.mediaSyncStatus.value
          : this.mediaSyncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMediaData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('mediaType: $mediaType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('localPath: $localPath, ')
          ..write('thumbnailLocalPath: $thumbnailLocalPath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('thumbnailRemoteUrl: $thumbnailRemoteUrl, ')
          ..write('mediaSyncStatus: $mediaSyncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    exerciseId,
    mediaType,
    sortOrder,
    localPath,
    thumbnailLocalPath,
    fileSizeBytes,
    durationSeconds,
    remoteUrl,
    thumbnailRemoteUrl,
    mediaSyncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseMediaData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.exerciseId == this.exerciseId &&
          other.mediaType == this.mediaType &&
          other.sortOrder == this.sortOrder &&
          other.localPath == this.localPath &&
          other.thumbnailLocalPath == this.thumbnailLocalPath &&
          other.fileSizeBytes == this.fileSizeBytes &&
          other.durationSeconds == this.durationSeconds &&
          other.remoteUrl == this.remoteUrl &&
          other.thumbnailRemoteUrl == this.thumbnailRemoteUrl &&
          other.mediaSyncStatus == this.mediaSyncStatus);
}

class ExerciseMediaCompanion extends UpdateCompanion<ExerciseMediaData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String> exerciseId;
  final Value<MediaType> mediaType;
  final Value<int> sortOrder;
  final Value<String> localPath;
  final Value<String?> thumbnailLocalPath;
  final Value<int> fileSizeBytes;
  final Value<int?> durationSeconds;
  final Value<String?> remoteUrl;
  final Value<String?> thumbnailRemoteUrl;
  final Value<MediaSyncStatus> mediaSyncStatus;
  final Value<int> rowid;
  const ExerciseMediaCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.localPath = const Value.absent(),
    this.thumbnailLocalPath = const Value.absent(),
    this.fileSizeBytes = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.thumbnailRemoteUrl = const Value.absent(),
    this.mediaSyncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseMediaCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String exerciseId,
    required MediaType mediaType,
    this.sortOrder = const Value.absent(),
    required String localPath,
    this.thumbnailLocalPath = const Value.absent(),
    required int fileSizeBytes,
    this.durationSeconds = const Value.absent(),
    this.remoteUrl = const Value.absent(),
    this.thumbnailRemoteUrl = const Value.absent(),
    this.mediaSyncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       mediaType = Value(mediaType),
       localPath = Value(localPath),
       fileSizeBytes = Value(fileSizeBytes);
  static Insertable<ExerciseMediaData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<String>? exerciseId,
    Expression<String>? mediaType,
    Expression<int>? sortOrder,
    Expression<String>? localPath,
    Expression<String>? thumbnailLocalPath,
    Expression<int>? fileSizeBytes,
    Expression<int>? durationSeconds,
    Expression<String>? remoteUrl,
    Expression<String>? thumbnailRemoteUrl,
    Expression<String>? mediaSyncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (mediaType != null) 'media_type': mediaType,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (localPath != null) 'local_path': localPath,
      if (thumbnailLocalPath != null)
        'thumbnail_local_path': thumbnailLocalPath,
      if (fileSizeBytes != null) 'file_size_bytes': fileSizeBytes,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (remoteUrl != null) 'remote_url': remoteUrl,
      if (thumbnailRemoteUrl != null)
        'thumbnail_remote_url': thumbnailRemoteUrl,
      if (mediaSyncStatus != null) 'media_sync_status': mediaSyncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseMediaCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<String>? exerciseId,
    Value<MediaType>? mediaType,
    Value<int>? sortOrder,
    Value<String>? localPath,
    Value<String?>? thumbnailLocalPath,
    Value<int>? fileSizeBytes,
    Value<int?>? durationSeconds,
    Value<String?>? remoteUrl,
    Value<String?>? thumbnailRemoteUrl,
    Value<MediaSyncStatus>? mediaSyncStatus,
    Value<int>? rowid,
  }) {
    return ExerciseMediaCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      exerciseId: exerciseId ?? this.exerciseId,
      mediaType: mediaType ?? this.mediaType,
      sortOrder: sortOrder ?? this.sortOrder,
      localPath: localPath ?? this.localPath,
      thumbnailLocalPath: thumbnailLocalPath ?? this.thumbnailLocalPath,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      thumbnailRemoteUrl: thumbnailRemoteUrl ?? this.thumbnailRemoteUrl,
      mediaSyncStatus: mediaSyncStatus ?? this.mediaSyncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
      map['sync_status'] = Variable<String>(
        $ExerciseMediaTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(
        $ExerciseMediaTable.$convertermediaType.toSql(mediaType.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (thumbnailLocalPath.present) {
      map['thumbnail_local_path'] = Variable<String>(thumbnailLocalPath.value);
    }
    if (fileSizeBytes.present) {
      map['file_size_bytes'] = Variable<int>(fileSizeBytes.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (remoteUrl.present) {
      map['remote_url'] = Variable<String>(remoteUrl.value);
    }
    if (thumbnailRemoteUrl.present) {
      map['thumbnail_remote_url'] = Variable<String>(thumbnailRemoteUrl.value);
    }
    if (mediaSyncStatus.present) {
      map['media_sync_status'] = Variable<String>(
        $ExerciseMediaTable.$convertermediaSyncStatus.toSql(
          mediaSyncStatus.value,
        ),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseMediaCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('mediaType: $mediaType, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('localPath: $localPath, ')
          ..write('thumbnailLocalPath: $thumbnailLocalPath, ')
          ..write('fileSizeBytes: $fileSizeBytes, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('remoteUrl: $remoteUrl, ')
          ..write('thumbnailRemoteUrl: $thumbnailRemoteUrl, ')
          ..write('mediaSyncStatus: $mediaSyncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutPlansTable extends WorkoutPlans
    with TableInfo<$WorkoutPlansTable, WorkoutPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending_push.name),
      ).withConverter<SyncStatus>($WorkoutPlansTable.$convertersyncStatus);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    name,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $WorkoutPlansTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $WorkoutPlansTable createAlias(String alias) {
    return $WorkoutPlansTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class WorkoutPlan extends DataClass implements Insertable<WorkoutPlan> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final String name;
  final String? notes;
  const WorkoutPlan({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.name,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $WorkoutPlansTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  WorkoutPlansCompanion toCompanion(bool nullToAbsent) {
    return WorkoutPlansCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory WorkoutPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutPlan(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $WorkoutPlansTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $WorkoutPlansTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  WorkoutPlan copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    String? name,
    Value<String?> notes = const Value.absent(),
  }) => WorkoutPlan(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
  );
  WorkoutPlan copyWithCompanion(WorkoutPlansCompanion data) {
    return WorkoutPlan(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlan(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('name: $name, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, syncStatus, name, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutPlan &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.name == this.name &&
          other.notes == this.notes);
}

class WorkoutPlansCompanion extends UpdateCompanion<WorkoutPlan> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String> name;
  final Value<String?> notes;
  final Value<int> rowid;
  const WorkoutPlansCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutPlansCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String name,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<WorkoutPlan> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutPlansCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<String>? name,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return WorkoutPlansCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
      map['sync_status'] = Variable<String>(
        $WorkoutPlansTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlansCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutPlanExercisesTable extends WorkoutPlanExercises
    with TableInfo<$WorkoutPlanExercisesTable, WorkoutPlanExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutPlanExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending_push.name),
      ).withConverter<SyncStatus>(
        $WorkoutPlanExercisesTable.$convertersyncStatus,
      );
  static const VerificationMeta _workoutPlanIdMeta = const VerificationMeta(
    'workoutPlanId',
  );
  @override
  late final GeneratedColumn<String> workoutPlanId = GeneratedColumn<String>(
    'workout_plan_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_plans (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _defaultGymMachineIdMeta =
      const VerificationMeta('defaultGymMachineId');
  @override
  late final GeneratedColumn<String> defaultGymMachineId =
      GeneratedColumn<String>(
        'default_gym_machine_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES gym_machines (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supersetGroupIdMeta = const VerificationMeta(
    'supersetGroupId',
  );
  @override
  late final GeneratedColumn<String> supersetGroupId = GeneratedColumn<String>(
    'superset_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetSetsMeta = const VerificationMeta(
    'targetSets',
  );
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
    'target_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _targetRepsMeta = const VerificationMeta(
    'targetReps',
  );
  @override
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
    'target_reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRestSecondsMeta = const VerificationMeta(
    'targetRestSeconds',
  );
  @override
  late final GeneratedColumn<int> targetRestSeconds = GeneratedColumn<int>(
    'target_rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    workoutPlanId,
    exerciseId,
    defaultGymMachineId,
    sortOrder,
    supersetGroupId,
    targetSets,
    targetReps,
    targetRestSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_plan_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutPlanExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('workout_plan_id')) {
      context.handle(
        _workoutPlanIdMeta,
        workoutPlanId.isAcceptableOrUnknown(
          data['workout_plan_id']!,
          _workoutPlanIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutPlanIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('default_gym_machine_id')) {
      context.handle(
        _defaultGymMachineIdMeta,
        defaultGymMachineId.isAcceptableOrUnknown(
          data['default_gym_machine_id']!,
          _defaultGymMachineIdMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('superset_group_id')) {
      context.handle(
        _supersetGroupIdMeta,
        supersetGroupId.isAcceptableOrUnknown(
          data['superset_group_id']!,
          _supersetGroupIdMeta,
        ),
      );
    }
    if (data.containsKey('target_sets')) {
      context.handle(
        _targetSetsMeta,
        targetSets.isAcceptableOrUnknown(data['target_sets']!, _targetSetsMeta),
      );
    }
    if (data.containsKey('target_reps')) {
      context.handle(
        _targetRepsMeta,
        targetReps.isAcceptableOrUnknown(data['target_reps']!, _targetRepsMeta),
      );
    }
    if (data.containsKey('target_rest_seconds')) {
      context.handle(
        _targetRestSecondsMeta,
        targetRestSeconds.isAcceptableOrUnknown(
          data['target_rest_seconds']!,
          _targetRestSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutPlanExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutPlanExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $WorkoutPlanExercisesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      workoutPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_plan_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      defaultGymMachineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_gym_machine_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      supersetGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}superset_group_id'],
      ),
      targetSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_sets'],
      )!,
      targetReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps'],
      ),
      targetRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_rest_seconds'],
      ),
    );
  }

  @override
  $WorkoutPlanExercisesTable createAlias(String alias) {
    return $WorkoutPlanExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class WorkoutPlanExercise extends DataClass
    implements Insertable<WorkoutPlanExercise> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final String workoutPlanId;
  final String exerciseId;
  final String? defaultGymMachineId;
  final int sortOrder;
  final String? supersetGroupId;
  final int targetSets;
  final int? targetReps;
  final int? targetRestSeconds;
  const WorkoutPlanExercise({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.workoutPlanId,
    required this.exerciseId,
    this.defaultGymMachineId,
    required this.sortOrder,
    this.supersetGroupId,
    required this.targetSets,
    this.targetReps,
    this.targetRestSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $WorkoutPlanExercisesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['workout_plan_id'] = Variable<String>(workoutPlanId);
    map['exercise_id'] = Variable<String>(exerciseId);
    if (!nullToAbsent || defaultGymMachineId != null) {
      map['default_gym_machine_id'] = Variable<String>(defaultGymMachineId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || supersetGroupId != null) {
      map['superset_group_id'] = Variable<String>(supersetGroupId);
    }
    map['target_sets'] = Variable<int>(targetSets);
    if (!nullToAbsent || targetReps != null) {
      map['target_reps'] = Variable<int>(targetReps);
    }
    if (!nullToAbsent || targetRestSeconds != null) {
      map['target_rest_seconds'] = Variable<int>(targetRestSeconds);
    }
    return map;
  }

  WorkoutPlanExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutPlanExercisesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      workoutPlanId: Value(workoutPlanId),
      exerciseId: Value(exerciseId),
      defaultGymMachineId: defaultGymMachineId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultGymMachineId),
      sortOrder: Value(sortOrder),
      supersetGroupId: supersetGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetGroupId),
      targetSets: Value(targetSets),
      targetReps: targetReps == null && nullToAbsent
          ? const Value.absent()
          : Value(targetReps),
      targetRestSeconds: targetRestSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRestSeconds),
    );
  }

  factory WorkoutPlanExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutPlanExercise(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $WorkoutPlanExercisesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      workoutPlanId: serializer.fromJson<String>(json['workoutPlanId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      defaultGymMachineId: serializer.fromJson<String?>(
        json['defaultGymMachineId'],
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      supersetGroupId: serializer.fromJson<String?>(json['supersetGroupId']),
      targetSets: serializer.fromJson<int>(json['targetSets']),
      targetReps: serializer.fromJson<int?>(json['targetReps']),
      targetRestSeconds: serializer.fromJson<int?>(json['targetRestSeconds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $WorkoutPlanExercisesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'workoutPlanId': serializer.toJson<String>(workoutPlanId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'defaultGymMachineId': serializer.toJson<String?>(defaultGymMachineId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'supersetGroupId': serializer.toJson<String?>(supersetGroupId),
      'targetSets': serializer.toJson<int>(targetSets),
      'targetReps': serializer.toJson<int?>(targetReps),
      'targetRestSeconds': serializer.toJson<int?>(targetRestSeconds),
    };
  }

  WorkoutPlanExercise copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    String? workoutPlanId,
    String? exerciseId,
    Value<String?> defaultGymMachineId = const Value.absent(),
    int? sortOrder,
    Value<String?> supersetGroupId = const Value.absent(),
    int? targetSets,
    Value<int?> targetReps = const Value.absent(),
    Value<int?> targetRestSeconds = const Value.absent(),
  }) => WorkoutPlanExercise(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    workoutPlanId: workoutPlanId ?? this.workoutPlanId,
    exerciseId: exerciseId ?? this.exerciseId,
    defaultGymMachineId: defaultGymMachineId.present
        ? defaultGymMachineId.value
        : this.defaultGymMachineId,
    sortOrder: sortOrder ?? this.sortOrder,
    supersetGroupId: supersetGroupId.present
        ? supersetGroupId.value
        : this.supersetGroupId,
    targetSets: targetSets ?? this.targetSets,
    targetReps: targetReps.present ? targetReps.value : this.targetReps,
    targetRestSeconds: targetRestSeconds.present
        ? targetRestSeconds.value
        : this.targetRestSeconds,
  );
  WorkoutPlanExercise copyWithCompanion(WorkoutPlanExercisesCompanion data) {
    return WorkoutPlanExercise(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      workoutPlanId: data.workoutPlanId.present
          ? data.workoutPlanId.value
          : this.workoutPlanId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      defaultGymMachineId: data.defaultGymMachineId.present
          ? data.defaultGymMachineId.value
          : this.defaultGymMachineId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      supersetGroupId: data.supersetGroupId.present
          ? data.supersetGroupId.value
          : this.supersetGroupId,
      targetSets: data.targetSets.present
          ? data.targetSets.value
          : this.targetSets,
      targetReps: data.targetReps.present
          ? data.targetReps.value
          : this.targetReps,
      targetRestSeconds: data.targetRestSeconds.present
          ? data.targetRestSeconds.value
          : this.targetRestSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlanExercise(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('workoutPlanId: $workoutPlanId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('defaultGymMachineId: $defaultGymMachineId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('supersetGroupId: $supersetGroupId, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('targetRestSeconds: $targetRestSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    workoutPlanId,
    exerciseId,
    defaultGymMachineId,
    sortOrder,
    supersetGroupId,
    targetSets,
    targetReps,
    targetRestSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutPlanExercise &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.workoutPlanId == this.workoutPlanId &&
          other.exerciseId == this.exerciseId &&
          other.defaultGymMachineId == this.defaultGymMachineId &&
          other.sortOrder == this.sortOrder &&
          other.supersetGroupId == this.supersetGroupId &&
          other.targetSets == this.targetSets &&
          other.targetReps == this.targetReps &&
          other.targetRestSeconds == this.targetRestSeconds);
}

class WorkoutPlanExercisesCompanion
    extends UpdateCompanion<WorkoutPlanExercise> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String> workoutPlanId;
  final Value<String> exerciseId;
  final Value<String?> defaultGymMachineId;
  final Value<int> sortOrder;
  final Value<String?> supersetGroupId;
  final Value<int> targetSets;
  final Value<int?> targetReps;
  final Value<int?> targetRestSeconds;
  final Value<int> rowid;
  const WorkoutPlanExercisesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.workoutPlanId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.defaultGymMachineId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.supersetGroupId = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.targetRestSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutPlanExercisesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String workoutPlanId,
    required String exerciseId,
    this.defaultGymMachineId = const Value.absent(),
    required int sortOrder,
    this.supersetGroupId = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.targetRestSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workoutPlanId = Value(workoutPlanId),
       exerciseId = Value(exerciseId),
       sortOrder = Value(sortOrder);
  static Insertable<WorkoutPlanExercise> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<String>? workoutPlanId,
    Expression<String>? exerciseId,
    Expression<String>? defaultGymMachineId,
    Expression<int>? sortOrder,
    Expression<String>? supersetGroupId,
    Expression<int>? targetSets,
    Expression<int>? targetReps,
    Expression<int>? targetRestSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (workoutPlanId != null) 'workout_plan_id': workoutPlanId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (defaultGymMachineId != null)
        'default_gym_machine_id': defaultGymMachineId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (supersetGroupId != null) 'superset_group_id': supersetGroupId,
      if (targetSets != null) 'target_sets': targetSets,
      if (targetReps != null) 'target_reps': targetReps,
      if (targetRestSeconds != null) 'target_rest_seconds': targetRestSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutPlanExercisesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<String>? workoutPlanId,
    Value<String>? exerciseId,
    Value<String?>? defaultGymMachineId,
    Value<int>? sortOrder,
    Value<String?>? supersetGroupId,
    Value<int>? targetSets,
    Value<int?>? targetReps,
    Value<int?>? targetRestSeconds,
    Value<int>? rowid,
  }) {
    return WorkoutPlanExercisesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      exerciseId: exerciseId ?? this.exerciseId,
      defaultGymMachineId: defaultGymMachineId ?? this.defaultGymMachineId,
      sortOrder: sortOrder ?? this.sortOrder,
      supersetGroupId: supersetGroupId ?? this.supersetGroupId,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      targetRestSeconds: targetRestSeconds ?? this.targetRestSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
      map['sync_status'] = Variable<String>(
        $WorkoutPlanExercisesTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (workoutPlanId.present) {
      map['workout_plan_id'] = Variable<String>(workoutPlanId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (defaultGymMachineId.present) {
      map['default_gym_machine_id'] = Variable<String>(
        defaultGymMachineId.value,
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (supersetGroupId.present) {
      map['superset_group_id'] = Variable<String>(supersetGroupId.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (targetRestSeconds.present) {
      map['target_rest_seconds'] = Variable<int>(targetRestSeconds.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutPlanExercisesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('workoutPlanId: $workoutPlanId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('defaultGymMachineId: $defaultGymMachineId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('supersetGroupId: $supersetGroupId, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('targetRestSeconds: $targetRestSeconds, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending_push.name),
      ).withConverter<SyncStatus>($WorkoutSessionsTable.$convertersyncStatus);
  static const VerificationMeta _workoutPlanIdMeta = const VerificationMeta(
    'workoutPlanId',
  );
  @override
  late final GeneratedColumn<String> workoutPlanId = GeneratedColumn<String>(
    'workout_plan_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_plans (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _gymLocationIdMeta = const VerificationMeta(
    'gymLocationId',
  );
  @override
  late final GeneratedColumn<String> gymLocationId = GeneratedColumn<String>(
    'gym_location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gym_locations (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionNotesMeta = const VerificationMeta(
    'sessionNotes',
  );
  @override
  late final GeneratedColumn<String> sessionNotes = GeneratedColumn<String>(
    'session_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    workoutPlanId,
    gymLocationId,
    startedAt,
    completedAt,
    sessionNotes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('workout_plan_id')) {
      context.handle(
        _workoutPlanIdMeta,
        workoutPlanId.isAcceptableOrUnknown(
          data['workout_plan_id']!,
          _workoutPlanIdMeta,
        ),
      );
    }
    if (data.containsKey('gym_location_id')) {
      context.handle(
        _gymLocationIdMeta,
        gymLocationId.isAcceptableOrUnknown(
          data['gym_location_id']!,
          _gymLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('session_notes')) {
      context.handle(
        _sessionNotesMeta,
        sessionNotes.isAcceptableOrUnknown(
          data['session_notes']!,
          _sessionNotesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $WorkoutSessionsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      workoutPlanId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_plan_id'],
      ),
      gymLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gym_location_id'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      sessionNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_notes'],
      ),
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class WorkoutSession extends DataClass implements Insertable<WorkoutSession> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final String? workoutPlanId;
  final String? gymLocationId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final String? sessionNotes;
  const WorkoutSession({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    this.workoutPlanId,
    this.gymLocationId,
    required this.startedAt,
    this.completedAt,
    this.sessionNotes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $WorkoutSessionsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    if (!nullToAbsent || workoutPlanId != null) {
      map['workout_plan_id'] = Variable<String>(workoutPlanId);
    }
    if (!nullToAbsent || gymLocationId != null) {
      map['gym_location_id'] = Variable<String>(gymLocationId);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || sessionNotes != null) {
      map['session_notes'] = Variable<String>(sessionNotes);
    }
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      workoutPlanId: workoutPlanId == null && nullToAbsent
          ? const Value.absent()
          : Value(workoutPlanId),
      gymLocationId: gymLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(gymLocationId),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      sessionNotes: sessionNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionNotes),
    );
  }

  factory WorkoutSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSession(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $WorkoutSessionsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      workoutPlanId: serializer.fromJson<String?>(json['workoutPlanId']),
      gymLocationId: serializer.fromJson<String?>(json['gymLocationId']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      sessionNotes: serializer.fromJson<String?>(json['sessionNotes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $WorkoutSessionsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'workoutPlanId': serializer.toJson<String?>(workoutPlanId),
      'gymLocationId': serializer.toJson<String?>(gymLocationId),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'sessionNotes': serializer.toJson<String?>(sessionNotes),
    };
  }

  WorkoutSession copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    Value<String?> workoutPlanId = const Value.absent(),
    Value<String?> gymLocationId = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> completedAt = const Value.absent(),
    Value<String?> sessionNotes = const Value.absent(),
  }) => WorkoutSession(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    workoutPlanId: workoutPlanId.present
        ? workoutPlanId.value
        : this.workoutPlanId,
    gymLocationId: gymLocationId.present
        ? gymLocationId.value
        : this.gymLocationId,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    sessionNotes: sessionNotes.present ? sessionNotes.value : this.sessionNotes,
  );
  WorkoutSession copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSession(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      workoutPlanId: data.workoutPlanId.present
          ? data.workoutPlanId.value
          : this.workoutPlanId,
      gymLocationId: data.gymLocationId.present
          ? data.gymLocationId.value
          : this.gymLocationId,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      sessionNotes: data.sessionNotes.present
          ? data.sessionNotes.value
          : this.sessionNotes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSession(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('workoutPlanId: $workoutPlanId, ')
          ..write('gymLocationId: $gymLocationId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('sessionNotes: $sessionNotes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    workoutPlanId,
    gymLocationId,
    startedAt,
    completedAt,
    sessionNotes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSession &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.workoutPlanId == this.workoutPlanId &&
          other.gymLocationId == this.gymLocationId &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.sessionNotes == this.sessionNotes);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSession> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String?> workoutPlanId;
  final Value<String?> gymLocationId;
  final Value<DateTime> startedAt;
  final Value<DateTime?> completedAt;
  final Value<String?> sessionNotes;
  final Value<int> rowid;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.workoutPlanId = const Value.absent(),
    this.gymLocationId = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.sessionNotes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.workoutPlanId = const Value.absent(),
    this.gymLocationId = const Value.absent(),
    required DateTime startedAt,
    this.completedAt = const Value.absent(),
    this.sessionNotes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<WorkoutSession> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<String>? workoutPlanId,
    Expression<String>? gymLocationId,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? sessionNotes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (workoutPlanId != null) 'workout_plan_id': workoutPlanId,
      if (gymLocationId != null) 'gym_location_id': gymLocationId,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (sessionNotes != null) 'session_notes': sessionNotes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<String?>? workoutPlanId,
    Value<String?>? gymLocationId,
    Value<DateTime>? startedAt,
    Value<DateTime?>? completedAt,
    Value<String?>? sessionNotes,
    Value<int>? rowid,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      workoutPlanId: workoutPlanId ?? this.workoutPlanId,
      gymLocationId: gymLocationId ?? this.gymLocationId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
      map['sync_status'] = Variable<String>(
        $WorkoutSessionsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (workoutPlanId.present) {
      map['workout_plan_id'] = Variable<String>(workoutPlanId.value);
    }
    if (gymLocationId.present) {
      map['gym_location_id'] = Variable<String>(gymLocationId.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (sessionNotes.present) {
      map['session_notes'] = Variable<String>(sessionNotes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('workoutPlanId: $workoutPlanId, ')
          ..write('gymLocationId: $gymLocationId, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('sessionNotes: $sessionNotes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionExercisesTable extends WorkoutSessionExercises
    with TableInfo<$WorkoutSessionExercisesTable, WorkoutSessionExercise> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending_push.name),
      ).withConverter<SyncStatus>(
        $WorkoutSessionExercisesTable.$convertersyncStatus,
      );
  static const VerificationMeta _workoutSessionIdMeta = const VerificationMeta(
    'workoutSessionId',
  );
  @override
  late final GeneratedColumn<String> workoutSessionId = GeneratedColumn<String>(
    'workout_session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _gymMachineIdMeta = const VerificationMeta(
    'gymMachineId',
  );
  @override
  late final GeneratedColumn<String> gymMachineId = GeneratedColumn<String>(
    'gym_machine_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gym_machines (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _supersetGroupIdMeta = const VerificationMeta(
    'supersetGroupId',
  );
  @override
  late final GeneratedColumn<String> supersetGroupId = GeneratedColumn<String>(
    'superset_group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    workoutSessionId,
    exerciseId,
    gymMachineId,
    sortOrder,
    supersetGroupId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_session_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSessionExercise> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('workout_session_id')) {
      context.handle(
        _workoutSessionIdMeta,
        workoutSessionId.isAcceptableOrUnknown(
          data['workout_session_id']!,
          _workoutSessionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutSessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('gym_machine_id')) {
      context.handle(
        _gymMachineIdMeta,
        gymMachineId.isAcceptableOrUnknown(
          data['gym_machine_id']!,
          _gymMachineIdMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('superset_group_id')) {
      context.handle(
        _supersetGroupIdMeta,
        supersetGroupId.isAcceptableOrUnknown(
          data['superset_group_id']!,
          _supersetGroupIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSessionExercise map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSessionExercise(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $WorkoutSessionExercisesTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      workoutSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      gymMachineId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gym_machine_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      supersetGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}superset_group_id'],
      ),
    );
  }

  @override
  $WorkoutSessionExercisesTable createAlias(String alias) {
    return $WorkoutSessionExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class WorkoutSessionExercise extends DataClass
    implements Insertable<WorkoutSessionExercise> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final String workoutSessionId;
  final String exerciseId;
  final String? gymMachineId;
  final int sortOrder;
  final String? supersetGroupId;
  const WorkoutSessionExercise({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.workoutSessionId,
    required this.exerciseId,
    this.gymMachineId,
    required this.sortOrder,
    this.supersetGroupId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $WorkoutSessionExercisesTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['workout_session_id'] = Variable<String>(workoutSessionId);
    map['exercise_id'] = Variable<String>(exerciseId);
    if (!nullToAbsent || gymMachineId != null) {
      map['gym_machine_id'] = Variable<String>(gymMachineId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || supersetGroupId != null) {
      map['superset_group_id'] = Variable<String>(supersetGroupId);
    }
    return map;
  }

  WorkoutSessionExercisesCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionExercisesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      workoutSessionId: Value(workoutSessionId),
      exerciseId: Value(exerciseId),
      gymMachineId: gymMachineId == null && nullToAbsent
          ? const Value.absent()
          : Value(gymMachineId),
      sortOrder: Value(sortOrder),
      supersetGroupId: supersetGroupId == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetGroupId),
    );
  }

  factory WorkoutSessionExercise.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSessionExercise(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $WorkoutSessionExercisesTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      workoutSessionId: serializer.fromJson<String>(json['workoutSessionId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      gymMachineId: serializer.fromJson<String?>(json['gymMachineId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      supersetGroupId: serializer.fromJson<String?>(json['supersetGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $WorkoutSessionExercisesTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'workoutSessionId': serializer.toJson<String>(workoutSessionId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'gymMachineId': serializer.toJson<String?>(gymMachineId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'supersetGroupId': serializer.toJson<String?>(supersetGroupId),
    };
  }

  WorkoutSessionExercise copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    String? workoutSessionId,
    String? exerciseId,
    Value<String?> gymMachineId = const Value.absent(),
    int? sortOrder,
    Value<String?> supersetGroupId = const Value.absent(),
  }) => WorkoutSessionExercise(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    workoutSessionId: workoutSessionId ?? this.workoutSessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    gymMachineId: gymMachineId.present ? gymMachineId.value : this.gymMachineId,
    sortOrder: sortOrder ?? this.sortOrder,
    supersetGroupId: supersetGroupId.present
        ? supersetGroupId.value
        : this.supersetGroupId,
  );
  WorkoutSessionExercise copyWithCompanion(
    WorkoutSessionExercisesCompanion data,
  ) {
    return WorkoutSessionExercise(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      workoutSessionId: data.workoutSessionId.present
          ? data.workoutSessionId.value
          : this.workoutSessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      gymMachineId: data.gymMachineId.present
          ? data.gymMachineId.value
          : this.gymMachineId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      supersetGroupId: data.supersetGroupId.present
          ? data.supersetGroupId.value
          : this.supersetGroupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionExercise(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('workoutSessionId: $workoutSessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('gymMachineId: $gymMachineId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('supersetGroupId: $supersetGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    workoutSessionId,
    exerciseId,
    gymMachineId,
    sortOrder,
    supersetGroupId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSessionExercise &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.workoutSessionId == this.workoutSessionId &&
          other.exerciseId == this.exerciseId &&
          other.gymMachineId == this.gymMachineId &&
          other.sortOrder == this.sortOrder &&
          other.supersetGroupId == this.supersetGroupId);
}

class WorkoutSessionExercisesCompanion
    extends UpdateCompanion<WorkoutSessionExercise> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String> workoutSessionId;
  final Value<String> exerciseId;
  final Value<String?> gymMachineId;
  final Value<int> sortOrder;
  final Value<String?> supersetGroupId;
  final Value<int> rowid;
  const WorkoutSessionExercisesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.workoutSessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.gymMachineId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.supersetGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSessionExercisesCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String workoutSessionId,
    required String exerciseId,
    this.gymMachineId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.supersetGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workoutSessionId = Value(workoutSessionId),
       exerciseId = Value(exerciseId);
  static Insertable<WorkoutSessionExercise> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<String>? workoutSessionId,
    Expression<String>? exerciseId,
    Expression<String>? gymMachineId,
    Expression<int>? sortOrder,
    Expression<String>? supersetGroupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (workoutSessionId != null) 'workout_session_id': workoutSessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (gymMachineId != null) 'gym_machine_id': gymMachineId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (supersetGroupId != null) 'superset_group_id': supersetGroupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSessionExercisesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<String>? workoutSessionId,
    Value<String>? exerciseId,
    Value<String?>? gymMachineId,
    Value<int>? sortOrder,
    Value<String?>? supersetGroupId,
    Value<int>? rowid,
  }) {
    return WorkoutSessionExercisesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      workoutSessionId: workoutSessionId ?? this.workoutSessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      gymMachineId: gymMachineId ?? this.gymMachineId,
      sortOrder: sortOrder ?? this.sortOrder,
      supersetGroupId: supersetGroupId ?? this.supersetGroupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
      map['sync_status'] = Variable<String>(
        $WorkoutSessionExercisesTable.$convertersyncStatus.toSql(
          syncStatus.value,
        ),
      );
    }
    if (workoutSessionId.present) {
      map['workout_session_id'] = Variable<String>(workoutSessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (gymMachineId.present) {
      map['gym_machine_id'] = Variable<String>(gymMachineId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (supersetGroupId.present) {
      map['superset_group_id'] = Variable<String>(supersetGroupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionExercisesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('workoutSessionId: $workoutSessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('gymMachineId: $gymMachineId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('supersetGroupId: $supersetGroupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSet> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending_push.name),
      ).withConverter<SyncStatus>($WorkoutSetsTable.$convertersyncStatus);
  static const VerificationMeta _workoutSessionExerciseIdMeta =
      const VerificationMeta('workoutSessionExerciseId');
  @override
  late final GeneratedColumn<String> workoutSessionExerciseId =
      GeneratedColumn<String>(
        'workout_session_exercise_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES workout_session_exercises (id) ON DELETE CASCADE',
        ),
      );
  static const VerificationMeta _setNumberMeta = const VerificationMeta(
    'setNumber',
  );
  @override
  late final GeneratedColumn<int> setNumber = GeneratedColumn<int>(
    'set_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentSetIdMeta = const VerificationMeta(
    'parentSetId',
  );
  @override
  late final GeneratedColumn<String> parentSetId = GeneratedColumn<String>(
    'parent_set_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sets (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<SetType, String> setType =
      GeneratedColumn<String>(
        'set_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SetType.normal.name),
      ).withConverter<SetType>($WorkoutSetsTable.$convertersetType);
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AssistanceType, String>
  assistanceType = GeneratedColumn<String>(
    'assistance_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: Constant(AssistanceType.solo.name),
  ).withConverter<AssistanceType>($WorkoutSetsTable.$converterassistanceType);
  static const VerificationMeta _targetRestSecondsMeta = const VerificationMeta(
    'targetRestSeconds',
  );
  @override
  late final GeneratedColumn<int> targetRestSeconds = GeneratedColumn<int>(
    'target_rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actualRestSecondsMeta = const VerificationMeta(
    'actualRestSeconds',
  );
  @override
  late final GeneratedColumn<int> actualRestSeconds = GeneratedColumn<int>(
    'actual_rest_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    workoutSessionExerciseId,
    setNumber,
    parentSetId,
    setType,
    weight,
    reps,
    durationSeconds,
    distanceMeters,
    rpe,
    assistanceType,
    targetRestSeconds,
    actualRestSeconds,
    isCompleted,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSet> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('workout_session_exercise_id')) {
      context.handle(
        _workoutSessionExerciseIdMeta,
        workoutSessionExerciseId.isAcceptableOrUnknown(
          data['workout_session_exercise_id']!,
          _workoutSessionExerciseIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workoutSessionExerciseIdMeta);
    }
    if (data.containsKey('set_number')) {
      context.handle(
        _setNumberMeta,
        setNumber.isAcceptableOrUnknown(data['set_number']!, _setNumberMeta),
      );
    } else if (isInserting) {
      context.missing(_setNumberMeta);
    }
    if (data.containsKey('parent_set_id')) {
      context.handle(
        _parentSetIdMeta,
        parentSetId.isAcceptableOrUnknown(
          data['parent_set_id']!,
          _parentSetIdMeta,
        ),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('target_rest_seconds')) {
      context.handle(
        _targetRestSecondsMeta,
        targetRestSeconds.isAcceptableOrUnknown(
          data['target_rest_seconds']!,
          _targetRestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('actual_rest_seconds')) {
      context.handle(
        _actualRestSecondsMeta,
        actualRestSeconds.isAcceptableOrUnknown(
          data['actual_rest_seconds']!,
          _actualRestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSet map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSet(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $WorkoutSetsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      workoutSessionExerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workout_session_exercise_id'],
      )!,
      setNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_number'],
      )!,
      parentSetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_set_id'],
      ),
      setType: $WorkoutSetsTable.$convertersetType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}set_type'],
        )!,
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      ),
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      ),
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rpe'],
      ),
      assistanceType: $WorkoutSetsTable.$converterassistanceType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}assistance_type'],
        )!,
      ),
      targetRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_rest_seconds'],
      ),
      actualRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_rest_seconds'],
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
  static JsonTypeConverter2<SetType, String, String> $convertersetType =
      const EnumNameConverter<SetType>(SetType.values);
  static JsonTypeConverter2<AssistanceType, String, String>
  $converterassistanceType = const EnumNameConverter<AssistanceType>(
    AssistanceType.values,
  );
}

class WorkoutSet extends DataClass implements Insertable<WorkoutSet> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final String workoutSessionExerciseId;
  final int setNumber;
  final String? parentSetId;
  final SetType setType;
  final double? weight;
  final int? reps;
  final int? durationSeconds;
  final double? distanceMeters;
  final double? rpe;
  final AssistanceType assistanceType;
  final int? targetRestSeconds;
  final int? actualRestSeconds;
  final bool isCompleted;
  final DateTime? completedAt;
  const WorkoutSet({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.workoutSessionExerciseId,
    required this.setNumber,
    this.parentSetId,
    required this.setType,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.distanceMeters,
    this.rpe,
    required this.assistanceType,
    this.targetRestSeconds,
    this.actualRestSeconds,
    required this.isCompleted,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $WorkoutSetsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['workout_session_exercise_id'] = Variable<String>(
      workoutSessionExerciseId,
    );
    map['set_number'] = Variable<int>(setNumber);
    if (!nullToAbsent || parentSetId != null) {
      map['parent_set_id'] = Variable<String>(parentSetId);
    }
    {
      map['set_type'] = Variable<String>(
        $WorkoutSetsTable.$convertersetType.toSql(setType),
      );
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<double>(weight);
    }
    if (!nullToAbsent || reps != null) {
      map['reps'] = Variable<int>(reps);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<double>(distanceMeters);
    }
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<double>(rpe);
    }
    {
      map['assistance_type'] = Variable<String>(
        $WorkoutSetsTable.$converterassistanceType.toSql(assistanceType),
      );
    }
    if (!nullToAbsent || targetRestSeconds != null) {
      map['target_rest_seconds'] = Variable<int>(targetRestSeconds);
    }
    if (!nullToAbsent || actualRestSeconds != null) {
      map['actual_rest_seconds'] = Variable<int>(actualRestSeconds);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      workoutSessionExerciseId: Value(workoutSessionExerciseId),
      setNumber: Value(setNumber),
      parentSetId: parentSetId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentSetId),
      setType: Value(setType),
      weight: weight == null && nullToAbsent
          ? const Value.absent()
          : Value(weight),
      reps: reps == null && nullToAbsent ? const Value.absent() : Value(reps),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      distanceMeters: distanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMeters),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      assistanceType: Value(assistanceType),
      targetRestSeconds: targetRestSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRestSeconds),
      actualRestSeconds: actualRestSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(actualRestSeconds),
      isCompleted: Value(isCompleted),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory WorkoutSet.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSet(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $WorkoutSetsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      workoutSessionExerciseId: serializer.fromJson<String>(
        json['workoutSessionExerciseId'],
      ),
      setNumber: serializer.fromJson<int>(json['setNumber']),
      parentSetId: serializer.fromJson<String?>(json['parentSetId']),
      setType: $WorkoutSetsTable.$convertersetType.fromJson(
        serializer.fromJson<String>(json['setType']),
      ),
      weight: serializer.fromJson<double?>(json['weight']),
      reps: serializer.fromJson<int?>(json['reps']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      distanceMeters: serializer.fromJson<double?>(json['distanceMeters']),
      rpe: serializer.fromJson<double?>(json['rpe']),
      assistanceType: $WorkoutSetsTable.$converterassistanceType.fromJson(
        serializer.fromJson<String>(json['assistanceType']),
      ),
      targetRestSeconds: serializer.fromJson<int?>(json['targetRestSeconds']),
      actualRestSeconds: serializer.fromJson<int?>(json['actualRestSeconds']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $WorkoutSetsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'workoutSessionExerciseId': serializer.toJson<String>(
        workoutSessionExerciseId,
      ),
      'setNumber': serializer.toJson<int>(setNumber),
      'parentSetId': serializer.toJson<String?>(parentSetId),
      'setType': serializer.toJson<String>(
        $WorkoutSetsTable.$convertersetType.toJson(setType),
      ),
      'weight': serializer.toJson<double?>(weight),
      'reps': serializer.toJson<int?>(reps),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'distanceMeters': serializer.toJson<double?>(distanceMeters),
      'rpe': serializer.toJson<double?>(rpe),
      'assistanceType': serializer.toJson<String>(
        $WorkoutSetsTable.$converterassistanceType.toJson(assistanceType),
      ),
      'targetRestSeconds': serializer.toJson<int?>(targetRestSeconds),
      'actualRestSeconds': serializer.toJson<int?>(actualRestSeconds),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  WorkoutSet copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    String? workoutSessionExerciseId,
    int? setNumber,
    Value<String?> parentSetId = const Value.absent(),
    SetType? setType,
    Value<double?> weight = const Value.absent(),
    Value<int?> reps = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<double?> distanceMeters = const Value.absent(),
    Value<double?> rpe = const Value.absent(),
    AssistanceType? assistanceType,
    Value<int?> targetRestSeconds = const Value.absent(),
    Value<int?> actualRestSeconds = const Value.absent(),
    bool? isCompleted,
    Value<DateTime?> completedAt = const Value.absent(),
  }) => WorkoutSet(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    workoutSessionExerciseId:
        workoutSessionExerciseId ?? this.workoutSessionExerciseId,
    setNumber: setNumber ?? this.setNumber,
    parentSetId: parentSetId.present ? parentSetId.value : this.parentSetId,
    setType: setType ?? this.setType,
    weight: weight.present ? weight.value : this.weight,
    reps: reps.present ? reps.value : this.reps,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    distanceMeters: distanceMeters.present
        ? distanceMeters.value
        : this.distanceMeters,
    rpe: rpe.present ? rpe.value : this.rpe,
    assistanceType: assistanceType ?? this.assistanceType,
    targetRestSeconds: targetRestSeconds.present
        ? targetRestSeconds.value
        : this.targetRestSeconds,
    actualRestSeconds: actualRestSeconds.present
        ? actualRestSeconds.value
        : this.actualRestSeconds,
    isCompleted: isCompleted ?? this.isCompleted,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  WorkoutSet copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSet(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      workoutSessionExerciseId: data.workoutSessionExerciseId.present
          ? data.workoutSessionExerciseId.value
          : this.workoutSessionExerciseId,
      setNumber: data.setNumber.present ? data.setNumber.value : this.setNumber,
      parentSetId: data.parentSetId.present
          ? data.parentSetId.value
          : this.parentSetId,
      setType: data.setType.present ? data.setType.value : this.setType,
      weight: data.weight.present ? data.weight.value : this.weight,
      reps: data.reps.present ? data.reps.value : this.reps,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      assistanceType: data.assistanceType.present
          ? data.assistanceType.value
          : this.assistanceType,
      targetRestSeconds: data.targetRestSeconds.present
          ? data.targetRestSeconds.value
          : this.targetRestSeconds,
      actualRestSeconds: data.actualRestSeconds.present
          ? data.actualRestSeconds.value
          : this.actualRestSeconds,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSet(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('workoutSessionExerciseId: $workoutSessionExerciseId, ')
          ..write('setNumber: $setNumber, ')
          ..write('parentSetId: $parentSetId, ')
          ..write('setType: $setType, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('rpe: $rpe, ')
          ..write('assistanceType: $assistanceType, ')
          ..write('targetRestSeconds: $targetRestSeconds, ')
          ..write('actualRestSeconds: $actualRestSeconds, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    workoutSessionExerciseId,
    setNumber,
    parentSetId,
    setType,
    weight,
    reps,
    durationSeconds,
    distanceMeters,
    rpe,
    assistanceType,
    targetRestSeconds,
    actualRestSeconds,
    isCompleted,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSet &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.workoutSessionExerciseId == this.workoutSessionExerciseId &&
          other.setNumber == this.setNumber &&
          other.parentSetId == this.parentSetId &&
          other.setType == this.setType &&
          other.weight == this.weight &&
          other.reps == this.reps &&
          other.durationSeconds == this.durationSeconds &&
          other.distanceMeters == this.distanceMeters &&
          other.rpe == this.rpe &&
          other.assistanceType == this.assistanceType &&
          other.targetRestSeconds == this.targetRestSeconds &&
          other.actualRestSeconds == this.actualRestSeconds &&
          other.isCompleted == this.isCompleted &&
          other.completedAt == this.completedAt);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSet> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<String> workoutSessionExerciseId;
  final Value<int> setNumber;
  final Value<String?> parentSetId;
  final Value<SetType> setType;
  final Value<double?> weight;
  final Value<int?> reps;
  final Value<int?> durationSeconds;
  final Value<double?> distanceMeters;
  final Value<double?> rpe;
  final Value<AssistanceType> assistanceType;
  final Value<int?> targetRestSeconds;
  final Value<int?> actualRestSeconds;
  final Value<bool> isCompleted;
  final Value<DateTime?> completedAt;
  final Value<int> rowid;
  const WorkoutSetsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.workoutSessionExerciseId = const Value.absent(),
    this.setNumber = const Value.absent(),
    this.parentSetId = const Value.absent(),
    this.setType = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.rpe = const Value.absent(),
    this.assistanceType = const Value.absent(),
    this.targetRestSeconds = const Value.absent(),
    this.actualRestSeconds = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String workoutSessionExerciseId,
    required int setNumber,
    this.parentSetId = const Value.absent(),
    this.setType = const Value.absent(),
    this.weight = const Value.absent(),
    this.reps = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.rpe = const Value.absent(),
    this.assistanceType = const Value.absent(),
    this.targetRestSeconds = const Value.absent(),
    this.actualRestSeconds = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : workoutSessionExerciseId = Value(workoutSessionExerciseId),
       setNumber = Value(setNumber);
  static Insertable<WorkoutSet> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<String>? workoutSessionExerciseId,
    Expression<int>? setNumber,
    Expression<String>? parentSetId,
    Expression<String>? setType,
    Expression<double>? weight,
    Expression<int>? reps,
    Expression<int>? durationSeconds,
    Expression<double>? distanceMeters,
    Expression<double>? rpe,
    Expression<String>? assistanceType,
    Expression<int>? targetRestSeconds,
    Expression<int>? actualRestSeconds,
    Expression<bool>? isCompleted,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (workoutSessionExerciseId != null)
        'workout_session_exercise_id': workoutSessionExerciseId,
      if (setNumber != null) 'set_number': setNumber,
      if (parentSetId != null) 'parent_set_id': parentSetId,
      if (setType != null) 'set_type': setType,
      if (weight != null) 'weight': weight,
      if (reps != null) 'reps': reps,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (rpe != null) 'rpe': rpe,
      if (assistanceType != null) 'assistance_type': assistanceType,
      if (targetRestSeconds != null) 'target_rest_seconds': targetRestSeconds,
      if (actualRestSeconds != null) 'actual_rest_seconds': actualRestSeconds,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSetsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<String>? workoutSessionExerciseId,
    Value<int>? setNumber,
    Value<String?>? parentSetId,
    Value<SetType>? setType,
    Value<double?>? weight,
    Value<int?>? reps,
    Value<int?>? durationSeconds,
    Value<double?>? distanceMeters,
    Value<double?>? rpe,
    Value<AssistanceType>? assistanceType,
    Value<int?>? targetRestSeconds,
    Value<int?>? actualRestSeconds,
    Value<bool>? isCompleted,
    Value<DateTime?>? completedAt,
    Value<int>? rowid,
  }) {
    return WorkoutSetsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      workoutSessionExerciseId:
          workoutSessionExerciseId ?? this.workoutSessionExerciseId,
      setNumber: setNumber ?? this.setNumber,
      parentSetId: parentSetId ?? this.parentSetId,
      setType: setType ?? this.setType,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      rpe: rpe ?? this.rpe,
      assistanceType: assistanceType ?? this.assistanceType,
      targetRestSeconds: targetRestSeconds ?? this.targetRestSeconds,
      actualRestSeconds: actualRestSeconds ?? this.actualRestSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
      map['sync_status'] = Variable<String>(
        $WorkoutSetsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (workoutSessionExerciseId.present) {
      map['workout_session_exercise_id'] = Variable<String>(
        workoutSessionExerciseId.value,
      );
    }
    if (setNumber.present) {
      map['set_number'] = Variable<int>(setNumber.value);
    }
    if (parentSetId.present) {
      map['parent_set_id'] = Variable<String>(parentSetId.value);
    }
    if (setType.present) {
      map['set_type'] = Variable<String>(
        $WorkoutSetsTable.$convertersetType.toSql(setType.value),
      );
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (assistanceType.present) {
      map['assistance_type'] = Variable<String>(
        $WorkoutSetsTable.$converterassistanceType.toSql(assistanceType.value),
      );
    }
    if (targetRestSeconds.present) {
      map['target_rest_seconds'] = Variable<int>(targetRestSeconds.value);
    }
    if (actualRestSeconds.present) {
      map['actual_rest_seconds'] = Variable<int>(actualRestSeconds.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('workoutSessionExerciseId: $workoutSessionExerciseId, ')
          ..write('setNumber: $setNumber, ')
          ..write('parentSetId: $parentSetId, ')
          ..write('setType: $setType, ')
          ..write('weight: $weight, ')
          ..write('reps: $reps, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('rpe: $rpe, ')
          ..write('assistanceType: $assistanceType, ')
          ..write('targetRestSeconds: $targetRestSeconds, ')
          ..write('actualRestSeconds: $actualRestSeconds, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => const Uuid().v4(),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<SyncStatus, String> syncStatus =
      GeneratedColumn<String>(
        'sync_status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(SyncStatus.pending_push.name),
      ).withConverter<SyncStatus>($AppSettingsTable.$convertersyncStatus);
  static const VerificationMeta _useSplitWarmupRestMeta =
      const VerificationMeta('useSplitWarmupRest');
  @override
  late final GeneratedColumn<bool> useSplitWarmupRest = GeneratedColumn<bool>(
    'use_split_warmup_rest',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("use_split_warmup_rest" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _largeMuscleWarmupRestSecondsMeta =
      const VerificationMeta('largeMuscleWarmupRestSeconds');
  @override
  late final GeneratedColumn<int> largeMuscleWarmupRestSeconds =
      GeneratedColumn<int>(
        'large_muscle_warmup_rest_seconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(90),
      );
  static const VerificationMeta _smallMuscleWarmupRestSecondsMeta =
      const VerificationMeta('smallMuscleWarmupRestSeconds');
  @override
  late final GeneratedColumn<int> smallMuscleWarmupRestSeconds =
      GeneratedColumn<int>(
        'small_muscle_warmup_rest_seconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(60),
      );
  static const VerificationMeta _globalWarmupRestSecondsMeta =
      const VerificationMeta('globalWarmupRestSeconds');
  @override
  late final GeneratedColumn<int> globalWarmupRestSeconds =
      GeneratedColumn<int>(
        'global_warmup_rest_seconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(60),
      );
  static const VerificationMeta _defaultWorkingSetRestSecondsMeta =
      const VerificationMeta('defaultWorkingSetRestSeconds');
  @override
  late final GeneratedColumn<int> defaultWorkingSetRestSeconds =
      GeneratedColumn<int>(
        'default_working_set_rest_seconds',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(180),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    useSplitWarmupRest,
    largeMuscleWarmupRestSeconds,
    smallMuscleWarmupRestSeconds,
    globalWarmupRestSeconds,
    defaultWorkingSetRestSeconds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('use_split_warmup_rest')) {
      context.handle(
        _useSplitWarmupRestMeta,
        useSplitWarmupRest.isAcceptableOrUnknown(
          data['use_split_warmup_rest']!,
          _useSplitWarmupRestMeta,
        ),
      );
    }
    if (data.containsKey('large_muscle_warmup_rest_seconds')) {
      context.handle(
        _largeMuscleWarmupRestSecondsMeta,
        largeMuscleWarmupRestSeconds.isAcceptableOrUnknown(
          data['large_muscle_warmup_rest_seconds']!,
          _largeMuscleWarmupRestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('small_muscle_warmup_rest_seconds')) {
      context.handle(
        _smallMuscleWarmupRestSecondsMeta,
        smallMuscleWarmupRestSeconds.isAcceptableOrUnknown(
          data['small_muscle_warmup_rest_seconds']!,
          _smallMuscleWarmupRestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('global_warmup_rest_seconds')) {
      context.handle(
        _globalWarmupRestSecondsMeta,
        globalWarmupRestSeconds.isAcceptableOrUnknown(
          data['global_warmup_rest_seconds']!,
          _globalWarmupRestSecondsMeta,
        ),
      );
    }
    if (data.containsKey('default_working_set_rest_seconds')) {
      context.handle(
        _defaultWorkingSetRestSecondsMeta,
        defaultWorkingSetRestSeconds.isAcceptableOrUnknown(
          data['default_working_set_rest_seconds']!,
          _defaultWorkingSetRestSecondsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncStatus: $AppSettingsTable.$convertersyncStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}sync_status'],
        )!,
      ),
      useSplitWarmupRest: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}use_split_warmup_rest'],
      )!,
      largeMuscleWarmupRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}large_muscle_warmup_rest_seconds'],
      )!,
      smallMuscleWarmupRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}small_muscle_warmup_rest_seconds'],
      )!,
      globalWarmupRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}global_warmup_rest_seconds'],
      )!,
      defaultWorkingSetRestSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_working_set_rest_seconds'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<SyncStatus, String, String> $convertersyncStatus =
      const EnumNameConverter<SyncStatus>(SyncStatus.values);
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final SyncStatus syncStatus;
  final bool useSplitWarmupRest;
  final int largeMuscleWarmupRestSeconds;
  final int smallMuscleWarmupRestSeconds;
  final int globalWarmupRestSeconds;
  final int defaultWorkingSetRestSeconds;
  const AppSetting({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncStatus,
    required this.useSplitWarmupRest,
    required this.largeMuscleWarmupRestSeconds,
    required this.smallMuscleWarmupRestSeconds,
    required this.globalWarmupRestSeconds,
    required this.defaultWorkingSetRestSeconds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    {
      map['sync_status'] = Variable<String>(
        $AppSettingsTable.$convertersyncStatus.toSql(syncStatus),
      );
    }
    map['use_split_warmup_rest'] = Variable<bool>(useSplitWarmupRest);
    map['large_muscle_warmup_rest_seconds'] = Variable<int>(
      largeMuscleWarmupRestSeconds,
    );
    map['small_muscle_warmup_rest_seconds'] = Variable<int>(
      smallMuscleWarmupRestSeconds,
    );
    map['global_warmup_rest_seconds'] = Variable<int>(globalWarmupRestSeconds);
    map['default_working_set_rest_seconds'] = Variable<int>(
      defaultWorkingSetRestSeconds,
    );
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncStatus: Value(syncStatus),
      useSplitWarmupRest: Value(useSplitWarmupRest),
      largeMuscleWarmupRestSeconds: Value(largeMuscleWarmupRestSeconds),
      smallMuscleWarmupRestSeconds: Value(smallMuscleWarmupRestSeconds),
      globalWarmupRestSeconds: Value(globalWarmupRestSeconds),
      defaultWorkingSetRestSeconds: Value(defaultWorkingSetRestSeconds),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncStatus: $AppSettingsTable.$convertersyncStatus.fromJson(
        serializer.fromJson<String>(json['syncStatus']),
      ),
      useSplitWarmupRest: serializer.fromJson<bool>(json['useSplitWarmupRest']),
      largeMuscleWarmupRestSeconds: serializer.fromJson<int>(
        json['largeMuscleWarmupRestSeconds'],
      ),
      smallMuscleWarmupRestSeconds: serializer.fromJson<int>(
        json['smallMuscleWarmupRestSeconds'],
      ),
      globalWarmupRestSeconds: serializer.fromJson<int>(
        json['globalWarmupRestSeconds'],
      ),
      defaultWorkingSetRestSeconds: serializer.fromJson<int>(
        json['defaultWorkingSetRestSeconds'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncStatus': serializer.toJson<String>(
        $AppSettingsTable.$convertersyncStatus.toJson(syncStatus),
      ),
      'useSplitWarmupRest': serializer.toJson<bool>(useSplitWarmupRest),
      'largeMuscleWarmupRestSeconds': serializer.toJson<int>(
        largeMuscleWarmupRestSeconds,
      ),
      'smallMuscleWarmupRestSeconds': serializer.toJson<int>(
        smallMuscleWarmupRestSeconds,
      ),
      'globalWarmupRestSeconds': serializer.toJson<int>(
        globalWarmupRestSeconds,
      ),
      'defaultWorkingSetRestSeconds': serializer.toJson<int>(
        defaultWorkingSetRestSeconds,
      ),
    };
  }

  AppSetting copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    SyncStatus? syncStatus,
    bool? useSplitWarmupRest,
    int? largeMuscleWarmupRestSeconds,
    int? smallMuscleWarmupRestSeconds,
    int? globalWarmupRestSeconds,
    int? defaultWorkingSetRestSeconds,
  }) => AppSetting(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    useSplitWarmupRest: useSplitWarmupRest ?? this.useSplitWarmupRest,
    largeMuscleWarmupRestSeconds:
        largeMuscleWarmupRestSeconds ?? this.largeMuscleWarmupRestSeconds,
    smallMuscleWarmupRestSeconds:
        smallMuscleWarmupRestSeconds ?? this.smallMuscleWarmupRestSeconds,
    globalWarmupRestSeconds:
        globalWarmupRestSeconds ?? this.globalWarmupRestSeconds,
    defaultWorkingSetRestSeconds:
        defaultWorkingSetRestSeconds ?? this.defaultWorkingSetRestSeconds,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      useSplitWarmupRest: data.useSplitWarmupRest.present
          ? data.useSplitWarmupRest.value
          : this.useSplitWarmupRest,
      largeMuscleWarmupRestSeconds: data.largeMuscleWarmupRestSeconds.present
          ? data.largeMuscleWarmupRestSeconds.value
          : this.largeMuscleWarmupRestSeconds,
      smallMuscleWarmupRestSeconds: data.smallMuscleWarmupRestSeconds.present
          ? data.smallMuscleWarmupRestSeconds.value
          : this.smallMuscleWarmupRestSeconds,
      globalWarmupRestSeconds: data.globalWarmupRestSeconds.present
          ? data.globalWarmupRestSeconds.value
          : this.globalWarmupRestSeconds,
      defaultWorkingSetRestSeconds: data.defaultWorkingSetRestSeconds.present
          ? data.defaultWorkingSetRestSeconds.value
          : this.defaultWorkingSetRestSeconds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('useSplitWarmupRest: $useSplitWarmupRest, ')
          ..write(
            'largeMuscleWarmupRestSeconds: $largeMuscleWarmupRestSeconds, ',
          )
          ..write(
            'smallMuscleWarmupRestSeconds: $smallMuscleWarmupRestSeconds, ',
          )
          ..write('globalWarmupRestSeconds: $globalWarmupRestSeconds, ')
          ..write('defaultWorkingSetRestSeconds: $defaultWorkingSetRestSeconds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncStatus,
    useSplitWarmupRest,
    largeMuscleWarmupRestSeconds,
    smallMuscleWarmupRestSeconds,
    globalWarmupRestSeconds,
    defaultWorkingSetRestSeconds,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncStatus == this.syncStatus &&
          other.useSplitWarmupRest == this.useSplitWarmupRest &&
          other.largeMuscleWarmupRestSeconds ==
              this.largeMuscleWarmupRestSeconds &&
          other.smallMuscleWarmupRestSeconds ==
              this.smallMuscleWarmupRestSeconds &&
          other.globalWarmupRestSeconds == this.globalWarmupRestSeconds &&
          other.defaultWorkingSetRestSeconds ==
              this.defaultWorkingSetRestSeconds);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<SyncStatus> syncStatus;
  final Value<bool> useSplitWarmupRest;
  final Value<int> largeMuscleWarmupRestSeconds;
  final Value<int> smallMuscleWarmupRestSeconds;
  final Value<int> globalWarmupRestSeconds;
  final Value<int> defaultWorkingSetRestSeconds;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.useSplitWarmupRest = const Value.absent(),
    this.largeMuscleWarmupRestSeconds = const Value.absent(),
    this.smallMuscleWarmupRestSeconds = const Value.absent(),
    this.globalWarmupRestSeconds = const Value.absent(),
    this.defaultWorkingSetRestSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.useSplitWarmupRest = const Value.absent(),
    this.largeMuscleWarmupRestSeconds = const Value.absent(),
    this.smallMuscleWarmupRestSeconds = const Value.absent(),
    this.globalWarmupRestSeconds = const Value.absent(),
    this.defaultWorkingSetRestSeconds = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? syncStatus,
    Expression<bool>? useSplitWarmupRest,
    Expression<int>? largeMuscleWarmupRestSeconds,
    Expression<int>? smallMuscleWarmupRestSeconds,
    Expression<int>? globalWarmupRestSeconds,
    Expression<int>? defaultWorkingSetRestSeconds,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (useSplitWarmupRest != null)
        'use_split_warmup_rest': useSplitWarmupRest,
      if (largeMuscleWarmupRestSeconds != null)
        'large_muscle_warmup_rest_seconds': largeMuscleWarmupRestSeconds,
      if (smallMuscleWarmupRestSeconds != null)
        'small_muscle_warmup_rest_seconds': smallMuscleWarmupRestSeconds,
      if (globalWarmupRestSeconds != null)
        'global_warmup_rest_seconds': globalWarmupRestSeconds,
      if (defaultWorkingSetRestSeconds != null)
        'default_working_set_rest_seconds': defaultWorkingSetRestSeconds,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<SyncStatus>? syncStatus,
    Value<bool>? useSplitWarmupRest,
    Value<int>? largeMuscleWarmupRestSeconds,
    Value<int>? smallMuscleWarmupRestSeconds,
    Value<int>? globalWarmupRestSeconds,
    Value<int>? defaultWorkingSetRestSeconds,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      useSplitWarmupRest: useSplitWarmupRest ?? this.useSplitWarmupRest,
      largeMuscleWarmupRestSeconds:
          largeMuscleWarmupRestSeconds ?? this.largeMuscleWarmupRestSeconds,
      smallMuscleWarmupRestSeconds:
          smallMuscleWarmupRestSeconds ?? this.smallMuscleWarmupRestSeconds,
      globalWarmupRestSeconds:
          globalWarmupRestSeconds ?? this.globalWarmupRestSeconds,
      defaultWorkingSetRestSeconds:
          defaultWorkingSetRestSeconds ?? this.defaultWorkingSetRestSeconds,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
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
      map['sync_status'] = Variable<String>(
        $AppSettingsTable.$convertersyncStatus.toSql(syncStatus.value),
      );
    }
    if (useSplitWarmupRest.present) {
      map['use_split_warmup_rest'] = Variable<bool>(useSplitWarmupRest.value);
    }
    if (largeMuscleWarmupRestSeconds.present) {
      map['large_muscle_warmup_rest_seconds'] = Variable<int>(
        largeMuscleWarmupRestSeconds.value,
      );
    }
    if (smallMuscleWarmupRestSeconds.present) {
      map['small_muscle_warmup_rest_seconds'] = Variable<int>(
        smallMuscleWarmupRestSeconds.value,
      );
    }
    if (globalWarmupRestSeconds.present) {
      map['global_warmup_rest_seconds'] = Variable<int>(
        globalWarmupRestSeconds.value,
      );
    }
    if (defaultWorkingSetRestSeconds.present) {
      map['default_working_set_rest_seconds'] = Variable<int>(
        defaultWorkingSetRestSeconds.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('useSplitWarmupRest: $useSplitWarmupRest, ')
          ..write(
            'largeMuscleWarmupRestSeconds: $largeMuscleWarmupRestSeconds, ',
          )
          ..write(
            'smallMuscleWarmupRestSeconds: $smallMuscleWarmupRestSeconds, ',
          )
          ..write('globalWarmupRestSeconds: $globalWarmupRestSeconds, ')
          ..write(
            'defaultWorkingSetRestSeconds: $defaultWorkingSetRestSeconds, ',
          )
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GymLocationsTable gymLocations = $GymLocationsTable(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $GymMachinesTable gymMachines = $GymMachinesTable(this);
  late final $ExerciseMediaTable exerciseMedia = $ExerciseMediaTable(this);
  late final $WorkoutPlansTable workoutPlans = $WorkoutPlansTable(this);
  late final $WorkoutPlanExercisesTable workoutPlanExercises =
      $WorkoutPlanExercisesTable(this);
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $WorkoutSessionExercisesTable workoutSessionExercises =
      $WorkoutSessionExercisesTable(this);
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    gymLocations,
    exercises,
    gymMachines,
    exerciseMedia,
    workoutPlans,
    workoutPlanExercises,
    workoutSessions,
    workoutSessionExercises,
    workoutSets,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'gym_locations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('gym_machines', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('gym_machines', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_media', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_plan_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_plan_exercises', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'gym_machines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_plan_exercises', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_plans',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'gym_locations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_sessions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('workout_session_exercises', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'gym_machines',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('workout_session_exercises', kind: UpdateKind.update),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_session_exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_sets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_sets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('workout_sets', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GymLocationsTableCreateCompanionBuilder =
    GymLocationsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      required String name,
      Value<String?> address,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$GymLocationsTableUpdateCompanionBuilder =
    GymLocationsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<String> name,
      Value<String?> address,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$GymLocationsTableReferences
    extends BaseReferences<_$AppDatabase, $GymLocationsTable, GymLocation> {
  $$GymLocationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GymMachinesTable, List<GymMachine>>
  _gymMachinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gymMachines,
    aliasName: 'gym_locations__id__gym_machines__gym_location_id',
  );

  $$GymMachinesTableProcessedTableManager get gymMachinesRefs {
    final manager = $$GymMachinesTableTableManager(
      $_db,
      $_db.gymMachines,
    ).filter((f) => f.gymLocationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gymMachinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutSessionsTable, List<WorkoutSession>>
  _workoutSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSessions,
    aliasName: 'gym_locations__id__workout_sessions__gym_location_id',
  );

  $$WorkoutSessionsTableProcessedTableManager get workoutSessionsRefs {
    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.gymLocationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GymLocationsTableFilterComposer
    extends Composer<_$AppDatabase, $GymLocationsTable> {
  $$GymLocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gymMachinesRefs(
    Expression<bool> Function($$GymMachinesTableFilterComposer f) f,
  ) {
    final $$GymMachinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gymMachines,
      getReferencedColumn: (t) => t.gymLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymMachinesTableFilterComposer(
            $db: $db,
            $table: $db.gymMachines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutSessionsRefs(
    Expression<bool> Function($$WorkoutSessionsTableFilterComposer f) f,
  ) {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.gymLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GymLocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $GymLocationsTable> {
  $$GymLocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GymLocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GymLocationsTable> {
  $$GymLocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> gymMachinesRefs<T extends Object>(
    Expression<T> Function($$GymMachinesTableAnnotationComposer a) f,
  ) {
    final $$GymMachinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gymMachines,
      getReferencedColumn: (t) => t.gymLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymMachinesTableAnnotationComposer(
            $db: $db,
            $table: $db.gymMachines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutSessionsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSessionsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.gymLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GymLocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GymLocationsTable,
          GymLocation,
          $$GymLocationsTableFilterComposer,
          $$GymLocationsTableOrderingComposer,
          $$GymLocationsTableAnnotationComposer,
          $$GymLocationsTableCreateCompanionBuilder,
          $$GymLocationsTableUpdateCompanionBuilder,
          (GymLocation, $$GymLocationsTableReferences),
          GymLocation,
          PrefetchHooks Function({
            bool gymMachinesRefs,
            bool workoutSessionsRefs,
          })
        > {
  $$GymLocationsTableTableManager(_$AppDatabase db, $GymLocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GymLocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GymLocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GymLocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GymLocationsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                name: name,
                address: address,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                required String name,
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GymLocationsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                name: name,
                address: address,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GymLocationsTable, GymLocation>(table),
                  $$GymLocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({gymMachinesRefs = false, workoutSessionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gymMachinesRefs) db.gymMachines,
                    if (workoutSessionsRefs) db.workoutSessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gymMachinesRefs)
                        await $_getPrefetchedDataByColumns<
                          GymLocation,
                          $GymLocationsTable,
                          GymMachine,
                          $GymMachinesTable
                        >(
                          currentTable: table,
                          referencedTable: $$GymLocationsTableReferences
                              ._gymMachinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GymLocationsTableReferences(
                                db,
                                table,
                                p0,
                              ).gymMachinesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'gym_location_id',
                          typedResults: items,
                        ),
                      if (workoutSessionsRefs)
                        await $_getPrefetchedDataByColumns<
                          GymLocation,
                          $GymLocationsTable,
                          WorkoutSession,
                          $WorkoutSessionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$GymLocationsTableReferences
                              ._workoutSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GymLocationsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSessionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'gym_location_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GymLocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GymLocationsTable,
      GymLocation,
      $$GymLocationsTableFilterComposer,
      $$GymLocationsTableOrderingComposer,
      $$GymLocationsTableAnnotationComposer,
      $$GymLocationsTableCreateCompanionBuilder,
      $$GymLocationsTableUpdateCompanionBuilder,
      (GymLocation, $$GymLocationsTableReferences),
      GymLocation,
      PrefetchHooks Function({bool gymMachinesRefs, bool workoutSessionsRefs})
    >;
typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<SyncStatus> syncStatus,
  required String name,
  required EquipmentCategory equipmentCategory,
  required MuscleGroup primaryMuscleGroup,
  Value<List<MuscleGroup>> secondaryMuscleGroups,
  required MuscleSizeCategory muscleSizeCategory,
  required ExerciseType exerciseType,
  Value<int?> defaultWorkingRestSeconds,
  Value<bool> isCustom,
  Value<int> rowid,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<SyncStatus> syncStatus,
  Value<String> name,
  Value<EquipmentCategory> equipmentCategory,
  Value<MuscleGroup> primaryMuscleGroup,
  Value<List<MuscleGroup>> secondaryMuscleGroups,
  Value<MuscleSizeCategory> muscleSizeCategory,
  Value<ExerciseType> exerciseType,
  Value<int?> defaultWorkingRestSeconds,
  Value<bool> isCustom,
  Value<int> rowid,
});

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, Exercise> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GymMachinesTable, List<GymMachine>>
  _gymMachinesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.gymMachines,
    aliasName: 'exercises__id__gym_machines__exercise_id',
  );

  $$GymMachinesTableProcessedTableManager get gymMachinesRefs {
    final manager = $$GymMachinesTableTableManager(
      $_db,
      $_db.gymMachines,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_gymMachinesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExerciseMediaTable, List<ExerciseMediaData>>
  _exerciseMediaRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseMedia,
    aliasName: 'exercises__id__exercise_media__exercise_id',
  );

  $$ExerciseMediaTableProcessedTableManager get exerciseMediaRefs {
    final manager = $$ExerciseMediaTableTableManager(
      $_db,
      $_db.exerciseMedia,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_exerciseMediaRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $WorkoutPlanExercisesTable,
    List<WorkoutPlanExercise>
  >
  _workoutPlanExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutPlanExercises,
        aliasName: 'exercises__id__workout_plan_exercises__exercise_id',
      );

  $$WorkoutPlanExercisesTableProcessedTableManager
  get workoutPlanExercisesRefs {
    final manager = $$WorkoutPlanExercisesTableTableManager(
      $_db,
      $_db.workoutPlanExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutPlanExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $WorkoutSessionExercisesTable,
    List<WorkoutSessionExercise>
  >
  _workoutSessionExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutSessionExercises,
        aliasName: 'exercises__id__workout_session_exercises__exercise_id',
      );

  $$WorkoutSessionExercisesTableProcessedTableManager
  get workoutSessionExercisesRefs {
    final manager = $$WorkoutSessionExercisesTableTableManager(
      $_db,
      $_db.workoutSessionExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutSessionExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EquipmentCategory, EquipmentCategory, String>
  get equipmentCategory => $composableBuilder(
    column: $table.equipmentCategory,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MuscleGroup, MuscleGroup, String>
  get primaryMuscleGroup => $composableBuilder(
    column: $table.primaryMuscleGroup,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<MuscleGroup>, List<MuscleGroup>, String>
  get secondaryMuscleGroups => $composableBuilder(
    column: $table.secondaryMuscleGroups,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MuscleSizeCategory, MuscleSizeCategory, String>
  get muscleSizeCategory => $composableBuilder(
    column: $table.muscleSizeCategory,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ExerciseType, ExerciseType, String>
  get exerciseType => $composableBuilder(
    column: $table.exerciseType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get defaultWorkingRestSeconds => $composableBuilder(
    column: $table.defaultWorkingRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gymMachinesRefs(
    Expression<bool> Function($$GymMachinesTableFilterComposer f) f,
  ) {
    final $$GymMachinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gymMachines,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymMachinesTableFilterComposer(
            $db: $db,
            $table: $db.gymMachines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exerciseMediaRefs(
    Expression<bool> Function($$ExerciseMediaTableFilterComposer f) f,
  ) {
    final $$ExerciseMediaTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMedia,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMediaTableFilterComposer(
            $db: $db,
            $table: $db.exerciseMedia,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutPlanExercisesRefs(
    Expression<bool> Function($$WorkoutPlanExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutPlanExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutPlanExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlanExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutPlanExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutSessionExercisesRefs(
    Expression<bool> Function($$WorkoutSessionExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutSessionExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableFilterComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipmentCategory => $composableBuilder(
    column: $table.equipmentCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscleGroup => $composableBuilder(
    column: $table.primaryMuscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscleGroups => $composableBuilder(
    column: $table.secondaryMuscleGroups,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleSizeCategory => $composableBuilder(
    column: $table.muscleSizeCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseType => $composableBuilder(
    column: $table.exerciseType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultWorkingRestSeconds => $composableBuilder(
    column: $table.defaultWorkingRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EquipmentCategory, String>
  get equipmentCategory => $composableBuilder(
    column: $table.equipmentCategory,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MuscleGroup, String>
  get primaryMuscleGroup => $composableBuilder(
    column: $table.primaryMuscleGroup,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<List<MuscleGroup>, String>
  get secondaryMuscleGroups => $composableBuilder(
    column: $table.secondaryMuscleGroups,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MuscleSizeCategory, String>
  get muscleSizeCategory => $composableBuilder(
    column: $table.muscleSizeCategory,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ExerciseType, String> get exerciseType =>
      $composableBuilder(
        column: $table.exerciseType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get defaultWorkingRestSeconds => $composableBuilder(
    column: $table.defaultWorkingRestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  Expression<T> gymMachinesRefs<T extends Object>(
    Expression<T> Function($$GymMachinesTableAnnotationComposer a) f,
  ) {
    final $$GymMachinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gymMachines,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymMachinesTableAnnotationComposer(
            $db: $db,
            $table: $db.gymMachines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exerciseMediaRefs<T extends Object>(
    Expression<T> Function($$ExerciseMediaTableAnnotationComposer a) f,
  ) {
    final $$ExerciseMediaTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseMedia,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseMediaTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseMedia,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutPlanExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutPlanExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutPlanExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutPlanExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutPlanExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutPlanExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutSessionExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutSessionExercisesTableAnnotationComposer a)
    f,
  ) {
    final $$WorkoutSessionExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          Exercise,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (Exercise, $$ExercisesTableReferences),
          Exercise,
          PrefetchHooks Function({
            bool gymMachinesRefs,
            bool exerciseMediaRefs,
            bool workoutPlanExercisesRefs,
            bool workoutSessionExercisesRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<EquipmentCategory> equipmentCategory =
                    const Value.absent(),
                Value<MuscleGroup> primaryMuscleGroup = const Value.absent(),
                Value<List<MuscleGroup>> secondaryMuscleGroups =
                    const Value.absent(),
                Value<MuscleSizeCategory> muscleSizeCategory =
                    const Value.absent(),
                Value<ExerciseType> exerciseType = const Value.absent(),
                Value<int?> defaultWorkingRestSeconds = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                name: name,
                equipmentCategory: equipmentCategory,
                primaryMuscleGroup: primaryMuscleGroup,
                secondaryMuscleGroups: secondaryMuscleGroups,
                muscleSizeCategory: muscleSizeCategory,
                exerciseType: exerciseType,
                defaultWorkingRestSeconds: defaultWorkingRestSeconds,
                isCustom: isCustom,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                required String name,
                required EquipmentCategory equipmentCategory,
                required MuscleGroup primaryMuscleGroup,
                Value<List<MuscleGroup>> secondaryMuscleGroups =
                    const Value.absent(),
                required MuscleSizeCategory muscleSizeCategory,
                required ExerciseType exerciseType,
                Value<int?> defaultWorkingRestSeconds = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                name: name,
                equipmentCategory: equipmentCategory,
                primaryMuscleGroup: primaryMuscleGroup,
                secondaryMuscleGroups: secondaryMuscleGroups,
                muscleSizeCategory: muscleSizeCategory,
                exerciseType: exerciseType,
                defaultWorkingRestSeconds: defaultWorkingRestSeconds,
                isCustom: isCustom,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExercisesTable, Exercise>(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gymMachinesRefs = false,
                exerciseMediaRefs = false,
                workoutPlanExercisesRefs = false,
                workoutSessionExercisesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (gymMachinesRefs) db.gymMachines,
                    if (exerciseMediaRefs) db.exerciseMedia,
                    if (workoutPlanExercisesRefs) db.workoutPlanExercises,
                    if (workoutSessionExercisesRefs) db.workoutSessionExercises,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (gymMachinesRefs)
                        await $_getPrefetchedDataByColumns<
                          Exercise,
                          $ExercisesTable,
                          GymMachine,
                          $GymMachinesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._gymMachinesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).gymMachinesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                      if (exerciseMediaRefs)
                        await $_getPrefetchedDataByColumns<
                          Exercise,
                          $ExercisesTable,
                          ExerciseMediaData,
                          $ExerciseMediaTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._exerciseMediaRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).exerciseMediaRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                      if (workoutPlanExercisesRefs)
                        await $_getPrefetchedDataByColumns<
                          Exercise,
                          $ExercisesTable,
                          WorkoutPlanExercise,
                          $WorkoutPlanExercisesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutPlanExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutPlanExercisesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                      if (workoutSessionExercisesRefs)
                        await $_getPrefetchedDataByColumns<
                          Exercise,
                          $ExercisesTable,
                          WorkoutSessionExercise,
                          $WorkoutSessionExercisesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutSessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSessionExercisesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'exercise_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      Exercise,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (Exercise, $$ExercisesTableReferences),
      Exercise,
      PrefetchHooks Function({
        bool gymMachinesRefs,
        bool exerciseMediaRefs,
        bool workoutPlanExercisesRefs,
        bool workoutSessionExercisesRefs,
      })
    >;
typedef $$GymMachinesTableCreateCompanionBuilder =
    GymMachinesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<String?> gymLocationId,
      required String exerciseId,
      Value<String?> brandName,
      Value<WeightUnit> weightUnit,
      Value<String?> pinnedNotes,
      Value<int> rowid,
    });
typedef $$GymMachinesTableUpdateCompanionBuilder =
    GymMachinesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<String?> gymLocationId,
      Value<String> exerciseId,
      Value<String?> brandName,
      Value<WeightUnit> weightUnit,
      Value<String?> pinnedNotes,
      Value<int> rowid,
    });

final class $$GymMachinesTableReferences
    extends BaseReferences<_$AppDatabase, $GymMachinesTable, GymMachine> {
  $$GymMachinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GymLocationsTable _gymLocationIdTable(_$AppDatabase db) => db
      .gymLocations
      .createAlias('gym_machines__gym_location_id__gym_locations__id');

  $$GymLocationsTableProcessedTableManager? get gymLocationId {
    final $_column = $_itemColumn<String>('gym_location_id');
    if ($_column == null) return null;
    final manager = $$GymLocationsTableTableManager(
      $_db,
      $_db.gymLocations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gymLocationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('gym_machines__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $WorkoutPlanExercisesTable,
    List<WorkoutPlanExercise>
  >
  _workoutPlanExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutPlanExercises,
        aliasName:
            'gym_machines__id__workout_plan_exercises__default_gym_machine_id',
      );

  $$WorkoutPlanExercisesTableProcessedTableManager
  get workoutPlanExercisesRefs {
    final manager =
        $$WorkoutPlanExercisesTableTableManager(
          $_db,
          $_db.workoutPlanExercises,
        ).filter(
          (f) =>
              f.defaultGymMachineId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _workoutPlanExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $WorkoutSessionExercisesTable,
    List<WorkoutSessionExercise>
  >
  _workoutSessionExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutSessionExercises,
        aliasName:
            'gym_machines__id__workout_session_exercises__gym_machine_id',
      );

  $$WorkoutSessionExercisesTableProcessedTableManager
  get workoutSessionExercisesRefs {
    final manager = $$WorkoutSessionExercisesTableTableManager(
      $_db,
      $_db.workoutSessionExercises,
    ).filter((f) => f.gymMachineId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutSessionExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GymMachinesTableFilterComposer
    extends Composer<_$AppDatabase, $GymMachinesTable> {
  $$GymMachinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WeightUnit, WeightUnit, String>
  get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get pinnedNotes => $composableBuilder(
    column: $table.pinnedNotes,
    builder: (column) => ColumnFilters(column),
  );

  $$GymLocationsTableFilterComposer get gymLocationId {
    final $$GymLocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gymLocationId,
      referencedTable: $db.gymLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymLocationsTableFilterComposer(
            $db: $db,
            $table: $db.gymLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workoutPlanExercisesRefs(
    Expression<bool> Function($$WorkoutPlanExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutPlanExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutPlanExercises,
      getReferencedColumn: (t) => t.defaultGymMachineId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlanExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutPlanExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutSessionExercisesRefs(
    Expression<bool> Function($$WorkoutSessionExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutSessionExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.gymMachineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableFilterComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GymMachinesTableOrderingComposer
    extends Composer<_$AppDatabase, $GymMachinesTable> {
  $$GymMachinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brandName => $composableBuilder(
    column: $table.brandName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weightUnit => $composableBuilder(
    column: $table.weightUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pinnedNotes => $composableBuilder(
    column: $table.pinnedNotes,
    builder: (column) => ColumnOrderings(column),
  );

  $$GymLocationsTableOrderingComposer get gymLocationId {
    final $$GymLocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gymLocationId,
      referencedTable: $db.gymLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymLocationsTableOrderingComposer(
            $db: $db,
            $table: $db.gymLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GymMachinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GymMachinesTable> {
  $$GymMachinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get brandName =>
      $composableBuilder(column: $table.brandName, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WeightUnit, String> get weightUnit =>
      $composableBuilder(
        column: $table.weightUnit,
        builder: (column) => column,
      );

  GeneratedColumn<String> get pinnedNotes => $composableBuilder(
    column: $table.pinnedNotes,
    builder: (column) => column,
  );

  $$GymLocationsTableAnnotationComposer get gymLocationId {
    final $$GymLocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gymLocationId,
      referencedTable: $db.gymLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymLocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.gymLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workoutPlanExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutPlanExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutPlanExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutPlanExercises,
          getReferencedColumn: (t) => t.defaultGymMachineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutPlanExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutPlanExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutSessionExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutSessionExercisesTableAnnotationComposer a)
    f,
  ) {
    final $$WorkoutSessionExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.gymMachineId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$GymMachinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GymMachinesTable,
          GymMachine,
          $$GymMachinesTableFilterComposer,
          $$GymMachinesTableOrderingComposer,
          $$GymMachinesTableAnnotationComposer,
          $$GymMachinesTableCreateCompanionBuilder,
          $$GymMachinesTableUpdateCompanionBuilder,
          (GymMachine, $$GymMachinesTableReferences),
          GymMachine,
          PrefetchHooks Function({
            bool gymLocationId,
            bool exerciseId,
            bool workoutPlanExercisesRefs,
            bool workoutSessionExercisesRefs,
          })
        > {
  $$GymMachinesTableTableManager(_$AppDatabase db, $GymMachinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GymMachinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GymMachinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GymMachinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> gymLocationId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String?> brandName = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
                Value<String?> pinnedNotes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GymMachinesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                gymLocationId: gymLocationId,
                exerciseId: exerciseId,
                brandName: brandName,
                weightUnit: weightUnit,
                pinnedNotes: pinnedNotes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> gymLocationId = const Value.absent(),
                required String exerciseId,
                Value<String?> brandName = const Value.absent(),
                Value<WeightUnit> weightUnit = const Value.absent(),
                Value<String?> pinnedNotes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GymMachinesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                gymLocationId: gymLocationId,
                exerciseId: exerciseId,
                brandName: brandName,
                weightUnit: weightUnit,
                pinnedNotes: pinnedNotes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GymMachinesTable, GymMachine>(table),
                  $$GymMachinesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gymLocationId = false,
                exerciseId = false,
                workoutPlanExercisesRefs = false,
                workoutSessionExercisesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutPlanExercisesRefs) db.workoutPlanExercises,
                    if (workoutSessionExercisesRefs) db.workoutSessionExercises,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (gymLocationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.gymLocationId,
                            referencedTable: $$GymMachinesTableReferences
                                ._gymLocationIdTable(db),
                            referencedColumn: $$GymMachinesTableReferences
                                ._gymLocationIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (exerciseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable: $$GymMachinesTableReferences
                                ._exerciseIdTable(db),
                            referencedColumn: $$GymMachinesTableReferences
                                ._exerciseIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutPlanExercisesRefs)
                        await $_getPrefetchedDataByColumns<
                          GymMachine,
                          $GymMachinesTable,
                          WorkoutPlanExercise,
                          $WorkoutPlanExercisesTable
                        >(
                          currentTable: table,
                          referencedTable: $$GymMachinesTableReferences
                              ._workoutPlanExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GymMachinesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutPlanExercisesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'default_gym_machine_id',
                          typedResults: items,
                        ),
                      if (workoutSessionExercisesRefs)
                        await $_getPrefetchedDataByColumns<
                          GymMachine,
                          $GymMachinesTable,
                          WorkoutSessionExercise,
                          $WorkoutSessionExercisesTable
                        >(
                          currentTable: table,
                          referencedTable: $$GymMachinesTableReferences
                              ._workoutSessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GymMachinesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSessionExercisesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'gym_machine_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GymMachinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GymMachinesTable,
      GymMachine,
      $$GymMachinesTableFilterComposer,
      $$GymMachinesTableOrderingComposer,
      $$GymMachinesTableAnnotationComposer,
      $$GymMachinesTableCreateCompanionBuilder,
      $$GymMachinesTableUpdateCompanionBuilder,
      (GymMachine, $$GymMachinesTableReferences),
      GymMachine,
      PrefetchHooks Function({
        bool gymLocationId,
        bool exerciseId,
        bool workoutPlanExercisesRefs,
        bool workoutSessionExercisesRefs,
      })
    >;
typedef $$ExerciseMediaTableCreateCompanionBuilder =
    ExerciseMediaCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      required String exerciseId,
      required MediaType mediaType,
      Value<int> sortOrder,
      required String localPath,
      Value<String?> thumbnailLocalPath,
      required int fileSizeBytes,
      Value<int?> durationSeconds,
      Value<String?> remoteUrl,
      Value<String?> thumbnailRemoteUrl,
      Value<MediaSyncStatus> mediaSyncStatus,
      Value<int> rowid,
    });
typedef $$ExerciseMediaTableUpdateCompanionBuilder =
    ExerciseMediaCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<String> exerciseId,
      Value<MediaType> mediaType,
      Value<int> sortOrder,
      Value<String> localPath,
      Value<String?> thumbnailLocalPath,
      Value<int> fileSizeBytes,
      Value<int?> durationSeconds,
      Value<String?> remoteUrl,
      Value<String?> thumbnailRemoteUrl,
      Value<MediaSyncStatus> mediaSyncStatus,
      Value<int> rowid,
    });

final class $$ExerciseMediaTableReferences
    extends
        BaseReferences<_$AppDatabase, $ExerciseMediaTable, ExerciseMediaData> {
  $$ExerciseMediaTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('exercise_media__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseMediaTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseMediaTable> {
  $$ExerciseMediaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<MediaType, MediaType, String> get mediaType =>
      $composableBuilder(
        column: $table.mediaType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailLocalPath => $composableBuilder(
    column: $table.thumbnailLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailRemoteUrl => $composableBuilder(
    column: $table.thumbnailRemoteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MediaSyncStatus, MediaSyncStatus, String>
  get mediaSyncStatus => $composableBuilder(
    column: $table.mediaSyncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMediaTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseMediaTable> {
  $$ExerciseMediaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailLocalPath => $composableBuilder(
    column: $table.thumbnailLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteUrl => $composableBuilder(
    column: $table.remoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailRemoteUrl => $composableBuilder(
    column: $table.thumbnailRemoteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaSyncStatus => $composableBuilder(
    column: $table.mediaSyncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMediaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseMediaTable> {
  $$ExerciseMediaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<MediaType, String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailLocalPath => $composableBuilder(
    column: $table.thumbnailLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSizeBytes => $composableBuilder(
    column: $table.fileSizeBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteUrl =>
      $composableBuilder(column: $table.remoteUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailRemoteUrl => $composableBuilder(
    column: $table.thumbnailRemoteUrl,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MediaSyncStatus, String>
  get mediaSyncStatus => $composableBuilder(
    column: $table.mediaSyncStatus,
    builder: (column) => column,
  );

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseMediaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseMediaTable,
          ExerciseMediaData,
          $$ExerciseMediaTableFilterComposer,
          $$ExerciseMediaTableOrderingComposer,
          $$ExerciseMediaTableAnnotationComposer,
          $$ExerciseMediaTableCreateCompanionBuilder,
          $$ExerciseMediaTableUpdateCompanionBuilder,
          (ExerciseMediaData, $$ExerciseMediaTableReferences),
          ExerciseMediaData,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$ExerciseMediaTableTableManager(_$AppDatabase db, $ExerciseMediaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseMediaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseMediaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseMediaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<MediaType> mediaType = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> thumbnailLocalPath = const Value.absent(),
                Value<int> fileSizeBytes = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<String?> thumbnailRemoteUrl = const Value.absent(),
                Value<MediaSyncStatus> mediaSyncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMediaCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                exerciseId: exerciseId,
                mediaType: mediaType,
                sortOrder: sortOrder,
                localPath: localPath,
                thumbnailLocalPath: thumbnailLocalPath,
                fileSizeBytes: fileSizeBytes,
                durationSeconds: durationSeconds,
                remoteUrl: remoteUrl,
                thumbnailRemoteUrl: thumbnailRemoteUrl,
                mediaSyncStatus: mediaSyncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                required String exerciseId,
                required MediaType mediaType,
                Value<int> sortOrder = const Value.absent(),
                required String localPath,
                Value<String?> thumbnailLocalPath = const Value.absent(),
                required int fileSizeBytes,
                Value<int?> durationSeconds = const Value.absent(),
                Value<String?> remoteUrl = const Value.absent(),
                Value<String?> thumbnailRemoteUrl = const Value.absent(),
                Value<MediaSyncStatus> mediaSyncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseMediaCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                exerciseId: exerciseId,
                mediaType: mediaType,
                sortOrder: sortOrder,
                localPath: localPath,
                thumbnailLocalPath: thumbnailLocalPath,
                fileSizeBytes: fileSizeBytes,
                durationSeconds: durationSeconds,
                remoteUrl: remoteUrl,
                thumbnailRemoteUrl: thumbnailRemoteUrl,
                mediaSyncStatus: mediaSyncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseMediaTable, ExerciseMediaData>(table),
                  $$ExerciseMediaTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$ExerciseMediaTableReferences
                            ._exerciseIdTable(db),
                        referencedColumn: $$ExerciseMediaTableReferences
                            ._exerciseIdTable(db)
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
        ),
      );
}

typedef $$ExerciseMediaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseMediaTable,
      ExerciseMediaData,
      $$ExerciseMediaTableFilterComposer,
      $$ExerciseMediaTableOrderingComposer,
      $$ExerciseMediaTableAnnotationComposer,
      $$ExerciseMediaTableCreateCompanionBuilder,
      $$ExerciseMediaTableUpdateCompanionBuilder,
      (ExerciseMediaData, $$ExerciseMediaTableReferences),
      ExerciseMediaData,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$WorkoutPlansTableCreateCompanionBuilder =
    WorkoutPlansCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      required String name,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$WorkoutPlansTableUpdateCompanionBuilder =
    WorkoutPlansCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<String> name,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$WorkoutPlansTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutPlansTable, WorkoutPlan> {
  $$WorkoutPlansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $WorkoutPlanExercisesTable,
    List<WorkoutPlanExercise>
  >
  _workoutPlanExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.workoutPlanExercises,
        aliasName: 'workout_plans__id__workout_plan_exercises__workout_plan_id',
      );

  $$WorkoutPlanExercisesTableProcessedTableManager
  get workoutPlanExercisesRefs {
    final manager = $$WorkoutPlanExercisesTableTableManager(
      $_db,
      $_db.workoutPlanExercises,
    ).filter((f) => f.workoutPlanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutPlanExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutSessionsTable, List<WorkoutSession>>
  _workoutSessionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSessions,
    aliasName: 'workout_plans__id__workout_sessions__workout_plan_id',
  );

  $$WorkoutSessionsTableProcessedTableManager get workoutSessionsRefs {
    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.workoutPlanId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _workoutSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutPlansTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutPlansTable> {
  $$WorkoutPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> workoutPlanExercisesRefs(
    Expression<bool> Function($$WorkoutPlanExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutPlanExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutPlanExercises,
      getReferencedColumn: (t) => t.workoutPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlanExercisesTableFilterComposer(
            $db: $db,
            $table: $db.workoutPlanExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutSessionsRefs(
    Expression<bool> Function($$WorkoutSessionsTableFilterComposer f) f,
  ) {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.workoutPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutPlansTable> {
  $$WorkoutPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutPlansTable> {
  $$WorkoutPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> workoutPlanExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutPlanExercisesTableAnnotationComposer a) f,
  ) {
    final $$WorkoutPlanExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutPlanExercises,
          getReferencedColumn: (t) => t.workoutPlanId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutPlanExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutPlanExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> workoutSessionsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSessionsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.workoutPlanId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutPlansTable,
          WorkoutPlan,
          $$WorkoutPlansTableFilterComposer,
          $$WorkoutPlansTableOrderingComposer,
          $$WorkoutPlansTableAnnotationComposer,
          $$WorkoutPlansTableCreateCompanionBuilder,
          $$WorkoutPlansTableUpdateCompanionBuilder,
          (WorkoutPlan, $$WorkoutPlansTableReferences),
          WorkoutPlan,
          PrefetchHooks Function({
            bool workoutPlanExercisesRefs,
            bool workoutSessionsRefs,
          })
        > {
  $$WorkoutPlansTableTableManager(_$AppDatabase db, $WorkoutPlansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutPlansCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                name: name,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                required String name,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutPlansCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                name: name,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutPlansTable, WorkoutPlan>(table),
                  $$WorkoutPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutPlanExercisesRefs = false,
                workoutSessionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutPlanExercisesRefs) db.workoutPlanExercises,
                    if (workoutSessionsRefs) db.workoutSessions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutPlanExercisesRefs)
                        await $_getPrefetchedDataByColumns<
                          WorkoutPlan,
                          $WorkoutPlansTable,
                          WorkoutPlanExercise,
                          $WorkoutPlanExercisesTable
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutPlansTableReferences
                              ._workoutPlanExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutPlansTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutPlanExercisesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'workout_plan_id',
                          typedResults: items,
                        ),
                      if (workoutSessionsRefs)
                        await $_getPrefetchedDataByColumns<
                          WorkoutPlan,
                          $WorkoutPlansTable,
                          WorkoutSession,
                          $WorkoutSessionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutPlansTableReferences
                              ._workoutSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutPlansTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSessionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'workout_plan_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutPlansTable,
      WorkoutPlan,
      $$WorkoutPlansTableFilterComposer,
      $$WorkoutPlansTableOrderingComposer,
      $$WorkoutPlansTableAnnotationComposer,
      $$WorkoutPlansTableCreateCompanionBuilder,
      $$WorkoutPlansTableUpdateCompanionBuilder,
      (WorkoutPlan, $$WorkoutPlansTableReferences),
      WorkoutPlan,
      PrefetchHooks Function({
        bool workoutPlanExercisesRefs,
        bool workoutSessionsRefs,
      })
    >;
typedef $$WorkoutPlanExercisesTableCreateCompanionBuilder =
    WorkoutPlanExercisesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      required String workoutPlanId,
      required String exerciseId,
      Value<String?> defaultGymMachineId,
      required int sortOrder,
      Value<String?> supersetGroupId,
      Value<int> targetSets,
      Value<int?> targetReps,
      Value<int?> targetRestSeconds,
      Value<int> rowid,
    });
typedef $$WorkoutPlanExercisesTableUpdateCompanionBuilder =
    WorkoutPlanExercisesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<String> workoutPlanId,
      Value<String> exerciseId,
      Value<String?> defaultGymMachineId,
      Value<int> sortOrder,
      Value<String?> supersetGroupId,
      Value<int> targetSets,
      Value<int?> targetReps,
      Value<int?> targetRestSeconds,
      Value<int> rowid,
    });

final class $$WorkoutPlanExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutPlanExercisesTable,
          WorkoutPlanExercise
        > {
  $$WorkoutPlanExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutPlansTable _workoutPlanIdTable(_$AppDatabase db) =>
      db.workoutPlans.createAlias(
        'workout_plan_exercises__workout_plan_id__workout_plans__id',
      );

  $$WorkoutPlansTableProcessedTableManager get workoutPlanId {
    final $_column = $_itemColumn<String>('workout_plan_id')!;

    final manager = $$WorkoutPlansTableTableManager(
      $_db,
      $_db.workoutPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutPlanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) => db.exercises
      .createAlias('workout_plan_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GymMachinesTable _defaultGymMachineIdTable(_$AppDatabase db) =>
      db.gymMachines.createAlias(
        'workout_plan_exercises__default_gym_machine_id__gym_machines__id',
      );

  $$GymMachinesTableProcessedTableManager? get defaultGymMachineId {
    final $_column = $_itemColumn<String>('default_gym_machine_id');
    if ($_column == null) return null;
    final manager = $$GymMachinesTableTableManager(
      $_db,
      $_db.gymMachines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_defaultGymMachineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutPlanExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutPlanExercisesTable> {
  $$WorkoutPlanExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supersetGroupId => $composableBuilder(
    column: $table.supersetGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetRestSeconds => $composableBuilder(
    column: $table.targetRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutPlansTableFilterComposer get workoutPlanId {
    final $$WorkoutPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutPlanId,
      referencedTable: $db.workoutPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlansTableFilterComposer(
            $db: $db,
            $table: $db.workoutPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GymMachinesTableFilterComposer get defaultGymMachineId {
    final $$GymMachinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultGymMachineId,
      referencedTable: $db.gymMachines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymMachinesTableFilterComposer(
            $db: $db,
            $table: $db.gymMachines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutPlanExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutPlanExercisesTable> {
  $$WorkoutPlanExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supersetGroupId => $composableBuilder(
    column: $table.supersetGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRestSeconds => $composableBuilder(
    column: $table.targetRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutPlansTableOrderingComposer get workoutPlanId {
    final $$WorkoutPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutPlanId,
      referencedTable: $db.workoutPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlansTableOrderingComposer(
            $db: $db,
            $table: $db.workoutPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GymMachinesTableOrderingComposer get defaultGymMachineId {
    final $$GymMachinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultGymMachineId,
      referencedTable: $db.gymMachines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymMachinesTableOrderingComposer(
            $db: $db,
            $table: $db.gymMachines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutPlanExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutPlanExercisesTable> {
  $$WorkoutPlanExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get supersetGroupId => $composableBuilder(
    column: $table.supersetGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetRestSeconds => $composableBuilder(
    column: $table.targetRestSeconds,
    builder: (column) => column,
  );

  $$WorkoutPlansTableAnnotationComposer get workoutPlanId {
    final $$WorkoutPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutPlanId,
      referencedTable: $db.workoutPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GymMachinesTableAnnotationComposer get defaultGymMachineId {
    final $$GymMachinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.defaultGymMachineId,
      referencedTable: $db.gymMachines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymMachinesTableAnnotationComposer(
            $db: $db,
            $table: $db.gymMachines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutPlanExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutPlanExercisesTable,
          WorkoutPlanExercise,
          $$WorkoutPlanExercisesTableFilterComposer,
          $$WorkoutPlanExercisesTableOrderingComposer,
          $$WorkoutPlanExercisesTableAnnotationComposer,
          $$WorkoutPlanExercisesTableCreateCompanionBuilder,
          $$WorkoutPlanExercisesTableUpdateCompanionBuilder,
          (WorkoutPlanExercise, $$WorkoutPlanExercisesTableReferences),
          WorkoutPlanExercise,
          PrefetchHooks Function({
            bool workoutPlanId,
            bool exerciseId,
            bool defaultGymMachineId,
          })
        > {
  $$WorkoutPlanExercisesTableTableManager(
    _$AppDatabase db,
    $WorkoutPlanExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutPlanExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutPlanExercisesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkoutPlanExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String> workoutPlanId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String?> defaultGymMachineId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> supersetGroupId = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int?> targetReps = const Value.absent(),
                Value<int?> targetRestSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutPlanExercisesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                workoutPlanId: workoutPlanId,
                exerciseId: exerciseId,
                defaultGymMachineId: defaultGymMachineId,
                sortOrder: sortOrder,
                supersetGroupId: supersetGroupId,
                targetSets: targetSets,
                targetReps: targetReps,
                targetRestSeconds: targetRestSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                required String workoutPlanId,
                required String exerciseId,
                Value<String?> defaultGymMachineId = const Value.absent(),
                required int sortOrder,
                Value<String?> supersetGroupId = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int?> targetReps = const Value.absent(),
                Value<int?> targetRestSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutPlanExercisesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                workoutPlanId: workoutPlanId,
                exerciseId: exerciseId,
                defaultGymMachineId: defaultGymMachineId,
                sortOrder: sortOrder,
                supersetGroupId: supersetGroupId,
                targetSets: targetSets,
                targetReps: targetReps,
                targetRestSeconds: targetRestSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutPlanExercisesTable, WorkoutPlanExercise>(
                    table,
                  ),
                  $$WorkoutPlanExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutPlanId = false,
                exerciseId = false,
                defaultGymMachineId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (workoutPlanId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workoutPlanId,
                            referencedTable:
                                $$WorkoutPlanExercisesTableReferences
                                    ._workoutPlanIdTable(db),
                            referencedColumn:
                                $$WorkoutPlanExercisesTableReferences
                                    ._workoutPlanIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (exerciseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable:
                                $$WorkoutPlanExercisesTableReferences
                                    ._exerciseIdTable(db),
                            referencedColumn:
                                $$WorkoutPlanExercisesTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (defaultGymMachineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.defaultGymMachineId,
                            referencedTable:
                                $$WorkoutPlanExercisesTableReferences
                                    ._defaultGymMachineIdTable(db),
                            referencedColumn:
                                $$WorkoutPlanExercisesTableReferences
                                    ._defaultGymMachineIdTable(db)
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
        ),
      );
}

typedef $$WorkoutPlanExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutPlanExercisesTable,
      WorkoutPlanExercise,
      $$WorkoutPlanExercisesTableFilterComposer,
      $$WorkoutPlanExercisesTableOrderingComposer,
      $$WorkoutPlanExercisesTableAnnotationComposer,
      $$WorkoutPlanExercisesTableCreateCompanionBuilder,
      $$WorkoutPlanExercisesTableUpdateCompanionBuilder,
      (WorkoutPlanExercise, $$WorkoutPlanExercisesTableReferences),
      WorkoutPlanExercise,
      PrefetchHooks Function({
        bool workoutPlanId,
        bool exerciseId,
        bool defaultGymMachineId,
      })
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<String?> workoutPlanId,
      Value<String?> gymLocationId,
      required DateTime startedAt,
      Value<DateTime?> completedAt,
      Value<String?> sessionNotes,
      Value<int> rowid,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<String?> workoutPlanId,
      Value<String?> gymLocationId,
      Value<DateTime> startedAt,
      Value<DateTime?> completedAt,
      Value<String?> sessionNotes,
      Value<int> rowid,
    });

final class $$WorkoutSessionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $WorkoutSessionsTable, WorkoutSession> {
  $$WorkoutSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutPlansTable _workoutPlanIdTable(_$AppDatabase db) => db
      .workoutPlans
      .createAlias('workout_sessions__workout_plan_id__workout_plans__id');

  $$WorkoutPlansTableProcessedTableManager? get workoutPlanId {
    final $_column = $_itemColumn<String>('workout_plan_id');
    if ($_column == null) return null;
    final manager = $$WorkoutPlansTableTableManager(
      $_db,
      $_db.workoutPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutPlanIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GymLocationsTable _gymLocationIdTable(_$AppDatabase db) => db
      .gymLocations
      .createAlias('workout_sessions__gym_location_id__gym_locations__id');

  $$GymLocationsTableProcessedTableManager? get gymLocationId {
    final $_column = $_itemColumn<String>('gym_location_id');
    if ($_column == null) return null;
    final manager = $$GymLocationsTableTableManager(
      $_db,
      $_db.gymLocations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gymLocationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $WorkoutSessionExercisesTable,
    List<WorkoutSessionExercise>
  >
  _workoutSessionExercisesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.workoutSessionExercises,
    aliasName:
        'workout_sessions__id__workout_session_exercises__workout_session_id',
  );

  $$WorkoutSessionExercisesTableProcessedTableManager
  get workoutSessionExercisesRefs {
    final manager =
        $$WorkoutSessionExercisesTableTableManager(
          $_db,
          $_db.workoutSessionExercises,
        ).filter(
          (f) => f.workoutSessionId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _workoutSessionExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionNotes => $composableBuilder(
    column: $table.sessionNotes,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutPlansTableFilterComposer get workoutPlanId {
    final $$WorkoutPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutPlanId,
      referencedTable: $db.workoutPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlansTableFilterComposer(
            $db: $db,
            $table: $db.workoutPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GymLocationsTableFilterComposer get gymLocationId {
    final $$GymLocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gymLocationId,
      referencedTable: $db.gymLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymLocationsTableFilterComposer(
            $db: $db,
            $table: $db.gymLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workoutSessionExercisesRefs(
    Expression<bool> Function($$WorkoutSessionExercisesTableFilterComposer f) f,
  ) {
    final $$WorkoutSessionExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.workoutSessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableFilterComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionNotes => $composableBuilder(
    column: $table.sessionNotes,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutPlansTableOrderingComposer get workoutPlanId {
    final $$WorkoutPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutPlanId,
      referencedTable: $db.workoutPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlansTableOrderingComposer(
            $db: $db,
            $table: $db.workoutPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GymLocationsTableOrderingComposer get gymLocationId {
    final $$GymLocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gymLocationId,
      referencedTable: $db.gymLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymLocationsTableOrderingComposer(
            $db: $db,
            $table: $db.gymLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionNotes => $composableBuilder(
    column: $table.sessionNotes,
    builder: (column) => column,
  );

  $$WorkoutPlansTableAnnotationComposer get workoutPlanId {
    final $$WorkoutPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutPlanId,
      referencedTable: $db.workoutPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GymLocationsTableAnnotationComposer get gymLocationId {
    final $$GymLocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gymLocationId,
      referencedTable: $db.gymLocations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymLocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.gymLocations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workoutSessionExercisesRefs<T extends Object>(
    Expression<T> Function($$WorkoutSessionExercisesTableAnnotationComposer a)
    f,
  ) {
    final $$WorkoutSessionExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.workoutSessionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSession,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (WorkoutSession, $$WorkoutSessionsTableReferences),
          WorkoutSession,
          PrefetchHooks Function({
            bool workoutPlanId,
            bool gymLocationId,
            bool workoutSessionExercisesRefs,
          })
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> workoutPlanId = const Value.absent(),
                Value<String?> gymLocationId = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> sessionNotes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                workoutPlanId: workoutPlanId,
                gymLocationId: gymLocationId,
                startedAt: startedAt,
                completedAt: completedAt,
                sessionNotes: sessionNotes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String?> workoutPlanId = const Value.absent(),
                Value<String?> gymLocationId = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<String?> sessionNotes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                workoutPlanId: workoutPlanId,
                gymLocationId: gymLocationId,
                startedAt: startedAt,
                completedAt: completedAt,
                sessionNotes: sessionNotes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSessionsTable, WorkoutSession>(table),
                  $$WorkoutSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutPlanId = false,
                gymLocationId = false,
                workoutSessionExercisesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutSessionExercisesRefs) db.workoutSessionExercises,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (workoutPlanId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workoutPlanId,
                            referencedTable: $$WorkoutSessionsTableReferences
                                ._workoutPlanIdTable(db),
                            referencedColumn: $$WorkoutSessionsTableReferences
                                ._workoutPlanIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (gymLocationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.gymLocationId,
                            referencedTable: $$WorkoutSessionsTableReferences
                                ._gymLocationIdTable(db),
                            referencedColumn: $$WorkoutSessionsTableReferences
                                ._gymLocationIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutSessionExercisesRefs)
                        await $_getPrefetchedDataByColumns<
                          WorkoutSession,
                          $WorkoutSessionsTable,
                          WorkoutSessionExercise,
                          $WorkoutSessionExercisesTable
                        >(
                          currentTable: table,
                          referencedTable: $$WorkoutSessionsTableReferences
                              ._workoutSessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutSessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSessionExercisesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'workout_session_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSession,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (WorkoutSession, $$WorkoutSessionsTableReferences),
      WorkoutSession,
      PrefetchHooks Function({
        bool workoutPlanId,
        bool gymLocationId,
        bool workoutSessionExercisesRefs,
      })
    >;
typedef $$WorkoutSessionExercisesTableCreateCompanionBuilder =
    WorkoutSessionExercisesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      required String workoutSessionId,
      required String exerciseId,
      Value<String?> gymMachineId,
      Value<int> sortOrder,
      Value<String?> supersetGroupId,
      Value<int> rowid,
    });
typedef $$WorkoutSessionExercisesTableUpdateCompanionBuilder =
    WorkoutSessionExercisesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<String> workoutSessionId,
      Value<String> exerciseId,
      Value<String?> gymMachineId,
      Value<int> sortOrder,
      Value<String?> supersetGroupId,
      Value<int> rowid,
    });

final class $$WorkoutSessionExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutSessionExercisesTable,
          WorkoutSessionExercise
        > {
  $$WorkoutSessionExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $WorkoutSessionsTable _workoutSessionIdTable(_$AppDatabase db) =>
      db.workoutSessions.createAlias(
        'workout_session_exercises__workout_session_id__workout_sessions__id',
      );

  $$WorkoutSessionsTableProcessedTableManager get workoutSessionId {
    final $_column = $_itemColumn<String>('workout_session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_workoutSessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) => db.exercises
      .createAlias('workout_session_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GymMachinesTable _gymMachineIdTable(_$AppDatabase db) =>
      db.gymMachines.createAlias(
        'workout_session_exercises__gym_machine_id__gym_machines__id',
      );

  $$GymMachinesTableProcessedTableManager? get gymMachineId {
    final $_column = $_itemColumn<String>('gym_machine_id');
    if ($_column == null) return null;
    final manager = $$GymMachinesTableTableManager(
      $_db,
      $_db.gymMachines,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gymMachineIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSet>>
  _workoutSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSets,
    aliasName: 'workout_session_exercises__id__workout_sets__workout_session_exercise_id',
  );

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager($_db, $_db.workoutSets)
        .filter(
          (f) => f.workoutSessionExerciseId.id.sqlEquals(
            $_itemColumn<String>('id')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutSessionExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionExercisesTable> {
  $$WorkoutSessionExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supersetGroupId => $composableBuilder(
    column: $table.supersetGroupId,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionsTableFilterComposer get workoutSessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutSessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GymMachinesTableFilterComposer get gymMachineId {
    final $$GymMachinesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gymMachineId,
      referencedTable: $db.gymMachines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymMachinesTableFilterComposer(
            $db: $db,
            $table: $db.gymMachines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> workoutSetsRefs(
    Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.workoutSessionExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionExercisesTable> {
  $$WorkoutSessionExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supersetGroupId => $composableBuilder(
    column: $table.supersetGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionsTableOrderingComposer get workoutSessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutSessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GymMachinesTableOrderingComposer get gymMachineId {
    final $$GymMachinesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gymMachineId,
      referencedTable: $db.gymMachines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymMachinesTableOrderingComposer(
            $db: $db,
            $table: $db.gymMachines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSessionExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionExercisesTable> {
  $$WorkoutSessionExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get supersetGroupId => $composableBuilder(
    column: $table.supersetGroupId,
    builder: (column) => column,
  );

  $$WorkoutSessionsTableAnnotationComposer get workoutSessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.workoutSessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GymMachinesTableAnnotationComposer get gymMachineId {
    final $$GymMachinesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gymMachineId,
      referencedTable: $db.gymMachines,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GymMachinesTableAnnotationComposer(
            $db: $db,
            $table: $db.gymMachines,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> workoutSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.workoutSessionExerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionExercisesTable,
          WorkoutSessionExercise,
          $$WorkoutSessionExercisesTableFilterComposer,
          $$WorkoutSessionExercisesTableOrderingComposer,
          $$WorkoutSessionExercisesTableAnnotationComposer,
          $$WorkoutSessionExercisesTableCreateCompanionBuilder,
          $$WorkoutSessionExercisesTableUpdateCompanionBuilder,
          (WorkoutSessionExercise, $$WorkoutSessionExercisesTableReferences),
          WorkoutSessionExercise,
          PrefetchHooks Function({
            bool workoutSessionId,
            bool exerciseId,
            bool gymMachineId,
            bool workoutSetsRefs,
          })
        > {
  $$WorkoutSessionExercisesTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionExercisesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$WorkoutSessionExercisesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$WorkoutSessionExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String> workoutSessionId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String?> gymMachineId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> supersetGroupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionExercisesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                workoutSessionId: workoutSessionId,
                exerciseId: exerciseId,
                gymMachineId: gymMachineId,
                sortOrder: sortOrder,
                supersetGroupId: supersetGroupId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                required String workoutSessionId,
                required String exerciseId,
                Value<String?> gymMachineId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> supersetGroupId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSessionExercisesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                workoutSessionId: workoutSessionId,
                exerciseId: exerciseId,
                gymMachineId: gymMachineId,
                sortOrder: sortOrder,
                supersetGroupId: supersetGroupId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $WorkoutSessionExercisesTable,
                    WorkoutSessionExercise
                  >(table),
                  $$WorkoutSessionExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                workoutSessionId = false,
                exerciseId = false,
                gymMachineId = false,
                workoutSetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (workoutSetsRefs) db.workoutSets,
                  ],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (workoutSessionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workoutSessionId,
                            referencedTable:
                                $$WorkoutSessionExercisesTableReferences
                                    ._workoutSessionIdTable(db),
                            referencedColumn:
                                $$WorkoutSessionExercisesTableReferences
                                    ._workoutSessionIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (exerciseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.exerciseId,
                            referencedTable:
                                $$WorkoutSessionExercisesTableReferences
                                    ._exerciseIdTable(db),
                            referencedColumn:
                                $$WorkoutSessionExercisesTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (gymMachineId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.gymMachineId,
                            referencedTable:
                                $$WorkoutSessionExercisesTableReferences
                                    ._gymMachineIdTable(db),
                            referencedColumn:
                                $$WorkoutSessionExercisesTableReferences
                                    ._gymMachineIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (workoutSetsRefs)
                        await $_getPrefetchedDataByColumns<
                          WorkoutSessionExercise,
                          $WorkoutSessionExercisesTable,
                          WorkoutSet,
                          $WorkoutSetsTable
                        >(
                          currentTable: table,
                          referencedTable:
                              $$WorkoutSessionExercisesTableReferences
                                  ._workoutSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$WorkoutSessionExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSetsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'workout_session_exercise_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$WorkoutSessionExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionExercisesTable,
      WorkoutSessionExercise,
      $$WorkoutSessionExercisesTableFilterComposer,
      $$WorkoutSessionExercisesTableOrderingComposer,
      $$WorkoutSessionExercisesTableAnnotationComposer,
      $$WorkoutSessionExercisesTableCreateCompanionBuilder,
      $$WorkoutSessionExercisesTableUpdateCompanionBuilder,
      (WorkoutSessionExercise, $$WorkoutSessionExercisesTableReferences),
      WorkoutSessionExercise,
      PrefetchHooks Function({
        bool workoutSessionId,
        bool exerciseId,
        bool gymMachineId,
        bool workoutSetsRefs,
      })
    >;
typedef $$WorkoutSetsTableCreateCompanionBuilder =
    WorkoutSetsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      required String workoutSessionExerciseId,
      required int setNumber,
      Value<String?> parentSetId,
      Value<SetType> setType,
      Value<double?> weight,
      Value<int?> reps,
      Value<int?> durationSeconds,
      Value<double?> distanceMeters,
      Value<double?> rpe,
      Value<AssistanceType> assistanceType,
      Value<int?> targetRestSeconds,
      Value<int?> actualRestSeconds,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });
typedef $$WorkoutSetsTableUpdateCompanionBuilder =
    WorkoutSetsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<String> workoutSessionExerciseId,
      Value<int> setNumber,
      Value<String?> parentSetId,
      Value<SetType> setType,
      Value<double?> weight,
      Value<int?> reps,
      Value<int?> durationSeconds,
      Value<double?> distanceMeters,
      Value<double?> rpe,
      Value<AssistanceType> assistanceType,
      Value<int?> targetRestSeconds,
      Value<int?> actualRestSeconds,
      Value<bool> isCompleted,
      Value<DateTime?> completedAt,
      Value<int> rowid,
    });

final class $$WorkoutSetsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSet> {
  $$WorkoutSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutSessionExercisesTable _workoutSessionExerciseIdTable(
    _$AppDatabase db,
  ) => db.workoutSessionExercises.createAlias(
    'workout_sets__workout_session_exercise_id__workout_session_exercises__id',
  );

  $$WorkoutSessionExercisesTableProcessedTableManager
  get workoutSessionExerciseId {
    final $_column = $_itemColumn<String>('workout_session_exercise_id')!;

    final manager = $$WorkoutSessionExercisesTableTableManager(
      $_db,
      $_db.workoutSessionExercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _workoutSessionExerciseIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WorkoutSetsTable _parentSetIdTable(_$AppDatabase db) => db.workoutSets
      .createAlias('workout_sets__parent_set_id__workout_sets__id');

  $$WorkoutSetsTableProcessedTableManager? get parentSetId {
    final $_column = $_itemColumn<String>('parent_set_id');
    if ($_column == null) return null;
    final manager = $$WorkoutSetsTableTableManager(
      $_db,
      $_db.workoutSets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentSetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SetType, SetType, String> get setType =>
      $composableBuilder(
        column: $table.setType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AssistanceType, AssistanceType, String>
  get assistanceType => $composableBuilder(
    column: $table.assistanceType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get targetRestSeconds => $composableBuilder(
    column: $table.targetRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualRestSeconds => $composableBuilder(
    column: $table.actualRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionExercisesTableFilterComposer get workoutSessionExerciseId {
    final $$WorkoutSessionExercisesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutSessionExerciseId,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableFilterComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$WorkoutSetsTableFilterComposer get parentSetId {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentSetId,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setNumber => $composableBuilder(
    column: $table.setNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setType => $composableBuilder(
    column: $table.setType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assistanceType => $composableBuilder(
    column: $table.assistanceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetRestSeconds => $composableBuilder(
    column: $table.targetRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualRestSeconds => $composableBuilder(
    column: $table.actualRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionExercisesTableOrderingComposer get workoutSessionExerciseId {
    final $$WorkoutSessionExercisesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutSessionExerciseId,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableOrderingComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$WorkoutSetsTableOrderingComposer get parentSetId {
    final $$WorkoutSetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentSetId,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<int> get setNumber =>
      $composableBuilder(column: $table.setNumber, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SetType, String> get setType =>
      $composableBuilder(column: $table.setType, builder: (column) => column);

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AssistanceType, String> get assistanceType =>
      $composableBuilder(
        column: $table.assistanceType,
        builder: (column) => column,
      );

  GeneratedColumn<int> get targetRestSeconds => $composableBuilder(
    column: $table.targetRestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualRestSeconds => $composableBuilder(
    column: $table.actualRestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$WorkoutSessionExercisesTableAnnotationComposer
  get workoutSessionExerciseId {
    final $$WorkoutSessionExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.workoutSessionExerciseId,
          referencedTable: $db.workoutSessionExercises,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$WorkoutSessionExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.workoutSessionExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$WorkoutSetsTableAnnotationComposer get parentSetId {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentSetId,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSetsTable,
          WorkoutSet,
          $$WorkoutSetsTableFilterComposer,
          $$WorkoutSetsTableOrderingComposer,
          $$WorkoutSetsTableAnnotationComposer,
          $$WorkoutSetsTableCreateCompanionBuilder,
          $$WorkoutSetsTableUpdateCompanionBuilder,
          (WorkoutSet, $$WorkoutSetsTableReferences),
          WorkoutSet,
          PrefetchHooks Function({
            bool workoutSessionExerciseId,
            bool parentSetId,
          })
        > {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<String> workoutSessionExerciseId = const Value.absent(),
                Value<int> setNumber = const Value.absent(),
                Value<String?> parentSetId = const Value.absent(),
                Value<SetType> setType = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<AssistanceType> assistanceType = const Value.absent(),
                Value<int?> targetRestSeconds = const Value.absent(),
                Value<int?> actualRestSeconds = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSetsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                workoutSessionExerciseId: workoutSessionExerciseId,
                setNumber: setNumber,
                parentSetId: parentSetId,
                setType: setType,
                weight: weight,
                reps: reps,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
                rpe: rpe,
                assistanceType: assistanceType,
                targetRestSeconds: targetRestSeconds,
                actualRestSeconds: actualRestSeconds,
                isCompleted: isCompleted,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                required String workoutSessionExerciseId,
                required int setNumber,
                Value<String?> parentSetId = const Value.absent(),
                Value<SetType> setType = const Value.absent(),
                Value<double?> weight = const Value.absent(),
                Value<int?> reps = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<double?> distanceMeters = const Value.absent(),
                Value<double?> rpe = const Value.absent(),
                Value<AssistanceType> assistanceType = const Value.absent(),
                Value<int?> targetRestSeconds = const Value.absent(),
                Value<int?> actualRestSeconds = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSetsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                workoutSessionExerciseId: workoutSessionExerciseId,
                setNumber: setNumber,
                parentSetId: parentSetId,
                setType: setType,
                weight: weight,
                reps: reps,
                durationSeconds: durationSeconds,
                distanceMeters: distanceMeters,
                rpe: rpe,
                assistanceType: assistanceType,
                targetRestSeconds: targetRestSeconds,
                actualRestSeconds: actualRestSeconds,
                isCompleted: isCompleted,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSetsTable, WorkoutSet>(table),
                  $$WorkoutSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({workoutSessionExerciseId = false, parentSetId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
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
                          dynamic
                        >
                      >(state) {
                        if (workoutSessionExerciseId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.workoutSessionExerciseId,
                            referencedTable: $$WorkoutSetsTableReferences
                                ._workoutSessionExerciseIdTable(db),
                            referencedColumn: $$WorkoutSetsTableReferences
                                ._workoutSessionExerciseIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (parentSetId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentSetId,
                            referencedTable: $$WorkoutSetsTableReferences
                                ._parentSetIdTable(db),
                            referencedColumn: $$WorkoutSetsTableReferences
                                ._parentSetIdTable(db)
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
        ),
      );
}

typedef $$WorkoutSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSetsTable,
      WorkoutSet,
      $$WorkoutSetsTableFilterComposer,
      $$WorkoutSetsTableOrderingComposer,
      $$WorkoutSetsTableAnnotationComposer,
      $$WorkoutSetsTableCreateCompanionBuilder,
      $$WorkoutSetsTableUpdateCompanionBuilder,
      (WorkoutSet, $$WorkoutSetsTableReferences),
      WorkoutSet,
      PrefetchHooks Function({bool workoutSessionExerciseId, bool parentSetId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<bool> useSplitWarmupRest,
      Value<int> largeMuscleWarmupRestSeconds,
      Value<int> smallMuscleWarmupRestSeconds,
      Value<int> globalWarmupRestSeconds,
      Value<int> defaultWorkingSetRestSeconds,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<SyncStatus> syncStatus,
      Value<bool> useSplitWarmupRest,
      Value<int> largeMuscleWarmupRestSeconds,
      Value<int> smallMuscleWarmupRestSeconds,
      Value<int> globalWarmupRestSeconds,
      Value<int> defaultWorkingSetRestSeconds,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SyncStatus, SyncStatus, String>
  get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get useSplitWarmupRest => $composableBuilder(
    column: $table.useSplitWarmupRest,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get largeMuscleWarmupRestSeconds => $composableBuilder(
    column: $table.largeMuscleWarmupRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get smallMuscleWarmupRestSeconds => $composableBuilder(
    column: $table.smallMuscleWarmupRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get globalWarmupRestSeconds => $composableBuilder(
    column: $table.globalWarmupRestSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultWorkingSetRestSeconds => $composableBuilder(
    column: $table.defaultWorkingSetRestSeconds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get useSplitWarmupRest => $composableBuilder(
    column: $table.useSplitWarmupRest,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get largeMuscleWarmupRestSeconds => $composableBuilder(
    column: $table.largeMuscleWarmupRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get smallMuscleWarmupRestSeconds => $composableBuilder(
    column: $table.smallMuscleWarmupRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get globalWarmupRestSeconds => $composableBuilder(
    column: $table.globalWarmupRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultWorkingSetRestSeconds => $composableBuilder(
    column: $table.defaultWorkingSetRestSeconds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SyncStatus, String> get syncStatus =>
      $composableBuilder(
        column: $table.syncStatus,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get useSplitWarmupRest => $composableBuilder(
    column: $table.useSplitWarmupRest,
    builder: (column) => column,
  );

  GeneratedColumn<int> get largeMuscleWarmupRestSeconds => $composableBuilder(
    column: $table.largeMuscleWarmupRestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get smallMuscleWarmupRestSeconds => $composableBuilder(
    column: $table.smallMuscleWarmupRestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get globalWarmupRestSeconds => $composableBuilder(
    column: $table.globalWarmupRestSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultWorkingSetRestSeconds => $composableBuilder(
    column: $table.defaultWorkingSetRestSeconds,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<bool> useSplitWarmupRest = const Value.absent(),
                Value<int> largeMuscleWarmupRestSeconds = const Value.absent(),
                Value<int> smallMuscleWarmupRestSeconds = const Value.absent(),
                Value<int> globalWarmupRestSeconds = const Value.absent(),
                Value<int> defaultWorkingSetRestSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                useSplitWarmupRest: useSplitWarmupRest,
                largeMuscleWarmupRestSeconds: largeMuscleWarmupRestSeconds,
                smallMuscleWarmupRestSeconds: smallMuscleWarmupRestSeconds,
                globalWarmupRestSeconds: globalWarmupRestSeconds,
                defaultWorkingSetRestSeconds: defaultWorkingSetRestSeconds,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<SyncStatus> syncStatus = const Value.absent(),
                Value<bool> useSplitWarmupRest = const Value.absent(),
                Value<int> largeMuscleWarmupRestSeconds = const Value.absent(),
                Value<int> smallMuscleWarmupRestSeconds = const Value.absent(),
                Value<int> globalWarmupRestSeconds = const Value.absent(),
                Value<int> defaultWorkingSetRestSeconds = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncStatus: syncStatus,
                useSplitWarmupRest: useSplitWarmupRest,
                largeMuscleWarmupRestSeconds: largeMuscleWarmupRestSeconds,
                smallMuscleWarmupRestSeconds: smallMuscleWarmupRestSeconds,
                globalWarmupRestSeconds: globalWarmupRestSeconds,
                defaultWorkingSetRestSeconds: defaultWorkingSetRestSeconds,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GymLocationsTableTableManager get gymLocations =>
      $$GymLocationsTableTableManager(_db, _db.gymLocations);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$GymMachinesTableTableManager get gymMachines =>
      $$GymMachinesTableTableManager(_db, _db.gymMachines);
  $$ExerciseMediaTableTableManager get exerciseMedia =>
      $$ExerciseMediaTableTableManager(_db, _db.exerciseMedia);
  $$WorkoutPlansTableTableManager get workoutPlans =>
      $$WorkoutPlansTableTableManager(_db, _db.workoutPlans);
  $$WorkoutPlanExercisesTableTableManager get workoutPlanExercises =>
      $$WorkoutPlanExercisesTableTableManager(_db, _db.workoutPlanExercises);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$WorkoutSessionExercisesTableTableManager get workoutSessionExercises =>
      $$WorkoutSessionExercisesTableTableManager(
        _db,
        _db.workoutSessionExercises,
      );
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';
