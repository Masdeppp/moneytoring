// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AccountsTable extends Accounts
    with TableInfo<$AccountsTable, AccountRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccountType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AccountType>($AccountsTable.$convertertype);
  static const VerificationMeta _initialBalanceMeta = const VerificationMeta(
    'initialBalance',
  );
  @override
  late final GeneratedColumn<int> initialBalance = GeneratedColumn<int>(
    'initial_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Tone, String> tone =
      GeneratedColumn<String>(
        'tone',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('brand'),
      ).withConverter<Tone>($AccountsTable.$convertertone);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    initialBalance,
    tone,
    icon,
    archived,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('initial_balance')) {
      context.handle(
        _initialBalanceMeta,
        initialBalance.isAcceptableOrUnknown(
          data['initial_balance']!,
          _initialBalanceMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AccountRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $AccountsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      initialBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}initial_balance'],
      )!,
      tone: $AccountsTable.$convertertone.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tone'],
        )!,
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $AccountsTable createAlias(String alias) {
    return $AccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountType, String, String> $convertertype =
      const EnumNameConverter<AccountType>(AccountType.values);
  static JsonTypeConverter2<Tone, String, String> $convertertone =
      const EnumNameConverter<Tone>(Tone.values);
}

class AccountRecord extends DataClass implements Insertable<AccountRecord> {
  final int id;
  final String name;
  final AccountType type;
  final int initialBalance;
  final Tone tone;
  final String icon;
  final bool archived;
  final int sortOrder;
  const AccountRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.tone,
    required this.icon,
    required this.archived,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>($AccountsTable.$convertertype.toSql(type));
    }
    map['initial_balance'] = Variable<int>(initialBalance);
    {
      map['tone'] = Variable<String>($AccountsTable.$convertertone.toSql(tone));
    }
    map['icon'] = Variable<String>(icon);
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  AccountsCompanion toCompanion(bool nullToAbsent) {
    return AccountsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      initialBalance: Value(initialBalance),
      tone: Value(tone),
      icon: Value(icon),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
    );
  }

  factory AccountRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountRecord(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $AccountsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      initialBalance: serializer.fromJson<int>(json['initialBalance']),
      tone: $AccountsTable.$convertertone.fromJson(
        serializer.fromJson<String>(json['tone']),
      ),
      icon: serializer.fromJson<String>(json['icon']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $AccountsTable.$convertertype.toJson(type),
      ),
      'initialBalance': serializer.toJson<int>(initialBalance),
      'tone': serializer.toJson<String>(
        $AccountsTable.$convertertone.toJson(tone),
      ),
      'icon': serializer.toJson<String>(icon),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  AccountRecord copyWith({
    int? id,
    String? name,
    AccountType? type,
    int? initialBalance,
    Tone? tone,
    String? icon,
    bool? archived,
    int? sortOrder,
  }) => AccountRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    initialBalance: initialBalance ?? this.initialBalance,
    tone: tone ?? this.tone,
    icon: icon ?? this.icon,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  AccountRecord copyWithCompanion(AccountsCompanion data) {
    return AccountRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      initialBalance: data.initialBalance.present
          ? data.initialBalance.value
          : this.initialBalance,
      tone: data.tone.present ? data.tone.value : this.tone,
      icon: data.icon.present ? data.icon.value : this.icon,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('tone: $tone, ')
          ..write('icon: $icon, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    initialBalance,
    tone,
    icon,
    archived,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.initialBalance == this.initialBalance &&
          other.tone == this.tone &&
          other.icon == this.icon &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder);
}

class AccountsCompanion extends UpdateCompanion<AccountRecord> {
  final Value<int> id;
  final Value<String> name;
  final Value<AccountType> type;
  final Value<int> initialBalance;
  final Value<Tone> tone;
  final Value<String> icon;
  final Value<bool> archived;
  final Value<int> sortOrder;
  const AccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.initialBalance = const Value.absent(),
    this.tone = const Value.absent(),
    this.icon = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  AccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required AccountType type,
    this.initialBalance = const Value.absent(),
    this.tone = const Value.absent(),
    required String icon,
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       icon = Value(icon);
  static Insertable<AccountRecord> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<int>? initialBalance,
    Expression<String>? tone,
    Expression<String>? icon,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (initialBalance != null) 'initial_balance': initialBalance,
      if (tone != null) 'tone': tone,
      if (icon != null) 'icon': icon,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  AccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<AccountType>? type,
    Value<int>? initialBalance,
    Value<Tone>? tone,
    Value<String>? icon,
    Value<bool>? archived,
    Value<int>? sortOrder,
  }) {
    return AccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      tone: tone ?? this.tone,
      icon: icon ?? this.icon,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $AccountsTable.$convertertype.toSql(type.value),
      );
    }
    if (initialBalance.present) {
      map['initial_balance'] = Variable<int>(initialBalance.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(
        $AccountsTable.$convertertone.toSql(tone.value),
      );
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('initialBalance: $initialBalance, ')
          ..write('tone: $tone, ')
          ..write('icon: $icon, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CategoryType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CategoryType>($CategoriesTable.$convertertype);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<Tone, String> tone =
      GeneratedColumn<String>(
        'tone',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Tone>($CategoriesTable.$convertertone);
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    icon,
    tone,
    isDefault,
    archived,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: $CategoriesTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      tone: $CategoriesTable.$convertertone.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tone'],
        )!,
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CategoryType, String, String> $convertertype =
      const EnumNameConverter<CategoryType>(CategoryType.values);
  static JsonTypeConverter2<Tone, String, String> $convertertone =
      const EnumNameConverter<Tone>(Tone.values);
}

class CategoryRecord extends DataClass implements Insertable<CategoryRecord> {
  final int id;
  final String name;
  final CategoryType type;

  /// Nama ikon Lucide, mis. `utensils`.
  final String icon;
  final Tone tone;
  final bool isDefault;
  final bool archived;
  final int sortOrder;
  const CategoryRecord({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.tone,
    required this.isDefault,
    required this.archived,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['type'] = Variable<String>(
        $CategoriesTable.$convertertype.toSql(type),
      );
    }
    map['icon'] = Variable<String>(icon);
    {
      map['tone'] = Variable<String>(
        $CategoriesTable.$convertertone.toSql(tone),
      );
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['archived'] = Variable<bool>(archived);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      icon: Value(icon),
      tone: Value(tone),
      isDefault: Value(isDefault),
      archived: Value(archived),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRecord(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: $CategoriesTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      icon: serializer.fromJson<String>(json['icon']),
      tone: $CategoriesTable.$convertertone.fromJson(
        serializer.fromJson<String>(json['tone']),
      ),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      archived: serializer.fromJson<bool>(json['archived']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(
        $CategoriesTable.$convertertype.toJson(type),
      ),
      'icon': serializer.toJson<String>(icon),
      'tone': serializer.toJson<String>(
        $CategoriesTable.$convertertone.toJson(tone),
      ),
      'isDefault': serializer.toJson<bool>(isDefault),
      'archived': serializer.toJson<bool>(archived),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryRecord copyWith({
    int? id,
    String? name,
    CategoryType? type,
    String? icon,
    Tone? tone,
    bool? isDefault,
    bool? archived,
    int? sortOrder,
  }) => CategoryRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    icon: icon ?? this.icon,
    tone: tone ?? this.tone,
    isDefault: isDefault ?? this.isDefault,
    archived: archived ?? this.archived,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryRecord copyWithCompanion(CategoriesCompanion data) {
    return CategoryRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      icon: data.icon.present ? data.icon.value : this.icon,
      tone: data.tone.present ? data.tone.value : this.tone,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      archived: data.archived.present ? data.archived.value : this.archived,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('tone: $tone, ')
          ..write('isDefault: $isDefault, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, type, icon, tone, isDefault, archived, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.icon == this.icon &&
          other.tone == this.tone &&
          other.isDefault == this.isDefault &&
          other.archived == this.archived &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRecord> {
  final Value<int> id;
  final Value<String> name;
  final Value<CategoryType> type;
  final Value<String> icon;
  final Value<Tone> tone;
  final Value<bool> isDefault;
  final Value<bool> archived;
  final Value<int> sortOrder;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.icon = const Value.absent(),
    this.tone = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required CategoryType type,
    required String icon,
    required Tone tone,
    this.isDefault = const Value.absent(),
    this.archived = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       type = Value(type),
       icon = Value(icon),
       tone = Value(tone);
  static Insertable<CategoryRecord> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? icon,
    Expression<String>? tone,
    Expression<bool>? isDefault,
    Expression<bool>? archived,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (tone != null) 'tone': tone,
      if (isDefault != null) 'is_default': isDefault,
      if (archived != null) 'archived': archived,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<CategoryType>? type,
    Value<String>? icon,
    Value<Tone>? tone,
    Value<bool>? isDefault,
    Value<bool>? archived,
    Value<int>? sortOrder,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      tone: tone ?? this.tone,
      isDefault: isDefault ?? this.isDefault,
      archived: archived ?? this.archived,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $CategoriesTable.$convertertype.toSql(type.value),
      );
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (tone.present) {
      map['tone'] = Variable<String>(
        $CategoriesTable.$convertertone.toSql(tone.value),
      );
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('tone: $tone, ')
          ..write('isDefault: $isDefault, ')
          ..write('archived: $archived, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ObligationsTable extends Obligations
    with TableInfo<$ObligationsTable, ObligationRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObligationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ObligationAmountType, String>
  amountType = GeneratedColumn<String>(
    'amount_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<ObligationAmountType>($ObligationsTable.$converteramountType);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    check: () => ComparableExpr(amount).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDayMeta = const VerificationMeta('dueDay');
  @override
  late final GeneratedColumn<int> dueDay = GeneratedColumn<int>(
    'due_day',
    aliasedName,
    false,
    check: () => ComparableExpr(dueDay).isBetweenValues(1, 31),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Recurrence, String> recurrence =
      GeneratedColumn<String>(
        'recurrence',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('monthly'),
      ).withConverter<Recurrence>($ObligationsTable.$converterrecurrence);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _autoMatchKeywordsMeta = const VerificationMeta(
    'autoMatchKeywords',
  );
  @override
  late final GeneratedColumn<String> autoMatchKeywords =
      GeneratedColumn<String>(
        'auto_match_keywords',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    amountType,
    amount,
    dueDay,
    categoryId,
    accountId,
    recurrence,
    active,
    autoMatchKeywords,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'obligations';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObligationRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('due_day')) {
      context.handle(
        _dueDayMeta,
        dueDay.isAcceptableOrUnknown(data['due_day']!, _dueDayMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDayMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('auto_match_keywords')) {
      context.handle(
        _autoMatchKeywordsMeta,
        autoMatchKeywords.isAcceptableOrUnknown(
          data['auto_match_keywords']!,
          _autoMatchKeywordsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ObligationRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObligationRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      amountType: $ObligationsTable.$converteramountType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}amount_type'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      dueDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_day'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
      recurrence: $ObligationsTable.$converterrecurrence.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recurrence'],
        )!,
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
      autoMatchKeywords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auto_match_keywords'],
      )!,
    );
  }

  @override
  $ObligationsTable createAlias(String alias) {
    return $ObligationsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ObligationAmountType, String, String>
  $converteramountType = const EnumNameConverter<ObligationAmountType>(
    ObligationAmountType.values,
  );
  static JsonTypeConverter2<Recurrence, String, String> $converterrecurrence =
      const EnumNameConverter<Recurrence>(Recurrence.values);
}

class ObligationRecord extends DataClass
    implements Insertable<ObligationRecord> {
  final int id;
  final String name;
  final ObligationAmountType amountType;
  final int amount;
  final int dueDay;
  final int categoryId;
  final int? accountId;
  final Recurrence recurrence;
  final bool active;

  /// Kata kunci tambahan untuk auto-match, dipisah koma.
  final String autoMatchKeywords;
  const ObligationRecord({
    required this.id,
    required this.name,
    required this.amountType,
    required this.amount,
    required this.dueDay,
    required this.categoryId,
    this.accountId,
    required this.recurrence,
    required this.active,
    required this.autoMatchKeywords,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['amount_type'] = Variable<String>(
        $ObligationsTable.$converteramountType.toSql(amountType),
      );
    }
    map['amount'] = Variable<int>(amount);
    map['due_day'] = Variable<int>(dueDay);
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    {
      map['recurrence'] = Variable<String>(
        $ObligationsTable.$converterrecurrence.toSql(recurrence),
      );
    }
    map['active'] = Variable<bool>(active);
    map['auto_match_keywords'] = Variable<String>(autoMatchKeywords);
    return map;
  }

  ObligationsCompanion toCompanion(bool nullToAbsent) {
    return ObligationsCompanion(
      id: Value(id),
      name: Value(name),
      amountType: Value(amountType),
      amount: Value(amount),
      dueDay: Value(dueDay),
      categoryId: Value(categoryId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      recurrence: Value(recurrence),
      active: Value(active),
      autoMatchKeywords: Value(autoMatchKeywords),
    );
  }

  factory ObligationRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObligationRecord(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amountType: $ObligationsTable.$converteramountType.fromJson(
        serializer.fromJson<String>(json['amountType']),
      ),
      amount: serializer.fromJson<int>(json['amount']),
      dueDay: serializer.fromJson<int>(json['dueDay']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      recurrence: $ObligationsTable.$converterrecurrence.fromJson(
        serializer.fromJson<String>(json['recurrence']),
      ),
      active: serializer.fromJson<bool>(json['active']),
      autoMatchKeywords: serializer.fromJson<String>(json['autoMatchKeywords']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'amountType': serializer.toJson<String>(
        $ObligationsTable.$converteramountType.toJson(amountType),
      ),
      'amount': serializer.toJson<int>(amount),
      'dueDay': serializer.toJson<int>(dueDay),
      'categoryId': serializer.toJson<int>(categoryId),
      'accountId': serializer.toJson<int?>(accountId),
      'recurrence': serializer.toJson<String>(
        $ObligationsTable.$converterrecurrence.toJson(recurrence),
      ),
      'active': serializer.toJson<bool>(active),
      'autoMatchKeywords': serializer.toJson<String>(autoMatchKeywords),
    };
  }

  ObligationRecord copyWith({
    int? id,
    String? name,
    ObligationAmountType? amountType,
    int? amount,
    int? dueDay,
    int? categoryId,
    Value<int?> accountId = const Value.absent(),
    Recurrence? recurrence,
    bool? active,
    String? autoMatchKeywords,
  }) => ObligationRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    amountType: amountType ?? this.amountType,
    amount: amount ?? this.amount,
    dueDay: dueDay ?? this.dueDay,
    categoryId: categoryId ?? this.categoryId,
    accountId: accountId.present ? accountId.value : this.accountId,
    recurrence: recurrence ?? this.recurrence,
    active: active ?? this.active,
    autoMatchKeywords: autoMatchKeywords ?? this.autoMatchKeywords,
  );
  ObligationRecord copyWithCompanion(ObligationsCompanion data) {
    return ObligationRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amountType: data.amountType.present
          ? data.amountType.value
          : this.amountType,
      amount: data.amount.present ? data.amount.value : this.amount,
      dueDay: data.dueDay.present ? data.dueDay.value : this.dueDay,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      recurrence: data.recurrence.present
          ? data.recurrence.value
          : this.recurrence,
      active: data.active.present ? data.active.value : this.active,
      autoMatchKeywords: data.autoMatchKeywords.present
          ? data.autoMatchKeywords.value
          : this.autoMatchKeywords,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObligationRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amountType: $amountType, ')
          ..write('amount: $amount, ')
          ..write('dueDay: $dueDay, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('recurrence: $recurrence, ')
          ..write('active: $active, ')
          ..write('autoMatchKeywords: $autoMatchKeywords')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    amountType,
    amount,
    dueDay,
    categoryId,
    accountId,
    recurrence,
    active,
    autoMatchKeywords,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObligationRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.amountType == this.amountType &&
          other.amount == this.amount &&
          other.dueDay == this.dueDay &&
          other.categoryId == this.categoryId &&
          other.accountId == this.accountId &&
          other.recurrence == this.recurrence &&
          other.active == this.active &&
          other.autoMatchKeywords == this.autoMatchKeywords);
}

class ObligationsCompanion extends UpdateCompanion<ObligationRecord> {
  final Value<int> id;
  final Value<String> name;
  final Value<ObligationAmountType> amountType;
  final Value<int> amount;
  final Value<int> dueDay;
  final Value<int> categoryId;
  final Value<int?> accountId;
  final Value<Recurrence> recurrence;
  final Value<bool> active;
  final Value<String> autoMatchKeywords;
  const ObligationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amountType = const Value.absent(),
    this.amount = const Value.absent(),
    this.dueDay = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.active = const Value.absent(),
    this.autoMatchKeywords = const Value.absent(),
  });
  ObligationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required ObligationAmountType amountType,
    required int amount,
    required int dueDay,
    required int categoryId,
    this.accountId = const Value.absent(),
    this.recurrence = const Value.absent(),
    this.active = const Value.absent(),
    this.autoMatchKeywords = const Value.absent(),
  }) : name = Value(name),
       amountType = Value(amountType),
       amount = Value(amount),
       dueDay = Value(dueDay),
       categoryId = Value(categoryId);
  static Insertable<ObligationRecord> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? amountType,
    Expression<int>? amount,
    Expression<int>? dueDay,
    Expression<int>? categoryId,
    Expression<int>? accountId,
    Expression<String>? recurrence,
    Expression<bool>? active,
    Expression<String>? autoMatchKeywords,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amountType != null) 'amount_type': amountType,
      if (amount != null) 'amount': amount,
      if (dueDay != null) 'due_day': dueDay,
      if (categoryId != null) 'category_id': categoryId,
      if (accountId != null) 'account_id': accountId,
      if (recurrence != null) 'recurrence': recurrence,
      if (active != null) 'active': active,
      if (autoMatchKeywords != null) 'auto_match_keywords': autoMatchKeywords,
    });
  }

  ObligationsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<ObligationAmountType>? amountType,
    Value<int>? amount,
    Value<int>? dueDay,
    Value<int>? categoryId,
    Value<int?>? accountId,
    Value<Recurrence>? recurrence,
    Value<bool>? active,
    Value<String>? autoMatchKeywords,
  }) {
    return ObligationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amountType: amountType ?? this.amountType,
      amount: amount ?? this.amount,
      dueDay: dueDay ?? this.dueDay,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      recurrence: recurrence ?? this.recurrence,
      active: active ?? this.active,
      autoMatchKeywords: autoMatchKeywords ?? this.autoMatchKeywords,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (amountType.present) {
      map['amount_type'] = Variable<String>(
        $ObligationsTable.$converteramountType.toSql(amountType.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (dueDay.present) {
      map['due_day'] = Variable<int>(dueDay.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (recurrence.present) {
      map['recurrence'] = Variable<String>(
        $ObligationsTable.$converterrecurrence.toSql(recurrence.value),
      );
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (autoMatchKeywords.present) {
      map['auto_match_keywords'] = Variable<String>(autoMatchKeywords.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObligationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amountType: $amountType, ')
          ..write('amount: $amount, ')
          ..write('dueDay: $dueDay, ')
          ..write('categoryId: $categoryId, ')
          ..write('accountId: $accountId, ')
          ..write('recurrence: $recurrence, ')
          ..write('active: $active, ')
          ..write('autoMatchKeywords: $autoMatchKeywords')
          ..write(')'))
        .toString();
  }
}

class $ObligationInstancesTable extends ObligationInstances
    with TableInfo<$ObligationInstancesTable, ObligationInstanceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ObligationInstancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _obligationIdMeta = const VerificationMeta(
    'obligationId',
  );
  @override
  late final GeneratedColumn<int> obligationId = GeneratedColumn<int>(
    'obligation_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES obligations (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _cycleStartMeta = const VerificationMeta(
    'cycleStart',
  );
  @override
  late final GeneratedColumn<DateTime> cycleStart = GeneratedColumn<DateTime>(
    'cycle_start',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedAmountMeta = const VerificationMeta(
    'expectedAmount',
  );
  @override
  late final GeneratedColumn<int> expectedAmount = GeneratedColumn<int>(
    'expected_amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ObligationStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('pending'),
      ).withConverter<ObligationStatus>(
        $ObligationInstancesTable.$converterstatus,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    obligationId,
    cycleStart,
    dueDate,
    expectedAmount,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'obligation_instances';
  @override
  VerificationContext validateIntegrity(
    Insertable<ObligationInstanceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('obligation_id')) {
      context.handle(
        _obligationIdMeta,
        obligationId.isAcceptableOrUnknown(
          data['obligation_id']!,
          _obligationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_obligationIdMeta);
    }
    if (data.containsKey('cycle_start')) {
      context.handle(
        _cycleStartMeta,
        cycleStart.isAcceptableOrUnknown(data['cycle_start']!, _cycleStartMeta),
      );
    } else if (isInserting) {
      context.missing(_cycleStartMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('expected_amount')) {
      context.handle(
        _expectedAmountMeta,
        expectedAmount.isAcceptableOrUnknown(
          data['expected_amount']!,
          _expectedAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedAmountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {obligationId, cycleStart},
  ];
  @override
  ObligationInstanceRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ObligationInstanceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      obligationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}obligation_id'],
      )!,
      cycleStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cycle_start'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      expectedAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_amount'],
      )!,
      status: $ObligationInstancesTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
    );
  }

  @override
  $ObligationInstancesTable createAlias(String alias) {
    return $ObligationInstancesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ObligationStatus, String, String> $converterstatus =
      const EnumNameConverter<ObligationStatus>(ObligationStatus.values);
}

class ObligationInstanceRecord extends DataClass
    implements Insertable<ObligationInstanceRecord> {
  final int id;
  final int obligationId;
  final DateTime cycleStart;
  final DateTime dueDate;
  final int expectedAmount;
  final ObligationStatus status;
  const ObligationInstanceRecord({
    required this.id,
    required this.obligationId,
    required this.cycleStart,
    required this.dueDate,
    required this.expectedAmount,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['obligation_id'] = Variable<int>(obligationId);
    map['cycle_start'] = Variable<DateTime>(cycleStart);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['expected_amount'] = Variable<int>(expectedAmount);
    {
      map['status'] = Variable<String>(
        $ObligationInstancesTable.$converterstatus.toSql(status),
      );
    }
    return map;
  }

  ObligationInstancesCompanion toCompanion(bool nullToAbsent) {
    return ObligationInstancesCompanion(
      id: Value(id),
      obligationId: Value(obligationId),
      cycleStart: Value(cycleStart),
      dueDate: Value(dueDate),
      expectedAmount: Value(expectedAmount),
      status: Value(status),
    );
  }

  factory ObligationInstanceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ObligationInstanceRecord(
      id: serializer.fromJson<int>(json['id']),
      obligationId: serializer.fromJson<int>(json['obligationId']),
      cycleStart: serializer.fromJson<DateTime>(json['cycleStart']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      expectedAmount: serializer.fromJson<int>(json['expectedAmount']),
      status: $ObligationInstancesTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'obligationId': serializer.toJson<int>(obligationId),
      'cycleStart': serializer.toJson<DateTime>(cycleStart),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'expectedAmount': serializer.toJson<int>(expectedAmount),
      'status': serializer.toJson<String>(
        $ObligationInstancesTable.$converterstatus.toJson(status),
      ),
    };
  }

  ObligationInstanceRecord copyWith({
    int? id,
    int? obligationId,
    DateTime? cycleStart,
    DateTime? dueDate,
    int? expectedAmount,
    ObligationStatus? status,
  }) => ObligationInstanceRecord(
    id: id ?? this.id,
    obligationId: obligationId ?? this.obligationId,
    cycleStart: cycleStart ?? this.cycleStart,
    dueDate: dueDate ?? this.dueDate,
    expectedAmount: expectedAmount ?? this.expectedAmount,
    status: status ?? this.status,
  );
  ObligationInstanceRecord copyWithCompanion(
    ObligationInstancesCompanion data,
  ) {
    return ObligationInstanceRecord(
      id: data.id.present ? data.id.value : this.id,
      obligationId: data.obligationId.present
          ? data.obligationId.value
          : this.obligationId,
      cycleStart: data.cycleStart.present
          ? data.cycleStart.value
          : this.cycleStart,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      expectedAmount: data.expectedAmount.present
          ? data.expectedAmount.value
          : this.expectedAmount,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ObligationInstanceRecord(')
          ..write('id: $id, ')
          ..write('obligationId: $obligationId, ')
          ..write('cycleStart: $cycleStart, ')
          ..write('dueDate: $dueDate, ')
          ..write('expectedAmount: $expectedAmount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    obligationId,
    cycleStart,
    dueDate,
    expectedAmount,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ObligationInstanceRecord &&
          other.id == this.id &&
          other.obligationId == this.obligationId &&
          other.cycleStart == this.cycleStart &&
          other.dueDate == this.dueDate &&
          other.expectedAmount == this.expectedAmount &&
          other.status == this.status);
}

class ObligationInstancesCompanion
    extends UpdateCompanion<ObligationInstanceRecord> {
  final Value<int> id;
  final Value<int> obligationId;
  final Value<DateTime> cycleStart;
  final Value<DateTime> dueDate;
  final Value<int> expectedAmount;
  final Value<ObligationStatus> status;
  const ObligationInstancesCompanion({
    this.id = const Value.absent(),
    this.obligationId = const Value.absent(),
    this.cycleStart = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.expectedAmount = const Value.absent(),
    this.status = const Value.absent(),
  });
  ObligationInstancesCompanion.insert({
    this.id = const Value.absent(),
    required int obligationId,
    required DateTime cycleStart,
    required DateTime dueDate,
    required int expectedAmount,
    this.status = const Value.absent(),
  }) : obligationId = Value(obligationId),
       cycleStart = Value(cycleStart),
       dueDate = Value(dueDate),
       expectedAmount = Value(expectedAmount);
  static Insertable<ObligationInstanceRecord> custom({
    Expression<int>? id,
    Expression<int>? obligationId,
    Expression<DateTime>? cycleStart,
    Expression<DateTime>? dueDate,
    Expression<int>? expectedAmount,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (obligationId != null) 'obligation_id': obligationId,
      if (cycleStart != null) 'cycle_start': cycleStart,
      if (dueDate != null) 'due_date': dueDate,
      if (expectedAmount != null) 'expected_amount': expectedAmount,
      if (status != null) 'status': status,
    });
  }

  ObligationInstancesCompanion copyWith({
    Value<int>? id,
    Value<int>? obligationId,
    Value<DateTime>? cycleStart,
    Value<DateTime>? dueDate,
    Value<int>? expectedAmount,
    Value<ObligationStatus>? status,
  }) {
    return ObligationInstancesCompanion(
      id: id ?? this.id,
      obligationId: obligationId ?? this.obligationId,
      cycleStart: cycleStart ?? this.cycleStart,
      dueDate: dueDate ?? this.dueDate,
      expectedAmount: expectedAmount ?? this.expectedAmount,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (obligationId.present) {
      map['obligation_id'] = Variable<int>(obligationId.value);
    }
    if (cycleStart.present) {
      map['cycle_start'] = Variable<DateTime>(cycleStart.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (expectedAmount.present) {
      map['expected_amount'] = Variable<int>(expectedAmount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ObligationInstancesTable.$converterstatus.toSql(status.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ObligationInstancesCompanion(')
          ..write('id: $id, ')
          ..write('obligationId: $obligationId, ')
          ..write('cycleStart: $cycleStart, ')
          ..write('dueDate: $dueDate, ')
          ..write('expectedAmount: $expectedAmount, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TransactionType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TransactionType>($TransactionsTable.$convertertype);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    check: () => ComparableExpr(amount).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _toAccountIdMeta = const VerificationMeta(
    'toAccountId',
  );
  @override
  late final GeneratedColumn<int> toAccountId = GeneratedColumn<int>(
    'to_account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _obligationInstanceIdMeta =
      const VerificationMeta('obligationInstanceId');
  @override
  late final GeneratedColumn<int> obligationInstanceId = GeneratedColumn<int>(
    'obligation_instance_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES obligation_instances (id) ON DELETE SET NULL',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<CategorySource?, String>
  categorySource =
      GeneratedColumn<String>(
        'category_source',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CategorySource?>(
        $TransactionsTable.$convertercategorySourcen,
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
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    amount,
    accountId,
    toAccountId,
    categoryId,
    date,
    note,
    obligationInstanceId,
    categorySource,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('to_account_id')) {
      context.handle(
        _toAccountIdMeta,
        toAccountId.isAcceptableOrUnknown(
          data['to_account_id']!,
          _toAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('obligation_instance_id')) {
      context.handle(
        _obligationInstanceIdMeta,
        obligationInstanceId.isAcceptableOrUnknown(
          data['obligation_instance_id']!,
          _obligationInstanceIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: $TransactionsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      )!,
      toAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_account_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      obligationInstanceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}obligation_instance_id'],
      ),
      categorySource: $TransactionsTable.$convertercategorySourcen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category_source'],
        ),
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TransactionType, String, String> $convertertype =
      const EnumNameConverter<TransactionType>(TransactionType.values);
  static JsonTypeConverter2<CategorySource, String, String>
  $convertercategorySource = const EnumNameConverter<CategorySource>(
    CategorySource.values,
  );
  static JsonTypeConverter2<CategorySource?, String?, String?>
  $convertercategorySourcen = JsonTypeConverter2.asNullable(
    $convertercategorySource,
  );
}

class TransactionRecord extends DataClass
    implements Insertable<TransactionRecord> {
  final int id;
  final TransactionType type;
  final int amount;
  final int accountId;

  /// Hanya untuk transfer: akun tujuan.
  final int? toAccountId;

  /// Kosong untuk transfer.
  final int? categoryId;

  /// Tanggal transaksi menurut pengguna (waktu lokal).
  final DateTime date;
  final String note;

  /// Pembayaran kewajiban. Satu kewajiban bisa dibayar beberapa kali (cicil).
  final int? obligationInstanceId;

  /// Langkah auto-kategori yang memberi kategori (untuk mengukur akurasi).
  final CategorySource? categorySource;
  final DateTime createdAt;
  const TransactionRecord({
    required this.id,
    required this.type,
    required this.amount,
    required this.accountId,
    this.toAccountId,
    this.categoryId,
    required this.date,
    required this.note,
    this.obligationInstanceId,
    this.categorySource,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<String>(
        $TransactionsTable.$convertertype.toSql(type),
      );
    }
    map['amount'] = Variable<int>(amount);
    map['account_id'] = Variable<int>(accountId);
    if (!nullToAbsent || toAccountId != null) {
      map['to_account_id'] = Variable<int>(toAccountId);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['date'] = Variable<DateTime>(date);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || obligationInstanceId != null) {
      map['obligation_instance_id'] = Variable<int>(obligationInstanceId);
    }
    if (!nullToAbsent || categorySource != null) {
      map['category_source'] = Variable<String>(
        $TransactionsTable.$convertercategorySourcen.toSql(categorySource),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      type: Value(type),
      amount: Value(amount),
      accountId: Value(accountId),
      toAccountId: toAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(toAccountId),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      date: Value(date),
      note: Value(note),
      obligationInstanceId: obligationInstanceId == null && nullToAbsent
          ? const Value.absent()
          : Value(obligationInstanceId),
      categorySource: categorySource == null && nullToAbsent
          ? const Value.absent()
          : Value(categorySource),
      createdAt: Value(createdAt),
    );
  }

  factory TransactionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionRecord(
      id: serializer.fromJson<int>(json['id']),
      type: $TransactionsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      amount: serializer.fromJson<int>(json['amount']),
      accountId: serializer.fromJson<int>(json['accountId']),
      toAccountId: serializer.fromJson<int?>(json['toAccountId']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      date: serializer.fromJson<DateTime>(json['date']),
      note: serializer.fromJson<String>(json['note']),
      obligationInstanceId: serializer.fromJson<int?>(
        json['obligationInstanceId'],
      ),
      categorySource: $TransactionsTable.$convertercategorySourcen.fromJson(
        serializer.fromJson<String?>(json['categorySource']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(
        $TransactionsTable.$convertertype.toJson(type),
      ),
      'amount': serializer.toJson<int>(amount),
      'accountId': serializer.toJson<int>(accountId),
      'toAccountId': serializer.toJson<int?>(toAccountId),
      'categoryId': serializer.toJson<int?>(categoryId),
      'date': serializer.toJson<DateTime>(date),
      'note': serializer.toJson<String>(note),
      'obligationInstanceId': serializer.toJson<int?>(obligationInstanceId),
      'categorySource': serializer.toJson<String?>(
        $TransactionsTable.$convertercategorySourcen.toJson(categorySource),
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TransactionRecord copyWith({
    int? id,
    TransactionType? type,
    int? amount,
    int? accountId,
    Value<int?> toAccountId = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    DateTime? date,
    String? note,
    Value<int?> obligationInstanceId = const Value.absent(),
    Value<CategorySource?> categorySource = const Value.absent(),
    DateTime? createdAt,
  }) => TransactionRecord(
    id: id ?? this.id,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    accountId: accountId ?? this.accountId,
    toAccountId: toAccountId.present ? toAccountId.value : this.toAccountId,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    date: date ?? this.date,
    note: note ?? this.note,
    obligationInstanceId: obligationInstanceId.present
        ? obligationInstanceId.value
        : this.obligationInstanceId,
    categorySource: categorySource.present
        ? categorySource.value
        : this.categorySource,
    createdAt: createdAt ?? this.createdAt,
  );
  TransactionRecord copyWithCompanion(TransactionsCompanion data) {
    return TransactionRecord(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      toAccountId: data.toAccountId.present
          ? data.toAccountId.value
          : this.toAccountId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      date: data.date.present ? data.date.value : this.date,
      note: data.note.present ? data.note.value : this.note,
      obligationInstanceId: data.obligationInstanceId.present
          ? data.obligationInstanceId.value
          : this.obligationInstanceId,
      categorySource: data.categorySource.present
          ? data.categorySource.value
          : this.categorySource,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionRecord(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('obligationInstanceId: $obligationInstanceId, ')
          ..write('categorySource: $categorySource, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    amount,
    accountId,
    toAccountId,
    categoryId,
    date,
    note,
    obligationInstanceId,
    categorySource,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionRecord &&
          other.id == this.id &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.accountId == this.accountId &&
          other.toAccountId == this.toAccountId &&
          other.categoryId == this.categoryId &&
          other.date == this.date &&
          other.note == this.note &&
          other.obligationInstanceId == this.obligationInstanceId &&
          other.categorySource == this.categorySource &&
          other.createdAt == this.createdAt);
}

class TransactionsCompanion extends UpdateCompanion<TransactionRecord> {
  final Value<int> id;
  final Value<TransactionType> type;
  final Value<int> amount;
  final Value<int> accountId;
  final Value<int?> toAccountId;
  final Value<int?> categoryId;
  final Value<DateTime> date;
  final Value<String> note;
  final Value<int?> obligationInstanceId;
  final Value<CategorySource?> categorySource;
  final Value<DateTime> createdAt;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.toAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.date = const Value.absent(),
    this.note = const Value.absent(),
    this.obligationInstanceId = const Value.absent(),
    this.categorySource = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required TransactionType type,
    required int amount,
    required int accountId,
    this.toAccountId = const Value.absent(),
    this.categoryId = const Value.absent(),
    required DateTime date,
    this.note = const Value.absent(),
    this.obligationInstanceId = const Value.absent(),
    this.categorySource = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : type = Value(type),
       amount = Value(amount),
       accountId = Value(accountId),
       date = Value(date);
  static Insertable<TransactionRecord> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<int>? amount,
    Expression<int>? accountId,
    Expression<int>? toAccountId,
    Expression<int>? categoryId,
    Expression<DateTime>? date,
    Expression<String>? note,
    Expression<int>? obligationInstanceId,
    Expression<String>? categorySource,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (accountId != null) 'account_id': accountId,
      if (toAccountId != null) 'to_account_id': toAccountId,
      if (categoryId != null) 'category_id': categoryId,
      if (date != null) 'date': date,
      if (note != null) 'note': note,
      if (obligationInstanceId != null)
        'obligation_instance_id': obligationInstanceId,
      if (categorySource != null) 'category_source': categorySource,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<TransactionType>? type,
    Value<int>? amount,
    Value<int>? accountId,
    Value<int?>? toAccountId,
    Value<int?>? categoryId,
    Value<DateTime>? date,
    Value<String>? note,
    Value<int?>? obligationInstanceId,
    Value<CategorySource?>? categorySource,
    Value<DateTime>? createdAt,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      obligationInstanceId: obligationInstanceId ?? this.obligationInstanceId,
      categorySource: categorySource ?? this.categorySource,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $TransactionsTable.$convertertype.toSql(type.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (toAccountId.present) {
      map['to_account_id'] = Variable<int>(toAccountId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (obligationInstanceId.present) {
      map['obligation_instance_id'] = Variable<int>(obligationInstanceId.value);
    }
    if (categorySource.present) {
      map['category_source'] = Variable<String>(
        $TransactionsTable.$convertercategorySourcen.toSql(
          categorySource.value,
        ),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('toAccountId: $toAccountId, ')
          ..write('categoryId: $categoryId, ')
          ..write('date: $date, ')
          ..write('note: $note, ')
          ..write('obligationInstanceId: $obligationInstanceId, ')
          ..write('categorySource: $categorySource, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PayCycleConfigsTable extends PayCycleConfigs
    with TableInfo<$PayCycleConfigsTable, PayCycleConfigRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayCycleConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => id.equals(1),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaydayRule, String> paydayRule =
      GeneratedColumn<String>(
        'payday_rule',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaydayRule>($PayCycleConfigsTable.$converterpaydayRule);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<int> day = GeneratedColumn<int>(
    'day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shiftOnHolidayMeta = const VerificationMeta(
    'shiftOnHoliday',
  );
  @override
  late final GeneratedColumn<bool> shiftOnHoliday = GeneratedColumn<bool>(
    'shift_on_holiday',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("shift_on_holiday" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _expectedIncomeMeta = const VerificationMeta(
    'expectedIncome',
  );
  @override
  late final GeneratedColumn<int> expectedIncome = GeneratedColumn<int>(
    'expected_income',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    paydayRule,
    day,
    shiftOnHoliday,
    expectedIncome,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pay_cycle_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayCycleConfigRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    }
    if (data.containsKey('shift_on_holiday')) {
      context.handle(
        _shiftOnHolidayMeta,
        shiftOnHoliday.isAcceptableOrUnknown(
          data['shift_on_holiday']!,
          _shiftOnHolidayMeta,
        ),
      );
    }
    if (data.containsKey('expected_income')) {
      context.handle(
        _expectedIncomeMeta,
        expectedIncome.isAcceptableOrUnknown(
          data['expected_income']!,
          _expectedIncomeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PayCycleConfigRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayCycleConfigRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      paydayRule: $PayCycleConfigsTable.$converterpaydayRule.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payday_rule'],
        )!,
      ),
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day'],
      ),
      shiftOnHoliday: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}shift_on_holiday'],
      )!,
      expectedIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_income'],
      )!,
    );
  }

  @override
  $PayCycleConfigsTable createAlias(String alias) {
    return $PayCycleConfigsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaydayRule, String, String> $converterpaydayRule =
      const EnumNameConverter<PaydayRule>(PaydayRule.values);
}

class PayCycleConfigRecord extends DataClass
    implements Insertable<PayCycleConfigRecord> {
  final int id;
  final PaydayRule paydayRule;

  /// Tanggal gajian (1–31) untuk aturan `fixedDate`.
  final int? day;
  final bool shiftOnHoliday;
  final int expectedIncome;
  const PayCycleConfigRecord({
    required this.id,
    required this.paydayRule,
    this.day,
    required this.shiftOnHoliday,
    required this.expectedIncome,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['payday_rule'] = Variable<String>(
        $PayCycleConfigsTable.$converterpaydayRule.toSql(paydayRule),
      );
    }
    if (!nullToAbsent || day != null) {
      map['day'] = Variable<int>(day);
    }
    map['shift_on_holiday'] = Variable<bool>(shiftOnHoliday);
    map['expected_income'] = Variable<int>(expectedIncome);
    return map;
  }

  PayCycleConfigsCompanion toCompanion(bool nullToAbsent) {
    return PayCycleConfigsCompanion(
      id: Value(id),
      paydayRule: Value(paydayRule),
      day: day == null && nullToAbsent ? const Value.absent() : Value(day),
      shiftOnHoliday: Value(shiftOnHoliday),
      expectedIncome: Value(expectedIncome),
    );
  }

  factory PayCycleConfigRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayCycleConfigRecord(
      id: serializer.fromJson<int>(json['id']),
      paydayRule: $PayCycleConfigsTable.$converterpaydayRule.fromJson(
        serializer.fromJson<String>(json['paydayRule']),
      ),
      day: serializer.fromJson<int?>(json['day']),
      shiftOnHoliday: serializer.fromJson<bool>(json['shiftOnHoliday']),
      expectedIncome: serializer.fromJson<int>(json['expectedIncome']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'paydayRule': serializer.toJson<String>(
        $PayCycleConfigsTable.$converterpaydayRule.toJson(paydayRule),
      ),
      'day': serializer.toJson<int?>(day),
      'shiftOnHoliday': serializer.toJson<bool>(shiftOnHoliday),
      'expectedIncome': serializer.toJson<int>(expectedIncome),
    };
  }

  PayCycleConfigRecord copyWith({
    int? id,
    PaydayRule? paydayRule,
    Value<int?> day = const Value.absent(),
    bool? shiftOnHoliday,
    int? expectedIncome,
  }) => PayCycleConfigRecord(
    id: id ?? this.id,
    paydayRule: paydayRule ?? this.paydayRule,
    day: day.present ? day.value : this.day,
    shiftOnHoliday: shiftOnHoliday ?? this.shiftOnHoliday,
    expectedIncome: expectedIncome ?? this.expectedIncome,
  );
  PayCycleConfigRecord copyWithCompanion(PayCycleConfigsCompanion data) {
    return PayCycleConfigRecord(
      id: data.id.present ? data.id.value : this.id,
      paydayRule: data.paydayRule.present
          ? data.paydayRule.value
          : this.paydayRule,
      day: data.day.present ? data.day.value : this.day,
      shiftOnHoliday: data.shiftOnHoliday.present
          ? data.shiftOnHoliday.value
          : this.shiftOnHoliday,
      expectedIncome: data.expectedIncome.present
          ? data.expectedIncome.value
          : this.expectedIncome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayCycleConfigRecord(')
          ..write('id: $id, ')
          ..write('paydayRule: $paydayRule, ')
          ..write('day: $day, ')
          ..write('shiftOnHoliday: $shiftOnHoliday, ')
          ..write('expectedIncome: $expectedIncome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, paydayRule, day, shiftOnHoliday, expectedIncome);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayCycleConfigRecord &&
          other.id == this.id &&
          other.paydayRule == this.paydayRule &&
          other.day == this.day &&
          other.shiftOnHoliday == this.shiftOnHoliday &&
          other.expectedIncome == this.expectedIncome);
}

class PayCycleConfigsCompanion extends UpdateCompanion<PayCycleConfigRecord> {
  final Value<int> id;
  final Value<PaydayRule> paydayRule;
  final Value<int?> day;
  final Value<bool> shiftOnHoliday;
  final Value<int> expectedIncome;
  const PayCycleConfigsCompanion({
    this.id = const Value.absent(),
    this.paydayRule = const Value.absent(),
    this.day = const Value.absent(),
    this.shiftOnHoliday = const Value.absent(),
    this.expectedIncome = const Value.absent(),
  });
  PayCycleConfigsCompanion.insert({
    this.id = const Value.absent(),
    required PaydayRule paydayRule,
    this.day = const Value.absent(),
    this.shiftOnHoliday = const Value.absent(),
    this.expectedIncome = const Value.absent(),
  }) : paydayRule = Value(paydayRule);
  static Insertable<PayCycleConfigRecord> custom({
    Expression<int>? id,
    Expression<String>? paydayRule,
    Expression<int>? day,
    Expression<bool>? shiftOnHoliday,
    Expression<int>? expectedIncome,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (paydayRule != null) 'payday_rule': paydayRule,
      if (day != null) 'day': day,
      if (shiftOnHoliday != null) 'shift_on_holiday': shiftOnHoliday,
      if (expectedIncome != null) 'expected_income': expectedIncome,
    });
  }

  PayCycleConfigsCompanion copyWith({
    Value<int>? id,
    Value<PaydayRule>? paydayRule,
    Value<int?>? day,
    Value<bool>? shiftOnHoliday,
    Value<int>? expectedIncome,
  }) {
    return PayCycleConfigsCompanion(
      id: id ?? this.id,
      paydayRule: paydayRule ?? this.paydayRule,
      day: day ?? this.day,
      shiftOnHoliday: shiftOnHoliday ?? this.shiftOnHoliday,
      expectedIncome: expectedIncome ?? this.expectedIncome,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (paydayRule.present) {
      map['payday_rule'] = Variable<String>(
        $PayCycleConfigsTable.$converterpaydayRule.toSql(paydayRule.value),
      );
    }
    if (day.present) {
      map['day'] = Variable<int>(day.value);
    }
    if (shiftOnHoliday.present) {
      map['shift_on_holiday'] = Variable<bool>(shiftOnHoliday.value);
    }
    if (expectedIncome.present) {
      map['expected_income'] = Variable<int>(expectedIncome.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayCycleConfigsCompanion(')
          ..write('id: $id, ')
          ..write('paydayRule: $paydayRule, ')
          ..write('day: $day, ')
          ..write('shiftOnHoliday: $shiftOnHoliday, ')
          ..write('expectedIncome: $expectedIncome')
          ..write(')'))
        .toString();
  }
}

class $SavingsTargetsTable extends SavingsTargets
    with TableInfo<$SavingsTargetsTable, SavingsTargetRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsTargetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountPerCycleMeta = const VerificationMeta(
    'amountPerCycle',
  );
  @override
  late final GeneratedColumn<int> amountPerCycle = GeneratedColumn<int>(
    'amount_per_cycle',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES accounts (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, amountPerCycle, accountId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_targets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsTargetRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount_per_cycle')) {
      context.handle(
        _amountPerCycleMeta,
        amountPerCycle.isAcceptableOrUnknown(
          data['amount_per_cycle']!,
          _amountPerCycleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountPerCycleMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsTargetRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsTargetRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amountPerCycle: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_per_cycle'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
    );
  }

  @override
  $SavingsTargetsTable createAlias(String alias) {
    return $SavingsTargetsTable(attachedDatabase, alias);
  }
}

class SavingsTargetRecord extends DataClass
    implements Insertable<SavingsTargetRecord> {
  final int id;
  final int amountPerCycle;
  final int? accountId;
  const SavingsTargetRecord({
    required this.id,
    required this.amountPerCycle,
    this.accountId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount_per_cycle'] = Variable<int>(amountPerCycle);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    return map;
  }

  SavingsTargetsCompanion toCompanion(bool nullToAbsent) {
    return SavingsTargetsCompanion(
      id: Value(id),
      amountPerCycle: Value(amountPerCycle),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
    );
  }

  factory SavingsTargetRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsTargetRecord(
      id: serializer.fromJson<int>(json['id']),
      amountPerCycle: serializer.fromJson<int>(json['amountPerCycle']),
      accountId: serializer.fromJson<int?>(json['accountId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amountPerCycle': serializer.toJson<int>(amountPerCycle),
      'accountId': serializer.toJson<int?>(accountId),
    };
  }

  SavingsTargetRecord copyWith({
    int? id,
    int? amountPerCycle,
    Value<int?> accountId = const Value.absent(),
  }) => SavingsTargetRecord(
    id: id ?? this.id,
    amountPerCycle: amountPerCycle ?? this.amountPerCycle,
    accountId: accountId.present ? accountId.value : this.accountId,
  );
  SavingsTargetRecord copyWithCompanion(SavingsTargetsCompanion data) {
    return SavingsTargetRecord(
      id: data.id.present ? data.id.value : this.id,
      amountPerCycle: data.amountPerCycle.present
          ? data.amountPerCycle.value
          : this.amountPerCycle,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsTargetRecord(')
          ..write('id: $id, ')
          ..write('amountPerCycle: $amountPerCycle, ')
          ..write('accountId: $accountId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amountPerCycle, accountId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsTargetRecord &&
          other.id == this.id &&
          other.amountPerCycle == this.amountPerCycle &&
          other.accountId == this.accountId);
}

class SavingsTargetsCompanion extends UpdateCompanion<SavingsTargetRecord> {
  final Value<int> id;
  final Value<int> amountPerCycle;
  final Value<int?> accountId;
  const SavingsTargetsCompanion({
    this.id = const Value.absent(),
    this.amountPerCycle = const Value.absent(),
    this.accountId = const Value.absent(),
  });
  SavingsTargetsCompanion.insert({
    this.id = const Value.absent(),
    required int amountPerCycle,
    this.accountId = const Value.absent(),
  }) : amountPerCycle = Value(amountPerCycle);
  static Insertable<SavingsTargetRecord> custom({
    Expression<int>? id,
    Expression<int>? amountPerCycle,
    Expression<int>? accountId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amountPerCycle != null) 'amount_per_cycle': amountPerCycle,
      if (accountId != null) 'account_id': accountId,
    });
  }

  SavingsTargetsCompanion copyWith({
    Value<int>? id,
    Value<int>? amountPerCycle,
    Value<int?>? accountId,
  }) {
    return SavingsTargetsCompanion(
      id: id ?? this.id,
      amountPerCycle: amountPerCycle ?? this.amountPerCycle,
      accountId: accountId ?? this.accountId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amountPerCycle.present) {
      map['amount_per_cycle'] = Variable<int>(amountPerCycle.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsTargetsCompanion(')
          ..write('id: $id, ')
          ..write('amountPerCycle: $amountPerCycle, ')
          ..write('accountId: $accountId')
          ..write(')'))
        .toString();
  }
}

class $AlertsTable extends Alerts with TableInfo<$AlertsTable, AlertRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AlertType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AlertType>($AlertsTable.$convertertype);
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
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
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AlertFeedback?, String> feedback =
      GeneratedColumn<String>(
        'feedback',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<AlertFeedback?>($AlertsTable.$converterfeedbackn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    payload,
    createdAt,
    readAt,
    feedback,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlertRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: $AlertsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      feedback: $AlertsTable.$converterfeedbackn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}feedback'],
        ),
      ),
    );
  }

  @override
  $AlertsTable createAlias(String alias) {
    return $AlertsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AlertType, String, String> $convertertype =
      const EnumNameConverter<AlertType>(AlertType.values);
  static JsonTypeConverter2<AlertFeedback, String, String> $converterfeedback =
      const EnumNameConverter<AlertFeedback>(AlertFeedback.values);
  static JsonTypeConverter2<AlertFeedback?, String?, String?>
  $converterfeedbackn = JsonTypeConverter2.asNullable($converterfeedback);
}

class AlertRecord extends DataClass implements Insertable<AlertRecord> {
  final int id;
  final AlertType type;

  /// Detail alert dalam JSON, mis. `{"obligationId": 3, "shortfall": 150000}`.
  final String payload;
  final DateTime createdAt;
  final DateTime? readAt;
  final AlertFeedback? feedback;
  const AlertRecord({
    required this.id,
    required this.type,
    required this.payload,
    required this.createdAt,
    this.readAt,
    this.feedback,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<String>($AlertsTable.$convertertype.toSql(type));
    }
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    if (!nullToAbsent || feedback != null) {
      map['feedback'] = Variable<String>(
        $AlertsTable.$converterfeedbackn.toSql(feedback),
      );
    }
    return map;
  }

  AlertsCompanion toCompanion(bool nullToAbsent) {
    return AlertsCompanion(
      id: Value(id),
      type: Value(type),
      payload: Value(payload),
      createdAt: Value(createdAt),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      feedback: feedback == null && nullToAbsent
          ? const Value.absent()
          : Value(feedback),
    );
  }

  factory AlertRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertRecord(
      id: serializer.fromJson<int>(json['id']),
      type: $AlertsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      feedback: $AlertsTable.$converterfeedbackn.fromJson(
        serializer.fromJson<String?>(json['feedback']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(
        $AlertsTable.$convertertype.toJson(type),
      ),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'feedback': serializer.toJson<String?>(
        $AlertsTable.$converterfeedbackn.toJson(feedback),
      ),
    };
  }

  AlertRecord copyWith({
    int? id,
    AlertType? type,
    String? payload,
    DateTime? createdAt,
    Value<DateTime?> readAt = const Value.absent(),
    Value<AlertFeedback?> feedback = const Value.absent(),
  }) => AlertRecord(
    id: id ?? this.id,
    type: type ?? this.type,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    readAt: readAt.present ? readAt.value : this.readAt,
    feedback: feedback.present ? feedback.value : this.feedback,
  );
  AlertRecord copyWithCompanion(AlertsCompanion data) {
    return AlertRecord(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      feedback: data.feedback.present ? data.feedback.value : this.feedback,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertRecord(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt, ')
          ..write('feedback: $feedback')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, payload, createdAt, readAt, feedback);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertRecord &&
          other.id == this.id &&
          other.type == this.type &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.readAt == this.readAt &&
          other.feedback == this.feedback);
}

class AlertsCompanion extends UpdateCompanion<AlertRecord> {
  final Value<int> id;
  final Value<AlertType> type;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<DateTime?> readAt;
  final Value<AlertFeedback?> feedback;
  const AlertsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.feedback = const Value.absent(),
  });
  AlertsCompanion.insert({
    this.id = const Value.absent(),
    required AlertType type,
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.feedback = const Value.absent(),
  }) : type = Value(type);
  static Insertable<AlertRecord> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? readAt,
    Expression<String>? feedback,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (readAt != null) 'read_at': readAt,
      if (feedback != null) 'feedback': feedback,
    });
  }

  AlertsCompanion copyWith({
    Value<int>? id,
    Value<AlertType>? type,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<DateTime?>? readAt,
    Value<AlertFeedback?>? feedback,
  }) {
    return AlertsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      feedback: feedback ?? this.feedback,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $AlertsTable.$convertertype.toSql(type.value),
      );
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (feedback.present) {
      map['feedback'] = Variable<String>(
        $AlertsTable.$converterfeedbackn.toSql(feedback.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('readAt: $readAt, ')
          ..write('feedback: $feedback')
          ..write(')'))
        .toString();
  }
}

class $AlertThresholdsTable extends AlertThresholds
    with TableInfo<$AlertThresholdsTable, AlertThresholdRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlertThresholdsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<AlertType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<AlertType>($AlertThresholdsTable.$convertertype);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [type, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alert_thresholds';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlertThresholdRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {type};
  @override
  AlertThresholdRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlertThresholdRecord(
      type: $AlertThresholdsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AlertThresholdsTable createAlias(String alias) {
    return $AlertThresholdsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AlertType, String, String> $convertertype =
      const EnumNameConverter<AlertType>(AlertType.values);
}

class AlertThresholdRecord extends DataClass
    implements Insertable<AlertThresholdRecord> {
  final AlertType type;
  final double value;
  final DateTime updatedAt;
  const AlertThresholdRecord({
    required this.type,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['type'] = Variable<String>(
        $AlertThresholdsTable.$convertertype.toSql(type),
      );
    }
    map['value'] = Variable<double>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AlertThresholdsCompanion toCompanion(bool nullToAbsent) {
    return AlertThresholdsCompanion(
      type: Value(type),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AlertThresholdRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlertThresholdRecord(
      type: $AlertThresholdsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      value: serializer.fromJson<double>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'type': serializer.toJson<String>(
        $AlertThresholdsTable.$convertertype.toJson(type),
      ),
      'value': serializer.toJson<double>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AlertThresholdRecord copyWith({
    AlertType? type,
    double? value,
    DateTime? updatedAt,
  }) => AlertThresholdRecord(
    type: type ?? this.type,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AlertThresholdRecord copyWithCompanion(AlertThresholdsCompanion data) {
    return AlertThresholdRecord(
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlertThresholdRecord(')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(type, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlertThresholdRecord &&
          other.type == this.type &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AlertThresholdsCompanion extends UpdateCompanion<AlertThresholdRecord> {
  final Value<AlertType> type;
  final Value<double> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AlertThresholdsCompanion({
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlertThresholdsCompanion.insert({
    required AlertType type,
    required double value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : type = Value(type),
       value = Value(value);
  static Insertable<AlertThresholdRecord> custom({
    Expression<String>? type,
    Expression<double>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlertThresholdsCompanion copyWith({
    Value<AlertType>? type,
    Value<double>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AlertThresholdsCompanion(
      type: type ?? this.type,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (type.present) {
      map['type'] = Variable<String>(
        $AlertThresholdsTable.$convertertype.toSql(type.value),
      );
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlertThresholdsCompanion(')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntitlementsTable extends Entitlements
    with TableInfo<$EntitlementsTable, EntitlementRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntitlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseTokenMeta = const VerificationMeta(
    'purchaseToken',
  );
  @override
  late final GeneratedColumn<String> purchaseToken = GeneratedColumn<String>(
    'purchase_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EntitlementStatus, String>
  status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<EntitlementStatus>($EntitlementsTable.$converterstatus);
  static const VerificationMeta _verifiedAtMeta = const VerificationMeta(
    'verifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> verifiedAt = GeneratedColumn<DateTime>(
    'verified_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    productId,
    purchaseToken,
    status,
    verifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entitlements';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntitlementRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('purchase_token')) {
      context.handle(
        _purchaseTokenMeta,
        purchaseToken.isAcceptableOrUnknown(
          data['purchase_token']!,
          _purchaseTokenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseTokenMeta);
    }
    if (data.containsKey('verified_at')) {
      context.handle(
        _verifiedAtMeta,
        verifiedAt.isAcceptableOrUnknown(data['verified_at']!, _verifiedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_verifiedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {productId};
  @override
  EntitlementRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntitlementRecord(
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_id'],
      )!,
      purchaseToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_token'],
      )!,
      status: $EntitlementsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      verifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}verified_at'],
      )!,
    );
  }

  @override
  $EntitlementsTable createAlias(String alias) {
    return $EntitlementsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EntitlementStatus, String, String>
  $converterstatus = const EnumNameConverter<EntitlementStatus>(
    EntitlementStatus.values,
  );
}

class EntitlementRecord extends DataClass
    implements Insertable<EntitlementRecord> {
  final String productId;
  final String purchaseToken;
  final EntitlementStatus status;
  final DateTime verifiedAt;
  const EntitlementRecord({
    required this.productId,
    required this.purchaseToken,
    required this.status,
    required this.verifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['product_id'] = Variable<String>(productId);
    map['purchase_token'] = Variable<String>(purchaseToken);
    {
      map['status'] = Variable<String>(
        $EntitlementsTable.$converterstatus.toSql(status),
      );
    }
    map['verified_at'] = Variable<DateTime>(verifiedAt);
    return map;
  }

  EntitlementsCompanion toCompanion(bool nullToAbsent) {
    return EntitlementsCompanion(
      productId: Value(productId),
      purchaseToken: Value(purchaseToken),
      status: Value(status),
      verifiedAt: Value(verifiedAt),
    );
  }

  factory EntitlementRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntitlementRecord(
      productId: serializer.fromJson<String>(json['productId']),
      purchaseToken: serializer.fromJson<String>(json['purchaseToken']),
      status: $EntitlementsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      verifiedAt: serializer.fromJson<DateTime>(json['verifiedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'productId': serializer.toJson<String>(productId),
      'purchaseToken': serializer.toJson<String>(purchaseToken),
      'status': serializer.toJson<String>(
        $EntitlementsTable.$converterstatus.toJson(status),
      ),
      'verifiedAt': serializer.toJson<DateTime>(verifiedAt),
    };
  }

  EntitlementRecord copyWith({
    String? productId,
    String? purchaseToken,
    EntitlementStatus? status,
    DateTime? verifiedAt,
  }) => EntitlementRecord(
    productId: productId ?? this.productId,
    purchaseToken: purchaseToken ?? this.purchaseToken,
    status: status ?? this.status,
    verifiedAt: verifiedAt ?? this.verifiedAt,
  );
  EntitlementRecord copyWithCompanion(EntitlementsCompanion data) {
    return EntitlementRecord(
      productId: data.productId.present ? data.productId.value : this.productId,
      purchaseToken: data.purchaseToken.present
          ? data.purchaseToken.value
          : this.purchaseToken,
      status: data.status.present ? data.status.value : this.status,
      verifiedAt: data.verifiedAt.present
          ? data.verifiedAt.value
          : this.verifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntitlementRecord(')
          ..write('productId: $productId, ')
          ..write('purchaseToken: $purchaseToken, ')
          ..write('status: $status, ')
          ..write('verifiedAt: $verifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(productId, purchaseToken, status, verifiedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntitlementRecord &&
          other.productId == this.productId &&
          other.purchaseToken == this.purchaseToken &&
          other.status == this.status &&
          other.verifiedAt == this.verifiedAt);
}

class EntitlementsCompanion extends UpdateCompanion<EntitlementRecord> {
  final Value<String> productId;
  final Value<String> purchaseToken;
  final Value<EntitlementStatus> status;
  final Value<DateTime> verifiedAt;
  final Value<int> rowid;
  const EntitlementsCompanion({
    this.productId = const Value.absent(),
    this.purchaseToken = const Value.absent(),
    this.status = const Value.absent(),
    this.verifiedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntitlementsCompanion.insert({
    required String productId,
    required String purchaseToken,
    required EntitlementStatus status,
    required DateTime verifiedAt,
    this.rowid = const Value.absent(),
  }) : productId = Value(productId),
       purchaseToken = Value(purchaseToken),
       status = Value(status),
       verifiedAt = Value(verifiedAt);
  static Insertable<EntitlementRecord> custom({
    Expression<String>? productId,
    Expression<String>? purchaseToken,
    Expression<String>? status,
    Expression<DateTime>? verifiedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (productId != null) 'product_id': productId,
      if (purchaseToken != null) 'purchase_token': purchaseToken,
      if (status != null) 'status': status,
      if (verifiedAt != null) 'verified_at': verifiedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntitlementsCompanion copyWith({
    Value<String>? productId,
    Value<String>? purchaseToken,
    Value<EntitlementStatus>? status,
    Value<DateTime>? verifiedAt,
    Value<int>? rowid,
  }) {
    return EntitlementsCompanion(
      productId: productId ?? this.productId,
      purchaseToken: purchaseToken ?? this.purchaseToken,
      status: status ?? this.status,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (purchaseToken.present) {
      map['purchase_token'] = Variable<String>(purchaseToken.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $EntitlementsTable.$converterstatus.toSql(status.value),
      );
    }
    if (verifiedAt.present) {
      map['verified_at'] = Variable<DateTime>(verifiedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntitlementsCompanion(')
          ..write('productId: $productId, ')
          ..write('purchaseToken: $purchaseToken, ')
          ..write('status: $status, ')
          ..write('verifiedAt: $verifiedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AccountsTable accounts = $AccountsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ObligationsTable obligations = $ObligationsTable(this);
  late final $ObligationInstancesTable obligationInstances =
      $ObligationInstancesTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  late final $PayCycleConfigsTable payCycleConfigs = $PayCycleConfigsTable(
    this,
  );
  late final $SavingsTargetsTable savingsTargets = $SavingsTargetsTable(this);
  late final $AlertsTable alerts = $AlertsTable(this);
  late final $AlertThresholdsTable alertThresholds = $AlertThresholdsTable(
    this,
  );
  late final $EntitlementsTable entitlements = $EntitlementsTable(this);
  late final Index idxTransactionsDate = Index(
    'idx_transactions_date',
    'CREATE INDEX idx_transactions_date ON transactions (date)',
  );
  late final Index idxTransactionsAccount = Index(
    'idx_transactions_account',
    'CREATE INDEX idx_transactions_account ON transactions (account_id)',
  );
  late final Index idxTransactionsCategory = Index(
    'idx_transactions_category',
    'CREATE INDEX idx_transactions_category ON transactions (category_id)',
  );
  late final Index idxAlertsCreated = Index(
    'idx_alerts_created',
    'CREATE INDEX idx_alerts_created ON alerts (created_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    accounts,
    categories,
    obligations,
    obligationInstances,
    transactions,
    payCycleConfigs,
    savingsTargets,
    alerts,
    alertThresholds,
    entitlements,
    idxTransactionsDate,
    idxTransactionsAccount,
    idxTransactionsCategory,
    idxAlertsCreated,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'obligations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('obligation_instances', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'obligation_instances',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$AccountsTableCreateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  required String name,
  required AccountType type,
  Value<int> initialBalance,
  Value<Tone> tone,
  required String icon,
  Value<bool> archived,
  Value<int> sortOrder,
});
typedef $$AccountsTableUpdateCompanionBuilder = AccountsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<AccountType> type,
  Value<int> initialBalance,
  Value<Tone> tone,
  Value<String> icon,
  Value<bool> archived,
  Value<int> sortOrder,
});

final class $$AccountsTableReferences
    extends BaseReferences<_$AppDatabase, $AccountsTable, AccountRecord> {
  $$AccountsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ObligationsTable, List<ObligationRecord>>
  _obligationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.obligations,
    aliasName: 'accounts__id__obligations__account_id',
  );

  $$ObligationsTableProcessedTableManager get obligationsRefs {
    final manager = $$ObligationsTableTableManager(
      $_db,
      $_db.obligations,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_obligationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRecord>>
  _transactionsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'accounts__id__transactions__account_id',
  );

  $$TransactionsTableProcessedTableManager get transactions {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRecord>>
  _incomingTransfersTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'accounts__id__transactions__to_account_id',
  );

  $$TransactionsTableProcessedTableManager get incomingTransfers {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.toAccountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_incomingTransfersTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SavingsTargetsTable, List<SavingsTargetRecord>>
  _savingsTargetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.savingsTargets,
    aliasName: 'accounts__id__savings_targets__account_id',
  );

  $$SavingsTargetsTableProcessedTableManager get savingsTargetsRefs {
    final manager = $$SavingsTargetsTableTableManager(
      $_db,
      $_db.savingsTargets,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_savingsTargetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AccountsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountType, AccountType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Tone, Tone, String> get tone =>
      $composableBuilder(
        column: $table.tone,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> obligationsRefs(
    Expression<bool> Function($$ObligationsTableFilterComposer f) f,
  ) {
    final $$ObligationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.obligations,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationsTableFilterComposer(
            $db: $db,
            $table: $db.obligations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactions(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incomingTransfers(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.toAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> savingsTargetsRefs(
    Expression<bool> Function($$SavingsTargetsTableFilterComposer f) f,
  ) {
    final $$SavingsTargetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savingsTargets,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingsTargetsTableFilterComposer(
            $db: $db,
            $table: $db.savingsTargets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountsTable> {
  $$AccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AccountType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get initialBalance => $composableBuilder(
    column: $table.initialBalance,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Tone, String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> obligationsRefs<T extends Object>(
    Expression<T> Function($$ObligationsTableAnnotationComposer a) f,
  ) {
    final $$ObligationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.obligations,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationsTableAnnotationComposer(
            $db: $db,
            $table: $db.obligations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactions<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incomingTransfers<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.toAccountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> savingsTargetsRefs<T extends Object>(
    Expression<T> Function($$SavingsTargetsTableAnnotationComposer a) f,
  ) {
    final $$SavingsTargetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.savingsTargets,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SavingsTargetsTableAnnotationComposer(
            $db: $db,
            $table: $db.savingsTargets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountsTable,
          AccountRecord,
          $$AccountsTableFilterComposer,
          $$AccountsTableOrderingComposer,
          $$AccountsTableAnnotationComposer,
          $$AccountsTableCreateCompanionBuilder,
          $$AccountsTableUpdateCompanionBuilder,
          (AccountRecord, $$AccountsTableReferences),
          AccountRecord,
          PrefetchHooks Function({
            bool obligationsRefs,
            bool transactions,
            bool incomingTransfers,
            bool savingsTargetsRefs,
          })
        > {
  $$AccountsTableTableManager(_$AppDatabase db, $AccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AccountType> type = const Value.absent(),
                Value<int> initialBalance = const Value.absent(),
                Value<Tone> tone = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => AccountsCompanion(
                id: id,
                name: name,
                type: type,
                initialBalance: initialBalance,
                tone: tone,
                icon: icon,
                archived: archived,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required AccountType type,
                Value<int> initialBalance = const Value.absent(),
                Value<Tone> tone = const Value.absent(),
                required String icon,
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => AccountsCompanion.insert(
                id: id,
                name: name,
                type: type,
                initialBalance: initialBalance,
                tone: tone,
                icon: icon,
                archived: archived,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountsTable, AccountRecord>(table),
                  $$AccountsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                obligationsRefs = false,
                transactions = false,
                incomingTransfers = false,
                savingsTargetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (obligationsRefs) db.obligations,
                    if (transactions) db.transactions,
                    if (incomingTransfers) db.transactions,
                    if (savingsTargetsRefs) db.savingsTargets,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (obligationsRefs)
                        await $_getPrefetchedDataByColumns<
                          AccountRecord,
                          $AccountsTable,
                          ObligationRecord,
                          $ObligationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._obligationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).obligationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                      if (transactions)
                        await $_getPrefetchedDataByColumns<
                          AccountRecord,
                          $AccountsTable,
                          TransactionRecord,
                          $TransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._transactionsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactions,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                      if (incomingTransfers)
                        await $_getPrefetchedDataByColumns<
                          AccountRecord,
                          $AccountsTable,
                          TransactionRecord,
                          $TransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._incomingTransfersTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).incomingTransfers,
                          currentColumn: 'id',
                          referencedColumn: 'to_account_id',
                          typedResults: items,
                        ),
                      if (savingsTargetsRefs)
                        await $_getPrefetchedDataByColumns<
                          AccountRecord,
                          $AccountsTable,
                          SavingsTargetRecord,
                          $SavingsTargetsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AccountsTableReferences
                              ._savingsTargetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AccountsTableReferences(
                                db,
                                table,
                                p0,
                              ).savingsTargetsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountsTable,
      AccountRecord,
      $$AccountsTableFilterComposer,
      $$AccountsTableOrderingComposer,
      $$AccountsTableAnnotationComposer,
      $$AccountsTableCreateCompanionBuilder,
      $$AccountsTableUpdateCompanionBuilder,
      (AccountRecord, $$AccountsTableReferences),
      AccountRecord,
      PrefetchHooks Function({
        bool obligationsRefs,
        bool transactions,
        bool incomingTransfers,
        bool savingsTargetsRefs,
      })
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required String name,
  required CategoryType type,
  required String icon,
  required Tone tone,
  Value<bool> isDefault,
  Value<bool> archived,
  Value<int> sortOrder,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<CategoryType> type,
  Value<String> icon,
  Value<Tone> tone,
  Value<bool> isDefault,
  Value<bool> archived,
  Value<int> sortOrder,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRecord> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ObligationsTable, List<ObligationRecord>>
  _obligationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.obligations,
    aliasName: 'categories__id__obligations__category_id',
  );

  $$ObligationsTableProcessedTableManager get obligationsRefs {
    final manager = $$ObligationsTableTableManager(
      $_db,
      $_db.obligations,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_obligationsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRecord>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'categories__id__transactions__category_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CategoryType, CategoryType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Tone, Tone, String> get tone =>
      $composableBuilder(
        column: $table.tone,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> obligationsRefs(
    Expression<bool> Function($$ObligationsTableFilterComposer f) f,
  ) {
    final $$ObligationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.obligations,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationsTableFilterComposer(
            $db: $db,
            $table: $db.obligations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tone => $composableBuilder(
    column: $table.tone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CategoryType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Tone, String> get tone =>
      $composableBuilder(column: $table.tone, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> obligationsRefs<T extends Object>(
    Expression<T> Function($$ObligationsTableAnnotationComposer a) f,
  ) {
    final $$ObligationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.obligations,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationsTableAnnotationComposer(
            $db: $db,
            $table: $db.obligations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRecord,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRecord, $$CategoriesTableReferences),
          CategoryRecord,
          PrefetchHooks Function({bool obligationsRefs, bool transactionsRefs})
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<CategoryType> type = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<Tone> tone = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                type: type,
                icon: icon,
                tone: tone,
                isDefault: isDefault,
                archived: archived,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required CategoryType type,
                required String icon,
                required Tone tone,
                Value<bool> isDefault = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                type: type,
                icon: icon,
                tone: tone,
                isDefault: isDefault,
                archived: archived,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRecord>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({obligationsRefs = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (obligationsRefs) db.obligations,
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (obligationsRefs)
                        await $_getPrefetchedDataByColumns<
                          CategoryRecord,
                          $CategoriesTable,
                          ObligationRecord,
                          $ObligationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._obligationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).obligationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          CategoryRecord,
                          $CategoriesTable,
                          TransactionRecord,
                          $TransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRecord,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRecord, $$CategoriesTableReferences),
      CategoryRecord,
      PrefetchHooks Function({bool obligationsRefs, bool transactionsRefs})
    >;
typedef $$ObligationsTableCreateCompanionBuilder =
    ObligationsCompanion Function({
      Value<int> id,
      required String name,
      required ObligationAmountType amountType,
      required int amount,
      required int dueDay,
      required int categoryId,
      Value<int?> accountId,
      Value<Recurrence> recurrence,
      Value<bool> active,
      Value<String> autoMatchKeywords,
    });
typedef $$ObligationsTableUpdateCompanionBuilder =
    ObligationsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<ObligationAmountType> amountType,
      Value<int> amount,
      Value<int> dueDay,
      Value<int> categoryId,
      Value<int?> accountId,
      Value<Recurrence> recurrence,
      Value<bool> active,
      Value<String> autoMatchKeywords,
    });

final class $$ObligationsTableReferences
    extends BaseReferences<_$AppDatabase, $ObligationsTable, ObligationRecord> {
  $$ObligationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('obligations__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('obligations__account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<int>('account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $ObligationInstancesTable,
    List<ObligationInstanceRecord>
  >
  _obligationInstancesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.obligationInstances,
        aliasName: 'obligations__id__obligation_instances__obligation_id',
      );

  $$ObligationInstancesTableProcessedTableManager get obligationInstancesRefs {
    final manager = $$ObligationInstancesTableTableManager(
      $_db,
      $_db.obligationInstances,
    ).filter((f) => f.obligationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _obligationInstancesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ObligationsTableFilterComposer
    extends Composer<_$AppDatabase, $ObligationsTable> {
  $$ObligationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    ObligationAmountType,
    ObligationAmountType,
    String
  >
  get amountType => $composableBuilder(
    column: $table.amountType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Recurrence, Recurrence, String>
  get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get autoMatchKeywords => $composableBuilder(
    column: $table.autoMatchKeywords,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> obligationInstancesRefs(
    Expression<bool> Function($$ObligationInstancesTableFilterComposer f) f,
  ) {
    final $$ObligationInstancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.obligationInstances,
      getReferencedColumn: (t) => t.obligationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationInstancesTableFilterComposer(
            $db: $db,
            $table: $db.obligationInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObligationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ObligationsTable> {
  $$ObligationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountType => $composableBuilder(
    column: $table.amountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueDay => $composableBuilder(
    column: $table.dueDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recurrence => $composableBuilder(
    column: $table.recurrence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get autoMatchKeywords => $composableBuilder(
    column: $table.autoMatchKeywords,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObligationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObligationsTable> {
  $$ObligationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ObligationAmountType, String>
  get amountType => $composableBuilder(
    column: $table.amountType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get dueDay =>
      $composableBuilder(column: $table.dueDay, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Recurrence, String> get recurrence =>
      $composableBuilder(
        column: $table.recurrence,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get autoMatchKeywords => $composableBuilder(
    column: $table.autoMatchKeywords,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> obligationInstancesRefs<T extends Object>(
    Expression<T> Function($$ObligationInstancesTableAnnotationComposer a) f,
  ) {
    final $$ObligationInstancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.obligationInstances,
          getReferencedColumn: (t) => t.obligationId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ObligationInstancesTableAnnotationComposer(
                $db: $db,
                $table: $db.obligationInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ObligationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObligationsTable,
          ObligationRecord,
          $$ObligationsTableFilterComposer,
          $$ObligationsTableOrderingComposer,
          $$ObligationsTableAnnotationComposer,
          $$ObligationsTableCreateCompanionBuilder,
          $$ObligationsTableUpdateCompanionBuilder,
          (ObligationRecord, $$ObligationsTableReferences),
          ObligationRecord,
          PrefetchHooks Function({
            bool categoryId,
            bool accountId,
            bool obligationInstancesRefs,
          })
        > {
  $$ObligationsTableTableManager(_$AppDatabase db, $ObligationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObligationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObligationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ObligationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<ObligationAmountType> amountType = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> dueDay = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<Recurrence> recurrence = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String> autoMatchKeywords = const Value.absent(),
              }) => ObligationsCompanion(
                id: id,
                name: name,
                amountType: amountType,
                amount: amount,
                dueDay: dueDay,
                categoryId: categoryId,
                accountId: accountId,
                recurrence: recurrence,
                active: active,
                autoMatchKeywords: autoMatchKeywords,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required ObligationAmountType amountType,
                required int amount,
                required int dueDay,
                required int categoryId,
                Value<int?> accountId = const Value.absent(),
                Value<Recurrence> recurrence = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<String> autoMatchKeywords = const Value.absent(),
              }) => ObligationsCompanion.insert(
                id: id,
                name: name,
                amountType: amountType,
                amount: amount,
                dueDay: dueDay,
                categoryId: categoryId,
                accountId: accountId,
                recurrence: recurrence,
                active: active,
                autoMatchKeywords: autoMatchKeywords,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ObligationsTable, ObligationRecord>(table),
                  $$ObligationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                accountId = false,
                obligationInstancesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (obligationInstancesRefs) db.obligationInstances,
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
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$ObligationsTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$ObligationsTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$ObligationsTableReferences
                                ._accountIdTable(db),
                            referencedColumn: $$ObligationsTableReferences
                                ._accountIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (obligationInstancesRefs)
                        await $_getPrefetchedDataByColumns<
                          ObligationRecord,
                          $ObligationsTable,
                          ObligationInstanceRecord,
                          $ObligationInstancesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ObligationsTableReferences
                              ._obligationInstancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObligationsTableReferences(
                                db,
                                table,
                                p0,
                              ).obligationInstancesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'obligation_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ObligationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObligationsTable,
      ObligationRecord,
      $$ObligationsTableFilterComposer,
      $$ObligationsTableOrderingComposer,
      $$ObligationsTableAnnotationComposer,
      $$ObligationsTableCreateCompanionBuilder,
      $$ObligationsTableUpdateCompanionBuilder,
      (ObligationRecord, $$ObligationsTableReferences),
      ObligationRecord,
      PrefetchHooks Function({
        bool categoryId,
        bool accountId,
        bool obligationInstancesRefs,
      })
    >;
typedef $$ObligationInstancesTableCreateCompanionBuilder =
    ObligationInstancesCompanion Function({
      Value<int> id,
      required int obligationId,
      required DateTime cycleStart,
      required DateTime dueDate,
      required int expectedAmount,
      Value<ObligationStatus> status,
    });
typedef $$ObligationInstancesTableUpdateCompanionBuilder =
    ObligationInstancesCompanion Function({
      Value<int> id,
      Value<int> obligationId,
      Value<DateTime> cycleStart,
      Value<DateTime> dueDate,
      Value<int> expectedAmount,
      Value<ObligationStatus> status,
    });

final class $$ObligationInstancesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ObligationInstancesTable,
          ObligationInstanceRecord
        > {
  $$ObligationInstancesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ObligationsTable _obligationIdTable(_$AppDatabase db) => db
      .obligations
      .createAlias('obligation_instances__obligation_id__obligations__id');

  $$ObligationsTableProcessedTableManager get obligationId {
    final $_column = $_itemColumn<int>('obligation_id')!;

    final manager = $$ObligationsTableTableManager(
      $_db,
      $_db.obligations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_obligationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionRecord>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'obligation_instances__id__transactions__obligation_instance_id',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager($_db, $_db.transactions)
        .filter(
          (f) => f.obligationInstanceId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ObligationInstancesTableFilterComposer
    extends Composer<_$AppDatabase, $ObligationInstancesTable> {
  $$ObligationInstancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cycleStart => $composableBuilder(
    column: $table.cycleStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedAmount => $composableBuilder(
    column: $table.expectedAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ObligationStatus, ObligationStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  $$ObligationsTableFilterComposer get obligationId {
    final $$ObligationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.obligationId,
      referencedTable: $db.obligations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationsTableFilterComposer(
            $db: $db,
            $table: $db.obligations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.obligationInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObligationInstancesTableOrderingComposer
    extends Composer<_$AppDatabase, $ObligationInstancesTable> {
  $$ObligationInstancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cycleStart => $composableBuilder(
    column: $table.cycleStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedAmount => $composableBuilder(
    column: $table.expectedAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  $$ObligationsTableOrderingComposer get obligationId {
    final $$ObligationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.obligationId,
      referencedTable: $db.obligations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationsTableOrderingComposer(
            $db: $db,
            $table: $db.obligations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ObligationInstancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ObligationInstancesTable> {
  $$ObligationInstancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get cycleStart => $composableBuilder(
    column: $table.cycleStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get expectedAmount => $composableBuilder(
    column: $table.expectedAmount,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ObligationStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$ObligationsTableAnnotationComposer get obligationId {
    final $$ObligationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.obligationId,
      referencedTable: $db.obligations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationsTableAnnotationComposer(
            $db: $db,
            $table: $db.obligations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.obligationInstanceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ObligationInstancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ObligationInstancesTable,
          ObligationInstanceRecord,
          $$ObligationInstancesTableFilterComposer,
          $$ObligationInstancesTableOrderingComposer,
          $$ObligationInstancesTableAnnotationComposer,
          $$ObligationInstancesTableCreateCompanionBuilder,
          $$ObligationInstancesTableUpdateCompanionBuilder,
          (ObligationInstanceRecord, $$ObligationInstancesTableReferences),
          ObligationInstanceRecord,
          PrefetchHooks Function({bool obligationId, bool transactionsRefs})
        > {
  $$ObligationInstancesTableTableManager(
    _$AppDatabase db,
    $ObligationInstancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ObligationInstancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ObligationInstancesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ObligationInstancesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> obligationId = const Value.absent(),
                Value<DateTime> cycleStart = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<int> expectedAmount = const Value.absent(),
                Value<ObligationStatus> status = const Value.absent(),
              }) => ObligationInstancesCompanion(
                id: id,
                obligationId: obligationId,
                cycleStart: cycleStart,
                dueDate: dueDate,
                expectedAmount: expectedAmount,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int obligationId,
                required DateTime cycleStart,
                required DateTime dueDate,
                required int expectedAmount,
                Value<ObligationStatus> status = const Value.absent(),
              }) => ObligationInstancesCompanion.insert(
                id: id,
                obligationId: obligationId,
                cycleStart: cycleStart,
                dueDate: dueDate,
                expectedAmount: expectedAmount,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $ObligationInstancesTable,
                    ObligationInstanceRecord
                  >(table),
                  $$ObligationInstancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({obligationId = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
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
                        if (obligationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.obligationId,
                            referencedTable:
                                $$ObligationInstancesTableReferences
                                    ._obligationIdTable(db),
                            referencedColumn:
                                $$ObligationInstancesTableReferences
                                    ._obligationIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          ObligationInstanceRecord,
                          $ObligationInstancesTable,
                          TransactionRecord,
                          $TransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ObligationInstancesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ObligationInstancesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'obligation_instance_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ObligationInstancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ObligationInstancesTable,
      ObligationInstanceRecord,
      $$ObligationInstancesTableFilterComposer,
      $$ObligationInstancesTableOrderingComposer,
      $$ObligationInstancesTableAnnotationComposer,
      $$ObligationInstancesTableCreateCompanionBuilder,
      $$ObligationInstancesTableUpdateCompanionBuilder,
      (ObligationInstanceRecord, $$ObligationInstancesTableReferences),
      ObligationInstanceRecord,
      PrefetchHooks Function({bool obligationId, bool transactionsRefs})
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required TransactionType type,
      required int amount,
      required int accountId,
      Value<int?> toAccountId,
      Value<int?> categoryId,
      required DateTime date,
      Value<String> note,
      Value<int?> obligationInstanceId,
      Value<CategorySource?> categorySource,
      Value<DateTime> createdAt,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<TransactionType> type,
      Value<int> amount,
      Value<int> accountId,
      Value<int?> toAccountId,
      Value<int?> categoryId,
      Value<DateTime> date,
      Value<String> note,
      Value<int?> obligationInstanceId,
      Value<CategorySource?> categorySource,
      Value<DateTime> createdAt,
    });

final class $$TransactionsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TransactionsTable, TransactionRecord> {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('transactions__account_id__accounts__id');

  $$AccountsTableProcessedTableManager get accountId {
    final $_column = $_itemColumn<int>('account_id')!;

    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AccountsTable _toAccountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('transactions__to_account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get toAccountId {
    final $_column = $_itemColumn<int>('to_account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toAccountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('transactions__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ObligationInstancesTable _obligationInstanceIdTable(
    _$AppDatabase db,
  ) => db.obligationInstances.createAlias(
    'transactions__obligation_instance_id__obligation_instances__id',
  );

  $$ObligationInstancesTableProcessedTableManager? get obligationInstanceId {
    final $_column = $_itemColumn<int>('obligation_instance_id');
    if ($_column == null) return null;
    final manager = $$ObligationInstancesTableTableManager(
      $_db,
      $_db.obligationInstances,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(
      _obligationInstanceIdTable($_db),
    );
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TransactionType, TransactionType, String>
  get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CategorySource?, CategorySource, String>
  get categorySource => $composableBuilder(
    column: $table.categorySource,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableFilterComposer get toAccountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObligationInstancesTableFilterComposer get obligationInstanceId {
    final $$ObligationInstancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.obligationInstanceId,
      referencedTable: $db.obligationInstances,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ObligationInstancesTableFilterComposer(
            $db: $db,
            $table: $db.obligationInstances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categorySource => $composableBuilder(
    column: $table.categorySource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableOrderingComposer get toAccountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObligationInstancesTableOrderingComposer get obligationInstanceId {
    final $$ObligationInstancesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.obligationInstanceId,
          referencedTable: $db.obligationInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ObligationInstancesTableOrderingComposer(
                $db: $db,
                $table: $db.obligationInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TransactionType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CategorySource?, String>
  get categorySource => $composableBuilder(
    column: $table.categorySource,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AccountsTableAnnotationComposer get toAccountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toAccountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ObligationInstancesTableAnnotationComposer get obligationInstanceId {
    final $$ObligationInstancesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.obligationInstanceId,
          referencedTable: $db.obligationInstances,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ObligationInstancesTableAnnotationComposer(
                $db: $db,
                $table: $db.obligationInstances,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionRecord,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (TransactionRecord, $$TransactionsTableReferences),
          TransactionRecord,
          PrefetchHooks Function({
            bool accountId,
            bool toAccountId,
            bool categoryId,
            bool obligationInstanceId,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<TransactionType> type = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> accountId = const Value.absent(),
                Value<int?> toAccountId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int?> obligationInstanceId = const Value.absent(),
                Value<CategorySource?> categorySource = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                type: type,
                amount: amount,
                accountId: accountId,
                toAccountId: toAccountId,
                categoryId: categoryId,
                date: date,
                note: note,
                obligationInstanceId: obligationInstanceId,
                categorySource: categorySource,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required TransactionType type,
                required int amount,
                required int accountId,
                Value<int?> toAccountId = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                required DateTime date,
                Value<String> note = const Value.absent(),
                Value<int?> obligationInstanceId = const Value.absent(),
                Value<CategorySource?> categorySource = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                type: type,
                amount: amount,
                accountId: accountId,
                toAccountId: toAccountId,
                categoryId: categoryId,
                date: date,
                note: note,
                obligationInstanceId: obligationInstanceId,
                categorySource: categorySource,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TransactionsTable, TransactionRecord>(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                accountId = false,
                toAccountId = false,
                categoryId = false,
                obligationInstanceId = false,
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
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$TransactionsTableReferences
                                ._accountIdTable(db),
                            referencedColumn: $$TransactionsTableReferences
                                ._accountIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (toAccountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.toAccountId,
                            referencedTable: $$TransactionsTableReferences
                                ._toAccountIdTable(db),
                            referencedColumn: $$TransactionsTableReferences
                                ._toAccountIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$TransactionsTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$TransactionsTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (obligationInstanceId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.obligationInstanceId,
                            referencedTable: $$TransactionsTableReferences
                                ._obligationInstanceIdTable(db),
                            referencedColumn: $$TransactionsTableReferences
                                ._obligationInstanceIdTable(db)
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

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionRecord,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (TransactionRecord, $$TransactionsTableReferences),
      TransactionRecord,
      PrefetchHooks Function({
        bool accountId,
        bool toAccountId,
        bool categoryId,
        bool obligationInstanceId,
      })
    >;
typedef $$PayCycleConfigsTableCreateCompanionBuilder =
    PayCycleConfigsCompanion Function({
      Value<int> id,
      required PaydayRule paydayRule,
      Value<int?> day,
      Value<bool> shiftOnHoliday,
      Value<int> expectedIncome,
    });
typedef $$PayCycleConfigsTableUpdateCompanionBuilder =
    PayCycleConfigsCompanion Function({
      Value<int> id,
      Value<PaydayRule> paydayRule,
      Value<int?> day,
      Value<bool> shiftOnHoliday,
      Value<int> expectedIncome,
    });

class $$PayCycleConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $PayCycleConfigsTable> {
  $$PayCycleConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaydayRule, PaydayRule, String>
  get paydayRule => $composableBuilder(
    column: $table.paydayRule,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get shiftOnHoliday => $composableBuilder(
    column: $table.shiftOnHoliday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedIncome => $composableBuilder(
    column: $table.expectedIncome,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PayCycleConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $PayCycleConfigsTable> {
  $$PayCycleConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paydayRule => $composableBuilder(
    column: $table.paydayRule,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get shiftOnHoliday => $composableBuilder(
    column: $table.shiftOnHoliday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedIncome => $composableBuilder(
    column: $table.expectedIncome,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PayCycleConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayCycleConfigsTable> {
  $$PayCycleConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaydayRule, String> get paydayRule =>
      $composableBuilder(
        column: $table.paydayRule,
        builder: (column) => column,
      );

  GeneratedColumn<int> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<bool> get shiftOnHoliday => $composableBuilder(
    column: $table.shiftOnHoliday,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedIncome => $composableBuilder(
    column: $table.expectedIncome,
    builder: (column) => column,
  );
}

class $$PayCycleConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayCycleConfigsTable,
          PayCycleConfigRecord,
          $$PayCycleConfigsTableFilterComposer,
          $$PayCycleConfigsTableOrderingComposer,
          $$PayCycleConfigsTableAnnotationComposer,
          $$PayCycleConfigsTableCreateCompanionBuilder,
          $$PayCycleConfigsTableUpdateCompanionBuilder,
          (
            PayCycleConfigRecord,
            BaseReferences<
              _$AppDatabase,
              $PayCycleConfigsTable,
              PayCycleConfigRecord
            >,
          ),
          PayCycleConfigRecord,
          PrefetchHooks Function()
        > {
  $$PayCycleConfigsTableTableManager(
    _$AppDatabase db,
    $PayCycleConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayCycleConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayCycleConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayCycleConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<PaydayRule> paydayRule = const Value.absent(),
                Value<int?> day = const Value.absent(),
                Value<bool> shiftOnHoliday = const Value.absent(),
                Value<int> expectedIncome = const Value.absent(),
              }) => PayCycleConfigsCompanion(
                id: id,
                paydayRule: paydayRule,
                day: day,
                shiftOnHoliday: shiftOnHoliday,
                expectedIncome: expectedIncome,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required PaydayRule paydayRule,
                Value<int?> day = const Value.absent(),
                Value<bool> shiftOnHoliday = const Value.absent(),
                Value<int> expectedIncome = const Value.absent(),
              }) => PayCycleConfigsCompanion.insert(
                id: id,
                paydayRule: paydayRule,
                day: day,
                shiftOnHoliday: shiftOnHoliday,
                expectedIncome: expectedIncome,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PayCycleConfigsTable, PayCycleConfigRecord>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $PayCycleConfigsTable,
                    PayCycleConfigRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PayCycleConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayCycleConfigsTable,
      PayCycleConfigRecord,
      $$PayCycleConfigsTableFilterComposer,
      $$PayCycleConfigsTableOrderingComposer,
      $$PayCycleConfigsTableAnnotationComposer,
      $$PayCycleConfigsTableCreateCompanionBuilder,
      $$PayCycleConfigsTableUpdateCompanionBuilder,
      (
        PayCycleConfigRecord,
        BaseReferences<
          _$AppDatabase,
          $PayCycleConfigsTable,
          PayCycleConfigRecord
        >,
      ),
      PayCycleConfigRecord,
      PrefetchHooks Function()
    >;
typedef $$SavingsTargetsTableCreateCompanionBuilder =
    SavingsTargetsCompanion Function({
      Value<int> id,
      required int amountPerCycle,
      Value<int?> accountId,
    });
typedef $$SavingsTargetsTableUpdateCompanionBuilder =
    SavingsTargetsCompanion Function({
      Value<int> id,
      Value<int> amountPerCycle,
      Value<int?> accountId,
    });

final class $$SavingsTargetsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SavingsTargetsTable,
          SavingsTargetRecord
        > {
  $$SavingsTargetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AccountsTable _accountIdTable(_$AppDatabase db) =>
      db.accounts.createAlias('savings_targets__account_id__accounts__id');

  $$AccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<int>('account_id');
    if ($_column == null) return null;
    final manager = $$AccountsTableTableManager(
      $_db,
      $_db.accounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SavingsTargetsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsTargetsTable> {
  $$SavingsTargetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountPerCycle => $composableBuilder(
    column: $table.amountPerCycle,
    builder: (column) => ColumnFilters(column),
  );

  $$AccountsTableFilterComposer get accountId {
    final $$AccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableFilterComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavingsTargetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsTargetsTable> {
  $$SavingsTargetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountPerCycle => $composableBuilder(
    column: $table.amountPerCycle,
    builder: (column) => ColumnOrderings(column),
  );

  $$AccountsTableOrderingComposer get accountId {
    final $$AccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableOrderingComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavingsTargetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsTargetsTable> {
  $$SavingsTargetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amountPerCycle => $composableBuilder(
    column: $table.amountPerCycle,
    builder: (column) => column,
  );

  $$AccountsTableAnnotationComposer get accountId {
    final $$AccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.accounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.accounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SavingsTargetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsTargetsTable,
          SavingsTargetRecord,
          $$SavingsTargetsTableFilterComposer,
          $$SavingsTargetsTableOrderingComposer,
          $$SavingsTargetsTableAnnotationComposer,
          $$SavingsTargetsTableCreateCompanionBuilder,
          $$SavingsTargetsTableUpdateCompanionBuilder,
          (SavingsTargetRecord, $$SavingsTargetsTableReferences),
          SavingsTargetRecord,
          PrefetchHooks Function({bool accountId})
        > {
  $$SavingsTargetsTableTableManager(
    _$AppDatabase db,
    $SavingsTargetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsTargetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsTargetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsTargetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amountPerCycle = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
              }) => SavingsTargetsCompanion(
                id: id,
                amountPerCycle: amountPerCycle,
                accountId: accountId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amountPerCycle,
                Value<int?> accountId = const Value.absent(),
              }) => SavingsTargetsCompanion.insert(
                id: id,
                amountPerCycle: amountPerCycle,
                accountId: accountId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavingsTargetsTable, SavingsTargetRecord>(table),
                  $$SavingsTargetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
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
                    if (accountId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.accountId,
                        referencedTable: $$SavingsTargetsTableReferences
                            ._accountIdTable(db),
                        referencedColumn: $$SavingsTargetsTableReferences
                            ._accountIdTable(db)
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

typedef $$SavingsTargetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsTargetsTable,
      SavingsTargetRecord,
      $$SavingsTargetsTableFilterComposer,
      $$SavingsTargetsTableOrderingComposer,
      $$SavingsTargetsTableAnnotationComposer,
      $$SavingsTargetsTableCreateCompanionBuilder,
      $$SavingsTargetsTableUpdateCompanionBuilder,
      (SavingsTargetRecord, $$SavingsTargetsTableReferences),
      SavingsTargetRecord,
      PrefetchHooks Function({bool accountId})
    >;
typedef $$AlertsTableCreateCompanionBuilder = AlertsCompanion Function({
  Value<int> id,
  required AlertType type,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<DateTime?> readAt,
  Value<AlertFeedback?> feedback,
});
typedef $$AlertsTableUpdateCompanionBuilder = AlertsCompanion Function({
  Value<int> id,
  Value<AlertType> type,
  Value<String> payload,
  Value<DateTime> createdAt,
  Value<DateTime?> readAt,
  Value<AlertFeedback?> feedback,
});

class $$AlertsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AlertType, AlertType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AlertFeedback?, AlertFeedback, String>
  get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$AlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedback => $composableBuilder(
    column: $table.feedback,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertsTable> {
  $$AlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AlertType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AlertFeedback?, String> get feedback =>
      $composableBuilder(column: $table.feedback, builder: (column) => column);
}

class $$AlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertsTable,
          AlertRecord,
          $$AlertsTableFilterComposer,
          $$AlertsTableOrderingComposer,
          $$AlertsTableAnnotationComposer,
          $$AlertsTableCreateCompanionBuilder,
          $$AlertsTableUpdateCompanionBuilder,
          (
            AlertRecord,
            BaseReferences<_$AppDatabase, $AlertsTable, AlertRecord>,
          ),
          AlertRecord,
          PrefetchHooks Function()
        > {
  $$AlertsTableTableManager(_$AppDatabase db, $AlertsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<AlertType> type = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<AlertFeedback?> feedback = const Value.absent(),
              }) => AlertsCompanion(
                id: id,
                type: type,
                payload: payload,
                createdAt: createdAt,
                readAt: readAt,
                feedback: feedback,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required AlertType type,
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<AlertFeedback?> feedback = const Value.absent(),
              }) => AlertsCompanion.insert(
                id: id,
                type: type,
                payload: payload,
                createdAt: createdAt,
                readAt: readAt,
                feedback: feedback,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlertsTable, AlertRecord>(table),
                  BaseReferences<_$AppDatabase, $AlertsTable, AlertRecord>(
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

typedef $$AlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertsTable,
      AlertRecord,
      $$AlertsTableFilterComposer,
      $$AlertsTableOrderingComposer,
      $$AlertsTableAnnotationComposer,
      $$AlertsTableCreateCompanionBuilder,
      $$AlertsTableUpdateCompanionBuilder,
      (AlertRecord, BaseReferences<_$AppDatabase, $AlertsTable, AlertRecord>),
      AlertRecord,
      PrefetchHooks Function()
    >;
typedef $$AlertThresholdsTableCreateCompanionBuilder =
    AlertThresholdsCompanion Function({
      required AlertType type,
      required double value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$AlertThresholdsTableUpdateCompanionBuilder =
    AlertThresholdsCompanion Function({
      Value<AlertType> type,
      Value<double> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AlertThresholdsTableFilterComposer
    extends Composer<_$AppDatabase, $AlertThresholdsTable> {
  $$AlertThresholdsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<AlertType, AlertType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AlertThresholdsTableOrderingComposer
    extends Composer<_$AppDatabase, $AlertThresholdsTable> {
  $$AlertThresholdsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AlertThresholdsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AlertThresholdsTable> {
  $$AlertThresholdsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<AlertType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AlertThresholdsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AlertThresholdsTable,
          AlertThresholdRecord,
          $$AlertThresholdsTableFilterComposer,
          $$AlertThresholdsTableOrderingComposer,
          $$AlertThresholdsTableAnnotationComposer,
          $$AlertThresholdsTableCreateCompanionBuilder,
          $$AlertThresholdsTableUpdateCompanionBuilder,
          (
            AlertThresholdRecord,
            BaseReferences<
              _$AppDatabase,
              $AlertThresholdsTable,
              AlertThresholdRecord
            >,
          ),
          AlertThresholdRecord,
          PrefetchHooks Function()
        > {
  $$AlertThresholdsTableTableManager(
    _$AppDatabase db,
    $AlertThresholdsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlertThresholdsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlertThresholdsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlertThresholdsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<AlertType> type = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertThresholdsCompanion(
                type: type,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required AlertType type,
                required double value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlertThresholdsCompanion.insert(
                type: type,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlertThresholdsTable, AlertThresholdRecord>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $AlertThresholdsTable,
                    AlertThresholdRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AlertThresholdsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AlertThresholdsTable,
      AlertThresholdRecord,
      $$AlertThresholdsTableFilterComposer,
      $$AlertThresholdsTableOrderingComposer,
      $$AlertThresholdsTableAnnotationComposer,
      $$AlertThresholdsTableCreateCompanionBuilder,
      $$AlertThresholdsTableUpdateCompanionBuilder,
      (
        AlertThresholdRecord,
        BaseReferences<
          _$AppDatabase,
          $AlertThresholdsTable,
          AlertThresholdRecord
        >,
      ),
      AlertThresholdRecord,
      PrefetchHooks Function()
    >;
typedef $$EntitlementsTableCreateCompanionBuilder =
    EntitlementsCompanion Function({
      required String productId,
      required String purchaseToken,
      required EntitlementStatus status,
      required DateTime verifiedAt,
      Value<int> rowid,
    });
typedef $$EntitlementsTableUpdateCompanionBuilder =
    EntitlementsCompanion Function({
      Value<String> productId,
      Value<String> purchaseToken,
      Value<EntitlementStatus> status,
      Value<DateTime> verifiedAt,
      Value<int> rowid,
    });

class $$EntitlementsTableFilterComposer
    extends Composer<_$AppDatabase, $EntitlementsTable> {
  $$EntitlementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseToken => $composableBuilder(
    column: $table.purchaseToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EntitlementStatus, EntitlementStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntitlementsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntitlementsTable> {
  $$EntitlementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get productId => $composableBuilder(
    column: $table.productId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseToken => $composableBuilder(
    column: $table.purchaseToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntitlementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntitlementsTable> {
  $$EntitlementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get purchaseToken => $composableBuilder(
    column: $table.purchaseToken,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<EntitlementStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get verifiedAt => $composableBuilder(
    column: $table.verifiedAt,
    builder: (column) => column,
  );
}

class $$EntitlementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntitlementsTable,
          EntitlementRecord,
          $$EntitlementsTableFilterComposer,
          $$EntitlementsTableOrderingComposer,
          $$EntitlementsTableAnnotationComposer,
          $$EntitlementsTableCreateCompanionBuilder,
          $$EntitlementsTableUpdateCompanionBuilder,
          (
            EntitlementRecord,
            BaseReferences<
              _$AppDatabase,
              $EntitlementsTable,
              EntitlementRecord
            >,
          ),
          EntitlementRecord,
          PrefetchHooks Function()
        > {
  $$EntitlementsTableTableManager(_$AppDatabase db, $EntitlementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntitlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntitlementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntitlementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> productId = const Value.absent(),
                Value<String> purchaseToken = const Value.absent(),
                Value<EntitlementStatus> status = const Value.absent(),
                Value<DateTime> verifiedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntitlementsCompanion(
                productId: productId,
                purchaseToken: purchaseToken,
                status: status,
                verifiedAt: verifiedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String productId,
                required String purchaseToken,
                required EntitlementStatus status,
                required DateTime verifiedAt,
                Value<int> rowid = const Value.absent(),
              }) => EntitlementsCompanion.insert(
                productId: productId,
                purchaseToken: purchaseToken,
                status: status,
                verifiedAt: verifiedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntitlementsTable, EntitlementRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $EntitlementsTable,
                    EntitlementRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntitlementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntitlementsTable,
      EntitlementRecord,
      $$EntitlementsTableFilterComposer,
      $$EntitlementsTableOrderingComposer,
      $$EntitlementsTableAnnotationComposer,
      $$EntitlementsTableCreateCompanionBuilder,
      $$EntitlementsTableUpdateCompanionBuilder,
      (
        EntitlementRecord,
        BaseReferences<_$AppDatabase, $EntitlementsTable, EntitlementRecord>,
      ),
      EntitlementRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ObligationsTableTableManager get obligations =>
      $$ObligationsTableTableManager(_db, _db.obligations);
  $$ObligationInstancesTableTableManager get obligationInstances =>
      $$ObligationInstancesTableTableManager(_db, _db.obligationInstances);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
  $$PayCycleConfigsTableTableManager get payCycleConfigs =>
      $$PayCycleConfigsTableTableManager(_db, _db.payCycleConfigs);
  $$SavingsTargetsTableTableManager get savingsTargets =>
      $$SavingsTargetsTableTableManager(_db, _db.savingsTargets);
  $$AlertsTableTableManager get alerts =>
      $$AlertsTableTableManager(_db, _db.alerts);
  $$AlertThresholdsTableTableManager get alertThresholds =>
      $$AlertThresholdsTableTableManager(_db, _db.alertThresholds);
  $$EntitlementsTableTableManager get entitlements =>
      $$EntitlementsTableTableManager(_db, _db.entitlements);
}
