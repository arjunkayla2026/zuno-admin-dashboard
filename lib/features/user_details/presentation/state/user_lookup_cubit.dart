import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zuno_admin_dashboard/core/enums/load_status.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_lookup_state.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/repositories/user_management_repository.dart';

class UserLookupCubit extends Cubit<UserLookupState> {
  UserLookupCubit(this._repository, {required this.userId})
    : super(const UserLookupState());

  final UserManagementRepository _repository;
  final String userId;

  Future<void> load() async {
    emit(const UserLookupState());
    final result = await _repository.findUser(userId);
    if (isClosed) return;
    emit(
      result.match(
        (failure) => UserLookupState(
          status: LoadStatus.failure,
          errorMessage: failure.message,
        ),
        (user) => UserLookupState(status: LoadStatus.loaded, user: user),
      ),
    );
  }
}
