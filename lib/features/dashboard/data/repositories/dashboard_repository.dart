import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/data_revision.dart';
import 'package:zuno_admin_dashboard/core/data/user_account_totals.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/core/utils/number_formatter.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/models/recharge_transaction.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/repositories/recharge_repository.dart';

typedef DashboardRange = (DateTime?, DateTime?);

class DashboardRepository {
  DashboardRepository(
    this._recharges,
    this._users,
    this._revision, {
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  static const Duration maxAge = Duration(minutes: 5);
  static const int recentRechargeLimit = 5;

  final RechargeRepository _recharges;
  final UsersRemoteDataSource _users;
  final DataRevision _revision;
  final DateTime Function() _clock;

  final _RangeCache<UserAccountTotals> _accounts = _RangeCache();
  final _RangeCache<List<RechargeTransaction>> _recent = _RangeCache();
  final _RangeCache<RechargeRevenue> _revenue = _RangeCache();

  UserAccountTotals? cachedAccounts(DashboardRange range) =>
      _accounts.peek(range);

  List<RechargeTransaction>? cachedRecentRecharges(DashboardRange range) =>
      _recent.peek(range);

  RechargeRevenue? cachedRevenue(DashboardRange range) => _revenue.peek(range);

  Future<Either<Failure, UserAccountTotals>> fetchAccounts(
    DashboardRange range, {
    bool force = false,
  }) => _accounts.load(range, () => _loadAccounts(range), _context(force));

  Future<Either<Failure, List<RechargeTransaction>>> fetchRecentRecharges(
    DashboardRange range, {
    bool force = false,
  }) => _recent.load(
    range,
    () => _recharges.fetchLatestRecharges(
      recentRechargeLimit,
      from: range.$1,
      until: range.$2,
    ),
    _context(force),
  );

  Future<Either<Failure, RechargeRevenue>> fetchRevenue(
    DashboardRange range, {
    bool force = false,
  }) => _revenue.load(
    range,
    () => _recharges.fetchRevenue(from: range.$1, until: range.$2),
    _context(force),
  );

  Future<Either<Failure, UserAccountTotals>> _loadAccounts(
    DashboardRange range,
  ) async {
    final (from, until) = range;
    final totals = await _users.fetchAccountTotals(from: from, until: until);
    if (from == null || until == null) return totals;

    return totals.fold((failure) async => left(failure), (welcomeTotals) async {
      final offers = await _recharges.fetchAdminRechargeOffers(
        from: from,
        until: until,
      );
      return offers.fold((failure) async => left(failure), (offers) async {
        if (offers.isEmpty) return right(welcomeTotals);
        final recipients = {for (final offer in offers) offer.userId};
        final records = await _users.fetchByIds(recipients);
        return records.map((records) {
          final welcomedInRange = {
            for (final record in records)
              if (record.welcomeBonusClaimedAt case final claimedAt?
                  when !claimedAt.isBefore(from) && claimedAt.isBefore(until))
                record.id,
          };
          return welcomeTotals.withBonus(
            users:
                welcomeTotals.bonusUsers +
                recipients.difference(welcomedInRange).length,
            amount: NumberFormatter.roundAmount(
              welcomeTotals.bonusAmount +
                  offers.fold(0.0, (total, offer) => total + offer.amount),
            ),
          );
        });
      });
    });
  }

  _LoadContext _context(bool force) =>
      _LoadContext(now: _clock(), revision: _revision.value, force: force);
}

class _LoadContext {
  const _LoadContext({
    required this.now,
    required this.revision,
    required this.force,
  });

  final DateTime now;
  final int revision;
  final bool force;
}

class _RangeCache<T> {
  static const int _maxRanges = 8;

  final Map<DashboardRange, _CachedResult<T>> _entries = {};

  T? peek(DashboardRange range) => _entries[range]?.value;

  Future<Either<Failure, T>> load(
    DashboardRange range,
    Future<Either<Failure, T>> Function() fetch,
    _LoadContext context,
  ) {
    final entry = _entries.remove(range) ?? _CachedResult<T>();
    _entries[range] = entry;
    while (_entries.length > _maxRanges) {
      _entries.remove(_entries.keys.first);
    }
    return entry.load(fetch, context);
  }
}

class _CachedResult<T> {
  T? value;
  DateTime? _fetchedAt;
  int _revision = -1;
  Future<Either<Failure, T>>? _pending;

  bool _isFresh(_LoadContext context) {
    final fetchedAt = _fetchedAt;
    return value != null &&
        fetchedAt != null &&
        _revision == context.revision &&
        context.now.difference(fetchedAt) < DashboardRepository.maxAge;
  }

  Future<Either<Failure, T>> load(
    Future<Either<Failure, T>> Function() fetch,
    _LoadContext context,
  ) {
    final cached = value;
    if (!context.force && cached != null && _isFresh(context)) {
      return Future.value(right(cached));
    }
    return _pending ??= _run(fetch, context);
  }

  Future<Either<Failure, T>> _run(
    Future<Either<Failure, T>> Function() fetch,
    _LoadContext context,
  ) async {
    try {
      final result = await fetch();
      if (result case Right(value: final fetched)) {
        value = fetched;
        _fetchedAt = context.now;
        _revision = context.revision;
      }
      return result;
    } finally {
      _pending = null;
    }
  }
}
