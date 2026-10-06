import 'package:nurnova_ai/core/stream/base_stream_controller.dart';
import 'package:nurnova_ai/domain/models/takephoto/taken_photo.dart';

class TakePhotoResultStreamController extends BaseStreamController<TakenPhoto> {
  TakePhotoResultStreamController({super.isBroadcast = true});
}
