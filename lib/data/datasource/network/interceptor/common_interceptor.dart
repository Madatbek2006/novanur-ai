import 'package:baiqavisit/data/datasource/device/device_info_holder.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class CommonInterceptor extends QueuedInterceptor {
  CommonInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (kIsWeb) {
      // Custom headers turn every browser request into a CORS preflight that
      // the API would have to allow explicitly.
      handler.next(options);
      return;
    }

    final headers = <String, String>{};

    headers['App-Version-Name'] = DeviceInfoHolder.appVersionName;
    headers['App-Version-Code'] = DeviceInfoHolder.appVersionCode;

    headers['Device-Id'] = DeviceInfoHolder.deviceId;
    headers['Device-Name'] = DeviceInfoHolder.deviceName;

    headers['Mobile-OS'] = DeviceInfoHolder.mobileOs;

    headers['App-Source'] = DeviceInfoHolder.appSource;

    options.headers.addAll(headers);
    handler.next(options);
  }
}
