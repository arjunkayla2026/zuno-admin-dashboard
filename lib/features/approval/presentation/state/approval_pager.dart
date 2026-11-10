import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';

class ApprovalFilter {
  const ApprovalFilter({this.term, this.from, this.until});

  final String? term;
  final DateTime? from;
  final DateTime? until;

  bool get isEmpty => term == null && from == null && until == null;

  String get key =>
      '$term|${from?.millisecondsSinceEpoch}|${until?.millisecondsSinceEpoch}';

  RecordPageQuery query({Object? cursor}) =>
      RecordPageQuery(term: term, from: from, until: until, cursor: cursor);
}

class ApprovalPaging {
  const ApprovalPaging({this.page = 1, this.totalPages = 1, this.total = 0});

  final int page;
  final int totalPages;
  final int total;

  int get firstIndex => (page - 1) * RecordPageQuery.pageSize;
}

class ApprovalPageView<T> {
  const ApprovalPageView({
    required this.items,
    required this.status,
    required this.paging,
    this.error,
    this.unfilteredTotal,
  });

  final List<T> items;
  final LoadStatus status;
  final ApprovalPaging paging;
  final String? error;
  final int? unfilteredTotal;
}

class _PagerEntry<T> {
  _PagerEntry(this.fetchedAt, {required this.isUnfiltered});

  final DateTime fetchedAt;
  final bool isUnfiltered;
  final List<List<T>> pages = [];
  final List<Object?> nextCursors = [];
  int? total;

  bool get hasNext => nextCursors.isNotEmpty && nextCursors.last != null;
}

class ApprovalPager<T> {
  ApprovalPager({
    required this.fetch,
    required this.count,
    required this.onChanged,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  static const int _maxEntries = 12;
  static const Duration _timeToLive = Duration(minutes: 2);

  final Future<Either<Failure, RecordPage<T>>> Function(RecordPageQuery) fetch;
  final Future<Either<Failure, int>> Function(RecordPageQuery) count;
  final void Function(ApprovalPageView<T> view) onChanged;
  final DateTime Function() _now;

  final Map<String, _PagerEntry<T>> _entries = {};
  int _latestRequest = 0;
  String? _inFlight;
  String? _key;
  int _page = 1;

  String? get appliedKey => _key;

  int get page => _page;

  Future<void> show(
    ApprovalFilter filter, {
    int page = 1,
    bool force = false,
  }) async {
    final key = filter.key;
    if (force) _entries.remove(key);

    final cached = _freshEntry(key);
    if (cached != null && page <= cached.pages.length) {
      _latestRequest++;
      _inFlight = null;
      _key = key;
      _page = page;
      onChanged(_loadedView(cached));
      return;
    }

    final targetPage = cached == null ? 1 : page;
    if (targetPage > 1 && !cached!.hasNext) return;

    final requestId = '$key#$targetPage';
    if (_inFlight == requestId) return;

    final request = ++_latestRequest;
    _inFlight = requestId;
    _key = key;
    _page = targetPage;
    onChanged(
      ApprovalPageView(
        items: List<T>.empty(),
        status: LoadStatus.loading,
        paging: ApprovalPaging(page: targetPage),
      ),
    );

    final entry =
        cached ?? _PagerEntry<T>(_now(), isUnfiltered: filter.isEmpty);
    final cursor = targetPage == 1 ? null : entry.nextCursors.last;
    final totalRequest = entry.total == null && filter.isEmpty
        ? count(filter.query())
        : null;
    final result = await fetch(filter.query(cursor: cursor));
    final totalResult = await totalRequest;

    if (_inFlight == requestId) _inFlight = null;
    if (request != _latestRequest) return;

    result.match(
      (failure) => onChanged(
        ApprovalPageView(
          items: List<T>.empty(),
          status: LoadStatus.failure,
          paging: ApprovalPaging(page: targetPage),
          error: failure.message,
        ),
      ),
      (loaded) {
        entry.total ??= totalResult?.toNullable();
        if (targetPage > 1 && loaded.items.isEmpty) {
          entry.nextCursors.last = null;
          _page = targetPage - 1;
        } else {
          entry.pages.add(loaded.items);
          entry.nextCursors.add(loaded.nextCursor);
        }
        _remember(key, entry);
        onChanged(_loadedView(entry));
      },
    );
  }

  void update(T Function(T item) transform) {
    for (final entry in _entries.values) {
      for (var index = 0; index < entry.pages.length; index++) {
        entry.pages[index] = entry.pages[index].map(transform).toList();
      }
    }
    final current = _entries[_key];
    if (current != null && _inFlight == null && _page <= current.pages.length) {
      onChanged(_loadedView(current, includeUnfilteredTotal: false));
    }
  }

  void recordDecision() {
    for (final entry in _entries.values) {
      final total = entry.total;
      if (entry.isUnfiltered && total != null && total > 0) {
        entry.total = total - 1;
      }
    }
  }

  _PagerEntry<T>? _freshEntry(String key) {
    final entry = _entries[key];
    if (entry == null) return null;
    if (_now().difference(entry.fetchedAt) <= _timeToLive) return entry;
    _entries.remove(key);
    return null;
  }

  void _remember(String key, _PagerEntry<T> entry) {
    _entries
      ..remove(key)
      ..[key] = entry;
    if (_entries.length > _maxEntries) _entries.remove(_entries.keys.first);
  }

  ApprovalPageView<T> _loadedView(
    _PagerEntry<T> entry, {
    bool includeUnfilteredTotal = true,
  }) {
    final items = entry.pages.isEmpty ? <T>[] : entry.pages[_page - 1];
    final firstIndex = (_page - 1) * RecordPageQuery.pageSize;
    return ApprovalPageView(
      items: items,
      status: LoadStatus.loaded,
      paging: ApprovalPaging(
        page: _page,
        totalPages: entry.pages.length + (entry.hasNext ? 1 : 0),
        total: entry.total ?? firstIndex + items.length,
      ),
      unfilteredTotal: includeUnfilteredTotal && entry.isUnfiltered
          ? entry.total
          : null,
    );
  }
}
