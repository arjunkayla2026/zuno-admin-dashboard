import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:zuno_admin_dashboard/core/data/admins_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/approval/data/repositories/approval_repository.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_cubit.dart';
import 'package:zuno_admin_dashboard/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/auth/data/repositories/auth_repository.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/admin_session_cubit.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/auth_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/repositories/host_management_repository.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_actions_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/packages/data/datasources/packages_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/packages/data/repositories/packages_repository.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/state/packages_cubit.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/datasources/recharge_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/repositories/recharge_repository.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/data/repositories/settings_repository.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/repositories/user_management_repository.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_actions_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_cubit.dart';

final GetIt getIt = GetIt.instance;

void configureDependencies() {
  getIt
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(FirebaseAuth.instance),
    )
    ..registerLazySingleton<AdminsRemoteDataSource>(
      () => AdminsRemoteDataSource(FirebaseFirestore.instance),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepository(
        getIt<AuthRemoteDataSource>(),
        getIt<AdminsRemoteDataSource>(),
      ),
    )
    ..registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>()))
    ..registerFactory<AdminSessionCubit>(
      () => AdminSessionCubit(getIt<AuthRepository>()),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepository(getIt<AdminsRemoteDataSource>()),
    )
    ..registerFactory<SettingsCubit>(
      () => SettingsCubit(getIt<SettingsRepository>()),
    )
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
    ..registerLazySingleton<PackagesRemoteDataSource>(
      () => PackagesRemoteDataSource(FirebaseFirestore.instance),
    )
    ..registerLazySingleton<PackagesRepository>(
      () => PackagesRepository(getIt<PackagesRemoteDataSource>()),
    )
    ..registerFactory<PackagesCubit>(
      () => PackagesCubit(getIt<PackagesRepository>()),
    )
    ..registerLazySingleton<RechargeRemoteDataSource>(
      () => RechargeRemoteDataSource(FirebaseFirestore.instance),
    )
    ..registerLazySingleton<RechargeRepository>(
      () => RechargeRepository(
        getIt<RechargeRemoteDataSource>(),
        getIt<UsersRemoteDataSource>(),
      ),
    )
    ..registerFactory<RechargeCubit>(
      () => RechargeCubit(getIt<RechargeRepository>()),
    )
    ..registerFactory<UserActionsCubit>(
      () => UserActionsCubit(getIt<UserManagementRepository>()),
    )
    ..registerFactory<HostActionsCubit>(
      () => HostActionsCubit(getIt<HostManagementRepository>()),
    );
}
