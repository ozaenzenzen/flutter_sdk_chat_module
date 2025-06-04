import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:konnek_native_core/src/support/app_connectivity_service.dart';
import 'package:konnek_native_core/src/support/app_logger.dart';

enum MethodRequestCS { post, get, put, delete }

class AppApiServiceCS {
  Dio dio = Dio();

  AppApiServiceCS(String baseUrl) {
    dio.options.baseUrl = baseUrl;
    // dio.options.connectTimeout = const Duration(milliseconds: 90000); //90s
    // dio.options.receiveTimeout = const Duration(milliseconds: 50000); //50s
    dio.options.connectTimeout = 90000; //90s
    dio.options.receiveTimeout = 50000; //50s
    dio.options.headers = {'Accept': 'application/json'};
    dio.options.receiveDataWhenStatusError = true;
  }

  
  /// WARNING!!! THIS SHOULD BE FALSE ON PRODUCTION
  bool useFoundation = false;

  /// WARNING!!! THIS SHOULD BE FALSE ON PRODUCTION
  bool useLogger = false;

  _localDebugPrint(String value, {bool isActive = true}) {
    if (useLogger) {
      if (isActive) {
        if (useFoundation) {
          debugPrint(value);
        } else {
          log(value);
        }
      }
    }
  }

  Future<Response> call(
    String url, {
    MethodRequestCS method = MethodRequestCS.post,
    Map<String, dynamic>? request,
    Map<String, String>? header,
    String? token,
    bool useFormData = false,
  }) async {
    AppLoggerCS.debugLog("current connectivity status :${AppConnectivityServiceCS().connectionStatus}");
    if (AppConnectivityServiceCS().connectionStatus == AppConnectivityStatus.offline) {
      Response response = Response(
        data: {
          "message": "You are offline",
          // "status": "error",
          "status": 0,
        },
        statusCode: 00,
        requestOptions: RequestOptions(path: ''),
      );
      return response;
    }
    if (header != null) {
      dio.options.headers = header;
    }
    if (token != null) {
      if (header != null) {
        header.addAll({
          'Authorization': 'Bearer $token',
        });
        dio.options.headers = header;
      } else {
        dio.options.headers = {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        };
      }
      if (method == MethodRequestCS.put) {
        dio.options.headers = {
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $token',
        };
      }
    }

    _localDebugPrint('\n');
    _localDebugPrint('======================================================================');
    _localDebugPrint('URL : $url');
    _localDebugPrint('BaseURL : ${dio.options.baseUrl}');
    _localDebugPrint('Method : $method');
    _localDebugPrint("Header : ${dio.options.headers}");
    _localDebugPrint("Request : $request");
    _localDebugPrint('======================================================================');
    _localDebugPrint('\n');

    // ignore: unused_local_variable
    MethodRequestCS selectedMethod;
    try {
      Response response;
      switch (method) {
        case MethodRequestCS.get:
          selectedMethod = method;
          response = await dio.get(url, queryParameters: request);
          break;
        case MethodRequestCS.put:
          selectedMethod = method;
          response = await dio.put(
            url,
            data: useFormData ? FormData.fromMap(request!) : request,
          );
          break;
        case MethodRequestCS.delete:
          selectedMethod = method;
          response = await dio.delete(
            url,
            data: useFormData ? FormData.fromMap(request!) : request,
          );
          break;
        default:
          selectedMethod = MethodRequestCS.post;
          response = await dio.post(
            url,
            data: useFormData ? FormData.fromMap(request!) : request,
          );
      }
      // debugPrint('Success $selectedMethod $url: \nResponse : ${url.contains("rss") ? "rss feed response to long" : response.data}');
      return response;
    } on DioError catch (e) {
      // debugPrint('Error $selectedMethod $url: $e\nData: ${(e.response?.data ?? "empty")}');
      if (e.response?.data is Map) {
        if ((e.response?.data as Map)['status'] == null) {
          (e.response?.data as Map).addAll(<String, dynamic>{
            "status": "error",
          });
        }
        // qoin.QoinSdk.defaultErrorHandler(e.response!);
        return e.response!;
      } else {
        Response response = Response(
          data: {
            "message": "Terjadi kesalahan, coba lagi beberapa saat",
            "status": e.response?.statusCode,
          },
          requestOptions: e.requestOptions,
          statusCode: e.response?.statusCode,
        );
        // qoin.QoinSdk.defaultErrorHandler(response);
        return response;
      }
    }
  }
}
