import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/payment/data/repositories/mock_withdrawals_repository.dart';
import 'package:zuno_admin_dashboard/features/payment/presentation/state/mock_withdrawals_state.dart';

class MockWithdrawalsCubit extends Cubit<MockWithdrawalsState> {
  MockWithdrawalsCubit(this._repository) : super(const MockWithdrawalsState());

  final MockWithdrawalsRepository _repository;
  int _loadRequest = 0;

  bool get isAvailable => _repository.isAvailable;

  Future<void> load() async {
    final request = ++_loadRequest;
    emit(state.copyWith(status: LoadStatus.loading));
    final result = await _repository.fetchSummary();
    if (isClosed || request != _loadRequest) return;
    result.match(
      (failure) => emit(
        state.copyWith(
          status: LoadStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (summary) =>
          emit(state.copyWith(status: LoadStatus.loaded, summary: summary)),
    );
  }

  Future<Either<Failure, ({int hosts, int payouts})>?> generate() =>
      _run(MockWithdrawalsAction.generating, _repository.generate);

  Future<Either<Failure, int>?> clear() =>
      _run(MockWithdrawalsAction.clearing, _repository.clear);

  Future<Either<Failure, T>?> _run<T>(
    MockWithdrawalsAction action,
    Future<Either<Failure, T>> Function() send,
  ) async {
    if (state.isBusy) return null;
    emit(state.copyWith(action: action));
    final result = await send();
    if (isClosed) return result;
    emit(
      state.copyWith(
        action: MockWithdrawalsAction.none,
        revision: result.isRight() ? state.revision + 1 : null,
      ),
    );
    await load();
    return result;
  }
}
