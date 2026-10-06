import 'package:nurnova_ai/core/stream/base_stream_controller.dart';
import 'package:nurnova_ai/domain/models/identity/identity.dart';

class GroupChangedStreamController extends BaseStreamController<Identity> {
  GroupChangedStreamController({super.isBroadcast = true});
}
