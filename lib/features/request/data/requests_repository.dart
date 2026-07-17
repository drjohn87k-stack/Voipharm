import 'package:sqflite/sqflite.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/database/database_helper.dart';
import '../domain/request_entity.dart';
import '../domain/request_item_entity.dart';

/// Repository for requests + request_items tables.
///
/// Persists request headers and their line items, supports loading
/// sessions grouped by date (history), and full save/load cycles.
class RequestsRepository {
  RequestsRepository._();
  static final RequestsRepository instance = RequestsRepository._();

  /// Save a request (header + items). If [request.id] is null a new row
  /// is inserted, otherwise the header is updated and items replaced.
  /// Returns the request id.
  Future<int> saveRequest(RequestEntity request) async {
    final db = await DatabaseHelper.instance.database();
    final now = DateTime.now().toIso8601String();
    final headerMap = request.toHeaderMap();

    int requestId;
    if (request.id == null) {
      headerMap['createdAt'] = now;
      headerMap['updatedAt'] = now;
      requestId = await db.insert(
        AppConstants.tableRequests,
        headerMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      requestId = request.id!;
      headerMap['updatedAt'] = now;
      await db.update(
        AppConstants.tableRequests,
        headerMap,
        where: 'id = ?',
        whereArgs: [requestId],
      );
      // Remove old items
      await db.delete(
        AppConstants.tableRequestItems,
        where: 'requestId = ?',
        whereArgs: [requestId],
      );
    }

    // Insert items
    final batch = db.batch();
    for (var i = 0; i < request.items.length; i++) {
      final item = request.items[i];
      batch.insert(
        AppConstants.tableRequestItems,
        {
          'requestId': requestId,
          'itemId': item.itemId,
          'itemName': item.itemName,
          'quantity': item.quantity,
          'notes': item.notes,
          'orderIndex': i,
        },
      );
    }
    await batch.commit(noResult: true);
    return requestId;
  }

  /// Load a single request with its items.
  Future<RequestEntity?> getRequest(int id) async {
    final db = await DatabaseHelper.instance.database();
    final headers = await db.query(
      AppConstants.tableRequests,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (headers.isEmpty) return null;
    final items = await db.query(
      AppConstants.tableRequestItems,
      where: 'requestId = ?',
      whereArgs: [id],
      orderBy: 'orderIndex ASC',
    );
    return RequestEntity.fromMap(
      headers.first,
      items: items.map(RequestItemEntity.fromMap).toList(),
    );
  }

  /// Load all requests ordered by date descending (most recent first).
  Future<List<RequestEntity>> allRequests() async {
    final db = await DatabaseHelper.instance.database();
    final headers = await db.query(
      AppConstants.tableRequests,
      orderBy: 'date DESC, updatedAt DESC',
    );
    final result = <RequestEntity>[];
    for (final h in headers) {
      final id = h['id'] as int;
      final items = await db.query(
        AppConstants.tableRequestItems,
        where: 'requestId = ?',
        whereArgs: [id],
        orderBy: 'orderIndex ASC',
      );
      result.add(RequestEntity.fromMap(
        h,
        items: items.map(RequestItemEntity.fromMap).toList(),
      ));
    }
    return result;
  }

  /// Delete a request and its items (cascade).
  Future<void> deleteRequest(int id) async {
    final db = await DatabaseHelper.instance.database();
    await db.delete(
      AppConstants.tableRequests,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Count of saved requests.
  Future<int> count() async {
    final db = await DatabaseHelper.instance.database();
    return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM ${AppConstants.tableRequests}')) ??
        0;
  }
}
