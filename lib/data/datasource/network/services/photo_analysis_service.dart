import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class PhotoAnalysisService {
  final Dio _dio;
  /// Open Food Facts. API v2 со списком полей отдаёт 0.5 КБ вместо 37 КБ
  /// полной карточки из v0 и отвечает вдвое быстрее — на мобильной сети это
  /// разница между «назвал сразу» и «назвал, когда уже отошёл от полки».
  final Dio _dio2 = Dio(
    BaseOptions(
      baseUrl: "https://world.openfoodfacts.org/api/v2/",
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      // На неизвестный код v2 отвечает 404 с обычным телом (status: 0).
      // Это «товара нет в базе», а не сбой связи.
      validateStatus: (status) =>
          status != null && (status < 400 || status == 404),
      // База просит представляться, иначе режет по лимитам. В браузере
      // User-Agent выставить нельзя — там он свой.
      headers: kIsWeb
          ? null
          : {'User-Agent': 'NurNovaAI/1.0 (https://nurnova-ai.nurnova.workers.dev)'},
    ),
  );

  /// Ровно то, что показывают и произносят приложение и сайт.
  static const _productFields = 'product_name,product_name_ru,product_name_uz,'
      'product_name_en,brands,quantity,ingredients_text,image_url';

  PhotoAnalysisService(this._dio);



  Future<Response> fetchPhotoAnalysis(XFile file) async {
    final formData = FormData.fromMap({
      // Browsers expose no file paths, and a picture opened in the desktop
      // dashboard lives only in memory too — those upload the bytes.
      'file': kIsWeb || file.path.isEmpty
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
        // Browsers refuse to override User-Agent; the ngrok bypass still
        // has to be repeated because Options replace the common headers.
        headers: kIsWeb
            ? {'ngrok-skip-browser-warning': 'true'}
            : {
                'User-Agent': 'insomnia/11.4.0', // если нужно
                // Options здесь перекрывает общие заголовки Dio, поэтому
                // обход заставки ngrok приходится повторить и тут.
                'ngrok-skip-browser-warning': 'true',
              },
      ),
    );
  }
  Future<Response> getProductData(String barcode) async {
    return _dio2.get(
      "product/$barcode",
      queryParameters: {'fields': _productFields},
    );
  }

}
