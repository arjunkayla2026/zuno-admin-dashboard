import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/firestore_failures.dart';
import 'package:zuno_admin_dashboard/core/data/search_keywords.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/resources/strings/app_strings.dart';

class RecordPageQuery {
  const RecordPageQuery({this.term, this.from, this.until, this.cursor});

  static const int pageSize = 10;

  final String? term;
  final DateTime? from;
  final DateTime? until;
  final Object? cursor;
}

class RecordPage<T> {
  const RecordPage(this.items, {this.nextCursor});

  final List<T> items;
  final Object? nextCursor;

  RecordPage<R> mapItems<R>(List<R> Function(List<T> items) transform) =>
      RecordPage(transform(items), nextCursor: nextCursor);
}

abstract final class RecordPages {
  static const String _defaultSortField = 'updatedAt';

  static Query<Map<String, dynamic>> _filtered(
    Query<Map<String, dynamic>> base,
    RecordPageQuery page,
    String sortField, {
    bool descending = true,
  }) {
    var query = base;
    if (page.term case final term?) {
      query = query.where(SearchKeywords.field, arrayContains: term);
    }
    if (page.from case final from?) {
      query = query.where(
        sortField,
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }
    if (page.until case final until?) {
      query = query.where(sortField, isLessThan: Timestamp.fromDate(until));
    }
    return query.orderBy(sortField, descending: descending);
  }

  static Future<Either<Failure, RecordPage<R>>> fetch<R>(
    Query<Map<String, dynamic>> base,
    RecordPageQuery page,
    R Function(String id, Map<String, dynamic> data) toRecord, {
    String sortField = _defaultSortField,
    int pageSize = RecordPageQuery.pageSize,
    bool descending = true,
  }) async {
    try {
      var query = _filtered(
        base,
        page,
        sortField,
        descending: descending,
      ).limit(pageSize);
      if (page.cursor case final DocumentSnapshot cursor) {
        query = query.startAfterDocument(cursor);
      }
      final snapshot = await query.get();
      final documents = snapshot.docs;
      return right(
        RecordPage(
          [
            for (final document in documents)
              toRecord(document.id, document.data()),
          ],
          nextCursor: documents.length == pageSize ? documents.last : null,
        ),
      );
    } on FirebaseException catch (error) {
      debugPrint('Firestore read failed [${error.code}]: ${error.message}');
      return left(FirestoreFailures.read(error.code));
    } catch (error, stackTrace) {
      debugPrint('Record load failed: $error $stackTrace');
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }

  static Future<Either<Failure, RecordPage<T>>> untilMatch<R, T>(
    Object? cursor,
    Future<Either<Failure, RecordPage<R>>> Function(Object? cursor) fetchBatch,
    Iterable<T> Function(List<R> batch) select,
  ) async {
    final matches = <T>[];
    var next = cursor;
    do {
      final result = await fetchBatch(next);
      switch (result) {
        case Left(value: final failure):
          return left(failure);
        case Right(value: final batch):
          matches.addAll(select(batch.items));
          next = batch.nextCursor;
      }
    } while (matches.isEmpty && next != null);
    return right(RecordPage(matches, nextCursor: next));
  }

  static Future<Either<Failure, int>> count(
    Query<Map<String, dynamic>> base,
    RecordPageQuery page,
  ) async {
    try {
      final snapshot = await _filtered(
        base,
        page,
        _defaultSortField,
      ).count().get();
      return right(snapshot.count ?? 0);
    } on FirebaseException catch (error) {
      debugPrint('Firestore read failed [${error.code}]: ${error.message}');
      return left(FirestoreFailures.read(error.code));
    } catch (error, stackTrace) {
      debugPrint('Record load failed: $error $stackTrace');
      return left(const DataFailure(AppStrings.recordsLoadFailed));
    }
  }
}
