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

  // NEW (nullable so older rows are fine)
  TextColumn get gender => text().nullable()(); // "M" / "F" / "Other"
  DateTimeColumn get dob => dateTime().nullable()();
  TextColumn get phone => text().nullable()();

  TextColumn get address => text().nullable()();
  TextColumn get allergies => text().nullable()();

  TextColumn get consentStatus => text().withDefault(const Constant('unknown'))();
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

  TextColumn get status => text().withDefault(const Constant('open'))(); // open/closed/cancelled
  TextColumn get type => text().withDefault(const Constant('OPD'))(); // ED/OPD/IP/HomeVisit/Tele

  TextColumn get unitId => text().nullable()();
  TextColumn get unitName => text().withDefault(const Constant('Unknown Unit'))();

  TextColumn get providerUserId => text().nullable()();
  TextColumn get providerName => text().nullable()();

  TextColumn get chiefComplaint => text().nullable()();
  TextColumn get triageCategory => text().nullable()();

  DateTimeColumn get startAt => dateTime()();
  DateTimeColumn get endAt => dateTime().nullable()();

  IntColumn get synced => integer().withDefault(const Constant(0))(); // 0/1
  TextColumn get syncState => text().withDefault(const Constant('pending'))(); // pending/synced/conflict
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
  TextColumn get status => text().withDefault(const Constant('draft'))(); // draft/signed/cancelled

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
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get facility => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Users extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get username => text()(); // unique
  TextColumn get displayName => text().nullable()();
  TextColumn get role => text()(); // "clinician", "admin", etc.

  TextColumn get passwordSaltB64 => text()();
  TextColumn get passwordHashB64 => text()();
  IntColumn get passwordIterations => integer()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserUnits extends Table {
  TextColumn get userId => text()();
  TextColumn get unitId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {userId, unitId};
}

/// NEW: Draft/autosave snapshots for encounter workflow (Option A).
class EncounterDrafts extends Table {
  TextColumn get id => text()(); // UUID

  // drift will name these columns encounter_id / patient_id in SQL
  TextColumn get encounterId => text()();
  TextColumn get patientId => text()();

  TextColumn get kind => text().withDefault(const Constant('registration'))();

  TextColumn get payloadJson => text()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// -----------------------------
/// Database
/// -----------------------------

@DriftDatabase(
  tables: [
    Patients,
    Encounters,
    Events,
    Units,
    Users,
    UserUnits,
    EncounterDrafts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal() : super(_openConnection());

  static final AppDatabase instance = AppDatabase._internal();

  static Future<void> initialize() async {
    await instance.customSelect('SELECT 1').get();
  }

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'pulseedge.db'));
      return NativeDatabase(file, logStatements: false);
    });
  }

  // bumped because we're adding columns + a new table + indexes
  @override
  int get schemaVersion => 5;

  Future<void> _ensureEncounterDraftsSchema() async {
    // Does table exist?
    final tbl = await customSelect(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='encounter_drafts'",
    ).get();

    if (tbl.isEmpty) {
      // Create in SQL to be resilient even if drift thinks it's mid-migration.
      await customStatement('''
        CREATE TABLE IF NOT EXISTS encounter_drafts (
          id TEXT NOT NULL PRIMARY KEY,
          encounter_id TEXT NOT NULL,
          patient_id TEXT NOT NULL,
          kind TEXT NOT NULL DEFAULT 'registration',
          payload_json TEXT NOT NULL,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');
    } else {
      // Patch missing columns if the table already exists (your current situation).
      final cols = await customSelect("PRAGMA table_info('encounter_drafts')").get();
      final existing = cols.map((r) => (r.data['name'] as String?) ?? '').toSet();

      Future<void> addIfMissing(String col, String sqlTypeAndDefault) async {
        if (!existing.contains(col)) {
          await customStatement(
            "ALTER TABLE encounter_drafts ADD COLUMN $col $sqlTypeAndDefault",
          );
        }
      }

      await addIfMissing('encounter_id', "TEXT NOT NULL DEFAULT ''");
      await addIfMissing('patient_id', "TEXT NOT NULL DEFAULT ''");
      await addIfMissing('kind', "TEXT NOT NULL DEFAULT 'registration'");
      await addIfMissing('payload_json', "TEXT NOT NULL DEFAULT '{}'");
      await addIfMissing('created_at', "INTEGER NOT NULL DEFAULT 0");
      await addIfMissing('updated_at', "INTEGER NOT NULL DEFAULT 0");
    }

    // Create indexes only AFTER the columns are guaranteed to exist.
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_encounter_drafts_encounter ON encounter_drafts(encounter_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_encounter_drafts_patient ON encounter_drafts(patient_id)',
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _ensureEncounterDraftsSchema();
        },
        onUpgrade: (m, from, to) async {
          // Add nullable patient demographic columns safely
          if (from < 5) {
            // only add if not already present; drift will throw if duplicated, so guard with try.
            try {
              await m.addColumn(patients, patients.gender);
            } catch (_) {}
            try {
              await m.addColumn(patients, patients.dob);
            } catch (_) {}
            try {
              await m.addColumn(patients, patients.phone);
            } catch (_) {}
          }

          // Ensure all declared tables exist (won't add missing columns)
          await m.createAll();

          // Fix/patch encounter_drafts + indexes even if a bad version already exists
          await _ensureEncounterDraftsSchema();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
          await customStatement('PRAGMA journal_mode = WAL;');
        },
      );
}