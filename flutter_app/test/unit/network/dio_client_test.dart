import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/core/storage/secure_storage.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DioClient Tests', () {
    late DioClient dioClient;
    late SecureStorage secureStorage;

    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
      secureStorage = SecureStorage();
      dioClient = DioClient(secureStorage);
    });

    test('should create dio instance with correct base URL', () {
      // Act
      final dio = dioClient.dio;

      // Assert
      expect(dio.options.baseUrl, ApiConstants.baseUrl);
    });

    test('should have correct default headers', () {
      // Act
      final dio = dioClient.dio;

      // Assert
      expect(dio.options.headers['Content-Type'], 'application/json');
      expect(dio.options.headers['Accept'], 'application/json');
    });

    test('should have correct timeout settings', () {
      // Act
      final dio = dioClient.dio;

      // Assert
      expect(dio.options.connectTimeout, const Duration(seconds: 30));
      expect(dio.options.receiveTimeout, const Duration(seconds: 30));
    });

    test('should have interceptors attached', () {
      // Act
      final dio = dioClient.dio;

      // Assert
      expect(dio.interceptors.length, greaterThan(0));
    });
  });
}
