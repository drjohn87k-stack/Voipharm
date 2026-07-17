import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_helper.dart';
import '../domain/medical_item.dart';

/// Repository for the master `medical_items` table.
///
/// Handles CRUD, fuzzy/text search, and first-run seeding from the
/// bundled JSON asset (`assets/seed/master_items.json`).
class ItemsRepository {
  ItemsRepository._();
  static final ItemsRepository instance = ItemsRepository._();

  bool _seeded = false;

  /// Ensure the master list is populated on first launch.
  Future<void> ensureSeeded() async {
    if (_seeded) return;
    final db = await DatabaseHelper.instance.database();
    final count = Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableMedicalItems}')) ??
        0;
    if (count == 0) {
      await _seedFromAsset();
    }
    _seeded = true;
  }

  Future<void> _seedFromAsset() async {
    final db = await DatabaseHelper.instance.database();
    final raw = await rootBundle.loadString(AppConstants.assetMasterItems);
    final list = jsonDecode(raw) as List<dynamic>;
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final item in list) {
      final map = item as Map<String, dynamic>;
      batch.insert(
        AppConstants.tableMedicalItems,
        {
          'itemName': map['itemName'] as String,
          'category': map['category'] as String?,
          'createdAt': now,
          'updatedAt': now,
        },
      );
    }
    await batch.commit(noResult: true);
  }

  /// Insert a single custom item.
  Future<int> insert(MedicalItem item) async {
    final db = await DatabaseHelper.instance.database();
    return db.insert(AppConstants.tableMedicalItems, item.toMap());
  }

  /// Get all items (use sparingly — the list is large).
  Future<List<MedicalItem>> all() async {
    final db = await DatabaseHelper.instance.database();
    final rows = await db.query(
      AppConstants.tableMedicalItems,
      orderBy: 'itemName ASC',
    );
    return rows.map(MedicalItem.fromMap).toList();
  }

  /// Total count of master items.
  Future<int> count() async {
    final db = await DatabaseHelper.instance.database();
    return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableMedicalItems}')) ??
        0;
  }

  /// SQL LIKE search (fast prefix/contains). Returns up to [limit] hits.
  Future<List<MedicalItem>> search(String query, {int limit = 50}) async {
    final db = await DatabaseHelper.instance.database();
    final q = query.trim();
    if (q.isEmpty) {
      final rows = await db.query(
        AppConstants.tableMedicalItems,
        orderBy: 'itemName ASC',
        limit: limit,
      );
      return rows.map(MedicalItem.fromMap).toList();
    }
    final rows = await db.query(
      AppConstants.tableMedicalItems,
      where: 'itemName LIKE ?',
      whereArgs: ['%$q%'],
      orderBy: 'itemName ASC',
      limit: limit,
    );
    return rows.map(MedicalItem.fromMap).toList();
  }

  /// Replace the entire master list (used by "replace" import mode).
  Future<void> replaceAll(List<MedicalItem> items) async {
    final db = await DatabaseHelper.instance.database();
    await db.transaction((txn) async {
      await txn.delete(AppConstants.tableMedicalItems);
      final now = DateTime.now().toIso8601String();
      final batch = txn.batch();
      for (final item in items) {
        batch.insert(AppConstants.tableMedicalItems, {
          'itemName': item.itemName,
          'category': item.category,
          'createdAt': item.createdAt.isEmpty ? now : item.createdAt,
          'updatedAt': now,
        });
      }
      await batch.commit(noResult: true);
    });
    _seeded = true;
  }

  /// Merge new items into the existing list (used by "merge" import mode).
  Future<int> mergeMany(List<MedicalItem> items) async {
    final db = await DatabaseHelper.instance.database();
    final existing = (await all()).map((e) => e.itemName.toLowerCase()).toSet();
    final now = DateTime.now().toIso8601String();
    int added = 0;
    final batch = db.batch();
    for (final item in items) {
      if (existing.contains(item.itemName.toLowerCase())) continue;
      batch.insert(AppConstants.tableMedicalItems, {
        'itemName': item.itemName,
        'category': item.category,
        'createdAt': now,
        'updatedAt': now,
      });
      existing.add(item.itemName.toLowerCase());
      added++;
    }
    await batch.commit(noResult: true);
    return added;
  }

  Future<void> delete(int id) async {
    final db = await DatabaseHelper.instance.database();
    await db.delete(
      AppConstants.tableMedicalItems,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
