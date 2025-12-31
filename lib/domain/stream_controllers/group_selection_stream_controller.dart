import 'package:baiqavisit/core/stream/base_stream_controller.dart';
import 'package:baiqavisit/domain/models/group/group.dart';

class GroupSelectionStreamController extends BaseStreamController<Group> {
  GroupSelectionStreamController({super.isBroadcast = true});
}
