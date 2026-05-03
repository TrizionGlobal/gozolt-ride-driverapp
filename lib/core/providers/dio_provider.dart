import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../network/auth_interceptor.dart';
import 'storage_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final dio = createDio();

  dio.interceptors.add(AuthInterceptor(
    dio: dio,
    storage: storage,
  ));

  return dio;
});
