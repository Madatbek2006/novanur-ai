import 'dart:io';

import 'package:nurnova_ai/domain/models/group/group_att_stats.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:logger/logger.dart';

class PhotoAnalysisService {
  final Dio _dio;
  final Dio _dio2 = Dio(
    BaseOptions(
      baseUrl: "https://world.openfoodfacts.org/api/v0/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  PhotoAnalysisService(this._dio);



  Future<Response> fetchPhotoAnalysis(XFile file) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.name, // чтобы сервер видел имя файла
      ),
    });

    return _dio.post(
      "api/create/chat",
      data: formData,
      options: Options(
        headers: {
          'User-Agent': 'insomnia/11.4.0', // если нужно
        },
      ),
    );
  }
  Future<Response> getProductData(String barcode) async {
    return _dio2.get("product/$barcode.json");
  }

}
