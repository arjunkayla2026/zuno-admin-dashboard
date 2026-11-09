import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/approval/data/repositories/approval_repository.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_cubit.dart';
import 'package:zuno_admin_dashboard/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/auth/data/repositories/auth_repository.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/auth_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/repositories/host_management_repository.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_actions_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/repositories/user_management_repository.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_actions_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_cubit.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(FirebaseAuth.instance),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(getIt<AuthRemoteDataSource>()),
    )
    ..registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()))
    ..registerLazySingleton<UsersRemoteDataSource>(
      () => UsersRemoteDataSource(FirebaseFirestore.instance),
    )
    ..registerLazySingleton<UserManagementRepository>(
      () => UserManagementRepository(getIt<UsersRemoteDataSource>()),
    )
    ..registerLazySingleton<HostManagementRepository>(
      () => HostManagementRepository(getIt<UsersRemoteDataSource>()),
    )
    ..registerFactory<UserManagementCubit>(
      () => UserManagementCubit(getIt<UserManagementRepository>()),
    )
    ..registerFactory<HostManagementCubit>(
      () => HostManagementCubit(getIt<HostManagementRepository>()),
    )
    ..registerLazySingleton<ApprovalRepository>(
      () => ApprovalRepository(getIt<UsersRemoteDataSource>()),
    )
    ..registerFactory<ApprovalCubit>(
      () => ApprovalCubit(getIt<ApprovalRepository>()),
    )
    ..registerFactory<UserActionsCubit>(
      () => UserActionsCubit(getIt<UserManagementRepository>()),
    )
    ..registerFactory<HostActionsCubit>(
      () => HostActionsCubit(getIt<HostManagementRepository>()),
    );
}
