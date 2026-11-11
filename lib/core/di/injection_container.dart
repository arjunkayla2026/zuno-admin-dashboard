import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zuno_admin_dashboard/core/data/admins_remote_data_source.dart';
import 'package:zuno_admin_dashboard/core/data/data_revision.dart';
import 'package:zuno_admin_dashboard/core/data/users_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/approval/data/datasources/payout_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/approval/data/repositories/approval_repository.dart';
import 'package:zuno_admin_dashboard/features/approval/data/repositories/payout_repository.dart';
import 'package:zuno_admin_dashboard/features/approval/presentation/state/approval_cubit.dart';
import 'package:zuno_admin_dashboard/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/auth/data/repositories/auth_repository.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/admin_session_cubit.dart';
import 'package:zuno_admin_dashboard/features/auth/presentation/state/auth_cubit.dart';
import 'package:zuno_admin_dashboard/features/dashboard/data/repositories/dashboard_repository.dart';
import 'package:zuno_admin_dashboard/features/dashboard/presentation/state/dashboard_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/data/repositories/host_management_repository.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_actions_cubit.dart';
import 'package:zuno_admin_dashboard/features/host_management/presentation/state/host_management_cubit.dart';
import 'package:zuno_admin_dashboard/features/packages/data/datasources/packages_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/packages/data/repositories/packages_repository.dart';
import 'package:zuno_admin_dashboard/features/packages/presentation/state/packages_cubit.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/datasources/recharge_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/recharge/data/repositories/recharge_repository.dart';
import 'package:zuno_admin_dashboard/features/recharge/presentation/state/recharge_cubit.dart';
import 'package:zuno_admin_dashboard/features/settings/data/datasources/banner_images_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/settings/data/datasources/notifications_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/settings/data/datasources/settings_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/settings/data/repositories/settings_repository.dart';
import 'package:zuno_admin_dashboard/features/settings/presentation/state/settings_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/add_recharge_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_details_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_details/presentation/state/user_recharge_history_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/data/repositories/user_management_repository.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_actions_cubit.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_details_arguments.dart';
import 'package:zuno_admin_dashboard/features/user_management/presentation/state/user_management_cubit.dart';

final GetIt getIt = GetIt.instance;
const String _functionsRegion = 'asia-south1';

void configureDependencies() {
  getIt
    ..registerLazySingleton<DataRevision>(DataRevision.new)
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
    ..registerLazySingleton<SettingsRemoteDataSource>(
      () => SettingsRemoteDataSource(FirebaseFirestore.instance),
    )
    ..registerLazySingleton<BannerImagesRemoteDataSource>(
      () => BannerImagesRemoteDataSource(
        FirebaseFirestore.instance,
        FirebaseStorage.instance,
      ),
    )
    ..registerLazySingleton<NotificationsRemoteDataSource>(
      () => NotificationsRemoteDataSource(
        FirebaseFunctions.instanceFor(region: 'asia-south1'),
      ),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepository(
        getIt<AdminsRemoteDataSource>(),
        getIt<SettingsRemoteDataSource>(),
        getIt<BannerImagesRemoteDataSource>(),
        getIt<UsersRemoteDataSource>(),
        getIt<NotificationsRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton<ImagePicker>(ImagePicker.new)
    ..registerFactory<SettingsCubit>(
      () => SettingsCubit(getIt<SettingsRepository>()),
    )
    ..registerLazySingleton<UsersRemoteDataSource>(
      () => UsersRemoteDataSource(
        FirebaseFirestore.instance,
        FirebaseAuth.instance,
        revision: getIt<DataRevision>(),
      ),
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
    ..registerLazySingleton<PayoutRemoteDataSource>(
      () => PayoutRemoteDataSource(
        FirebaseFirestore.instance,
        FirebaseAuth.instance,
      ),
    )
    ..registerLazySingleton<PayoutRepository>(
      () => PayoutRepository(
        getIt<PayoutRemoteDataSource>(),
        getIt<UsersRemoteDataSource>(),
        getIt<AuthRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton<ApprovalRepository>(
      () => ApprovalRepository(getIt<UsersRemoteDataSource>()),
    )
    ..registerFactory<ApprovalCubit>(
      () =>
          ApprovalCubit(getIt<ApprovalRepository>(), getIt<PayoutRepository>()),
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
      () => RechargeRemoteDataSource(
        FirebaseFirestore.instance,
        FirebaseFunctions.instanceFor(region: _functionsRegion),
        revision: getIt<DataRevision>(),
      ),
    )
    ..registerLazySingleton<RechargeRepository>(
      () => RechargeRepository(
        getIt<RechargeRemoteDataSource>(),
        getIt<UsersRemoteDataSource>(),
      ),
    )
    ..registerLazySingleton<DashboardRepository>(
      () => DashboardRepository(
        getIt<RechargeRepository>(),
        getIt<UsersRemoteDataSource>(),
        getIt<DataRevision>(),
      ),
    )
    ..registerFactory<DashboardCubit>(
      () => DashboardCubit(getIt<DashboardRepository>()),
    )
    ..registerFactory<RechargeCubit>(
      () => RechargeCubit(getIt<RechargeRepository>()),
    )
    ..registerFactory<AddRechargeCubit>(
      () => AddRechargeCubit(
        getIt<PackagesRepository>(),
        getIt<RechargeRepository>(),
      ),
    )
    ..registerFactoryParam<UserDetailsCubit, UserDetailsArguments, void>(
      (arguments, _) => UserDetailsCubit(
        getIt<RechargeRepository>(),
        user: arguments.user,
        onUserChanged: arguments.onUserChanged,
      ),
    )
    ..registerFactoryParam<UserRechargeHistoryCubit, String, void>(
      (userId, _) =>
          UserRechargeHistoryCubit(getIt<RechargeRepository>(), userId),
    )
    ..registerFactory<UserActionsCubit>(
      () => UserActionsCubit(getIt<UserManagementRepository>()),
    )
    ..registerFactory<HostActionsCubit>(
      () => HostActionsCubit(getIt<HostManagementRepository>()),
    );
}
