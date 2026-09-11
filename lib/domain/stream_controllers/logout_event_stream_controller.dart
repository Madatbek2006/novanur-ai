import 'package:nurnova_ai/core/stream/base_stream_controller.dart';
import 'package:nurnova_ai/domain/models/logout/logout_event.dart';

class LogoutEventStreamController extends BaseStreamController<LogoutEvent> {
  LogoutEventStreamController({super.isBroadcast = true});
}
