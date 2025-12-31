import 'package:baiqavisit/core/stream/base_stream_controller.dart';
import 'package:baiqavisit/domain/models/takephoto/taken_photo.dart';

class TakePhotoResultStreamController extends BaseStreamController<TakenPhoto> {
  TakePhotoResultStreamController({super.isBroadcast = true});
}
