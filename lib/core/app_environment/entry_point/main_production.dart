import 'package:zuno_admin_dashboard/core/enums/app_environment.dart';
import 'package:zuno_admin_dashboard/main.dart';

Future<void> main() async {
  await flavorMain(Environment.production);
}
