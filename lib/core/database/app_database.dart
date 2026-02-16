// lib/core/database/app_database.dart
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// -----------------------------
/// Tables
/// -----------------------------

class Patients extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get mrn => text().nullable()(); // hospital MRN

  TextColumn get fullName => text()();
  TextColumn get fullNameNorm => text()(); // normalized

  TextColumn get nric => text()(); // normalized NRIC
  TextColumn get nricHash => text()(); // SHA-256 hex

  TextColumn get address => text().nullable()();
  TextColumn get allergies => text().nullable()();

  TextColumn get consentStatus =>
      text().withDefault(const Constant('unknown'))();
  TextColumn get source => text().withDefault(const Constant('local'))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Encounters extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get patientId => text()(); // FK -> Patients.id

  TextColumn get encounterNo => text().nullable()(); // HIS number when synced

  TextColumn get status =>
      text().withDefault(const Constant('open'))(); // open/closed/cancelled
  TextColumn get type =>
      text().withDefault(const Constant('OPD'))(); // ED/OPD/IP/HomeVisit/Tele

  TextColumn get unitId => text().nullable()();
  TextColumn get unitName =>
      text().withDefault(const Constant('Unknown Unit'))();

  TextColumn get providerUserId => text().nullable()();
  TextColumn get providerName => text().nullable()();

  TextColumn get chiefComplaint => text().nullable()();
  TextColumn get triageCategory => text().nullable()();

  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime().nullable()();

  IntColumn get synced => integer().withDefault(const Constant(0))(); // 0/1
  TextColumn get syncState =>
      text().withDefault(const Constant('pending'))(); // pending/synced/conflict
  TextColumn get aiMetadata => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Events extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get encounterId => text()(); // FK -> Encounters.id

  TextColumn get kind => text()(); // NOTE | ORDER | DOC | VITALS | ...
  TextColumn get title => text()();
  TextColumn get status =>
      text().withDefault(const Constant('draft'))(); // draft/signed/cancelled

  TextColumn get bodyText => text().nullable()(); // quick text store (notes)
  TextColumn get payloadJson => text().nullable()(); // module-specific json

  TextColumn get createdBy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  TextColumn get signedBy => text().nullable()();
  DateTimeColumn get signedAt => dateTime().nullable()();

  IntColumn get synced => integer().withDefault(const Constant(0))();
  TextColumn get syncState => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class Units extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get code => text()(); // e.g. "BINTULU_OUTREACH_A"
  TextColumn get name => text()(); // e.g. "Bintulu Outreach Team A"
  TextColumn get facility => text().nullable()(); // optional
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Users extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get username => text()(); // unique
  TextColumn get displayName => text().nullable()();
  TextColumn get role => text()(); // "clinician", "admin", etc.

  // Password storage (PBKDF2 – base64 fields)
  TextColumn get passwordSaltB64 => text()();
  TextColumn get passwordHashB64 => text()();
  IntColumn get passwordIterations => integer()();

  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))(); // Drift wants Value<bool> in companions

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Many-to-many: which user belongs to which unit(s)
class UserUnits extends Table {
  TextColumn get userId => text()();
  TextColumn get unitId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId, unitId};
}

/// -----------------------------
/// Database
/// -----------------------------

@DriftDatabase(tables: [Patients, Encounters, Events, Units, Users, UserUnits])
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  /// Singleton instance (used by AuthService, AnalyticsEngine, etc.)
  static final AppDatabase instance = AppDatabase._internal();

  /// Call once at app start.
  /// This guarantees the DB file exists, migrations run, and pragmas are applied.
  static Future<void> initialize() async {
    // Touch the DB to force open + run migrations.
    await instance.customSelect('SELECT 1').get();
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'pulseedge.db'));
      return NativeDatabase(
        file,
        logStatements: false,
      );
    });
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Keep upgrades safe for MVP:
          // - Create missing tables/columns when possible
          // - Avoid destructive deletes here (deletes cause data loss).
          //
          // If you later do breaking schema changes, we’ll write explicit
          // migrations and data backfills per version.
          await m.createAll();
        },
        beforeOpen: (details) async {
          // Good defaults for correctness.
          await customStatement('PRAGMA foreign_keys = ON;');
          await customStatement('PRAGMA journal_mode = WAL;');

          // NOTE:
          // Do NOT seed users/passwords here.
          // AuthService.initialize()/ensureSeedAdmin() should handle that,
          // so we never write non-base64 placeholders (prevents the
          // "Invalid encoding before padding" login issue).
        },
      );
}