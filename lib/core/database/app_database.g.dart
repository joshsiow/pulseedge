// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PatientsTable extends Patients with TableInfo<$PatientsTable, Patient> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PatientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mrnMeta = const VerificationMeta('mrn');
  @override
  late final GeneratedColumn<String> mrn = GeneratedColumn<String>(
      'mrn', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _fullNameNormMeta =
      const VerificationMeta('fullNameNorm');
  @override
  late final GeneratedColumn<String> fullNameNorm = GeneratedColumn<String>(
      'full_name_norm', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nricMeta = const VerificationMeta('nric');
  @override
  late final GeneratedColumn<String> nric = GeneratedColumn<String>(
      'nric', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nricHashMeta =
      const VerificationMeta('nricHash');
  @override
  late final GeneratedColumn<String> nricHash = GeneratedColumn<String>(
      'nric_hash', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
      'gender', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dobMeta = const VerificationMeta('dob');
  @override
  late final GeneratedColumn<DateTime> dob = GeneratedColumn<DateTime>(
      'dob', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _addressMeta =
      const VerificationMeta('address');
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
      'address', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _allergiesMeta =
      const VerificationMeta('allergies');
  @override
  late final GeneratedColumn<String> allergies = GeneratedColumn<String>(
      'allergies', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _consentStatusMeta =
      const VerificationMeta('consentStatus');
  @override
  late final GeneratedColumn<String> consentStatus = GeneratedColumn<String>(
      'consent_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('unknown'));
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('local'));
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        mrn,
        fullName,
        fullNameNorm,
        nric,
        nricHash,
        gender,
        dob,
        phone,
        address,
        allergies,
        consentStatus,
        source,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'patients';
  @override
  VerificationContext validateIntegrity(Insertable<Patient> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('mrn')) {
      context.handle(
          _mrnMeta, mrn.isAcceptableOrUnknown(data['mrn']!, _mrnMeta));
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('full_name_norm')) {
      context.handle(
          _fullNameNormMeta,
          fullNameNorm.isAcceptableOrUnknown(
              data['full_name_norm']!, _fullNameNormMeta));
    } else if (isInserting) {
      context.missing(_fullNameNormMeta);
    }
    if (data.containsKey('nric')) {
      context.handle(
          _nricMeta, nric.isAcceptableOrUnknown(data['nric']!, _nricMeta));
    } else if (isInserting) {
      context.missing(_nricMeta);
    }
    if (data.containsKey('nric_hash')) {
      context.handle(_nricHashMeta,
          nricHash.isAcceptableOrUnknown(data['nric_hash']!, _nricHashMeta));
    } else if (isInserting) {
      context.missing(_nricHashMeta);
    }
    if (data.containsKey('gender')) {
      context.handle(_genderMeta,
          gender.isAcceptableOrUnknown(data['gender']!, _genderMeta));
    }
    if (data.containsKey('dob')) {
      context.handle(
          _dobMeta, dob.isAcceptableOrUnknown(data['dob']!, _dobMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('address')) {
      context.handle(_addressMeta,
          address.isAcceptableOrUnknown(data['address']!, _addressMeta));
    }
    if (data.containsKey('allergies')) {
      context.handle(_allergiesMeta,
          allergies.isAcceptableOrUnknown(data['allergies']!, _allergiesMeta));
    }
    if (data.containsKey('consent_status')) {
      context.handle(
          _consentStatusMeta,
          consentStatus.isAcceptableOrUnknown(
              data['consent_status']!, _consentStatusMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Patient map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Patient(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mrn: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mrn']),
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      fullNameNorm: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name_norm'])!,
      nric: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nric'])!,
      nricHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}nric_hash'])!,
      gender: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}gender']),
      dob: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}dob']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      address: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address']),
      allergies: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}allergies']),
      consentStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}consent_status'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PatientsTable createAlias(String alias) {
    return $PatientsTable(attachedDatabase, alias);
  }
}

class Patient extends DataClass implements Insertable<Patient> {
  final String id;
  final String? mrn;
  final String fullName;
  final String fullNameNorm;
  final String nric;
  final String nricHash;
  final String? gender;
  final DateTime? dob;
  final String? phone;
  final String? address;
  final String? allergies;
  final String consentStatus;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Patient(
      {required this.id,
      this.mrn,
      required this.fullName,
      required this.fullNameNorm,
      required this.nric,
      required this.nricHash,
      this.gender,
      this.dob,
      this.phone,
      this.address,
      this.allergies,
      required this.consentStatus,
      required this.source,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || mrn != null) {
      map['mrn'] = Variable<String>(mrn);
    }
    map['full_name'] = Variable<String>(fullName);
    map['full_name_norm'] = Variable<String>(fullNameNorm);
    map['nric'] = Variable<String>(nric);
    map['nric_hash'] = Variable<String>(nricHash);
    if (!nullToAbsent || gender != null) {
      map['gender'] = Variable<String>(gender);
    }
    if (!nullToAbsent || dob != null) {
      map['dob'] = Variable<DateTime>(dob);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || allergies != null) {
      map['allergies'] = Variable<String>(allergies);
    }
    map['consent_status'] = Variable<String>(consentStatus);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PatientsCompanion toCompanion(bool nullToAbsent) {
    return PatientsCompanion(
      id: Value(id),
      mrn: mrn == null && nullToAbsent ? const Value.absent() : Value(mrn),
      fullName: Value(fullName),
      fullNameNorm: Value(fullNameNorm),
      nric: Value(nric),
      nricHash: Value(nricHash),
      gender:
          gender == null && nullToAbsent ? const Value.absent() : Value(gender),
      dob: dob == null && nullToAbsent ? const Value.absent() : Value(dob),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      allergies: allergies == null && nullToAbsent
          ? const Value.absent()
          : Value(allergies),
      consentStatus: Value(consentStatus),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Patient.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Patient(
      id: serializer.fromJson<String>(json['id']),
      mrn: serializer.fromJson<String?>(json['mrn']),
      fullName: serializer.fromJson<String>(json['fullName']),
      fullNameNorm: serializer.fromJson<String>(json['fullNameNorm']),
      nric: serializer.fromJson<String>(json['nric']),
      nricHash: serializer.fromJson<String>(json['nricHash']),
      gender: serializer.fromJson<String?>(json['gender']),
      dob: serializer.fromJson<DateTime?>(json['dob']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      allergies: serializer.fromJson<String?>(json['allergies']),
      consentStatus: serializer.fromJson<String>(json['consentStatus']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mrn': serializer.toJson<String?>(mrn),
      'fullName': serializer.toJson<String>(fullName),
      'fullNameNorm': serializer.toJson<String>(fullNameNorm),
      'nric': serializer.toJson<String>(nric),
      'nricHash': serializer.toJson<String>(nricHash),
      'gender': serializer.toJson<String?>(gender),
      'dob': serializer.toJson<DateTime?>(dob),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'allergies': serializer.toJson<String?>(allergies),
      'consentStatus': serializer.toJson<String>(consentStatus),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Patient copyWith(
          {String? id,
          Value<String?> mrn = const Value.absent(),
          String? fullName,
          String? fullNameNorm,
          String? nric,
          String? nricHash,
          Value<String?> gender = const Value.absent(),
          Value<DateTime?> dob = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<String?> address = const Value.absent(),
          Value<String?> allergies = const Value.absent(),
          String? consentStatus,
          String? source,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Patient(
        id: id ?? this.id,
        mrn: mrn.present ? mrn.value : this.mrn,
        fullName: fullName ?? this.fullName,
        fullNameNorm: fullNameNorm ?? this.fullNameNorm,
        nric: nric ?? this.nric,
        nricHash: nricHash ?? this.nricHash,
        gender: gender.present ? gender.value : this.gender,
        dob: dob.present ? dob.value : this.dob,
        phone: phone.present ? phone.value : this.phone,
        address: address.present ? address.value : this.address,
        allergies: allergies.present ? allergies.value : this.allergies,
        consentStatus: consentStatus ?? this.consentStatus,
        source: source ?? this.source,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Patient copyWithCompanion(PatientsCompanion data) {
    return Patient(
      id: data.id.present ? data.id.value : this.id,
      mrn: data.mrn.present ? data.mrn.value : this.mrn,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      fullNameNorm: data.fullNameNorm.present
          ? data.fullNameNorm.value
          : this.fullNameNorm,
      nric: data.nric.present ? data.nric.value : this.nric,
      nricHash: data.nricHash.present ? data.nricHash.value : this.nricHash,
      gender: data.gender.present ? data.gender.value : this.gender,
      dob: data.dob.present ? data.dob.value : this.dob,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      allergies: data.allergies.present ? data.allergies.value : this.allergies,
      consentStatus: data.consentStatus.present
          ? data.consentStatus.value
          : this.consentStatus,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Patient(')
          ..write('id: $id, ')
          ..write('mrn: $mrn, ')
          ..write('fullName: $fullName, ')
          ..write('fullNameNorm: $fullNameNorm, ')
          ..write('nric: $nric, ')
          ..write('nricHash: $nricHash, ')
          ..write('gender: $gender, ')
          ..write('dob: $dob, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('allergies: $allergies, ')
          ..write('consentStatus: $consentStatus, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      mrn,
      fullName,
      fullNameNorm,
      nric,
      nricHash,
      gender,
      dob,
      phone,
      address,
      allergies,
      consentStatus,
      source,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Patient &&
          other.id == this.id &&
          other.mrn == this.mrn &&
          other.fullName == this.fullName &&
          other.fullNameNorm == this.fullNameNorm &&
          other.nric == this.nric &&
          other.nricHash == this.nricHash &&
          other.gender == this.gender &&
          other.dob == this.dob &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.allergies == this.allergies &&
          other.consentStatus == this.consentStatus &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PatientsCompanion extends UpdateCompanion<Patient> {
  final Value<String> id;
  final Value<String?> mrn;
  final Value<String> fullName;
  final Value<String> fullNameNorm;
  final Value<String> nric;
  final Value<String> nricHash;
  final Value<String?> gender;
  final Value<DateTime?> dob;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String?> allergies;
  final Value<String> consentStatus;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PatientsCompanion({
    this.id = const Value.absent(),
    this.mrn = const Value.absent(),
    this.fullName = const Value.absent(),
    this.fullNameNorm = const Value.absent(),
    this.nric = const Value.absent(),
    this.nricHash = const Value.absent(),
    this.gender = const Value.absent(),
    this.dob = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.allergies = const Value.absent(),
    this.consentStatus = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PatientsCompanion.insert({
    required String id,
    this.mrn = const Value.absent(),
    required String fullName,
    required String fullNameNorm,
    required String nric,
    required String nricHash,
    this.gender = const Value.absent(),
    this.dob = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.allergies = const Value.absent(),
    this.consentStatus = const Value.absent(),
    this.source = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        fullName = Value(fullName),
        fullNameNorm = Value(fullNameNorm),
        nric = Value(nric),
        nricHash = Value(nricHash),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Patient> custom({
    Expression<String>? id,
    Expression<String>? mrn,
    Expression<String>? fullName,
    Expression<String>? fullNameNorm,
    Expression<String>? nric,
    Expression<String>? nricHash,
    Expression<String>? gender,
    Expression<DateTime>? dob,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? allergies,
    Expression<String>? consentStatus,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mrn != null) 'mrn': mrn,
      if (fullName != null) 'full_name': fullName,
      if (fullNameNorm != null) 'full_name_norm': fullNameNorm,
      if (nric != null) 'nric': nric,
      if (nricHash != null) 'nric_hash': nricHash,
      if (gender != null) 'gender': gender,
      if (dob != null) 'dob': dob,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (allergies != null) 'allergies': allergies,
      if (consentStatus != null) 'consent_status': consentStatus,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PatientsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? mrn,
      Value<String>? fullName,
      Value<String>? fullNameNorm,
      Value<String>? nric,
      Value<String>? nricHash,
      Value<String?>? gender,
      Value<DateTime?>? dob,
      Value<String?>? phone,
      Value<String?>? address,
      Value<String?>? allergies,
      Value<String>? consentStatus,
      Value<String>? source,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return PatientsCompanion(
      id: id ?? this.id,
      mrn: mrn ?? this.mrn,
      fullName: fullName ?? this.fullName,
      fullNameNorm: fullNameNorm ?? this.fullNameNorm,
      nric: nric ?? this.nric,
      nricHash: nricHash ?? this.nricHash,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      allergies: allergies ?? this.allergies,
      consentStatus: consentStatus ?? this.consentStatus,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mrn.present) {
      map['mrn'] = Variable<String>(mrn.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (fullNameNorm.present) {
      map['full_name_norm'] = Variable<String>(fullNameNorm.value);
    }
    if (nric.present) {
      map['nric'] = Variable<String>(nric.value);
    }
    if (nricHash.present) {
      map['nric_hash'] = Variable<String>(nricHash.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (dob.present) {
      map['dob'] = Variable<DateTime>(dob.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (allergies.present) {
      map['allergies'] = Variable<String>(allergies.value);
    }
    if (consentStatus.present) {
      map['consent_status'] = Variable<String>(consentStatus.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('PatientsCompanion(')
          ..write('id: $id, ')
          ..write('mrn: $mrn, ')
          ..write('fullName: $fullName, ')
          ..write('fullNameNorm: $fullNameNorm, ')
          ..write('nric: $nric, ')
          ..write('nricHash: $nricHash, ')
          ..write('gender: $gender, ')
          ..write('dob: $dob, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('allergies: $allergies, ')
          ..write('consentStatus: $consentStatus, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EncountersTable extends Encounters
    with TableInfo<$EncountersTable, Encounter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncountersTable(this.attachedDatabase, [this._alias]);
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
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _encounterNoMeta =
      const VerificationMeta('encounterNo');
  @override
  late final GeneratedColumn<String> encounterNo = GeneratedColumn<String>(
      'encounter_no', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('open'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('OPD'));
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
      'unit_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _unitNameMeta =
      const VerificationMeta('unitName');
  @override
  late final GeneratedColumn<String> unitName = GeneratedColumn<String>(
      'unit_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Unknown Unit'));
  static const VerificationMeta _providerUserIdMeta =
      const VerificationMeta('providerUserId');
  @override
  late final GeneratedColumn<String> providerUserId = GeneratedColumn<String>(
      'provider_user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _providerNameMeta =
      const VerificationMeta('providerName');
  @override
  late final GeneratedColumn<String> providerName = GeneratedColumn<String>(
      'provider_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _chiefComplaintMeta =
      const VerificationMeta('chiefComplaint');
  @override
  late final GeneratedColumn<String> chiefComplaint = GeneratedColumn<String>(
      'chief_complaint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _triageCategoryMeta =
      const VerificationMeta('triageCategory');
  @override
  late final GeneratedColumn<String> triageCategory = GeneratedColumn<String>(
      'triage_category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startAtMeta =
      const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
      'start_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
      'end_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<int> synced = GeneratedColumn<int>(
      'synced', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  static const VerificationMeta _aiMetadataMeta =
      const VerificationMeta('aiMetadata');
  @override
  late final GeneratedColumn<String> aiMetadata = GeneratedColumn<String>(
      'ai_metadata', aliasedName, true,
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
  @override
  List<GeneratedColumn> get $columns => [
        id,
        patientId,
        encounterNo,
        status,
        type,
        unitId,
        unitName,
        providerUserId,
        providerName,
        chiefComplaint,
        triageCategory,
        startAt,
        endAt,
        synced,
        syncState,
        aiMetadata,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encounters';
  @override
  VerificationContext validateIntegrity(Insertable<Encounter> instance,
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
    if (data.containsKey('encounter_no')) {
      context.handle(
          _encounterNoMeta,
          encounterNo.isAcceptableOrUnknown(
              data['encounter_no']!, _encounterNoMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta,
          unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    }
    if (data.containsKey('unit_name')) {
      context.handle(_unitNameMeta,
          unitName.isAcceptableOrUnknown(data['unit_name']!, _unitNameMeta));
    }
    if (data.containsKey('provider_user_id')) {
      context.handle(
          _providerUserIdMeta,
          providerUserId.isAcceptableOrUnknown(
              data['provider_user_id']!, _providerUserIdMeta));
    }
    if (data.containsKey('provider_name')) {
      context.handle(
          _providerNameMeta,
          providerName.isAcceptableOrUnknown(
              data['provider_name']!, _providerNameMeta));
    }
    if (data.containsKey('chief_complaint')) {
      context.handle(
          _chiefComplaintMeta,
          chiefComplaint.isAcceptableOrUnknown(
              data['chief_complaint']!, _chiefComplaintMeta));
    }
    if (data.containsKey('triage_category')) {
      context.handle(
          _triageCategoryMeta,
          triageCategory.isAcceptableOrUnknown(
              data['triage_category']!, _triageCategoryMeta));
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta,
          startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    } else if (isInserting) {
      context.missing(_startAtMeta);
    }
    if (data.containsKey('end_at')) {
      context.handle(
          _endAtMeta, endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    if (data.containsKey('ai_metadata')) {
      context.handle(
          _aiMetadataMeta,
          aiMetadata.isAcceptableOrUnknown(
              data['ai_metadata']!, _aiMetadataMeta));
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Encounter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Encounter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      encounterNo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}encounter_no']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      unitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_id']),
      unitName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_name'])!,
      providerUserId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}provider_user_id']),
      providerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider_name']),
      chiefComplaint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}chief_complaint']),
      triageCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}triage_category']),
      startAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_at'])!,
      endAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_at']),
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}synced'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
      aiMetadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ai_metadata']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $EncountersTable createAlias(String alias) {
    return $EncountersTable(attachedDatabase, alias);
  }
}

class Encounter extends DataClass implements Insertable<Encounter> {
  final String id;
  final String patientId;
  final String? encounterNo;
  final String status;
  final String type;
  final String? unitId;
  final String unitName;
  final String? providerUserId;
  final String? providerName;
  final String? chiefComplaint;
  final String? triageCategory;
  final DateTime startAt;
  final DateTime? endAt;
  final int synced;
  final String syncState;
  final String? aiMetadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Encounter(
      {required this.id,
      required this.patientId,
      this.encounterNo,
      required this.status,
      required this.type,
      this.unitId,
      required this.unitName,
      this.providerUserId,
      this.providerName,
      this.chiefComplaint,
      this.triageCategory,
      required this.startAt,
      this.endAt,
      required this.synced,
      required this.syncState,
      this.aiMetadata,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['patient_id'] = Variable<String>(patientId);
    if (!nullToAbsent || encounterNo != null) {
      map['encounter_no'] = Variable<String>(encounterNo);
    }
    map['status'] = Variable<String>(status);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || unitId != null) {
      map['unit_id'] = Variable<String>(unitId);
    }
    map['unit_name'] = Variable<String>(unitName);
    if (!nullToAbsent || providerUserId != null) {
      map['provider_user_id'] = Variable<String>(providerUserId);
    }
    if (!nullToAbsent || providerName != null) {
      map['provider_name'] = Variable<String>(providerName);
    }
    if (!nullToAbsent || chiefComplaint != null) {
      map['chief_complaint'] = Variable<String>(chiefComplaint);
    }
    if (!nullToAbsent || triageCategory != null) {
      map['triage_category'] = Variable<String>(triageCategory);
    }
    map['start_at'] = Variable<DateTime>(startAt);
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<DateTime>(endAt);
    }
    map['synced'] = Variable<int>(synced);
    map['sync_state'] = Variable<String>(syncState);
    if (!nullToAbsent || aiMetadata != null) {
      map['ai_metadata'] = Variable<String>(aiMetadata);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EncountersCompanion toCompanion(bool nullToAbsent) {
    return EncountersCompanion(
      id: Value(id),
      patientId: Value(patientId),
      encounterNo: encounterNo == null && nullToAbsent
          ? const Value.absent()
          : Value(encounterNo),
      status: Value(status),
      type: Value(type),
      unitId:
          unitId == null && nullToAbsent ? const Value.absent() : Value(unitId),
      unitName: Value(unitName),
      providerUserId: providerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(providerUserId),
      providerName: providerName == null && nullToAbsent
          ? const Value.absent()
          : Value(providerName),
      chiefComplaint: chiefComplaint == null && nullToAbsent
          ? const Value.absent()
          : Value(chiefComplaint),
      triageCategory: triageCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(triageCategory),
      startAt: Value(startAt),
      endAt:
          endAt == null && nullToAbsent ? const Value.absent() : Value(endAt),
      synced: Value(synced),
      syncState: Value(syncState),
      aiMetadata: aiMetadata == null && nullToAbsent
          ? const Value.absent()
          : Value(aiMetadata),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Encounter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Encounter(
      id: serializer.fromJson<String>(json['id']),
      patientId: serializer.fromJson<String>(json['patientId']),
      encounterNo: serializer.fromJson<String?>(json['encounterNo']),
      status: serializer.fromJson<String>(json['status']),
      type: serializer.fromJson<String>(json['type']),
      unitId: serializer.fromJson<String?>(json['unitId']),
      unitName: serializer.fromJson<String>(json['unitName']),
      providerUserId: serializer.fromJson<String?>(json['providerUserId']),
      providerName: serializer.fromJson<String?>(json['providerName']),
      chiefComplaint: serializer.fromJson<String?>(json['chiefComplaint']),
      triageCategory: serializer.fromJson<String?>(json['triageCategory']),
      startAt: serializer.fromJson<DateTime>(json['startAt']),
      endAt: serializer.fromJson<DateTime?>(json['endAt']),
      synced: serializer.fromJson<int>(json['synced']),
      syncState: serializer.fromJson<String>(json['syncState']),
      aiMetadata: serializer.fromJson<String?>(json['aiMetadata']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patientId': serializer.toJson<String>(patientId),
      'encounterNo': serializer.toJson<String?>(encounterNo),
      'status': serializer.toJson<String>(status),
      'type': serializer.toJson<String>(type),
      'unitId': serializer.toJson<String?>(unitId),
      'unitName': serializer.toJson<String>(unitName),
      'providerUserId': serializer.toJson<String?>(providerUserId),
      'providerName': serializer.toJson<String?>(providerName),
      'chiefComplaint': serializer.toJson<String?>(chiefComplaint),
      'triageCategory': serializer.toJson<String?>(triageCategory),
      'startAt': serializer.toJson<DateTime>(startAt),
      'endAt': serializer.toJson<DateTime?>(endAt),
      'synced': serializer.toJson<int>(synced),
      'syncState': serializer.toJson<String>(syncState),
      'aiMetadata': serializer.toJson<String?>(aiMetadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Encounter copyWith(
          {String? id,
          String? patientId,
          Value<String?> encounterNo = const Value.absent(),
          String? status,
          String? type,
          Value<String?> unitId = const Value.absent(),
          String? unitName,
          Value<String?> providerUserId = const Value.absent(),
          Value<String?> providerName = const Value.absent(),
          Value<String?> chiefComplaint = const Value.absent(),
          Value<String?> triageCategory = const Value.absent(),
          DateTime? startAt,
          Value<DateTime?> endAt = const Value.absent(),
          int? synced,
          String? syncState,
          Value<String?> aiMetadata = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Encounter(
        id: id ?? this.id,
        patientId: patientId ?? this.patientId,
        encounterNo: encounterNo.present ? encounterNo.value : this.encounterNo,
        status: status ?? this.status,
        type: type ?? this.type,
        unitId: unitId.present ? unitId.value : this.unitId,
        unitName: unitName ?? this.unitName,
        providerUserId:
            providerUserId.present ? providerUserId.value : this.providerUserId,
        providerName:
            providerName.present ? providerName.value : this.providerName,
        chiefComplaint:
            chiefComplaint.present ? chiefComplaint.value : this.chiefComplaint,
        triageCategory:
            triageCategory.present ? triageCategory.value : this.triageCategory,
        startAt: startAt ?? this.startAt,
        endAt: endAt.present ? endAt.value : this.endAt,
        synced: synced ?? this.synced,
        syncState: syncState ?? this.syncState,
        aiMetadata: aiMetadata.present ? aiMetadata.value : this.aiMetadata,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Encounter copyWithCompanion(EncountersCompanion data) {
    return Encounter(
      id: data.id.present ? data.id.value : this.id,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      encounterNo:
          data.encounterNo.present ? data.encounterNo.value : this.encounterNo,
      status: data.status.present ? data.status.value : this.status,
      type: data.type.present ? data.type.value : this.type,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      unitName: data.unitName.present ? data.unitName.value : this.unitName,
      providerUserId: data.providerUserId.present
          ? data.providerUserId.value
          : this.providerUserId,
      providerName: data.providerName.present
          ? data.providerName.value
          : this.providerName,
      chiefComplaint: data.chiefComplaint.present
          ? data.chiefComplaint.value
          : this.chiefComplaint,
      triageCategory: data.triageCategory.present
          ? data.triageCategory.value
          : this.triageCategory,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      aiMetadata:
          data.aiMetadata.present ? data.aiMetadata.value : this.aiMetadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Encounter(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('encounterNo: $encounterNo, ')
          ..write('status: $status, ')
          ..write('type: $type, ')
          ..write('unitId: $unitId, ')
          ..write('unitName: $unitName, ')
          ..write('providerUserId: $providerUserId, ')
          ..write('providerName: $providerName, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('triageCategory: $triageCategory, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('synced: $synced, ')
          ..write('syncState: $syncState, ')
          ..write('aiMetadata: $aiMetadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      patientId,
      encounterNo,
      status,
      type,
      unitId,
      unitName,
      providerUserId,
      providerName,
      chiefComplaint,
      triageCategory,
      startAt,
      endAt,
      synced,
      syncState,
      aiMetadata,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Encounter &&
          other.id == this.id &&
          other.patientId == this.patientId &&
          other.encounterNo == this.encounterNo &&
          other.status == this.status &&
          other.type == this.type &&
          other.unitId == this.unitId &&
          other.unitName == this.unitName &&
          other.providerUserId == this.providerUserId &&
          other.providerName == this.providerName &&
          other.chiefComplaint == this.chiefComplaint &&
          other.triageCategory == this.triageCategory &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.synced == this.synced &&
          other.syncState == this.syncState &&
          other.aiMetadata == this.aiMetadata &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EncountersCompanion extends UpdateCompanion<Encounter> {
  final Value<String> id;
  final Value<String> patientId;
  final Value<String?> encounterNo;
  final Value<String> status;
  final Value<String> type;
  final Value<String?> unitId;
  final Value<String> unitName;
  final Value<String?> providerUserId;
  final Value<String?> providerName;
  final Value<String?> chiefComplaint;
  final Value<String?> triageCategory;
  final Value<DateTime> startAt;
  final Value<DateTime?> endAt;
  final Value<int> synced;
  final Value<String> syncState;
  final Value<String?> aiMetadata;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EncountersCompanion({
    this.id = const Value.absent(),
    this.patientId = const Value.absent(),
    this.encounterNo = const Value.absent(),
    this.status = const Value.absent(),
    this.type = const Value.absent(),
    this.unitId = const Value.absent(),
    this.unitName = const Value.absent(),
    this.providerUserId = const Value.absent(),
    this.providerName = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.triageCategory = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncState = const Value.absent(),
    this.aiMetadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EncountersCompanion.insert({
    required String id,
    required String patientId,
    this.encounterNo = const Value.absent(),
    this.status = const Value.absent(),
    this.type = const Value.absent(),
    this.unitId = const Value.absent(),
    this.unitName = const Value.absent(),
    this.providerUserId = const Value.absent(),
    this.providerName = const Value.absent(),
    this.chiefComplaint = const Value.absent(),
    this.triageCategory = const Value.absent(),
    required DateTime startAt,
    this.endAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncState = const Value.absent(),
    this.aiMetadata = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        patientId = Value(patientId),
        startAt = Value(startAt),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Encounter> custom({
    Expression<String>? id,
    Expression<String>? patientId,
    Expression<String>? encounterNo,
    Expression<String>? status,
    Expression<String>? type,
    Expression<String>? unitId,
    Expression<String>? unitName,
    Expression<String>? providerUserId,
    Expression<String>? providerName,
    Expression<String>? chiefComplaint,
    Expression<String>? triageCategory,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<int>? synced,
    Expression<String>? syncState,
    Expression<String>? aiMetadata,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patientId != null) 'patient_id': patientId,
      if (encounterNo != null) 'encounter_no': encounterNo,
      if (status != null) 'status': status,
      if (type != null) 'type': type,
      if (unitId != null) 'unit_id': unitId,
      if (unitName != null) 'unit_name': unitName,
      if (providerUserId != null) 'provider_user_id': providerUserId,
      if (providerName != null) 'provider_name': providerName,
      if (chiefComplaint != null) 'chief_complaint': chiefComplaint,
      if (triageCategory != null) 'triage_category': triageCategory,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (synced != null) 'synced': synced,
      if (syncState != null) 'sync_state': syncState,
      if (aiMetadata != null) 'ai_metadata': aiMetadata,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EncountersCompanion copyWith(
      {Value<String>? id,
      Value<String>? patientId,
      Value<String?>? encounterNo,
      Value<String>? status,
      Value<String>? type,
      Value<String?>? unitId,
      Value<String>? unitName,
      Value<String?>? providerUserId,
      Value<String?>? providerName,
      Value<String?>? chiefComplaint,
      Value<String?>? triageCategory,
      Value<DateTime>? startAt,
      Value<DateTime?>? endAt,
      Value<int>? synced,
      Value<String>? syncState,
      Value<String?>? aiMetadata,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return EncountersCompanion(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      encounterNo: encounterNo ?? this.encounterNo,
      status: status ?? this.status,
      type: type ?? this.type,
      unitId: unitId ?? this.unitId,
      unitName: unitName ?? this.unitName,
      providerUserId: providerUserId ?? this.providerUserId,
      providerName: providerName ?? this.providerName,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      triageCategory: triageCategory ?? this.triageCategory,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      synced: synced ?? this.synced,
      syncState: syncState ?? this.syncState,
      aiMetadata: aiMetadata ?? this.aiMetadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (encounterNo.present) {
      map['encounter_no'] = Variable<String>(encounterNo.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
    }
    if (unitName.present) {
      map['unit_name'] = Variable<String>(unitName.value);
    }
    if (providerUserId.present) {
      map['provider_user_id'] = Variable<String>(providerUserId.value);
    }
    if (providerName.present) {
      map['provider_name'] = Variable<String>(providerName.value);
    }
    if (chiefComplaint.present) {
      map['chief_complaint'] = Variable<String>(chiefComplaint.value);
    }
    if (triageCategory.present) {
      map['triage_category'] = Variable<String>(triageCategory.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<int>(synced.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (aiMetadata.present) {
      map['ai_metadata'] = Variable<String>(aiMetadata.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('EncountersCompanion(')
          ..write('id: $id, ')
          ..write('patientId: $patientId, ')
          ..write('encounterNo: $encounterNo, ')
          ..write('status: $status, ')
          ..write('type: $type, ')
          ..write('unitId: $unitId, ')
          ..write('unitName: $unitName, ')
          ..write('providerUserId: $providerUserId, ')
          ..write('providerName: $providerName, ')
          ..write('chiefComplaint: $chiefComplaint, ')
          ..write('triageCategory: $triageCategory, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('synced: $synced, ')
          ..write('syncState: $syncState, ')
          ..write('aiMetadata: $aiMetadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventsTable extends Events with TableInfo<$EventsTable, Event> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _encounterIdMeta =
      const VerificationMeta('encounterId');
  @override
  late final GeneratedColumn<String> encounterId = GeneratedColumn<String>(
      'encounter_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  static const VerificationMeta _bodyTextMeta =
      const VerificationMeta('bodyText');
  @override
  late final GeneratedColumn<String> bodyText = GeneratedColumn<String>(
      'body_text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _signedByMeta =
      const VerificationMeta('signedBy');
  @override
  late final GeneratedColumn<String> signedBy = GeneratedColumn<String>(
      'signed_by', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _signedAtMeta =
      const VerificationMeta('signedAt');
  @override
  late final GeneratedColumn<DateTime> signedAt = GeneratedColumn<DateTime>(
      'signed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<int> synced = GeneratedColumn<int>(
      'synced', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _syncStateMeta =
      const VerificationMeta('syncState');
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
      'sync_state', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        encounterId,
        kind,
        title,
        status,
        bodyText,
        payloadJson,
        createdBy,
        createdAt,
        signedBy,
        signedAt,
        synced,
        syncState
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'events';
  @override
  VerificationContext validateIntegrity(Insertable<Event> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('encounter_id')) {
      context.handle(
          _encounterIdMeta,
          encounterId.isAcceptableOrUnknown(
              data['encounter_id']!, _encounterIdMeta));
    } else if (isInserting) {
      context.missing(_encounterIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('body_text')) {
      context.handle(_bodyTextMeta,
          bodyText.isAcceptableOrUnknown(data['body_text']!, _bodyTextMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('signed_by')) {
      context.handle(_signedByMeta,
          signedBy.isAcceptableOrUnknown(data['signed_by']!, _signedByMeta));
    }
    if (data.containsKey('signed_at')) {
      context.handle(_signedAtMeta,
          signedAt.isAcceptableOrUnknown(data['signed_at']!, _signedAtMeta));
    }
    if (data.containsKey('synced')) {
      context.handle(_syncedMeta,
          synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta));
    }
    if (data.containsKey('sync_state')) {
      context.handle(_syncStateMeta,
          syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Event map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Event(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      encounterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}encounter_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      bodyText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body_text']),
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      signedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}signed_by']),
      signedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}signed_at']),
      synced: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}synced'])!,
      syncState: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_state'])!,
    );
  }

  @override
  $EventsTable createAlias(String alias) {
    return $EventsTable(attachedDatabase, alias);
  }
}

class Event extends DataClass implements Insertable<Event> {
  final String id;
  final String encounterId;
  final String kind;
  final String title;
  final String status;
  final String? bodyText;
  final String? payloadJson;
  final String? createdBy;
  final DateTime createdAt;
  final String? signedBy;
  final DateTime? signedAt;
  final int synced;
  final String syncState;
  const Event(
      {required this.id,
      required this.encounterId,
      required this.kind,
      required this.title,
      required this.status,
      this.bodyText,
      this.payloadJson,
      this.createdBy,
      required this.createdAt,
      this.signedBy,
      this.signedAt,
      required this.synced,
      required this.syncState});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['encounter_id'] = Variable<String>(encounterId);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || bodyText != null) {
      map['body_text'] = Variable<String>(bodyText);
    }
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || signedBy != null) {
      map['signed_by'] = Variable<String>(signedBy);
    }
    if (!nullToAbsent || signedAt != null) {
      map['signed_at'] = Variable<DateTime>(signedAt);
    }
    map['synced'] = Variable<int>(synced);
    map['sync_state'] = Variable<String>(syncState);
    return map;
  }

  EventsCompanion toCompanion(bool nullToAbsent) {
    return EventsCompanion(
      id: Value(id),
      encounterId: Value(encounterId),
      kind: Value(kind),
      title: Value(title),
      status: Value(status),
      bodyText: bodyText == null && nullToAbsent
          ? const Value.absent()
          : Value(bodyText),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      createdAt: Value(createdAt),
      signedBy: signedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(signedBy),
      signedAt: signedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(signedAt),
      synced: Value(synced),
      syncState: Value(syncState),
    );
  }

  factory Event.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Event(
      id: serializer.fromJson<String>(json['id']),
      encounterId: serializer.fromJson<String>(json['encounterId']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      bodyText: serializer.fromJson<String?>(json['bodyText']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      signedBy: serializer.fromJson<String?>(json['signedBy']),
      signedAt: serializer.fromJson<DateTime?>(json['signedAt']),
      synced: serializer.fromJson<int>(json['synced']),
      syncState: serializer.fromJson<String>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'encounterId': serializer.toJson<String>(encounterId),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'bodyText': serializer.toJson<String?>(bodyText),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'createdBy': serializer.toJson<String?>(createdBy),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'signedBy': serializer.toJson<String?>(signedBy),
      'signedAt': serializer.toJson<DateTime?>(signedAt),
      'synced': serializer.toJson<int>(synced),
      'syncState': serializer.toJson<String>(syncState),
    };
  }

  Event copyWith(
          {String? id,
          String? encounterId,
          String? kind,
          String? title,
          String? status,
          Value<String?> bodyText = const Value.absent(),
          Value<String?> payloadJson = const Value.absent(),
          Value<String?> createdBy = const Value.absent(),
          DateTime? createdAt,
          Value<String?> signedBy = const Value.absent(),
          Value<DateTime?> signedAt = const Value.absent(),
          int? synced,
          String? syncState}) =>
      Event(
        id: id ?? this.id,
        encounterId: encounterId ?? this.encounterId,
        kind: kind ?? this.kind,
        title: title ?? this.title,
        status: status ?? this.status,
        bodyText: bodyText.present ? bodyText.value : this.bodyText,
        payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
        createdBy: createdBy.present ? createdBy.value : this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        signedBy: signedBy.present ? signedBy.value : this.signedBy,
        signedAt: signedAt.present ? signedAt.value : this.signedAt,
        synced: synced ?? this.synced,
        syncState: syncState ?? this.syncState,
      );
  Event copyWithCompanion(EventsCompanion data) {
    return Event(
      id: data.id.present ? data.id.value : this.id,
      encounterId:
          data.encounterId.present ? data.encounterId.value : this.encounterId,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      bodyText: data.bodyText.present ? data.bodyText.value : this.bodyText,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      signedBy: data.signedBy.present ? data.signedBy.value : this.signedBy,
      signedAt: data.signedAt.present ? data.signedAt.value : this.signedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Event(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('bodyText: $bodyText, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('signedBy: $signedBy, ')
          ..write('signedAt: $signedAt, ')
          ..write('synced: $synced, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      encounterId,
      kind,
      title,
      status,
      bodyText,
      payloadJson,
      createdBy,
      createdAt,
      signedBy,
      signedAt,
      synced,
      syncState);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Event &&
          other.id == this.id &&
          other.encounterId == this.encounterId &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.status == this.status &&
          other.bodyText == this.bodyText &&
          other.payloadJson == this.payloadJson &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.signedBy == this.signedBy &&
          other.signedAt == this.signedAt &&
          other.synced == this.synced &&
          other.syncState == this.syncState);
}

class EventsCompanion extends UpdateCompanion<Event> {
  final Value<String> id;
  final Value<String> encounterId;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> status;
  final Value<String?> bodyText;
  final Value<String?> payloadJson;
  final Value<String?> createdBy;
  final Value<DateTime> createdAt;
  final Value<String?> signedBy;
  final Value<DateTime?> signedAt;
  final Value<int> synced;
  final Value<String> syncState;
  final Value<int> rowid;
  const EventsCompanion({
    this.id = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.bodyText = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.signedBy = const Value.absent(),
    this.signedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventsCompanion.insert({
    required String id,
    required String encounterId,
    required String kind,
    required String title,
    this.status = const Value.absent(),
    this.bodyText = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdBy = const Value.absent(),
    required DateTime createdAt,
    this.signedBy = const Value.absent(),
    this.signedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.syncState = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        encounterId = Value(encounterId),
        kind = Value(kind),
        title = Value(title),
        createdAt = Value(createdAt);
  static Insertable<Event> custom({
    Expression<String>? id,
    Expression<String>? encounterId,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? status,
    Expression<String>? bodyText,
    Expression<String>? payloadJson,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<String>? signedBy,
    Expression<DateTime>? signedAt,
    Expression<int>? synced,
    Expression<String>? syncState,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encounterId != null) 'encounter_id': encounterId,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (bodyText != null) 'body_text': bodyText,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (signedBy != null) 'signed_by': signedBy,
      if (signedAt != null) 'signed_at': signedAt,
      if (synced != null) 'synced': synced,
      if (syncState != null) 'sync_state': syncState,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventsCompanion copyWith(
      {Value<String>? id,
      Value<String>? encounterId,
      Value<String>? kind,
      Value<String>? title,
      Value<String>? status,
      Value<String?>? bodyText,
      Value<String?>? payloadJson,
      Value<String?>? createdBy,
      Value<DateTime>? createdAt,
      Value<String?>? signedBy,
      Value<DateTime?>? signedAt,
      Value<int>? synced,
      Value<String>? syncState,
      Value<int>? rowid}) {
    return EventsCompanion(
      id: id ?? this.id,
      encounterId: encounterId ?? this.encounterId,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      status: status ?? this.status,
      bodyText: bodyText ?? this.bodyText,
      payloadJson: payloadJson ?? this.payloadJson,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      signedBy: signedBy ?? this.signedBy,
      signedAt: signedAt ?? this.signedAt,
      synced: synced ?? this.synced,
      syncState: syncState ?? this.syncState,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (encounterId.present) {
      map['encounter_id'] = Variable<String>(encounterId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (bodyText.present) {
      map['body_text'] = Variable<String>(bodyText.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (signedBy.present) {
      map['signed_by'] = Variable<String>(signedBy.value);
    }
    if (signedAt.present) {
      map['signed_at'] = Variable<DateTime>(signedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<int>(synced.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventsCompanion(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('bodyText: $bodyText, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('signedBy: $signedBy, ')
          ..write('signedAt: $signedAt, ')
          ..write('synced: $synced, ')
          ..write('syncState: $syncState, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitsTable extends Units with TableInfo<$UnitsTable, Unit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _facilityMeta =
      const VerificationMeta('facility');
  @override
  late final GeneratedColumn<String> facility = GeneratedColumn<String>(
      'facility', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, code, name, facility, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units';
  @override
  VerificationContext validateIntegrity(Insertable<Unit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('facility')) {
      context.handle(_facilityMeta,
          facility.isAcceptableOrUnknown(data['facility']!, _facilityMeta));
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
  Unit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Unit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      facility: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}facility']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UnitsTable createAlias(String alias) {
    return $UnitsTable(attachedDatabase, alias);
  }
}

class Unit extends DataClass implements Insertable<Unit> {
  final String id;
  final String code;
  final String name;
  final String? facility;
  final DateTime createdAt;
  const Unit(
      {required this.id,
      required this.code,
      required this.name,
      this.facility,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || facility != null) {
      map['facility'] = Variable<String>(facility);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UnitsCompanion toCompanion(bool nullToAbsent) {
    return UnitsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      facility: facility == null && nullToAbsent
          ? const Value.absent()
          : Value(facility),
      createdAt: Value(createdAt),
    );
  }

  factory Unit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Unit(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      facility: serializer.fromJson<String?>(json['facility']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'facility': serializer.toJson<String?>(facility),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Unit copyWith(
          {String? id,
          String? code,
          String? name,
          Value<String?> facility = const Value.absent(),
          DateTime? createdAt}) =>
      Unit(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        facility: facility.present ? facility.value : this.facility,
        createdAt: createdAt ?? this.createdAt,
      );
  Unit copyWithCompanion(UnitsCompanion data) {
    return Unit(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      facility: data.facility.present ? data.facility.value : this.facility,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Unit(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('facility: $facility, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, name, facility, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Unit &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.facility == this.facility &&
          other.createdAt == this.createdAt);
}

class UnitsCompanion extends UpdateCompanion<Unit> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String?> facility;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UnitsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.facility = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitsCompanion.insert({
    required String id,
    required String code,
    required String name,
    this.facility = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        code = Value(code),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<Unit> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? facility,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (facility != null) 'facility': facility,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitsCompanion copyWith(
      {Value<String>? id,
      Value<String>? code,
      Value<String>? name,
      Value<String?>? facility,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return UnitsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      facility: facility ?? this.facility,
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
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (facility.present) {
      map['facility'] = Variable<String>(facility.value);
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
    return (StringBuffer('UnitsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('facility: $facility, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordSaltB64Meta =
      const VerificationMeta('passwordSaltB64');
  @override
  late final GeneratedColumn<String> passwordSaltB64 = GeneratedColumn<String>(
      'password_salt_b64', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordHashB64Meta =
      const VerificationMeta('passwordHashB64');
  @override
  late final GeneratedColumn<String> passwordHashB64 = GeneratedColumn<String>(
      'password_hash_b64', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordIterationsMeta =
      const VerificationMeta('passwordIterations');
  @override
  late final GeneratedColumn<int> passwordIterations = GeneratedColumn<int>(
      'password_iterations', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        username,
        displayName,
        role,
        passwordSaltB64,
        passwordHashB64,
        passwordIterations,
        isActive,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('password_salt_b64')) {
      context.handle(
          _passwordSaltB64Meta,
          passwordSaltB64.isAcceptableOrUnknown(
              data['password_salt_b64']!, _passwordSaltB64Meta));
    } else if (isInserting) {
      context.missing(_passwordSaltB64Meta);
    }
    if (data.containsKey('password_hash_b64')) {
      context.handle(
          _passwordHashB64Meta,
          passwordHashB64.isAcceptableOrUnknown(
              data['password_hash_b64']!, _passwordHashB64Meta));
    } else if (isInserting) {
      context.missing(_passwordHashB64Meta);
    }
    if (data.containsKey('password_iterations')) {
      context.handle(
          _passwordIterationsMeta,
          passwordIterations.isAcceptableOrUnknown(
              data['password_iterations']!, _passwordIterationsMeta));
    } else if (isInserting) {
      context.missing(_passwordIterationsMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
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
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name']),
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      passwordSaltB64: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}password_salt_b64'])!,
      passwordHashB64: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}password_hash_b64'])!,
      passwordIterations: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}password_iterations'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String username;
  final String? displayName;
  final String role;
  final String passwordSaltB64;
  final String passwordHashB64;
  final int passwordIterations;
  final bool isActive;
  final DateTime createdAt;
  const User(
      {required this.id,
      required this.username,
      this.displayName,
      required this.role,
      required this.passwordSaltB64,
      required this.passwordHashB64,
      required this.passwordIterations,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['username'] = Variable<String>(username);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['role'] = Variable<String>(role);
    map['password_salt_b64'] = Variable<String>(passwordSaltB64);
    map['password_hash_b64'] = Variable<String>(passwordHashB64);
    map['password_iterations'] = Variable<int>(passwordIterations);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      username: Value(username),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      role: Value(role),
      passwordSaltB64: Value(passwordSaltB64),
      passwordHashB64: Value(passwordHashB64),
      passwordIterations: Value(passwordIterations),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      role: serializer.fromJson<String>(json['role']),
      passwordSaltB64: serializer.fromJson<String>(json['passwordSaltB64']),
      passwordHashB64: serializer.fromJson<String>(json['passwordHashB64']),
      passwordIterations: serializer.fromJson<int>(json['passwordIterations']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'username': serializer.toJson<String>(username),
      'displayName': serializer.toJson<String?>(displayName),
      'role': serializer.toJson<String>(role),
      'passwordSaltB64': serializer.toJson<String>(passwordSaltB64),
      'passwordHashB64': serializer.toJson<String>(passwordHashB64),
      'passwordIterations': serializer.toJson<int>(passwordIterations),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  User copyWith(
          {String? id,
          String? username,
          Value<String?> displayName = const Value.absent(),
          String? role,
          String? passwordSaltB64,
          String? passwordHashB64,
          int? passwordIterations,
          bool? isActive,
          DateTime? createdAt}) =>
      User(
        id: id ?? this.id,
        username: username ?? this.username,
        displayName: displayName.present ? displayName.value : this.displayName,
        role: role ?? this.role,
        passwordSaltB64: passwordSaltB64 ?? this.passwordSaltB64,
        passwordHashB64: passwordHashB64 ?? this.passwordHashB64,
        passwordIterations: passwordIterations ?? this.passwordIterations,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      role: data.role.present ? data.role.value : this.role,
      passwordSaltB64: data.passwordSaltB64.present
          ? data.passwordSaltB64.value
          : this.passwordSaltB64,
      passwordHashB64: data.passwordHashB64.present
          ? data.passwordHashB64.value
          : this.passwordHashB64,
      passwordIterations: data.passwordIterations.present
          ? data.passwordIterations.value
          : this.passwordIterations,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('passwordSaltB64: $passwordSaltB64, ')
          ..write('passwordHashB64: $passwordHashB64, ')
          ..write('passwordIterations: $passwordIterations, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      username,
      displayName,
      role,
      passwordSaltB64,
      passwordHashB64,
      passwordIterations,
      isActive,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.username == this.username &&
          other.displayName == this.displayName &&
          other.role == this.role &&
          other.passwordSaltB64 == this.passwordSaltB64 &&
          other.passwordHashB64 == this.passwordHashB64 &&
          other.passwordIterations == this.passwordIterations &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> username;
  final Value<String?> displayName;
  final Value<String> role;
  final Value<String> passwordSaltB64;
  final Value<String> passwordHashB64;
  final Value<int> passwordIterations;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.displayName = const Value.absent(),
    this.role = const Value.absent(),
    this.passwordSaltB64 = const Value.absent(),
    this.passwordHashB64 = const Value.absent(),
    this.passwordIterations = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String username,
    this.displayName = const Value.absent(),
    required String role,
    required String passwordSaltB64,
    required String passwordHashB64,
    required int passwordIterations,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        username = Value(username),
        role = Value(role),
        passwordSaltB64 = Value(passwordSaltB64),
        passwordHashB64 = Value(passwordHashB64),
        passwordIterations = Value(passwordIterations),
        createdAt = Value(createdAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? username,
    Expression<String>? displayName,
    Expression<String>? role,
    Expression<String>? passwordSaltB64,
    Expression<String>? passwordHashB64,
    Expression<int>? passwordIterations,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (displayName != null) 'display_name': displayName,
      if (role != null) 'role': role,
      if (passwordSaltB64 != null) 'password_salt_b64': passwordSaltB64,
      if (passwordHashB64 != null) 'password_hash_b64': passwordHashB64,
      if (passwordIterations != null) 'password_iterations': passwordIterations,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith(
      {Value<String>? id,
      Value<String>? username,
      Value<String?>? displayName,
      Value<String>? role,
      Value<String>? passwordSaltB64,
      Value<String>? passwordHashB64,
      Value<int>? passwordIterations,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return UsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      passwordSaltB64: passwordSaltB64 ?? this.passwordSaltB64,
      passwordHashB64: passwordHashB64 ?? this.passwordHashB64,
      passwordIterations: passwordIterations ?? this.passwordIterations,
      isActive: isActive ?? this.isActive,
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
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (passwordSaltB64.present) {
      map['password_salt_b64'] = Variable<String>(passwordSaltB64.value);
    }
    if (passwordHashB64.present) {
      map['password_hash_b64'] = Variable<String>(passwordHashB64.value);
    }
    if (passwordIterations.present) {
      map['password_iterations'] = Variable<int>(passwordIterations.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
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
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('passwordSaltB64: $passwordSaltB64, ')
          ..write('passwordHashB64: $passwordHashB64, ')
          ..write('passwordIterations: $passwordIterations, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserUnitsTable extends UserUnits
    with TableInfo<$UserUnitsTable, UserUnit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserUnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _unitIdMeta = const VerificationMeta('unitId');
  @override
  late final GeneratedColumn<String> unitId = GeneratedColumn<String>(
      'unit_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [userId, unitId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_units';
  @override
  VerificationContext validateIntegrity(Insertable<UserUnit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('unit_id')) {
      context.handle(_unitIdMeta,
          unitId.isAcceptableOrUnknown(data['unit_id']!, _unitIdMeta));
    } else if (isInserting) {
      context.missing(_unitIdMeta);
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
  Set<GeneratedColumn> get $primaryKey => {userId, unitId};
  @override
  UserUnit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserUnit(
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      unitId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UserUnitsTable createAlias(String alias) {
    return $UserUnitsTable(attachedDatabase, alias);
  }
}

class UserUnit extends DataClass implements Insertable<UserUnit> {
  final String userId;
  final String unitId;
  final DateTime createdAt;
  const UserUnit(
      {required this.userId, required this.unitId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_id'] = Variable<String>(userId);
    map['unit_id'] = Variable<String>(unitId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserUnitsCompanion toCompanion(bool nullToAbsent) {
    return UserUnitsCompanion(
      userId: Value(userId),
      unitId: Value(unitId),
      createdAt: Value(createdAt),
    );
  }

  factory UserUnit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserUnit(
      userId: serializer.fromJson<String>(json['userId']),
      unitId: serializer.fromJson<String>(json['unitId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userId': serializer.toJson<String>(userId),
      'unitId': serializer.toJson<String>(unitId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserUnit copyWith({String? userId, String? unitId, DateTime? createdAt}) =>
      UserUnit(
        userId: userId ?? this.userId,
        unitId: unitId ?? this.unitId,
        createdAt: createdAt ?? this.createdAt,
      );
  UserUnit copyWithCompanion(UserUnitsCompanion data) {
    return UserUnit(
      userId: data.userId.present ? data.userId.value : this.userId,
      unitId: data.unitId.present ? data.unitId.value : this.unitId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserUnit(')
          ..write('userId: $userId, ')
          ..write('unitId: $unitId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userId, unitId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserUnit &&
          other.userId == this.userId &&
          other.unitId == this.unitId &&
          other.createdAt == this.createdAt);
}

class UserUnitsCompanion extends UpdateCompanion<UserUnit> {
  final Value<String> userId;
  final Value<String> unitId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserUnitsCompanion({
    this.userId = const Value.absent(),
    this.unitId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserUnitsCompanion.insert({
    required String userId,
    required String unitId,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : userId = Value(userId),
        unitId = Value(unitId),
        createdAt = Value(createdAt);
  static Insertable<UserUnit> custom({
    Expression<String>? userId,
    Expression<String>? unitId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userId != null) 'user_id': userId,
      if (unitId != null) 'unit_id': unitId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserUnitsCompanion copyWith(
      {Value<String>? userId,
      Value<String>? unitId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return UserUnitsCompanion(
      userId: userId ?? this.userId,
      unitId: unitId ?? this.unitId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (unitId.present) {
      map['unit_id'] = Variable<String>(unitId.value);
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
    return (StringBuffer('UserUnitsCompanion(')
          ..write('userId: $userId, ')
          ..write('unitId: $unitId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EncounterDraftsTable extends EncounterDrafts
    with TableInfo<$EncounterDraftsTable, EncounterDraft> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncounterDraftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _encounterIdMeta =
      const VerificationMeta('encounterId');
  @override
  late final GeneratedColumn<String> encounterId = GeneratedColumn<String>(
      'encounter_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patientIdMeta =
      const VerificationMeta('patientId');
  @override
  late final GeneratedColumn<String> patientId = GeneratedColumn<String>(
      'patient_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
      'kind', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('registration'));
  static const VerificationMeta _payloadJsonMeta =
      const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
      'payload_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  @override
  List<GeneratedColumn> get $columns =>
      [id, encounterId, patientId, kind, payloadJson, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encounter_drafts';
  @override
  VerificationContext validateIntegrity(Insertable<EncounterDraft> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('encounter_id')) {
      context.handle(
          _encounterIdMeta,
          encounterId.isAcceptableOrUnknown(
              data['encounter_id']!, _encounterIdMeta));
    } else if (isInserting) {
      context.missing(_encounterIdMeta);
    }
    if (data.containsKey('patient_id')) {
      context.handle(_patientIdMeta,
          patientId.isAcceptableOrUnknown(data['patient_id']!, _patientIdMeta));
    } else if (isInserting) {
      context.missing(_patientIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
          _kindMeta, kind.isAcceptableOrUnknown(data['kind']!, _kindMeta));
    }
    if (data.containsKey('payload_json')) {
      context.handle(
          _payloadJsonMeta,
          payloadJson.isAcceptableOrUnknown(
              data['payload_json']!, _payloadJsonMeta));
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EncounterDraft map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EncounterDraft(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      encounterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}encounter_id'])!,
      patientId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}patient_id'])!,
      kind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}kind'])!,
      payloadJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload_json'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $EncounterDraftsTable createAlias(String alias) {
    return $EncounterDraftsTable(attachedDatabase, alias);
  }
}

class EncounterDraft extends DataClass implements Insertable<EncounterDraft> {
  final String id;
  final String encounterId;
  final String patientId;
  final String kind;
  final String payloadJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EncounterDraft(
      {required this.id,
      required this.encounterId,
      required this.patientId,
      required this.kind,
      required this.payloadJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['encounter_id'] = Variable<String>(encounterId);
    map['patient_id'] = Variable<String>(patientId);
    map['kind'] = Variable<String>(kind);
    map['payload_json'] = Variable<String>(payloadJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EncounterDraftsCompanion toCompanion(bool nullToAbsent) {
    return EncounterDraftsCompanion(
      id: Value(id),
      encounterId: Value(encounterId),
      patientId: Value(patientId),
      kind: Value(kind),
      payloadJson: Value(payloadJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EncounterDraft.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EncounterDraft(
      id: serializer.fromJson<String>(json['id']),
      encounterId: serializer.fromJson<String>(json['encounterId']),
      patientId: serializer.fromJson<String>(json['patientId']),
      kind: serializer.fromJson<String>(json['kind']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'encounterId': serializer.toJson<String>(encounterId),
      'patientId': serializer.toJson<String>(patientId),
      'kind': serializer.toJson<String>(kind),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EncounterDraft copyWith(
          {String? id,
          String? encounterId,
          String? patientId,
          String? kind,
          String? payloadJson,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      EncounterDraft(
        id: id ?? this.id,
        encounterId: encounterId ?? this.encounterId,
        patientId: patientId ?? this.patientId,
        kind: kind ?? this.kind,
        payloadJson: payloadJson ?? this.payloadJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  EncounterDraft copyWithCompanion(EncounterDraftsCompanion data) {
    return EncounterDraft(
      id: data.id.present ? data.id.value : this.id,
      encounterId:
          data.encounterId.present ? data.encounterId.value : this.encounterId,
      patientId: data.patientId.present ? data.patientId.value : this.patientId,
      kind: data.kind.present ? data.kind.value : this.kind,
      payloadJson:
          data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EncounterDraft(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('patientId: $patientId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, encounterId, patientId, kind, payloadJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EncounterDraft &&
          other.id == this.id &&
          other.encounterId == this.encounterId &&
          other.patientId == this.patientId &&
          other.kind == this.kind &&
          other.payloadJson == this.payloadJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EncounterDraftsCompanion extends UpdateCompanion<EncounterDraft> {
  final Value<String> id;
  final Value<String> encounterId;
  final Value<String> patientId;
  final Value<String> kind;
  final Value<String> payloadJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EncounterDraftsCompanion({
    this.id = const Value.absent(),
    this.encounterId = const Value.absent(),
    this.patientId = const Value.absent(),
    this.kind = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EncounterDraftsCompanion.insert({
    required String id,
    required String encounterId,
    required String patientId,
    this.kind = const Value.absent(),
    required String payloadJson,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        encounterId = Value(encounterId),
        patientId = Value(patientId),
        payloadJson = Value(payloadJson),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<EncounterDraft> custom({
    Expression<String>? id,
    Expression<String>? encounterId,
    Expression<String>? patientId,
    Expression<String>? kind,
    Expression<String>? payloadJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encounterId != null) 'encounter_id': encounterId,
      if (patientId != null) 'patient_id': patientId,
      if (kind != null) 'kind': kind,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EncounterDraftsCompanion copyWith(
      {Value<String>? id,
      Value<String>? encounterId,
      Value<String>? patientId,
      Value<String>? kind,
      Value<String>? payloadJson,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return EncounterDraftsCompanion(
      id: id ?? this.id,
      encounterId: encounterId ?? this.encounterId,
      patientId: patientId ?? this.patientId,
      kind: kind ?? this.kind,
      payloadJson: payloadJson ?? this.payloadJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (encounterId.present) {
      map['encounter_id'] = Variable<String>(encounterId.value);
    }
    if (patientId.present) {
      map['patient_id'] = Variable<String>(patientId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('EncounterDraftsCompanion(')
          ..write('id: $id, ')
          ..write('encounterId: $encounterId, ')
          ..write('patientId: $patientId, ')
          ..write('kind: $kind, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PatientsTable patients = $PatientsTable(this);
  late final $EncountersTable encounters = $EncountersTable(this);
  late final $EventsTable events = $EventsTable(this);
  late final $UnitsTable units = $UnitsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $UserUnitsTable userUnits = $UserUnitsTable(this);
  late final $EncounterDraftsTable encounterDrafts =
      $EncounterDraftsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [patients, encounters, events, units, users, userUnits, encounterDrafts];
}

typedef $$PatientsTableCreateCompanionBuilder = PatientsCompanion Function({
  required String id,
  Value<String?> mrn,
  required String fullName,
  required String fullNameNorm,
  required String nric,
  required String nricHash,
  Value<String?> gender,
  Value<DateTime?> dob,
  Value<String?> phone,
  Value<String?> address,
  Value<String?> allergies,
  Value<String> consentStatus,
  Value<String> source,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PatientsTableUpdateCompanionBuilder = PatientsCompanion Function({
  Value<String> id,
  Value<String?> mrn,
  Value<String> fullName,
  Value<String> fullNameNorm,
  Value<String> nric,
  Value<String> nricHash,
  Value<String?> gender,
  Value<DateTime?> dob,
  Value<String?> phone,
  Value<String?> address,
  Value<String?> allergies,
  Value<String> consentStatus,
  Value<String> source,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PatientsTableFilterComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mrn => $composableBuilder(
      column: $table.mrn, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullNameNorm => $composableBuilder(
      column: $table.fullNameNorm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nric => $composableBuilder(
      column: $table.nric, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nricHash => $composableBuilder(
      column: $table.nricHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dob => $composableBuilder(
      column: $table.dob, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get allergies => $composableBuilder(
      column: $table.allergies, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get consentStatus => $composableBuilder(
      column: $table.consentStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PatientsTableOrderingComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mrn => $composableBuilder(
      column: $table.mrn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullNameNorm => $composableBuilder(
      column: $table.fullNameNorm,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nric => $composableBuilder(
      column: $table.nric, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nricHash => $composableBuilder(
      column: $table.nricHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get gender => $composableBuilder(
      column: $table.gender, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dob => $composableBuilder(
      column: $table.dob, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get address => $composableBuilder(
      column: $table.address, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allergies => $composableBuilder(
      column: $table.allergies, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get consentStatus => $composableBuilder(
      column: $table.consentStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PatientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PatientsTable> {
  $$PatientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mrn =>
      $composableBuilder(column: $table.mrn, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get fullNameNorm => $composableBuilder(
      column: $table.fullNameNorm, builder: (column) => column);

  GeneratedColumn<String> get nric =>
      $composableBuilder(column: $table.nric, builder: (column) => column);

  GeneratedColumn<String> get nricHash =>
      $composableBuilder(column: $table.nricHash, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get dob =>
      $composableBuilder(column: $table.dob, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get allergies =>
      $composableBuilder(column: $table.allergies, builder: (column) => column);

  GeneratedColumn<String> get consentStatus => $composableBuilder(
      column: $table.consentStatus, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PatientsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PatientsTable,
    Patient,
    $$PatientsTableFilterComposer,
    $$PatientsTableOrderingComposer,
    $$PatientsTableAnnotationComposer,
    $$PatientsTableCreateCompanionBuilder,
    $$PatientsTableUpdateCompanionBuilder,
    (Patient, BaseReferences<_$AppDatabase, $PatientsTable, Patient>),
    Patient,
    PrefetchHooks Function()> {
  $$PatientsTableTableManager(_$AppDatabase db, $PatientsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PatientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PatientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PatientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> mrn = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String> fullNameNorm = const Value.absent(),
            Value<String> nric = const Value.absent(),
            Value<String> nricHash = const Value.absent(),
            Value<String?> gender = const Value.absent(),
            Value<DateTime?> dob = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> allergies = const Value.absent(),
            Value<String> consentStatus = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsCompanion(
            id: id,
            mrn: mrn,
            fullName: fullName,
            fullNameNorm: fullNameNorm,
            nric: nric,
            nricHash: nricHash,
            gender: gender,
            dob: dob,
            phone: phone,
            address: address,
            allergies: allergies,
            consentStatus: consentStatus,
            source: source,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> mrn = const Value.absent(),
            required String fullName,
            required String fullNameNorm,
            required String nric,
            required String nricHash,
            Value<String?> gender = const Value.absent(),
            Value<DateTime?> dob = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> address = const Value.absent(),
            Value<String?> allergies = const Value.absent(),
            Value<String> consentStatus = const Value.absent(),
            Value<String> source = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              PatientsCompanion.insert(
            id: id,
            mrn: mrn,
            fullName: fullName,
            fullNameNorm: fullNameNorm,
            nric: nric,
            nricHash: nricHash,
            gender: gender,
            dob: dob,
            phone: phone,
            address: address,
            allergies: allergies,
            consentStatus: consentStatus,
            source: source,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PatientsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PatientsTable,
    Patient,
    $$PatientsTableFilterComposer,
    $$PatientsTableOrderingComposer,
    $$PatientsTableAnnotationComposer,
    $$PatientsTableCreateCompanionBuilder,
    $$PatientsTableUpdateCompanionBuilder,
    (Patient, BaseReferences<_$AppDatabase, $PatientsTable, Patient>),
    Patient,
    PrefetchHooks Function()>;
typedef $$EncountersTableCreateCompanionBuilder = EncountersCompanion Function({
  required String id,
  required String patientId,
  Value<String?> encounterNo,
  Value<String> status,
  Value<String> type,
  Value<String?> unitId,
  Value<String> unitName,
  Value<String?> providerUserId,
  Value<String?> providerName,
  Value<String?> chiefComplaint,
  Value<String?> triageCategory,
  required DateTime startAt,
  Value<DateTime?> endAt,
  Value<int> synced,
  Value<String> syncState,
  Value<String?> aiMetadata,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$EncountersTableUpdateCompanionBuilder = EncountersCompanion Function({
  Value<String> id,
  Value<String> patientId,
  Value<String?> encounterNo,
  Value<String> status,
  Value<String> type,
  Value<String?> unitId,
  Value<String> unitName,
  Value<String?> providerUserId,
  Value<String?> providerName,
  Value<String?> chiefComplaint,
  Value<String?> triageCategory,
  Value<DateTime> startAt,
  Value<DateTime?> endAt,
  Value<int> synced,
  Value<String> syncState,
  Value<String?> aiMetadata,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$EncountersTableFilterComposer
    extends Composer<_$AppDatabase, $EncountersTable> {
  $$EncountersTableFilterComposer({
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

  ColumnFilters<String> get encounterNo => $composableBuilder(
      column: $table.encounterNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitName => $composableBuilder(
      column: $table.unitName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerUserId => $composableBuilder(
      column: $table.providerUserId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get providerName => $composableBuilder(
      column: $table.providerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get chiefComplaint => $composableBuilder(
      column: $table.chiefComplaint,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get triageCategory => $composableBuilder(
      column: $table.triageCategory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aiMetadata => $composableBuilder(
      column: $table.aiMetadata, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$EncountersTableOrderingComposer
    extends Composer<_$AppDatabase, $EncountersTable> {
  $$EncountersTableOrderingComposer({
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

  ColumnOrderings<String> get encounterNo => $composableBuilder(
      column: $table.encounterNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitName => $composableBuilder(
      column: $table.unitName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerUserId => $composableBuilder(
      column: $table.providerUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get providerName => $composableBuilder(
      column: $table.providerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get chiefComplaint => $composableBuilder(
      column: $table.chiefComplaint,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get triageCategory => $composableBuilder(
      column: $table.triageCategory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aiMetadata => $composableBuilder(
      column: $table.aiMetadata, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$EncountersTableAnnotationComposer
    extends Composer<_$AppDatabase, $EncountersTable> {
  $$EncountersTableAnnotationComposer({
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

  GeneratedColumn<String> get encounterNo => $composableBuilder(
      column: $table.encounterNo, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<String> get unitName =>
      $composableBuilder(column: $table.unitName, builder: (column) => column);

  GeneratedColumn<String> get providerUserId => $composableBuilder(
      column: $table.providerUserId, builder: (column) => column);

  GeneratedColumn<String> get providerName => $composableBuilder(
      column: $table.providerName, builder: (column) => column);

  GeneratedColumn<String> get chiefComplaint => $composableBuilder(
      column: $table.chiefComplaint, builder: (column) => column);

  GeneratedColumn<String> get triageCategory => $composableBuilder(
      column: $table.triageCategory, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<int> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get aiMetadata => $composableBuilder(
      column: $table.aiMetadata, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EncountersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EncountersTable,
    Encounter,
    $$EncountersTableFilterComposer,
    $$EncountersTableOrderingComposer,
    $$EncountersTableAnnotationComposer,
    $$EncountersTableCreateCompanionBuilder,
    $$EncountersTableUpdateCompanionBuilder,
    (Encounter, BaseReferences<_$AppDatabase, $EncountersTable, Encounter>),
    Encounter,
    PrefetchHooks Function()> {
  $$EncountersTableTableManager(_$AppDatabase db, $EncountersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncountersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncountersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncountersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<String?> encounterNo = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> unitId = const Value.absent(),
            Value<String> unitName = const Value.absent(),
            Value<String?> providerUserId = const Value.absent(),
            Value<String?> providerName = const Value.absent(),
            Value<String?> chiefComplaint = const Value.absent(),
            Value<String?> triageCategory = const Value.absent(),
            Value<DateTime> startAt = const Value.absent(),
            Value<DateTime?> endAt = const Value.absent(),
            Value<int> synced = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<String?> aiMetadata = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EncountersCompanion(
            id: id,
            patientId: patientId,
            encounterNo: encounterNo,
            status: status,
            type: type,
            unitId: unitId,
            unitName: unitName,
            providerUserId: providerUserId,
            providerName: providerName,
            chiefComplaint: chiefComplaint,
            triageCategory: triageCategory,
            startAt: startAt,
            endAt: endAt,
            synced: synced,
            syncState: syncState,
            aiMetadata: aiMetadata,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String patientId,
            Value<String?> encounterNo = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> unitId = const Value.absent(),
            Value<String> unitName = const Value.absent(),
            Value<String?> providerUserId = const Value.absent(),
            Value<String?> providerName = const Value.absent(),
            Value<String?> chiefComplaint = const Value.absent(),
            Value<String?> triageCategory = const Value.absent(),
            required DateTime startAt,
            Value<DateTime?> endAt = const Value.absent(),
            Value<int> synced = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<String?> aiMetadata = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              EncountersCompanion.insert(
            id: id,
            patientId: patientId,
            encounterNo: encounterNo,
            status: status,
            type: type,
            unitId: unitId,
            unitName: unitName,
            providerUserId: providerUserId,
            providerName: providerName,
            chiefComplaint: chiefComplaint,
            triageCategory: triageCategory,
            startAt: startAt,
            endAt: endAt,
            synced: synced,
            syncState: syncState,
            aiMetadata: aiMetadata,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EncountersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EncountersTable,
    Encounter,
    $$EncountersTableFilterComposer,
    $$EncountersTableOrderingComposer,
    $$EncountersTableAnnotationComposer,
    $$EncountersTableCreateCompanionBuilder,
    $$EncountersTableUpdateCompanionBuilder,
    (Encounter, BaseReferences<_$AppDatabase, $EncountersTable, Encounter>),
    Encounter,
    PrefetchHooks Function()>;
typedef $$EventsTableCreateCompanionBuilder = EventsCompanion Function({
  required String id,
  required String encounterId,
  required String kind,
  required String title,
  Value<String> status,
  Value<String?> bodyText,
  Value<String?> payloadJson,
  Value<String?> createdBy,
  required DateTime createdAt,
  Value<String?> signedBy,
  Value<DateTime?> signedAt,
  Value<int> synced,
  Value<String> syncState,
  Value<int> rowid,
});
typedef $$EventsTableUpdateCompanionBuilder = EventsCompanion Function({
  Value<String> id,
  Value<String> encounterId,
  Value<String> kind,
  Value<String> title,
  Value<String> status,
  Value<String?> bodyText,
  Value<String?> payloadJson,
  Value<String?> createdBy,
  Value<DateTime> createdAt,
  Value<String?> signedBy,
  Value<DateTime?> signedAt,
  Value<int> synced,
  Value<String> syncState,
  Value<int> rowid,
});

class $$EventsTableFilterComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encounterId => $composableBuilder(
      column: $table.encounterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bodyText => $composableBuilder(
      column: $table.bodyText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get signedBy => $composableBuilder(
      column: $table.signedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get signedAt => $composableBuilder(
      column: $table.signedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnFilters(column));
}

class $$EventsTableOrderingComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encounterId => $composableBuilder(
      column: $table.encounterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bodyText => $composableBuilder(
      column: $table.bodyText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get signedBy => $composableBuilder(
      column: $table.signedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get signedAt => $composableBuilder(
      column: $table.signedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get synced => $composableBuilder(
      column: $table.synced, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncState => $composableBuilder(
      column: $table.syncState, builder: (column) => ColumnOrderings(column));
}

class $$EventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EventsTable> {
  $$EventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get encounterId => $composableBuilder(
      column: $table.encounterId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get bodyText =>
      $composableBuilder(column: $table.bodyText, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get signedBy =>
      $composableBuilder(column: $table.signedBy, builder: (column) => column);

  GeneratedColumn<DateTime> get signedAt =>
      $composableBuilder(column: $table.signedAt, builder: (column) => column);

  GeneratedColumn<int> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);
}

class $$EventsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
    Event,
    PrefetchHooks Function()> {
  $$EventsTableTableManager(_$AppDatabase db, $EventsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> encounterId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> bodyText = const Value.absent(),
            Value<String?> payloadJson = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> signedBy = const Value.absent(),
            Value<DateTime?> signedAt = const Value.absent(),
            Value<int> synced = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion(
            id: id,
            encounterId: encounterId,
            kind: kind,
            title: title,
            status: status,
            bodyText: bodyText,
            payloadJson: payloadJson,
            createdBy: createdBy,
            createdAt: createdAt,
            signedBy: signedBy,
            signedAt: signedAt,
            synced: synced,
            syncState: syncState,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String encounterId,
            required String kind,
            required String title,
            Value<String> status = const Value.absent(),
            Value<String?> bodyText = const Value.absent(),
            Value<String?> payloadJson = const Value.absent(),
            Value<String?> createdBy = const Value.absent(),
            required DateTime createdAt,
            Value<String?> signedBy = const Value.absent(),
            Value<DateTime?> signedAt = const Value.absent(),
            Value<int> synced = const Value.absent(),
            Value<String> syncState = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EventsCompanion.insert(
            id: id,
            encounterId: encounterId,
            kind: kind,
            title: title,
            status: status,
            bodyText: bodyText,
            payloadJson: payloadJson,
            createdBy: createdBy,
            createdAt: createdAt,
            signedBy: signedBy,
            signedAt: signedAt,
            synced: synced,
            syncState: syncState,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EventsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EventsTable,
    Event,
    $$EventsTableFilterComposer,
    $$EventsTableOrderingComposer,
    $$EventsTableAnnotationComposer,
    $$EventsTableCreateCompanionBuilder,
    $$EventsTableUpdateCompanionBuilder,
    (Event, BaseReferences<_$AppDatabase, $EventsTable, Event>),
    Event,
    PrefetchHooks Function()>;
typedef $$UnitsTableCreateCompanionBuilder = UnitsCompanion Function({
  required String id,
  required String code,
  required String name,
  Value<String?> facility,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$UnitsTableUpdateCompanionBuilder = UnitsCompanion Function({
  Value<String> id,
  Value<String> code,
  Value<String> name,
  Value<String?> facility,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$UnitsTableFilterComposer extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get facility => $composableBuilder(
      column: $table.facility, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$UnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get facility => $composableBuilder(
      column: $table.facility, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get facility =>
      $composableBuilder(column: $table.facility, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UnitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UnitsTable,
    Unit,
    $$UnitsTableFilterComposer,
    $$UnitsTableOrderingComposer,
    $$UnitsTableAnnotationComposer,
    $$UnitsTableCreateCompanionBuilder,
    $$UnitsTableUpdateCompanionBuilder,
    (Unit, BaseReferences<_$AppDatabase, $UnitsTable, Unit>),
    Unit,
    PrefetchHooks Function()> {
  $$UnitsTableTableManager(_$AppDatabase db, $UnitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> facility = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UnitsCompanion(
            id: id,
            code: code,
            name: name,
            facility: facility,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String code,
            required String name,
            Value<String?> facility = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UnitsCompanion.insert(
            id: id,
            code: code,
            name: name,
            facility: facility,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UnitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UnitsTable,
    Unit,
    $$UnitsTableFilterComposer,
    $$UnitsTableOrderingComposer,
    $$UnitsTableAnnotationComposer,
    $$UnitsTableCreateCompanionBuilder,
    $$UnitsTableUpdateCompanionBuilder,
    (Unit, BaseReferences<_$AppDatabase, $UnitsTable, Unit>),
    Unit,
    PrefetchHooks Function()>;
typedef $$UsersTableCreateCompanionBuilder = UsersCompanion Function({
  required String id,
  required String username,
  Value<String?> displayName,
  required String role,
  required String passwordSaltB64,
  required String passwordHashB64,
  required int passwordIterations,
  Value<bool> isActive,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$UsersTableUpdateCompanionBuilder = UsersCompanion Function({
  Value<String> id,
  Value<String> username,
  Value<String?> displayName,
  Value<String> role,
  Value<String> passwordSaltB64,
  Value<String> passwordHashB64,
  Value<int> passwordIterations,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordSaltB64 => $composableBuilder(
      column: $table.passwordSaltB64,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHashB64 => $composableBuilder(
      column: $table.passwordHashB64,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get passwordIterations => $composableBuilder(
      column: $table.passwordIterations,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordSaltB64 => $composableBuilder(
      column: $table.passwordSaltB64,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHashB64 => $composableBuilder(
      column: $table.passwordHashB64,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get passwordIterations => $composableBuilder(
      column: $table.passwordIterations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get passwordSaltB64 => $composableBuilder(
      column: $table.passwordSaltB64, builder: (column) => column);

  GeneratedColumn<String> get passwordHashB64 => $composableBuilder(
      column: $table.passwordHashB64, builder: (column) => column);

  GeneratedColumn<int> get passwordIterations => $composableBuilder(
      column: $table.passwordIterations, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()> {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> username = const Value.absent(),
            Value<String?> displayName = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> passwordSaltB64 = const Value.absent(),
            Value<String> passwordHashB64 = const Value.absent(),
            Value<int> passwordIterations = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion(
            id: id,
            username: username,
            displayName: displayName,
            role: role,
            passwordSaltB64: passwordSaltB64,
            passwordHashB64: passwordHashB64,
            passwordIterations: passwordIterations,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String username,
            Value<String?> displayName = const Value.absent(),
            required String role,
            required String passwordSaltB64,
            required String passwordHashB64,
            required int passwordIterations,
            Value<bool> isActive = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UsersCompanion.insert(
            id: id,
            username: username,
            displayName: displayName,
            role: role,
            passwordSaltB64: passwordSaltB64,
            passwordHashB64: passwordHashB64,
            passwordIterations: passwordIterations,
            isActive: isActive,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UsersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UsersTable,
    User,
    $$UsersTableFilterComposer,
    $$UsersTableOrderingComposer,
    $$UsersTableAnnotationComposer,
    $$UsersTableCreateCompanionBuilder,
    $$UsersTableUpdateCompanionBuilder,
    (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
    User,
    PrefetchHooks Function()>;
typedef $$UserUnitsTableCreateCompanionBuilder = UserUnitsCompanion Function({
  required String userId,
  required String unitId,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$UserUnitsTableUpdateCompanionBuilder = UserUnitsCompanion Function({
  Value<String> userId,
  Value<String> unitId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$UserUnitsTableFilterComposer
    extends Composer<_$AppDatabase, $UserUnitsTable> {
  $$UserUnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$UserUnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserUnitsTable> {
  $$UserUnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unitId => $composableBuilder(
      column: $table.unitId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UserUnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserUnitsTable> {
  $$UserUnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get unitId =>
      $composableBuilder(column: $table.unitId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserUnitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserUnitsTable,
    UserUnit,
    $$UserUnitsTableFilterComposer,
    $$UserUnitsTableOrderingComposer,
    $$UserUnitsTableAnnotationComposer,
    $$UserUnitsTableCreateCompanionBuilder,
    $$UserUnitsTableUpdateCompanionBuilder,
    (UserUnit, BaseReferences<_$AppDatabase, $UserUnitsTable, UserUnit>),
    UserUnit,
    PrefetchHooks Function()> {
  $$UserUnitsTableTableManager(_$AppDatabase db, $UserUnitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserUnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserUnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserUnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> userId = const Value.absent(),
            Value<String> unitId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserUnitsCompanion(
            userId: userId,
            unitId: unitId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String userId,
            required String unitId,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserUnitsCompanion.insert(
            userId: userId,
            unitId: unitId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserUnitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserUnitsTable,
    UserUnit,
    $$UserUnitsTableFilterComposer,
    $$UserUnitsTableOrderingComposer,
    $$UserUnitsTableAnnotationComposer,
    $$UserUnitsTableCreateCompanionBuilder,
    $$UserUnitsTableUpdateCompanionBuilder,
    (UserUnit, BaseReferences<_$AppDatabase, $UserUnitsTable, UserUnit>),
    UserUnit,
    PrefetchHooks Function()>;
typedef $$EncounterDraftsTableCreateCompanionBuilder = EncounterDraftsCompanion
    Function({
  required String id,
  required String encounterId,
  required String patientId,
  Value<String> kind,
  required String payloadJson,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$EncounterDraftsTableUpdateCompanionBuilder = EncounterDraftsCompanion
    Function({
  Value<String> id,
  Value<String> encounterId,
  Value<String> patientId,
  Value<String> kind,
  Value<String> payloadJson,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$EncounterDraftsTableFilterComposer
    extends Composer<_$AppDatabase, $EncounterDraftsTable> {
  $$EncounterDraftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get encounterId => $composableBuilder(
      column: $table.encounterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$EncounterDraftsTableOrderingComposer
    extends Composer<_$AppDatabase, $EncounterDraftsTable> {
  $$EncounterDraftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get encounterId => $composableBuilder(
      column: $table.encounterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get patientId => $composableBuilder(
      column: $table.patientId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kind => $composableBuilder(
      column: $table.kind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$EncounterDraftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EncounterDraftsTable> {
  $$EncounterDraftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get encounterId => $composableBuilder(
      column: $table.encounterId, builder: (column) => column);

  GeneratedColumn<String> get patientId =>
      $composableBuilder(column: $table.patientId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
      column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EncounterDraftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EncounterDraftsTable,
    EncounterDraft,
    $$EncounterDraftsTableFilterComposer,
    $$EncounterDraftsTableOrderingComposer,
    $$EncounterDraftsTableAnnotationComposer,
    $$EncounterDraftsTableCreateCompanionBuilder,
    $$EncounterDraftsTableUpdateCompanionBuilder,
    (
      EncounterDraft,
      BaseReferences<_$AppDatabase, $EncounterDraftsTable, EncounterDraft>
    ),
    EncounterDraft,
    PrefetchHooks Function()> {
  $$EncounterDraftsTableTableManager(
      _$AppDatabase db, $EncounterDraftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncounterDraftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncounterDraftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncounterDraftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> encounterId = const Value.absent(),
            Value<String> patientId = const Value.absent(),
            Value<String> kind = const Value.absent(),
            Value<String> payloadJson = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EncounterDraftsCompanion(
            id: id,
            encounterId: encounterId,
            patientId: patientId,
            kind: kind,
            payloadJson: payloadJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String encounterId,
            required String patientId,
            Value<String> kind = const Value.absent(),
            required String payloadJson,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              EncounterDraftsCompanion.insert(
            id: id,
            encounterId: encounterId,
            patientId: patientId,
            kind: kind,
            payloadJson: payloadJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EncounterDraftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EncounterDraftsTable,
    EncounterDraft,
    $$EncounterDraftsTableFilterComposer,
    $$EncounterDraftsTableOrderingComposer,
    $$EncounterDraftsTableAnnotationComposer,
    $$EncounterDraftsTableCreateCompanionBuilder,
    $$EncounterDraftsTableUpdateCompanionBuilder,
    (
      EncounterDraft,
      BaseReferences<_$AppDatabase, $EncounterDraftsTable, EncounterDraft>
    ),
    EncounterDraft,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db, _db.patients);
  $$EncountersTableTableManager get encounters =>
      $$EncountersTableTableManager(_db, _db.encounters);
  $$EventsTableTableManager get events =>
      $$EventsTableTableManager(_db, _db.events);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db, _db.units);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$UserUnitsTableTableManager get userUnits =>
      $$UserUnitsTableTableManager(_db, _db.userUnits);
  $$EncounterDraftsTableTableManager get encounterDrafts =>
      $$EncounterDraftsTableTableManager(_db, _db.encounterDrafts);
}
