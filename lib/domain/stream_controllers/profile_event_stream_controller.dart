import 'package:baiqavisit/core/stream/base_stream_controller.dart';
import 'package:baiqavisit/domain/models/profile/profile_event.dart';

class ProfileEventStreamController extends BaseStreamController<ProfileEvent> {
  ProfileEventStreamController({super.isBroadcast = true});
}
