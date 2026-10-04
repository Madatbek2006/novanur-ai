import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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
      // Browsers expose no file paths, so the web build uploads the bytes.
      'file': kIsWeb
          ? MultipartFile.fromBytes(
              await file.readAsBytes(),
              filename: file.name.isNotEmpty ? file.name : 'photo.jpg',
              contentType: DioMediaType.parse(file.mimeType ?? 'image/jpeg'),
            )
          : await MultipartFile.fromFile(
              file.path,
              filename: file.name, // чтобы сервер видел имя файла
            ),
    });

    return _dio.post(
      "api/create/chat",
      data: formData,
      options: Options(
        // Browsers refuse to override User-Agent.
        headers: kIsWeb
            ? null
            : {
                'User-Agent': 'insomnia/11.4.0', // если нужно
              },
      ),
    );
  }
  Future<Response> getProductData(String barcode) async {
    return _dio2.get("product/$barcode.json");
  }

}
