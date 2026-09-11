import 'package:nurnova_ai/core/stream/base_stream_controller.dart';
import 'package:nurnova_ai/domain/models/profile/profile_event.dart';

class ProfileEventStreamController extends BaseStreamController<ProfileEvent> {
  ProfileEventStreamController({super.isBroadcast = true});
}
