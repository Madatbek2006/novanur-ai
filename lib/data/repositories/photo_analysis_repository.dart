import 'package:nurnova_ai/core/gen/localization/strings.dart';
import 'package:nurnova_ai/data/datasource/network/dto/barcode/product_response.dart';
import 'package:nurnova_ai/data/datasource/network/dto/photo_analise_response/photo_analise_response.dart';
import 'package:nurnova_ai/data/datasource/network/services/photo_analysis_service.dart';
import 'package:camera/camera.dart';
import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PhotoAnalysisRepository {
  final PhotoAnalysisService _photoAnalysis;

  PhotoAnalysisRepository(
    this._photoAnalysis,
  );


  Future<String> fetchPhotoAnalysis(XFile file) async {
    var response = await _photoAnalysis.fetchPhotoAnalysis(file);
    Logger().d("TTT=> ${response.data}");
    final data = response.data; // это Map<String, dynamic>
    final captions = data['chat_id']; // List<dynamic>
    final captionString = captions.isNotEmpty ? captions as String : '';

    return captionString;
  }
  /// Название товара или «Товар не найден». Нужен старым экранам, которые
  /// умеют только произнести строку.
  Future<String> getProductData(String barcode, {String languageCode = 'en'}) async {
    final product = await getProduct(barcode);
    return product?.nameFor(languageCode) ?? Strings.commonProductNotFound;
  }

  /// Full product card, or null when Open Food Facts doesn't know the code.
  Future<ProductResponse?> getProduct(String barcode) async {
    var response = await _photoAnalysis.getProductData(barcode);
    final root = ProductRootResponse.fromJson(response.data);
    return root.status == 1 ? root.product : null;
  }






  // Future<List<VisitorAttendance>> fetchAttendedVisitors(DateTime date) async {
    // var response = await _photoAnalysis.fetchVisitorAttendances(date);
    // final List<dynamic> data = response.data;
    //
    // return data
    //     .map((json) => VisitorAttendanceResponse.fromJson(json).toModel())
    //     .toList();
  // }


}
