import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/data/admin_account.dart';
import 'package:zuno_admin_dashboard/features/auth/data/repositories/auth_repository.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/admin_session_state.dart';

class AdminSessionCubit extends Cubit<AdminSessionState> {
  AdminSessionCubit(this._repository) : super(const AdminSessionState());

  final AuthRepository _repository;

  Future<void> restore() async {
    emit(const AdminSessionState());
    final result = await _repository.restoreSession();
    if (isClosed) return;

    result.match(
      (failure) => emit(
        AdminSessionState(
          status: AdminSessionStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (account) => emit(
        account == null
            ? const AdminSessionState(status: AdminSessionStatus.signedOut)
            : AdminSessionState(
                status: AdminSessionStatus.signedIn,
                account: account,
              ),
      ),
    );
  }

  void signedIn(AdminAccount account) => emit(
    AdminSessionState(status: AdminSessionStatus.signedIn, account: account),
  );

  void signedOut() =>
      emit(const AdminSessionState(status: AdminSessionStatus.signedOut));

  void refreshIfCurrent(AdminAccount account) {
    if (state.account?.email == account.email) signedIn(account);
  }
}
