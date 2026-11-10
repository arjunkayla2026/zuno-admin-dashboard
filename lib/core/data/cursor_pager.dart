import 'dart:math';

import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';

class CursorPageView<T> {
  const CursorPageView({
    required this.items,
    required this.status,
    required this.page,
    this.totalPages = 1,
    this.firstIndex = 0,
    this.error,
  });

  final List<T> items;
  final LoadStatus status;
  final int page;
  final int totalPages;
  final int firstIndex;
  final String? error;
}

class CursorPager<T extends Object> {
  CursorPager({required this.fetch, required this.onChanged});

  final Future<Either<Failure, RecordPage<T>>> Function(Object? cursor) fetch;
  final void Function(CursorPageView<T> view) onChanged;

  final List<List<T>> _pages = [];
  final List<Object?> _cursors = [];
  LoadStatus _status = LoadStatus.loading;
  int _latestRequest = 0;
  bool _isLoading = false;
  int _page = 1;

  bool get _hasNext => _cursors.isNotEmpty && _cursors.last != null;

  int get _knownPages => max(1, _pages.length + (_hasNext ? 1 : 0));

  Future<void> load() async {
    if (_isLoading || _status == LoadStatus.loaded) return;
    await _load();
  }

  Future<void> reset() {
    _pages.clear();
    _cursors.clear();
    return _load();
  }

  void goToPage(int page) {
    if (_isLoading || page == _page) return;
    if (page <= _pages.length) {
      _show(page);
    } else if (page == _pages.length + 1 && _hasNext) {
      _load();
    }
  }

  void update(T? Function(T item) transform) {
    for (var index = 0; index < _pages.length; index++) {
      _pages[index] = [for (final item in _pages[index]) ?transform(item)];
    }

    Object? droppedCursor;
    final emptied = _pages.indexWhere((rows) => rows.isEmpty);
    if (emptied >= 0) {
      _pages.removeAt(emptied);
      droppedCursor = _cursors.removeAt(emptied);
      if (emptied > 0) _cursors[emptied - 1] = droppedCursor;
    }

    if (_isLoading || _status != LoadStatus.loaded) return;
    if (_pages.isEmpty && droppedCursor != null) {
      _load();
      return;
    }
    final page = min(_page, _knownPages);
    if (page > _pages.length && _hasNext) {
      _load();
    } else {
      _show(page);
    }
  }

  Future<void> _load() async {
    final request = ++_latestRequest;
    _isLoading = true;
    _status = LoadStatus.loading;
    _page = _pages.length + 1;
    onChanged(
      CursorPageView(
        items: List<T>.empty(),
        status: LoadStatus.loading,
        page: _page,
      ),
    );

    final result = await fetch(_cursors.isEmpty ? null : _cursors.last);
    if (request != _latestRequest) return;
    _isLoading = false;

    result.match(
      (failure) {
        _status = LoadStatus.failure;
        onChanged(
          CursorPageView(
            items: List<T>.empty(),
            status: LoadStatus.failure,
            page: _page,
            error: failure.message,
          ),
        );
      },
      (loaded) {
        if (loaded.items.isEmpty) {
          if (_cursors.isNotEmpty) _cursors.last = null;
          _show(max(1, _pages.length));
          return;
        }
        _pages.add(loaded.items);
        _cursors.add(loaded.nextCursor);
        _show(_pages.length);
      },
    );
  }

  void _show(int page) {
    _status = LoadStatus.loaded;
    _page = page;
    onChanged(
      CursorPageView(
        items: _pages.isEmpty ? List<T>.empty() : _pages[page - 1],
        status: LoadStatus.loaded,
        page: page,
        totalPages: _knownPages,
        firstIndex: _pages
            .take(page - 1)
            .fold<int>(0, (total, rows) => total + rows.length),
      ),
    );
  }
}
