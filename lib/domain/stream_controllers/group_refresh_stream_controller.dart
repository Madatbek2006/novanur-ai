import 'package:baiqavisit/core/stream/base_stream_controller.dart';
import 'package:baiqavisit/domain/models/identity/identity.dart';

class GroupChangedStreamController extends BaseStreamController<Identity> {
  GroupChangedStreamController({super.isBroadcast = true});
}
