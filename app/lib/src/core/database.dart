import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_sqlcipher/sqflite.dart';

class LocalDatabase {
  LocalDatabase({FlutterSecureStorage? secureStorage}) : _secureStorage = secureStorage ?? const FlutterSecureStorage();
  final FlutterSecureStorage _secureStorage;
  Database? _db;

  Future<Database> open() async {
    if (_db != null) return _db!;
    final root = await getDatabasesPath();
    final path = p.join(root, 'vytra.db');
    var key = await _secureStorage.read(key: 'vytra_sqlcipher_key');
    if (key == null) {
      key = base64Url.encode(List<int>.generate(32, (i) => DateTime.now().microsecondsSinceEpoch.hashCode ^ (i * 7919)));
      await _secureStorage.write(key: 'vytra_sqlcipher_key', value: key);
    }
    _db = await openDatabase(path, password: key, version: 1, onCreate: (db, _) async {
      await db.execute('''CREATE TABLE screenings (
        screening_id TEXT PRIMARY KEY, captured_at TEXT NOT NULL,
        anemia_risk TEXT NOT NULL, jaundice_risk TEXT NOT NULL,
        anemia_a_star REAL, jaundice_b_star REAL,
        valid_anemia_count INTEGER NOT NULL DEFAULT 0,
        valid_jaundice_count INTEGER NOT NULL DEFAULT 0,
        final_quality_score REAL, algorithm_version TEXT NOT NULL,
        threshold_version TEXT NOT NULL, app_version TEXT NOT NULL,
        device_model TEXT, fitzpatrick_scale INTEGER,
        fitzpatrick_assessment_method TEXT, ambient_lighting TEXT,
        sync_status TEXT NOT NULL DEFAULT 'PENDING', consent_recorded_at TEXT NOT NULL
      )''');
      await db.execute('''CREATE TABLE captures (
        capture_id TEXT PRIMARY KEY, screening_id TEXT NOT NULL,
        series TEXT NOT NULL, capture_index INTEGER NOT NULL,
        blur_score REAL, exposure_score REAL, eye_openness_score REAL,
        roi_quality_score REAL, white_reference_score REAL,
        anemia_a_star REAL, jaundice_b_star REAL, l_star REAL,
        valid INTEGER NOT NULL DEFAULT 0, rejection_reason TEXT,
        mesh_used INTEGER NOT NULL DEFAULT 0, captured_at TEXT NOT NULL,
        UNIQUE(screening_id, series, capture_index)
      )''');
      await db.execute('CREATE INDEX idx_screenings_captured_at ON screenings(captured_at)');
      await db.execute('CREATE INDEX idx_screenings_sync ON screenings(sync_status)');
    });
    return _db!;
  }

  Future<void> writeScreening({required Map<String, Object?> screening, required List<Map<String, Object?>> captures}) async {
    final db = await open();
    await db.transaction((txn) async {
      await txn.insert('screenings', screening, conflictAlgorithm: ConflictAlgorithm.replace);
      for (final capture in captures) {
        await txn.insert('captures', capture, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<int> deleteEligible({DateTime? now}) async {
    final db = await open();
    final cutoff = (now ?? DateTime.now()).subtract(const Duration(days: 30)).toIso8601String();
    return db.delete('screenings', where: 'captured_at < ?', whereArgs: [cutoff]);
  }

  Future<List<Map<String, Object?>>> pendingScreenings() async {
    final db = await open();
    return db.query('screenings', where: "sync_status IN ('PENDING','FAILED')", orderBy: 'captured_at ASC');
  }

  Future<void> close() async { await _db?.close(); _db = null; }
}
