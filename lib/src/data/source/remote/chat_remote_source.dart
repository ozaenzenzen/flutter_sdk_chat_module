import 'dart:io';


import 'package:dio/dio.dart';
import 'package:konnek_native_core/inter_module.dart';
import 'package:konnek_native_core/src/data/models/request/send_chat_request_model.dart';
import 'package:konnek_native_core/src/env.dart';
import 'package:konnek_native_core/src/support/app_api_service.dart';
import 'package:konnek_native_core/src/support/app_logger.dart';
import 'package:konnek_native_core/src/support/app_socketio_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

abstract class ChatRemoteSource {
  Future<Response?> sendChat({
    required String clientId,
    required SendChatRequestModel request,
  });
  Future<Response?> getConversation({
    required int limit,
    required String roomId,
    required int currentPage,
    required String sesionId,
  });
  Future<Response?> getConfig({
    required String clientId,
  });
  Future<Response?> uploadMedia({
    required Map<String, dynamic> requestData,
  });
  io.Socket? startWebSocketIO();
}

class ChatRemoteSourceImpl extends ChatRemoteSource {
  static String baseUrl = EnvironmentConfig.baseUrl();
  static String baseUrlSocket = EnvironmentConfig.baseUrlSocket();
  static AppApiServiceCS apiService = InterModule.appApiService;

  @override
  io.Socket? startWebSocketIO() {
    try {
      if (InterModule.accessToken == "") {
        return null;
      } else {
        io.Socket socket = AppSocketioService.connect(
          url: baseUrlSocket,
          token: InterModule.accessToken,
        );
        return socket;
      }
    } catch (e) {
      AppLoggerCS.debugLog("[ChatRemoteSourceImpl][startWebSocketIO] error: $e");
      rethrow;
    }
  }

  @override
  Future<Response?> getConfig({required String clientId}) async {
    try {
      String url = "$baseUrl/channel/config/$clientId/${checkPlatform()}";
      // String url = "$baseUrl/channel/config/$clientId/web";
      Response? response = await apiService.call(
        url,
        method: MethodRequestCS.get,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response?> getConversation({
    required int limit,
    required String roomId,
    required int currentPage,
    required String sesionId,
  }) async {
    try {
      AppLoggerCS.debugLog("[remoteSource] currentPage: $currentPage");
      String url = "$baseUrl/room/conversation/$roomId?page=$currentPage&limit=20&session_id=$sesionId";
      Response? response = await apiService.call(
        url,
        method: MethodRequestCS.get,
        header: {
          'Authorization': InterModule.accessToken,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Response?> sendChat({
    required String clientId,
    required SendChatRequestModel request,
  }) async {
    try {
      String url = "$baseUrl/webhook/${checkPlatform()}/$clientId";
      // String url = "$baseUrl/webhook/widget/$clientId";
      Response? response = await apiService.call(
        url,
        request: request.toJson(),
        method: MethodRequestCS.post,
      );
      return response;
    } catch (e) {
      AppLoggerCS.debugLog("[ChatRemoteSourceImpl][sendChat] error: $e");
      rethrow;
    }
  }

  @override
  Future<Response?> uploadMedia({
    required Map<String, dynamic> requestData,
  }) async {
    try {
      String url = "$baseUrl/chat/media";
      Response? response = await apiService.call(
        url,
        header: {
          "Access-Control-Allow-Origin": "*",
          'Authorization': InterModule.accessToken,
          // 'Authorization': accessToken,
        },
        request: requestData,
        method: MethodRequestCS.post,
        useFormData: true,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  String checkPlatform() {
    String platform = "webhook";
    if (Platform.isAndroid) {
      platform = "android";
    } else if (Platform.isIOS) {
      platform = "ios";
    } else {
      platform = "web";
    }
    AppLoggerCS.debugLog("[checkPlatform]: $platform");
    return platform;
  }
}
