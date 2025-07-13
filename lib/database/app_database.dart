// lib/database/app_database.dart
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart'; // For mobile (Android/iOS)
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'ecotrack.sqlite'));
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // If you update your schemaVersion in future, handle upgrades here
      // For development, you can reset the table like this:
      await m.deleteTable('users');
      await m.createAll();
    },
    beforeOpen: (details) async {
      // Optional: seed data or setup here
    },
  );

  // Insert new user
  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  // Get user by email
  Future<User?> getUserByEmail(String email) {
    return (select(users)
      ..where((u) => u.email.equals(email))).getSingleOrNull();
  }

  // Get all users
  Future<List<User>> getAllUsers() => select(users).get();
}
