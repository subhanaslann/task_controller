import 'package:integration_test/integration_test_driver.dart';

/// TekTech Mini Task Tracker
/// Integration Test Driver
/// 
/// This driver is used to run integration tests.
/// 
/// To run integration tests:
/// ```
/// flutter drive \
///   --driver=integration_test/integration_test_driver.dart \
///   --target=integration_test/offline_sync_test.dart \
///   --profile
/// ```
Future<void> main() => integrationDriver();
