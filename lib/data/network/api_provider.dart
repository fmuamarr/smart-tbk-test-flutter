import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

enum MethodRequest { post, get, put, delete }

class ApiProvider {
  final Dio dio;

  ApiProvider({required String baseUrl, int duration = 30})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: Duration(seconds: duration),
          receiveTimeout: Duration(seconds: duration),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        compact: true,
        maxWidth: 150,
      ),
    );
  }

  Future<dynamic> call(
    String url, {
    MethodRequest method = MethodRequest.post,
    dynamic request,
    Map<String, String>? headers,
    String? token,
  }) async {
    headers ??= {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (kDebugMode) {
      debugPrint('Request [$method]: $url');
      if (request != null) {
        debugPrint('Body: $request');
      }
    }

    Response response;

    switch (method) {
      case MethodRequest.get:
        response = await dio.get(url, options: Options(headers: headers));
        break;
      case MethodRequest.put:
        response = await dio.put(
          url,
          data: request,
          options: Options(headers: headers),
        );
        break;
      case MethodRequest.delete:
        response = await dio.delete(
          url,
          queryParameters: request,
          options: Options(headers: headers),
        );
        break;
      case MethodRequest.post:
        response = await dio.post(
          url,
          data: request,
          options: Options(headers: headers),
        );
        break;
    }

    return response.data;
  }

  void updateBaseUrl(String baseUrl) {
    dio.options.baseUrl = baseUrl;
  }

  String get currentBaseUrl => dio.options.baseUrl;

  Future<void> downloadFile(
    String url,
    String savePath,
    Function(int received, int total) onProgress,
  ) async {
    await Dio().download(
      url,
      savePath,
      onReceiveProgress: (received, total) {
        onProgress(received, total);
      },
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
