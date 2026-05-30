import 'package:dio/dio.dart';

class ApiService {
  late final Dio dio;

  ApiService() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://reqres.in/api',

        headers: {'x-api-key': 'reqres-free-v1'},

        connectTimeout: const Duration(seconds: 10),

        receiveTimeout: const Duration(seconds: 10),
      ),
    );
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await dio.post(
      '/login',

      data: {'email': email, 'password': password},
    );
  }
}
