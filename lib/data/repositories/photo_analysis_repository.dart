import 'package:baiqavisit/data/datasource/network/dto/barcode/product_response.dart';
import 'package:baiqavisit/data/datasource/network/dto/photo_analise_response/photo_analise_response.dart';
import 'package:baiqavisit/data/datasource/network/services/photo_analysis_service.dart';
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
  Future<String> getProductData(String barcode) async {
    var response = await _photoAnalysis.getProductData(barcode);
    Logger().d("TTT=> ${response.data}");
    return ProductRootResponse.fromJson(response.data).product?.productName??"product not found";
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
