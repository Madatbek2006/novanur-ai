import 'package:nurnova_ai/core/stream/base_stream_controller.dart';
import 'package:nurnova_ai/domain/models/group/group.dart';

class GroupSelectionStreamController extends BaseStreamController<Group> {
  GroupSelectionStreamController({super.isBroadcast = true});
}
