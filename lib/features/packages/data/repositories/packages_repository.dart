import 'package:fpdart/fpdart.dart';
import 'package:zuno_admin_dashboard/core/data/record_page.dart';
import 'package:zuno_admin_dashboard/core/errors/failure.dart';
import 'package:zuno_admin_dashboard/features/packages/data/datasources/packages_remote_data_source.dart';
import 'package:zuno_admin_dashboard/features/packages/data/models/package_plan.dart';

class PackagesRepository {
  const PackagesRepository(this._dataSource);

  static const int _pageSize = 10;

  final PackagesRemoteDataSource _dataSource;

  Future<Either<Failure, RecordPage<PackagePlan>>> fetchPackages({
    Object? cursor,
  }) => _dataSource.fetchPage(cursor, pageSize: _pageSize);

  Future<Either<Failure, ({int total, int active})>> fetchCounts() =>
      _dataSource.fetchCounts();

  Future<Either<Failure, PackagePlan>> savePackage(PackagePlan plan) async {
    final fields = plan.toFields();
    if (plan.isNew) {
      final result = await _dataSource.createPackage(fields);
      return result.map((id) => plan.copyWith(id: id));
    }
    final result = await _dataSource.updatePackage(plan.id, fields);
    return result.map((_) => plan);
  }
}
